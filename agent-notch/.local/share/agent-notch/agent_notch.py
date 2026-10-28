"""Agent notch: remaining Claude Code and Codex usage, pinned to the right
screen edge.

This file fetches the limits (see usage.py) in a background thread every 10
minutes and hands them to the window in Notch.qml. When a fetch starts failing
in a new way, it also sends one desktop notification; the card in the window
keeps showing the reason until a fetch succeeds again.

Started at login by the agent-notch systemd user service.
"""

import signal
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

from PySide6.QtCore import Property, QObject, QRect, QTimer, QUrl, Signal, Slot
from PySide6.QtGui import QGuiApplication, QRegion, QWindow
from PySide6.QtQml import QQmlApplicationEngine

import usage

REFRESH_SECONDS = 10 * 60
# wait after a 429 when the reply doesn't say how long
RATE_LIMIT_BACKOFF_SECONDS = 15 * 60

PROVIDERS = {
    "claude": ("Claude", usage.claude),
    "codex": ("Codex", usage.codex),
}


class Agents(QObject):
    """The usage state of every provider, as the list Notch.qml draws."""

    changed = Signal()
    # emitted from the worker threads; Qt delivers it on the main thread
    _fetched = Signal(str, object)

    def __init__(self):
        super().__init__()
        self._state = {
            key: {
                "id": key,
                "name": name,
                "windows": [],
                "asOf": 0,
                "error": "",
                "errorKind": "",
            }
            for key, (name, _) in PROVIDERS.items()
        }
        self._not_before = dict.fromkeys(PROVIDERS, 0.0)
        self._running = set()
        self._pool = ThreadPoolExecutor(max_workers=len(PROVIDERS))
        self._fetched.connect(self._on_fetched)

        self._timer = QTimer(self)
        self._timer.timeout.connect(self.refresh)
        self._timer.start(REFRESH_SECONDS * 1000)

    @Property("QVariantList", notify=changed)
    def agents(self):
        return list(self._state.values())

    @Slot()
    def refresh(self):
        """Fetch every provider that isn't already fetching or backing off after
        a 429."""
        now = time.time()
        for key, (_, provider) in PROVIDERS.items():
            if key in self._running or now < self._not_before[key]:
                continue
            self._running.add(key)
            self._pool.submit(
                lambda key=key, provider=provider: self._fetched.emit(
                    key, usage.fetch(provider)
                )
            )

    def _on_fetched(self, key, result):
        self._running.discard(key)
        state = self._state[key]

        if result.error_kind is None:
            state["windows"] = [
                {"name": w.name, "left": round(w.left), "resetsAt": w.resets_at or 0}
                for w in result.windows
            ]
            state["asOf"] = time.time()
            state["error"] = state["errorKind"] = ""
        else:
            # the last good numbers stay on screen, marked by their age
            if result.error_kind == "rate_limited":
                self._not_before[key] = time.time() + (
                    result.retry_after or RATE_LIMIT_BACKOFF_SECONDS
                )
            elif result.error_kind != state["errorKind"]:
                notify(f"{state['name']} usage", result.error)
            state["error"] = result.error
            state["errorKind"] = result.error_kind

        self.changed.emit()


class InputRegion(QObject):
    """Limits mouse input to the visible parts of the window; the rest lets
    clicks through to the windows below."""

    # the window keeps one size and changes its input region instead: resizing a
    # layer-shell window as it slides out shows one stretched frame of the old
    # size

    def __init__(self) -> None:
        super().__init__()
        self._window: QWindow | None = None
        self._rects: list = []

    @Slot("QVariantList")
    def set(self, rects):
        """Take `[[x, y, width, height], ...]` in window coordinates."""
        self._rects = rects
        self._apply()

    def attach(self, window):
        self._window = window
        self._apply()

    def _apply(self):
        if self._window is None:
            return
        region = QRegion()
        for x, y, w, h in self._rects:
            region = region.united(QRect(round(x), round(y), round(w), round(h)))
        self._window.setMask(region)


def notify(title, body):
    subprocess.Popen(
        ["notify-send", "--app-name=Agent notch", "--icon=dialog-warning", title, body]
    )


def main():
    # Qt's event loop keeps Python from handling Ctrl-C; end the process the
    # default way
    signal.signal(signal.SIGINT, signal.SIG_DFL)

    app = QGuiApplication(sys.argv)
    app.setApplicationName("agent-notch")

    agents = Agents()
    input_region = InputRegion()
    engine = QQmlApplicationEngine()
    engine.setInitialProperties({"agents": agents, "inputRegion": input_region})
    engine.load(QUrl.fromLocalFile(str(Path(__file__).with_name("Notch.qml"))))
    if not engine.rootObjects():
        sys.exit(1)
    input_region.attach(engine.rootObjects()[0])

    agents.refresh()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
