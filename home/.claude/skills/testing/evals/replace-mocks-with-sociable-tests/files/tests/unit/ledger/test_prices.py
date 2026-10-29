"""parse_price and total: plain functions, no I/O."""

from decimal import Decimal

import pytest

from ledger.prices import parse_price, total


def test_a_comma_decimal_is_parsed() -> None:
    price = parse_price("1,50")

    assert price == Decimal("1.50")


def test_surrounding_whitespace_is_ignored() -> None:
    assert parse_price(" 2 ") == Decimal("2.00")


def test_text_that_is_not_a_number_is_rejected() -> None:
    with pytest.raises(ValueError, match="not a price: 'abc'"):
        parse_price("abc")


def test_a_negative_price_is_rejected() -> None:
    with pytest.raises(ValueError, match="must not be negative"):
        parse_price("-3")


def test_the_total_of_nothing_is_zero() -> None:
    assert total([]) == Decimal("0.00")


def test_the_total_adds_prices() -> None:
    assert total([Decimal("1.10"), Decimal("2.20")]) == Decimal("3.30")
