from decimal import Decimal

import pytest

from ledger.budget import Budget


@pytest.fixture(scope="module")
def budget() -> Budget:
    return Budget(Decimal("10.00"))


def test_a_fresh_budget_has_the_whole_limit_left(budget: Budget) -> None:
    assert budget.remaining() == Decimal("10.00")


def test_adding_a_price_reduces_what_is_left(budget: Budget) -> None:
    budget.add(Decimal("4.00"))

    assert budget.remaining() == Decimal("6.00")


def test_a_price_over_the_limit_is_rejected(budget: Budget) -> None:
    with pytest.raises(ValueError, match="over budget by 2.00"):
        budget.add(Decimal("12.00"))


def test_a_budget_is_not_over_until_it_is_spent(budget: Budget) -> None:
    assert not budget.is_over()
