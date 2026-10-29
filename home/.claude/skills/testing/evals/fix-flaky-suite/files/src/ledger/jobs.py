"""Run a callable in a background thread."""

from __future__ import annotations

import threading
from collections.abc import Callable
from typing import Any


class Job:
    def __init__(self, work: Callable[[], Any]) -> None:
        self._work = work
        self._result: Any = None
        self._done = threading.Event()

    def start(self) -> None:
        threading.Thread(target=self._run, daemon=True).start()

    def _run(self) -> None:
        self._result = self._work()
        self._done.set()

    def wait(self, timeout: float) -> bool:
        """True when the job finished within `timeout` seconds."""
        return self._done.wait(timeout)

    def result(self) -> Any:
        return self._result
