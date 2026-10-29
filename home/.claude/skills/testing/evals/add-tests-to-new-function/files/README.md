# ledger

A toy ledger: parse prices written by people, store them in SQLite, print totals.

## Tests

- `tests/unit`: in memory, no file or process. Run after every change: `uv run pytest tests/unit`.
- `tests/integration`: one external point per module (the SQLite file, the CLI subprocess). Run with
  everything before a commit: `uv run pytest`.
