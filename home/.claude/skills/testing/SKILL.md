---
name: testing
description: How to write, review and restructure automated tests in any repository (pytest or another xUnit): the test pyramid as directories (unit, integration, e2e), one behaviour per test in arrange/act/assert, sociable tests with doubles only where a collaborator is awkward, narrow integration tests, non-determinism, coverage as a map. Load it before writing or reorganising tests, before reviewing a test suite, or when asked "come strutturo i test", "aggiungi i test", "test strategy", "unit vs integration", "flaky test", "coverage".
---

# Testing

This file holds the conventions that differ from one team to another and would otherwise be
decided afresh in every session. Each repository's AGENTS.md holds only what this file cannot
know: where the tests live, which integration points exist, the command for the fast layer.

## The ten rules

1. Layers are directories: `tests/unit`, `tests/integration`, `tests/e2e`. Many unit, fewer
   integration, very few e2e. `pytest tests/unit` after every change, everything before a commit.
2. One test module per public class or function; one behaviour per test; arrange / act / assert
   separated by blank lines; the name is a sentence.
3. Test the public interface and observable behaviour. Never which collaborators were called.
4. Sociable by default: real collaborators. A double only when the real one is slow, remote,
   non-deterministic or has side effects. Hand-written fakes over mocking frameworks.
5. An integration test covers exactly one external point: files, subprocess, database, a real
   model, a compiler stack, an HTTP API.
6. Push every test as far down as it goes; delete a higher test that a lower one now covers.
7. Parametrize one behaviour over several inputs. Different behaviours are different tests.
8. An error test asserts the message (`match=`), not just the type.
9. No flaky test in the main suite: seed randomness, freeze time, no bare sleeps, every
   timeout in a named constant, fresh state per test, loud tear-down.
10. Coverage is a map of what is untested, never a target. A fix is done when its regression
    test exists.

## Vocabulary

"Unit test" has dozens of definitions. Fix the terms per repository, in the README, and use them
consistently:

- **Unit test**: fast, in memory, one small part (a class, a function, a small cluster).
  *Sociable* uses real collaborators; *solitary* replaces them with doubles.
- **Narrow integration test**: only the code that talks to one external thing, nothing else.
  Often no larger than a unit test. "Integration test" means this; the broad kind is "e2e".
- **End-to-end test**: drives most of the system through its outer interface (CLI, examples).
- **Contract test**: checks that a double still matches the real external service.
- **Threshold test**: fails the build when a measured value (time, memory) crosses a limit.

## Layout

```
tests/
  helpers/        shared example objects (an Object Mother) and hand-written doubles
  unit/<pkg>/     mirrors the packages; test_<public_class>.py
  integration/<pkg>/  one external point per module: test_loading.py, test_export.py, ...
  e2e/            the documented user journeys, as subprocesses, compared with committed
                  golden outputs on a small input set; never with metric thresholds
```

Omit a layer that has nothing. No markers: the directory is the layer. Helpers expose objects
whose names explain themselves, so a test still reads top to bottom without opening them; a
double used by one file stays in that file. Duplicate basenames across layers need
`--import-mode=importlib` and `pythonpath = ["."]` so tests import `tests.helpers.*`.

The README has a "Tests" section that defines each layer in one line and gives the command
for the fast layer and for the whole suite. Write it whenever you create or rename a layer.

## Adding tests to new code

1. A new function or class: its unit tests, written with the code, happy path plus every edge
   and error path. Work is not done until they pass.
2. A new boundary (file format, subprocess, external library, network): one narrow integration
   test for that boundary, real resource if it runs locally fast and stable, a double otherwise.
3. A new remote service: a double in the suite plus a contract test that runs on its own
   schedule, outside the commit pipeline.
4. A new user journey: one e2e test. Anything else is covered below it.
5. A performance or memory regression that was fixed: a threshold test, with a limit that is
   tightened as the code improves, so the regression cannot return silently.
6. A bug: first a failing test at the lowest level that shows it, then the fix. Look for the
   sibling cases the bug reveals.
7. Break the code once and watch the new test go red.

## Writing a test

- Private methods are implementation. If one needs a test, extract it into something public.
- Don't test trivial code: getters, setters, code without conditions.
- Assert values when they can be computed, shapes or types only when they cannot. Never assert
  on log text or `repr`.
- Test that the code does *not* proceed on a failed step: wrong behaviour deserves a test as
  much as right.
- Readability over DRY: rule of three before extracting a helper.
- Adequacy check: "if I break this line, does a test fail?" Excess check: a simple change to
  the code forces long changes to the tests.

## Doubles and integration points

- Prefer state verification. Behaviour verification only where state cannot show it (a cache
  hit versus miss).
- Mocking tools that patch statics and constructors are for getting legacy code under test;
  hard-to-test code is a design signal: extract the logic. Hard-to-test edges (UI, CLI
  framework, async plumbing) become a thin shell with the logic in plain testable code.
- Time: never read the clock directly; wrap it so a test can freeze it.
- Real resource when local, fast and stable (SQLite, `tmp_path`, a model built without
  downloading weights). Be wary of in-memory substitutes that differ from production.
- An expensive object (a model, a server) may be a module-scoped fixture only if every test
  treats it as immutable. A test that mutates it (`.train()`, a setting, a write) builds its own.
- Remote services: a double in the main suite (record once, replay), verified by the contract
  test. Never test against production.

## Non-determinism

A flaky test is worse than no test: it teaches people to ignore red builds.

- Quarantine a flaky test out of the main suite and fix it within days. Don't delete it.
- Isolation: each test rebuilds its state; tear-down failures must be loud; no ordering;
  restore anything global the test touched (`sys.path`, `sys.modules`, loggers, env).
- Async: wait on the subject's own completion signal (callback, event, `wait(timeout)`),
  never on a sleep; the timeout and any polling interval live in named constants.
- Randomness: fixed inputs, or a seed in a fixture. Fuzz tests are not regression tests.
- Date logic: freeze the clock; test around midnight and month end.
- Resource leaks: pool size 1 in tests, so the leaking test is the one that fails.
- A test that needs an installed external tool says so in its failure message.

## Speed, coverage, health

- Unit layer in seconds, commit suite under ten minutes. Slow tests move to a later stage,
  they are not deleted.
- Run coverage occasionally, read the missing lines, decide whether they worry you. Upper 80s
  or 90s is normal; be suspicious of 100%. Under half is trouble.
- Test code gets the same review, style and cleanup as production code.
- Test cancer: a failing test is investigated, never skipped, commented out or dropped from
  the build to go green.
- Automated tests only find what someone anticipated. Suggest a short exploratory session
  when a feature lands.

## When the request conflicts with the method

Some requests ask for the number, not the outcome: "get coverage to 100%", "make the suite
green, I release in an hour", "mock every collaborator". Say in one sentence what the request
would cost (tests of trivial code, a skipped test that hides a real bug, tests coupled to the
implementation), do the part that has value (the error paths, the real cause of the red test,
state-based tests), and say plainly what you left out and why. Never skip, xfail or weaken a
test to reach the number.

## Restructuring an existing suite

1. `pytest --durations=25`: slow tests mark the integration points.
2. Classify every test (unit, which integration point, e2e) and move it to its directory.
3. Split modules that test several public classes; split tests that assert several
   behaviours; add the blank lines; rename to sentences.
4. Shared example objects to `tests/helpers/`; single-use doubles stay in the test file.
5. Export/compile, filesystem, subprocess and real-model work out of unit tests into
   integration or e2e modules, one point each.
6. Delete higher-level tests whose behaviour a lower-level test now covers.
7. Run both layers, lint, type-check. Count tests before and after and explain any loss.
8. Update README (layer definitions, commands), the task runner, and AGENTS.md.

## The repository's AGENTS.md

Under "Testing pattern and framework", three lines like:

```
- Tests: pytest, `tests/unit` (in memory, run after every change: `just test-fast`) and
  `tests/integration` (one external point per module: files+import system, pyrefly, torch.export, timm).
- Before writing or reorganising tests load the `testing` skill.
```

## Sources

Martin Fowler, martinfowler.com/testing: Unit Test; The Practical Test Pyramid (Ham Vocke);
Test Pyramid; On the Diverse and Fantastical Shapes of Testing; Integration Test; Broad Stack
Test; Component Test; Subcutaneous Test; Contract Test; Threshold Test; Test Double; Mocks
Aren't Stubs; Eradicating Non-Determinism in Tests; Test Coverage; Self Testing Code; Test
Driven Development; Is TDD Dead?; Object Mother; Humble Object; Self Initializing Fake; Clock
Wrapper; Testing Resource Pools; Test Cancer; Goto Fail, Heartbleed, and Unit Testing Culture
(Mike Bland); Modern Mocking Tools and Black Magic; Exploratory Testing; QA in Production;
Synthetic Monitoring; Page Object; Story Test; Business Facing Test; Specification By Example.
