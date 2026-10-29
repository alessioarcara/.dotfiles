"""Prices written by people: "1,50", "2", " 3.25 "."""

from decimal import Decimal, InvalidOperation


def parse_price(text: str) -> Decimal:
    """A non-negative price with up to two decimals, comma or dot."""
    cleaned = text.strip().replace(",", ".")
    try:
        price = Decimal(cleaned)
    except InvalidOperation:
        raise ValueError(f"not a price: {text!r}") from None
    if price < 0:
        raise ValueError(f"price must not be negative: {text!r}")
    return price.quantize(Decimal("0.01"))


def total(prices: list[Decimal]) -> Decimal:
    return sum(prices, Decimal("0.00"))
