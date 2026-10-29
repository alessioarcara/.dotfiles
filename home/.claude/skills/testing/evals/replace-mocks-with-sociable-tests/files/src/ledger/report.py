"""A text summary of a Store."""

from __future__ import annotations

from ledger.store import Store


class Report:
    def __init__(self, store: Store) -> None:
        self.store = store

    def summary(self) -> str:
        lines = [f"{label:<10} {price:>8}" for label, price in self.store.all()]
        lines.append(f"{'total':<10} {self.store.sum():>8}")
        return "\n".join(lines)
