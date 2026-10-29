from decimal import Decimal
from unittest.mock import patch

import pytest

from ledger.budget import Budget


def test_check_rejects_negative():
    budget = Budget(Decimal("10.00"))

    with pytest.raises(ValueError):
        budget._check(Decimal("-1.00"))


def test_add_records_in_history():
    budget = Budget(Decimal("10.00"))

    budget.add(Decimal("2.50"))
    budget.add(Decimal("3.00"))

    assert budget._history == [Decimal("2.50"), Decimal("3.00")]


def test_add_calls_check_before_recording():
    budget = Budget(Decimal("10.00"))

    with patch.object(Budget, "_check") as check:
        budget.add(Decimal("2.50"))

    check.assert_called_once_with(Decimal("2.50"))


def test_is_over_after_remaining_goes_negative():
    budget = Budget(Decimal("1.00"))
    budget._history = [Decimal("5.00")]

    assert budget.is_over()
