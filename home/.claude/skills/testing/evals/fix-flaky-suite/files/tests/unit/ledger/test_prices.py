"""parse_price and total: plain functions, no I/O."""

import random
from decimal import Decimal

import pytest

from ledger.prices import parse_price, total


def test_a_comma_decimal_is_parsed() -> None:
    assert parse_price("1,50") == Decimal("1.50")


def test_text_that_is_not_a_number_is_rejected() -> None:
    with pytest.raises(ValueError, match="not a price: 'abc'"):
        parse_price("abc")


def test_the_total_matches_the_sum_of_random_prices() -> None:
    amounts = [round(random.uniform(0, 100), 2) for _ in range(50)]
    prices = [parse_price(str(amount)) for amount in amounts]

    assert total(prices) == Decimal(str(round(sum(amounts), 2)))
