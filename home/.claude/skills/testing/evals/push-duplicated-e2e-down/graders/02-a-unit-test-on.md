---
type: llm
focus: trace
weight: 1
---

A unit test on parse_price covers the half-cent rounding inputs 2.675 -> 2.68 and 2.665 -> 2.66 (it did not exist before and is not lost).
