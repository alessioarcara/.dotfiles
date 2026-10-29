# Mutation testing

Read this when judging whether a suite catches regressions, before deleting tests during a
restructuring, or when reviewing tests an agent wrote.

## Why

Coverage says a line ran, not that its result was checked. Mutation testing makes small changes
to the code (flip `<` to `<=`, `and` to `or`, delete a statement, replace a value) and reruns
the tests:

- a **killed** mutant means a test noticed the change;
- a **surviving** mutant on a line with a decision in it means an assertion is missing or weak.

Evidence:

- Google shows surviving mutants on the changed lines during code review; after filtering,
  80-89% were judged useful, and developers who saw them wrote more and better tests (Petrović
  et al., 2021).
- Agent-written suites at 99-100% line coverage still had many survivors (Böckeler, 2026).
- Meta ranks mutation coverage above line coverage.

## When to run it

The tool reruns the selected tests for every mutant, so it is slow on a large codebase.

- **Cadence**: same as the integration tests. Run it before a commit and in CI, never after
  every edit.
- **Scope**: the modules the change touched, or the critical modules. Google likewise mutates
  only the changed lines.
- **Whole package**: once as a baseline before restructuring a suite, and again afterwards.

## Setup with mutmut (3.x, `src/` layout)

```bash
uv add --dev mutmut
```

```toml
[tool.mutmut]
source_paths = ["src/<package>"]                    # the whole package, not single files
pytest_add_cli_args_test_selection = ["tests/unit"] # the in-memory layer

[tool.pytest.ini_options]
pythonpath = [".", "src"]                           # src first: see below
```

Add `mutants/` (generated) to `.gitignore`.

```bash
mutmut run "<package>.<module>*"   # the mutants of the modules you changed
mutmut results                     # survivors and timeouts
mutmut show <mutant-name>          # the diff of one mutant
mutmut tests-for-mutant <name>     # the tests that ran against it
```

Gotchas:

- **The whole package must be in `source_paths`.** mutmut copies `source_paths` into `mutants/`
  and runs pytest there. If you list single files, the rest of the package is missing and
  collection fails with `ModuleNotFoundError`. Use the `run` filter to narrow instead.
- **`src` must come first on pytest's `pythonpath`.** Otherwise an editable install imports the
  original code instead of the mutated copy.
- **Select the in-memory layer.** Tests that start a subprocess, or that reset `PYTHONPATH` for a
  child process, make mutmut stop with "failed to collect stats". Code covered only by
  integration tests then shows as "no tests" or as false survivors; read those results with that
  in mind.
- **Code that runs at import time can survive falsely.** Metaclasses, `__init_subclass__` and
  module-level decorators run while pytest imports the test modules, before mutmut switches a
  mutant on, so their survivors can be false. Before writing a test for one, break the line by
  hand and run the tests. A test that builds its class inside the test function does see the
  mutant.
- **Tools found next to `sys.executable`** (a type checker, a CLI) must exist in the environment
  mutmut runs in.
- **The old keys `paths_to_mutate` and `tests_dir` are deprecated.**

## Reading the results

Most raw survivors are noise. Google found about 85% unproductive before filtering, and a test
written to kill one is a change detector that pins the implementation. Skip survivors in:

- logging calls and their message strings, writes to stdout;
- type-only code (`cast("T", x)`, annotations, `TYPE_CHECKING` blocks);
- time values (sleeps, deadlines, timeouts, backoff constants);
- configuration flags and capacity hints;
- monitoring counters;
- memoization and caches, where removing the cache changes speed, not results;
- equivalent mutants (`len(x) == 0` → `len(x) <= 0`);
- message text of an error whose wording is not part of the contract.

To drop the most common noise before reading the rest:

```bash
for m in $(mutmut results | grep survived | cut -d: -f1); do
  mutmut show "$m" | grep -qE '^[-+] .*(logger\.|log\.|cast\()' || echo "$m"
done
```

For each remaining survivor, name the behaviour the mutant breaks, then add or tighten an
assertion on that behaviour. Never assert on the mutated detail itself.

A **timeout** means the mutant made the tests hang or slow down a lot. Count it as detected.

When restructuring a suite, compare the survivors before and after. Deleting a test is safe only
if no new survivors appear.
