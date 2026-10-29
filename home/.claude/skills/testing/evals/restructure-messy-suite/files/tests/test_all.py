import random
import subprocess
import sys
import time
from decimal import Decimal
from pathlib import Path

import pytest

from ledger.prices import parse_price, total
from ledger.store import Store


def test_parse_price():
    assert parse_price("1,50") == Decimal("1.50")
    assert parse_price(" 2 ") == Decimal("2.00")
    with pytest.raises(ValueError):
        parse_price("abc")
    with pytest.raises(ValueError):
        parse_price("-3")


@pytest.mark.parametrize("text,expected", [("3.25", Decimal("3.25")), ("0", Decimal("0.00")), ("x", None), ("", None)])
def test_parse_price_cases(text, expected):
    if expected is None:
        with pytest.raises(ValueError):
            parse_price(text)
    else:
        assert parse_price(text) == expected


def test_total():
    assert total([]) == Decimal("0.00")
    prices = [Decimal(random.randint(0, 1000)) / 100 for _ in range(10)]
    assert total(prices) == sum(prices)
    assert total([Decimal("1.10"), Decimal("2.20")]) == Decimal("3.30")


def test_store(tmp_path):
    store = Store(tmp_path / "ledger.db")
    store.add("coffee", Decimal("1.50"))
    store.add("tea", Decimal("2.00"))
    time.sleep(0.2)  # let sqlite flush
    assert store.all() == [("coffee", Decimal("1.50")), ("tea", Decimal("2.00"))]
    assert store.sum() == Decimal("3.50")
    store.close()
    again = Store(tmp_path / "ledger.db")
    assert again.sum() == Decimal("3.50")
    assert Store(tmp_path / "empty.db").sum() == Decimal("0.00")


def test_cli():
    out = subprocess.run([sys.executable, "-m", "ledger", "1,50", "2"], capture_output=True, text=True, check=True)
    assert out.stdout.strip() == "3.50"
    bad = subprocess.run([sys.executable, "-m", "ledger", "1", "x"], capture_output=True, text=True)
    assert bad.returncode == 2
    assert "error" in bad.stderr


def test_cli_main_function(capsys):
    from ledger.cli import main

    assert main(["1", "2"]) == 0
    assert capsys.readouterr().out.strip() == "3.00"
    assert main(["oops"]) == 2
