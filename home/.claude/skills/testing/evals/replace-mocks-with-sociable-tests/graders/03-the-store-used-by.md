---
type: llm
focus: trace
weight: 1
---

The store used by the Report tests is either a hand-written fake with all() and sum() (test placed under tests/unit) or the real Store on tmp_path (test placed under tests/integration); the module path matches that choice.
