"""`python -m ledger 1,50 2 3.25` prints the total of the prices given."""

import sys

from ledger.prices import parse_price, total


def main(argv: list[str] | None = None) -> int:
    args = sys.argv[1:] if argv is None else argv
    try:
        prices = [parse_price(arg) for arg in args]
    except ValueError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2
    print(total(prices))
    return 0
