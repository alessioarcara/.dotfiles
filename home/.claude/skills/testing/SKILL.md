---
name: testing
description: How to write, fix, review and restructure automated tests in Python (pytest) or another xUnit. Covers test layers, one behaviour per test, sociable tests with doubles only at awkward boundaries, where expected values come from (oracles, Hypothesis property tests, metamorphic relations, golden files), flaky tests, mutation testing, the rules an agent follows when it changes tests, and model-quality evals kept out of the test suite. Use it before writing or reorganising tests, reviewing a test suite or a test-heavy diff, or when asked about test strategy, unit vs integration, mocks, flaky tests, coverage, mutation testing, property tests or golden files ("aggiungi i test", "sistema i test", "come strutturo i test").
---

# Testing

Conventions for automated tests that would otherwise be decided afresh in every session. The
repository's AGENTS.md (or README) states what this skill cannot know: where the tests live,
which integration points exist, the commands for the fast layer and for the whole suite. Load a
file from `references/` when the situation listed under "References" comes up.

## Rules

1. **Layers are directories.** `tests/unit` is in memory, one process, no network, disk or
   sleep. `tests/integration` holds one external point per module. `tests/e2e` drives the outer
   interface. Run the unit layer after every change, everything before a commit and in CI.
2. **One behaviour per test.** Arrange, act and assert are separated by blank lines, and the
   name is a sentence that says why the test exists. One test module per public unit (a
   function, a class, or a small cluster used together).
3. **Test observable behaviour through the public interface**: return values, state, outputs.
   Verify a call only when it is an outgoing command to something you do not own (a file
   handed to another program, a message sent, a metric emitted), recorded as a domain action.
   Never verify calls between your own objects, and never verify calls to a stub.
4. **Sociable by default.** Use real collaborators. A double goes only at a boundary that is
   slow, remote, non-deterministic or has side effects, at the lowest wrapper of that boundary,
   never in front of your own classes.
5. **Expected values come from the specification**, a hand-worked example or an independent
   oracle, never from calling the code under test or a sibling of it. When the exact value is
   unknown, assert the strongest property that does not overconstrain.
6. **An integration test covers exactly one external point**, its success and failure paths.
7. **Push a test down only while it stays sociable.** Keep a higher test that checks wiring,
   serialization or behaviour that emerges between units. Delete a higher test only when you
   can name the lower test that checks the same behaviour.
8. **Parametrize one behaviour over several inputs.** Two independent dimensions get N + M + 1
   tests (each dimension alone plus one wiring test), not an N x M grid.
9. **An error test asserts the type and the stable part of the message** (`match=`). A negative
   assertion is as precise as a positive one (`"B:" not in out`, not `"B" not in out`).
10. **No flaky test in the main suite.** Seed randomness, freeze time, never use a bare sleep,
    keep timeouts in named constants, build fresh state per test, make tear-down loud. Run a
    new test several times before accepting it.
11. **Coverage is a map of what is untested, never a target.** Mutation testing on the changed
    modules shows whether the tests check what they run.
12. **A failing test is investigated**, never skipped, xfailed, loosened or deleted to go green.
    An expected value or golden file changes only when a stated requirement changed.
13. **A fix is done when its regression test exists**, in the same change, and was red before
    the fix.

## Vocabulary

Fix these terms in the repository's README; "unit test" alone has dozens of meanings.

- **Unit test**: in memory and fast, one small unit of behaviour. *Sociable* uses real
  collaborators; *solitary* replaces them. *Isolated* means independent of other tests (any
  order, parallel-safe), not cut off from collaborators.
- **Narrow integration test**: only the code that talks to one external thing. The broad kind
  is e2e.
- **End-to-end test**: drives the system through its outer interface (CLI, public entry point).
- **Size and scope are separate.** A narrow test of a file loader still needs disk, so it goes
  in `integration`.
- **Doubles**:
  - *dummy*: fills a parameter;
  - *stub*: returns canned answers;
  - *spy*: records calls;
  - *mock*: carries pre-set expectations;
  - *fake*: a working shortcut implementation, such as an in-memory store.
- **Contract test**: checks that a double still matches the real external thing.
- **Threshold test**: fails when a measured value (time, memory) crosses a limit. The limit is
  tightened as the code improves and relaxed only as a conscious decision.
- **Eval**: a measured rate of model quality on a curated set. It is not a test and never runs
  in the test suite.

## Layout

```
tests/
  helpers/            shared example objects (an Object Mother) and hand-written doubles
  unit/<pkg>/         one module per public unit
  integration/<pkg>/  one external point per module: test_loading.py, test_export.py, ...
  e2e/                documented user journeys, compared with committed golden outputs
                      on a small input set, never with metric thresholds
evals/                model quality on real weights, only if the project has learned models
```

- Omit a layer that has nothing in it. Use no markers: the directory is the layer.
- A double used by one file stays in that file.
- If basenames repeat across layers, configure `--import-mode=importlib` and
  `pythonpath = ["."]`, so tests can import `tests.helpers.*`.
- The README has a "Tests" section that defines each layer in one line and gives both commands.

## Adding tests to new code

1. **List the requirements first** and map each one to at least one test. Behaviour without a
   test tends to be missing from the code.
2. **A new function or class.** Settle what it promises, what it requires, and which inputs
   trigger each behaviour. Test the happy path and each failure that can plausibly happen: one
   test per step that can fail, each with a result you can tell apart. Skip code with no
   decision in it (getters, constant wiring, logging calls).
3. **A new boundary** (file format, subprocess, library, network). Write one narrow integration
   test for the lowest wrapper, against the real thing, covering success and failure (missing
   file, malformed input, timeout).
4. **A new remote service.** Put a double in the suite and run a contract test on its own
   schedule.
5. **A new user journey.** Write one e2e test; everything else is covered below it.
6. **A fixed performance or memory regression.** Add a threshold test.
7. **A bug.** First write a failing test at the lowest level that shows it, plus an API-level
   test if the low one does not prove the user-visible symptom. Then fix it, and look for
   sibling cases.
8. **Break the code where each new test aims** (flip the condition, delete the line) and watch
   the test go red for that reason.

## Writing a test

- **Private functions are implementation.** If one needs its own test, reach it through a seam
  rather than making it public.
- **A shape or type check alone catches almost nothing.** Assert properties of the value
  instead: bounds, invariants, relations between outputs.
- **Do not assert on log text or `repr`.** When logging or telemetry *is* the requirement,
  record it as structured data and assert on that.
- **A failure message should be diagnosable from the test alone**: inputs, expected, received.
- **Build the subject through helper functions** whose keyword arguments default to obviously
  irrelevant values, so a signature change is fixed in one place. In assertions, prefer readable
  repetition to clever helpers.
- **Never read the clock directly.** Wrap it, so a test can freeze it.
- **An expensive object (a model, a server) may be a module-scoped fixture** only if every test
  treats it as immutable.
- **Two checks:**
  - *Adequacy*: "if I break this line, does a test fail?"
  - *Excess*: a small code change forces long test changes, or several tests check the same
    behaviour the same way.

## When an agent changes tests

These are the mistakes agents make most often. Each one needs evidence, not a claim.

- **Report the command and its summary line** (passed, failed, skipped). A suite that cannot run
  blocks "done": say so first, do not work around it.
- **A red test means the code is wrong until shown otherwise.** Do not change an expected value
  or regenerate a golden file to match new output unless a requirement changed. If one did, name
  the requirement and flag the change for review.
- **Do not silence the symptom in production code** to turn a test green: a broader `except`, a
  bigger timeout, a default that hides `None`.
- **Search the existing tests first**, and extend a parametrization before adding a new test.
- **Before deleting a test, name the test that now covers its behaviour.** Count tests before
  and after, and preferably show that the mutation results did not get worse.
- **Design the cases from the requirements up front.** Red-green ceremony inside the agent's own
  loop adds cost without measured benefit. The exception is a bug: reproduce it with a failing
  test first.

## When the request conflicts with the method

Some requests aim at a number rather than an outcome: "100% coverage", "make the suite green, I
release in an hour", "mock every collaborator".

1. Say in one sentence what the request would cost: tests of trivial code, a skipped test that
   hides a real bug, or tests coupled to the implementation.
2. Do the part that has value: the error paths, the real cause of the red test, state-based tests.
3. Say plainly what you left out and why.

## Restructuring an existing suite

1. Run `pytest --durations=25`: slow tests mark the integration points. Record a
   mutation-testing baseline on the core modules.
2. Classify every test (unit, which integration point, e2e) and move it to its directory.
3. Split modules that test several units and tests that assert several behaviours. Add the
   blank lines and rename tests to sentences.
4. Move shared example objects to `tests/helpers/`; single-use doubles stay in their file.
5. Replace mocks of your own classes with the real ones, one double at a time, keeping the test
   green after each.
6. Move filesystem, subprocess, export and real-model work out of unit tests, one external point
   per module.
7. Remove duplicates. A test copied from another and extended is trimmed to its new check. A
   higher test goes only when a named lower test covers it.
8. Run every layer, the linter, the type checker and the mutation baseline again. Explain any
   drop in the test count.
9. Update the README, the task runner and AGENTS.md.

## Judging a suite

- **Coverage**: run it occasionally from the unit layer and read the missing lines.
- **Mutation testing**: run it on the changed modules at the integration-test cadence (before a
  commit, not after every edit). A surviving mutant on a line with a decision is a missing
  assertion. On logging, timeouts, flags or caches it is noise.
- **Test code** gets the same review, style and cleanup as production code.
- **Exploratory testing**: automated tests only find what someone anticipated, so suggest a
  short exploratory session when a feature lands.

## References

| File | Read it when |
|---|---|
| `references/assertions.md` | The expected value is not obvious; for property tests, metamorphic relations, golden files, tensor comparisons, and finding the cases of a new function. |
| `references/doubles.md` | Choosing or placing a double, wrapping a library or service, or converting a mock-heavy suite. |
| `references/flaky-tests.md` | A test fails intermittently or depends on time, order, async work or a remote service. |
| `references/mutation-testing.md` | Judging whether a suite catches regressions, or before deleting tests. |
| `references/ml-models.md` | The code contains a neural network or another learned component. |
| `references/tradeoffs.md` | Unit vs integration, pyramid vs trophy, how many tests, or two rules pulling apart. |
