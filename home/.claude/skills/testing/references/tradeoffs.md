# Tradeoffs: shapes, levels and how many tests

Read this when someone asks "unit vs integration", pyramid vs trophy, how many tests to write, or
when two rules of the skill pull in different directions.

## The shapes are mostly a vocabulary dispute

| Source | Shape | What it actually recommends |
|---|---|---|
| Cohn, Fowler, Vocke | Pyramid | Many fast low-level tests, fewer service-level tests, very few UI/e2e tests. |
| Dodds | Trophy | Static analysis at the base, "mostly integration". His "integration" means several units together with no external system: Fowler's sociable unit test. |
| Spotify | Honeycomb | Mostly integration tests, for microservices. |
| Shore | No broad tests | Overlapping narrow sociable tests, plus one or two smoke tests. |
| Google | 80 / 15 / 5 | A pyramid by count, plus size limits independent of scope. |

Fowler (*On the Diverse and Fantastical Shapes of Testing*) shows that the disagreement is mostly
about what "unit" means. Justin Searls: the ratio debate distracts from what matters, which is
tests that "establish clear boundaries, run quickly & reliably, and only fail for useful
reasons". The pyramid rests on an assumption (Fowler's footnote): high-level tests are slow,
brittle and expensive. If a given high-level test is fast, reliable and cheap to change, lower
tests under it may be unnecessary.

The criterion to use is confidence gained per cost, which all the sources share. In practice:

- **Sociable unit tests do most of the work.** They are fast and they exercise real collaborations.
- **Narrow integration tests cover each external point.** This includes every place data is
  serialized or deserialized: files, exports, subprocess I/O, network.
- **A few e2e tests cover the documented journeys.** A failure that only an e2e test catches
  reveals a gap below it, and that gap gets filled with a lower test.
- **Avoid the ice-cream cone** (many e2e, few unit) and **the hourglass** (many e2e, many unit, few
  integration; usually a sign of components too coupled to instantiate alone).

## Beck's Test Desiderata: the twelve properties

No test has them all. Name the ones a choice sacrifices.

- **Isolated:** same result in any order.
- **Composable:** dimensions of variability are tested separately and combined.
- **Deterministic:** same result if nothing changed.
- **Fast:** quick to run.
- **Writable:** cheap to write relative to the code.
- **Readable:** the reader sees why the test exists.
- **Behavioral:** fails when behaviour breaks.
- **Structure-insensitive:** survives a refactor.
- **Automated:** runs without a human.
- **Specific:** a failure points to its cause.
- **Predictive:** green means ready for production.
- **Inspiring:** green gives confidence.

Two of the most useful pairs:

- **Behavioral vs structure-insensitive.** A test that breaks on a refactor is a false positive; a
  test that passes with broken behaviour is a false negative (Khorikov). Mocks of in-process
  collaborators trade the second for the first.
- **Specific vs predictive.** Tiny tests localise failures, broad tests predict production.
  Composability gets both: test each dimension narrowly, plus one test that the pieces are wired
  together (N + M + 1 instead of N x M).

**Composable tests** (Beck, 2025): when `test_b` was made by copying `test_a` and adding a check,
trim `test_b` down to the new check rather than deleting `test_a`. The pair stays predictive and
becomes more specific.

## How many tests

- **Only test things that can possibly break** (Beck, quoted by Fowler). Assume the library works,
  but test your use of it where misuse is plausible and costly.
- **Delta coverage** (Beck): every test should cover something no other test does, or document
  something. Testing one behaviour several ways is coupling that raises the cost of change.
- **Too much and too little** (Fowler): too much testing shows as code changes that cost more in
  test edits than in code; too little shows as fear of changing code. Occasional overshoot is fine.
- **Scale with criticality.** The cost of a failure, how recoverable it is, how long the code will
  live, and whether it will be handed over all raise the investment (Beck, Clemson). Throw-away
  prototypes can skip thorough tests, but once the code survives, the debt is due (Bland).
- **Coverage numbers are not goals.** Fowler finds upper 80s to 90s typical of a well-tested
  codebase, and is suspicious of 100%. Dodds sees diminishing returns past roughly 70%. Google
  measures coverage only from small tests, and warns that a target becomes a ceiling.
- **Don't test what the type checker or linter already guarantees** (Dodds).

## TDD and self-testing code

- **Self-testing code is the goal.** One command runs a suite you trust enough that green means
  releasable. TDD is one way to get there (Fowler; Beck in *Is TDD Dead?*).
- **Test-first pays off on tricky logic with a clear interface.** Beck calls it "4WD low gear".
  Elsewhere, code and tests still arrive in the same change.
- **TDD has three steps.** Keep a test list, pick the next test toward the design point, then
  red, green, refactor. Skipping the refactor is the most common failure (Fowler).
- **For an agent, ceremony adds no measured quality.** Prompting an agent to run red-green inside
  its own loop gave no gain at 3 to 8.5 times the tokens (Böckeler, 2026, small sample). For a bug
  fix, though, a failing reproduction first is cheap and has a clear oracle.

## Pipeline stages

- **Run tests by speed and scope, not by type.** A fast narrow integration test may run with the
  unit layer (Vocke).
- **The commit suite takes minutes; the unit layer takes seconds.** The real criterion is that the
  suite is fast enough to run all the time, so a failure points to recent work.
- **Speed slow tests up before moving them.** Parallelize them, or select them by impact
  (`pytest-testmon` derives the selection from coverage). Moving tests to a nightly run is the
  "shift right" that weakens CI (Hammant). Any selection must always run new and previously
  failing tests, and treat changed fixtures or golden files as affecting the tests that read them.
  CI still runs everything.
