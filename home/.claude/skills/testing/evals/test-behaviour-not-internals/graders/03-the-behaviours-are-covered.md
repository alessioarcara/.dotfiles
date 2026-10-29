---
type: llm
focus: trace
weight: 1
---

The behaviours are covered through add(), remaining() and is_over(): a negative price is rejected with its message, adds reduce remaining(), a price over the remaining budget is rejected with the 'over budget' message, and is_over() reflects the state.
