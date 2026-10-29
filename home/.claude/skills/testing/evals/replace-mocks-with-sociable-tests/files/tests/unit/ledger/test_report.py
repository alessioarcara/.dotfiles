from decimal import Decimal
from unittest.mock import MagicMock, patch

from ledger.report import Report


def test_summary_calls_all_and_sum():
    store = MagicMock()
    store.all.return_value = [("coffee", Decimal("1.50"))]
    store.sum.return_value = Decimal("1.50")

    Report(store).summary()

    store.all.assert_called_once_with()
    store.sum.assert_called_once_with()


def test_summary_builds_lines_from_store_calls():
    store = MagicMock()
    store.all.return_value = [("coffee", Decimal("1.50")), ("tea", Decimal("2.00"))]
    store.sum.return_value = Decimal("3.50")

    text = Report(store).summary()

    assert store.all.call_count == 1
    assert store.sum.call_count == 1
    assert text.count("\n") == 2


@patch("ledger.report.Store")
def test_report_keeps_the_store_it_is_given(store_cls):
    store = store_cls.return_value

    report = Report(store)

    assert report.store is store
    store_cls.assert_not_called()
