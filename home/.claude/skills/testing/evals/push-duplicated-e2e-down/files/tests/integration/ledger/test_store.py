"""Store against a real SQLite file: the integration point is the database on disk."""

from decimal import Decimal
from pathlib import Path

from ledger.store import Store


def test_entries_come_back_in_insertion_order(tmp_path: Path) -> None:
    store = Store(tmp_path / "ledger.db")
    store.add("coffee", Decimal("1.50"))
    store.add("tea", Decimal("2.00"))

    entries = store.all()

    assert entries == [("coffee", Decimal("1.50")), ("tea", Decimal("2.00"))]


def test_the_sum_survives_reopening_the_file(tmp_path: Path) -> None:
    first = Store(tmp_path / "ledger.db")
    first.add("coffee", Decimal("1.50"))
    first.close()

    again = Store(tmp_path / "ledger.db")

    assert again.sum() == Decimal("1.50")
