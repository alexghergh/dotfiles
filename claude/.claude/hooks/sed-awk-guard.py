#!/usr/bin/env python3
"""PreToolUse guard for sed/awk/gawk invocations in Bash commands.

Reads the hook payload from stdin and inspects every simple command in
tool_input.command whose executable resolves to sed, awk, or gawk. An
invocation passes silently (exit 0, no output) only when it matches a
recognized inert shape; anything else emits a permissionDecision "ask" so the
user is prompted even when an allow rule like Bash(sed --sandbox:*) would
otherwise auto-approve it.

An invocation is inert when all of these hold:
  - every flag is in the read-only whitelist (no in-place edit, no gawk
    profile/dump output);
  - the --sandbox flag is present, so the script body executes no exec, read,
    or write and needs no inspection here: GNU sed rejects its e/r/w commands
    at parse time, and GNU gawk fatally aborts on system(), redirection, and
    getline when they are reached;
  - the command has no output/input redirection;
  - no token carries a shell expansion outside single quotes ($var, $(...), or
    backticks, including inside double quotes), which the guard cannot evaluate
    and which could expand into a dangerous flag or path at runtime.

The lexer dequotes tokens, so a spliced command name still resolves to its
real executable. --help/--version, when parsed as a genuine option, make
sed/awk print and exit without touching files.

Claude-only by design: Codex auto-approves commands through its own read-only
sandbox rather than per-command allow rules, so it needs no equivalent guard.
"""

import json
import re
import sys

WORD_RE = re.compile(r"\b(sed|awk|gawk)\b")

# process wrappers the permission matcher strips before rule matching; a
# wrapped `timeout 5 sed --sandbox ...` still hits the allow rule, so the
# guard must see through the same set
WRAPPERS = {"timeout", "time", "nice", "nohup", "stdbuf", "env", "command", "xargs"}

# cluster: short flags without a value, combinable (e.g. -nEz); arg: short
# flags that consume a value (attached or next token); long maps option name
# to whether it consumes a separate value token
SED_CLUSTER = set("nErszu")
SED_ARG = set("efl")
SED_LONG = {
    "--sandbox": False, "--posix": False, "--quiet": False, "--silent": False,
    "--regexp-extended": False, "--separate": False, "--null-data": False,
    "--unbuffered": False, "--debug": False, "--help": False,
    "--version": False, "--expression": True, "--file": True,
    "--line-length": True,
}

AWK_CLUSTER = set("bnMOrS")
AWK_ARG = set("Fvfe")
AWK_LONG = {
    "--sandbox": False, "--csv": False, "--posix": False,
    "--traditional": False, "--lint": False, "--characters-as-bytes": False,
    "--non-decimal-data": False, "--bignum": False, "--optimize": False,
    "--re-interval": False, "--help": False, "--version": False,
    "--field-separator": True, "--assign": True, "--file": True,
    "--source": True,
}

_ASSIGN_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*=")
_WRAPPER_ARG_RE = re.compile(r"^[0-9]+[smhd]?$")

# a sed script that is one line address (a line number or $) or range plus the
# p command; provably read-only (prints, never exec/read/write) regardless of
# --sandbox, so it can auto-approve without it
_PRINT_RE = re.compile(r"^(\d+|\$)(,(\d+|\$))?p$")

# shell operators, longest match first; redirects mark the command, separators
# end it
_OPS = [
    "&>>", "<<<", ">>", "<<", "&>", ">&", "<&", ">|",
    "||", "&&", "|&", ";", "|", "&", "<", ">", "(", ")",
]
_REDIRECTS = {"&>>", "<<<", ">>", "<<", "&>", ">&", "<&", ">|", "<", ">"}


def lex(cmd):
    """Split cmd into simple commands, tracking quoting.

    Returns a list of {"words": [(text, has_expansion), ...], "redirect": bool}.
    has_expansion is True when the token carried a $ or backtick outside single
    quotes (double-quoted expansions included). Raises ValueError on an
    unbalanced quote.
    """
    cmds, words = [], []
    redirect = False
    buf, buf_exp, started = [], False, False

    def end_word():
        nonlocal buf, buf_exp, started
        if started:
            words.append(("".join(buf), buf_exp))
            buf, buf_exp, started = [], False, False

    def end_cmd():
        nonlocal words, redirect
        end_word()
        if words or redirect:
            cmds.append({"words": words, "redirect": redirect})
        words, redirect = [], False

    i, n = 0, len(cmd)
    while i < n:
        ch = cmd[i]
        if ch == "'":
            j = cmd.index("'", i + 1)  # ValueError if unbalanced
            buf.append(cmd[i + 1:j])
            started = True
            i = j + 1
        elif ch == '"':
            j = i + 1
            while j < n and cmd[j] != '"':
                if cmd[j] == "\\" and j + 1 < n:
                    if cmd[j + 1] != "\n":  # backslash-newline: line continuation
                        buf.append(cmd[j + 1])
                    j += 2
                    continue
                if cmd[j] in "$`":
                    buf_exp = True
                buf.append(cmd[j])
                j += 1
            if j >= n:
                raise ValueError("unbalanced double quote")
            started = True
            i = j + 1
        elif ch == "\\":
            if i + 1 < n and cmd[i + 1] == "\n":
                # backslash-newline is line continuation; the shell removes it
                i += 2
            elif i + 1 < n:
                buf.append(cmd[i + 1])
                started = True
                i += 2
            else:
                i += 1
        elif ch in "$`":
            buf_exp = True
            buf.append(ch)
            started = True
            i += 1
        elif ch == "\n":
            end_cmd()
            i += 1
        elif ch.isspace():
            end_word()
            i += 1
        elif ch in ";|&<>()":
            end_word()
            op = next((c for c in _OPS if cmd.startswith(c, i)), ch)
            if op in _REDIRECTS:
                redirect = True
            else:
                end_cmd()
            i += len(op)
        else:
            buf.append(ch)
            started = True
            i += 1
    end_cmd()
    return cmds


def resolve_base(words):
    """Index and basename of the executable after env-assignment and wrapper prefixes."""
    idx = 0
    while idx < len(words):
        text = words[idx][0]
        if _ASSIGN_RE.match(text):
            idx += 1
            continue
        if text.rsplit("/", 1)[-1] in WRAPPERS:
            idx += 1
            while idx < len(words):
                t2 = words[idx][0]
                if t2.startswith("-") or _WRAPPER_ARG_RE.match(t2) or _ASSIGN_RE.match(t2):
                    idx += 1
                    continue
                break
            continue
        break
    if idx >= len(words):
        return idx, ""
    return idx, words[idx][0].rsplit("/", 1)[-1]


def check_flags(base, args):
    """Return (ask-reason or None, saw_sandbox, saw_helpver) for the argument list.

    saw_helpver is True only when --help/--version appears as a genuine parsed
    option: before any -- end-of-options marker and not consumed as the value of
    an arg-taking flag. In either of those positions the token is a filename or
    a script fragment, not an exit-early option, and must not waive later checks.
    """
    cluster, argflags, longs = (
        (SED_CLUSTER, SED_ARG, SED_LONG) if base == "sed"
        else (AWK_CLUSTER, AWK_ARG, AWK_LONG)
    )
    saw_sandbox = False
    saw_helpver = False
    j = 0
    seen_ddash = False
    while j < len(args):
        tok = args[j]
        if seen_ddash or not tok.startswith("-") or tok == "-":
            j += 1
            continue
        if tok == "--":
            seen_ddash = True
            j += 1
            continue
        if tok.startswith("--"):
            name = tok.split("=", 1)[0]
            if name == "--sandbox":
                saw_sandbox = True
            if name in ("--help", "--version"):
                saw_helpver = True
            if name not in longs:
                return f"{base}: flag {name} is not in the read-only whitelist", saw_sandbox, saw_helpver
            if longs[name] and "=" not in tok:
                j += 1
        else:
            body = tok[1:]
            for k, ch in enumerate(body):
                if ch in cluster:
                    continue
                if ch in argflags:
                    if k == len(body) - 1:
                        j += 1
                    break
                return f"{base}: flag -{ch} is not in the read-only whitelist", saw_sandbox, saw_helpver
        j += 1
    return None, saw_sandbox, saw_helpver


def pure_print(cmd):
    """True when cmd is a sed line-print (`-n '<addr>p'`) with no external script.

    The read-only whitelist plus a positional script matching _PRINT_RE make the
    invocation provably print-only, so it is safe without --sandbox. External
    scripts (-e/-f/--expression/--file/--source) and any arg-taking flag are
    rejected: the script must be the first positional so it can be inspected here.
    """
    if cmd["redirect"] or any(exp for _, exp in cmd["words"]):
        return False
    idx, base = resolve_base(cmd["words"])
    if base != "sed":
        return False
    suppress = False
    positionals = []
    seen_ddash = False
    for tok in (t for t, _ in cmd["words"][idx + 1:]):
        if seen_ddash or not tok.startswith("-") or tok == "-":
            positionals.append(tok)
        elif tok == "--":
            seen_ddash = True
        elif tok.startswith("--"):
            name = tok.split("=", 1)[0]
            if name in ("--quiet", "--silent"):
                suppress = True
            elif name in ("--expression", "--file", "--source", "--line-length"):
                return False
            elif name not in SED_LONG:
                return False
        else:
            for ch in tok[1:]:
                if ch == "n":
                    suppress = True
                elif ch in SED_ARG:
                    return False
                elif ch not in SED_CLUSTER:
                    return False
    return suppress and bool(positionals) and bool(_PRINT_RE.match(positionals[0]))


def check_command(cmd):
    """Return an ask-reason for a sed/awk command outside the inert shape, else None."""
    words = cmd["words"]
    if not words:
        return None
    if not any(t.rsplit("/", 1)[-1] in ("sed", "awk", "gawk") for t, _ in words):
        return None

    any_exp = any(exp for _, exp in words)
    idx, base = resolve_base(words)

    if base not in ("sed", "awk", "gawk"):
        # references sed/awk but the executable did not resolve cleanly (e.g. an
        # expansion sits in a prefix position); ask if anything unresolved or a
        # redirect is present
        if any_exp or cmd["redirect"]:
            return "sed/awk invocation could not be resolved to a read-only form"
        return None

    if cmd["redirect"]:
        return f"{base}: redirection is not allowed in an auto-approved sed/awk command"
    if any_exp:
        return f"{base}: unresolved variable or command substitution is not allowed in an auto-approved sed/awk command"

    args = [t for t, _ in words[idx + 1:]]
    reason, saw_sandbox, saw_helpver = check_flags(base, args)
    if reason:
        return reason
    if saw_helpver:
        return None
    if not saw_sandbox and not pure_print(cmd):
        return f"{base}: an auto-approved sed/awk command must pass --sandbox"
    return None


def emit(decision, reason):
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": decision,
            "permissionDecisionReason": reason,
        }
    }))


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return
    if payload.get("tool_name") != "Bash":
        return
    cmd = (payload.get("tool_input") or {}).get("command") or ""

    # lex unconditionally so a spliced name (s''ed) is dequoted before the
    # sed/awk check; the raw-string prefilter only gates the parse-failure path
    try:
        commands = lex(cmd)
    except ValueError:
        if not WORD_RE.search(cmd):
            return
        reason = "command mentions sed/awk but could not be parsed"
        commands = None

    if commands is not None:
        reason = None
        for command in commands:
            reason = check_command(command)
            if reason:
                break

    if reason:
        emit("ask", reason)
        return

    # a standalone sed line-print has no allow rule to approve it (only
    # --sandbox forms do), so grant it here; gated to a single simple command so
    # the decision can never cover a hidden compound segment
    if (commands is not None and len(commands) == 1 and pure_print(commands[0])
            and "--sandbox" not in [t for t, _ in commands[0]["words"]]):
        emit("allow", "sed line-print is read-only")


main()
