"""A spending limit."""

from decimal import Decimal


class Budget:
    def __init__(self, limit: Decimal) -> None:
        self.limit = limit
        self._spent: list[Decimal] = []

    def add(self, price: Decimal) -> None:
        self._validate(price)
        self._spent.append(price)

    def remaining(self) -> Decimal:
        return self.limit - sum(self._spent, Decimal("0.00"))

    def is_over(self) -> bool:
        return self.remaining() < 0

    def _validate(self, price: Decimal) -> None:
        if price < 0:
            raise ValueError(f"price must not be negative: {price}")
        if price > self.remaining():
            raise ValueError(f"over budget by {price - self.remaining()}")
