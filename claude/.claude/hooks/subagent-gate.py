#!/usr/bin/env python3
"""Keeps a turn open while sub-agents it started are still running.

Wired to three events. SubagentStart and SubagentStop maintain the set of live
sub-agent ids for the session under /tmp/claude; Stop blocks the turn while
that set is non-empty, so the main agent cannot finish ahead of work it
delegated.

A sub-agent that dies without firing SubagentStop would strand its id and block
every later turn, so a Stop that blocks records the fact and the next Stop
clears the set and lets the turn end. The gate therefore delays a turn at most
once per stranded sub-agent.
"""

import fcntl
import json
import os
import re
import sys
import time

STATE_DIR = "/tmp/claude"
SAFE_ID_RE = re.compile(r"^[A-Za-z0-9._-]+$")


def update(path, mutate):
    """Apply mutate(state) to the stored state under an exclusive lock; returns its result."""
    os.makedirs(STATE_DIR, exist_ok=True)
    with open(path, "a+") as handle:
        fcntl.flock(handle, fcntl.LOCK_EX)
        handle.seek(0)
        raw = handle.read()
        try:
            state = json.loads(raw) if raw.strip() else {}
        except ValueError:
            state = {}
        state.setdefault("live", {})
        state.setdefault("blocked", False)
        result = mutate(state)
        handle.seek(0)
        handle.truncate()
        json.dump(state, handle)
        return result


def on_stop(state):
    """Return the outstanding ids to block on, or None to let the turn end."""
    live = sorted(state["live"])
    if not live:
        state["blocked"] = False
        return None
    if state["blocked"]:
        state["live"].clear()
        state["blocked"] = False
        return None
    state["blocked"] = True
    return live


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return
    session_id = payload.get("session_id") or ""
    if not SAFE_ID_RE.match(session_id):
        return
    path = os.path.join(STATE_DIR, "subagents-%s.json" % session_id)
    event = payload.get("hook_event_name")
    agent_id = payload.get("agent_id") or ""

    if event == "SubagentStart" and agent_id:
        update(path, lambda state: state["live"].update({agent_id: time.time()}))
    elif event == "SubagentStop" and agent_id:
        update(path, lambda state: state["live"].pop(agent_id, None))
    elif event == "Stop":
        outstanding = update(path, on_stop)
        if outstanding:
            print(json.dumps({
                "decision": "block",
                "reason": "%d sub-agent(s) still running (%s); wait for them and "
                          "report their results before ending the turn"
                          % (len(outstanding), ", ".join(outstanding)),
            }))


main()
