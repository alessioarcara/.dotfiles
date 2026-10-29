"""Split a list into batches of a given size."""

from collections.abc import Sequence
from typing import TypeVar

T = TypeVar("T")


def split_batches(items: Sequence[T], size: int) -> list[list[T]]:
    """Consecutive batches of `size` items; the last one may be shorter."""
    if size < 1:
        raise ValueError(f"size must be at least 1, got {size}")
    return [list(items[i : i + size]) for i in range(0, len(items), size)]
