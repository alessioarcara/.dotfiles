---
type: llm
focus: trace
weight: 1
---

No test function both asserts a returned value and expects an exception: the original test_parse_price is split into separate tests, one per behaviour, and the parametrized case no longer branches on an `expected is None` sentinel.
