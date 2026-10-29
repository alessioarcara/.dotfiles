"""A ledger of prices in a SQLite file."""

from __future__ import annotations

import sqlite3
from decimal import Decimal
from pathlib import Path


class Store:
    def __init__(self, path: Path) -> None:
        self.connection = sqlite3.connect(path)
        self.connection.execute("CREATE TABLE IF NOT EXISTS entries (label TEXT, cents INTEGER)")

    def add(self, label: str, price: Decimal) -> None:
        self.connection.execute("INSERT INTO entries VALUES (?, ?)", (label, int(price * 100)))
        self.connection.commit()

    def all(self) -> list[tuple[str, Decimal]]:
        rows = self.connection.execute("SELECT label, cents FROM entries ORDER BY rowid").fetchall()
        return [(label, Decimal(cents) / 100) for label, cents in rows]

    def sum(self) -> Decimal:
        (cents,) = self.connection.execute("SELECT COALESCE(SUM(cents), 0) FROM entries").fetchone()
        return Decimal(cents) / 100

    def close(self) -> None:
        self.connection.close()
