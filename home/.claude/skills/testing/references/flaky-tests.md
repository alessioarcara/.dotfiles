# Flaky tests and non-determinism

Read this when a test fails intermittently, or when writing a test that depends on time, order,
async work, randomness or a remote service. Main source: Fowler, *Eradicating Non-Determinism in
Tests*.

A non-deterministic test is worse than none: people learn to rerun until green and then miss
real failures. Google keeps flakiness around 0.15%; near 1% a suite loses its value. Rerunning
hides the cause.

## First response

1. Move the test to quarantine (out of the main suite) at its first random failure, with an
   owner and a limit: about a week, and only a handful of tests in quarantine at once. Past the
   limit, fix it or delete it deliberately and say so.
2. Never "fix" it by adding a retry, a longer sleep or a skip in the main suite.
3. Diagnose the causes below in this order of likelihood.

## Causes and remedies

**Lack of isolation.** A test depends on state another test left behind.
- Each test builds its own state; prefer rebuild-from-scratch to clean-up (a clean-up bug makes a
  different test fail). Where rebuild is too slow: a transaction rolled back after the test, or a
  copy of a prebuilt database file.
- Look for hidden shared state: module globals, singletons, class attributes, caches, `sys.path`,
  `sys.modules`, loggers, environment variables, the current working directory, the clock stub
  itself. Restore anything global the test touched (`monkeypatch` does this).
- Tear-down errors must fail loudly.
- Tests run in any order and in parallel; no test depends on another having run.

**Async behaviour.**
- Never a bare `sleep`. Either wait on the subject's own completion signal (callback, event,
  future, `join(timeout)`), or poll: check the condition in a loop with a small interval and a
  high overall limit, and raise a dedicated timeout error that says what was awaited.
- The wait limit and the polling interval live in named constants in one place.
- If you own a fire-and-forget component, give it a completion signal for tests.

**Remote services.**
- A double in the main suite (record once, replay), a contract test outside it.
- If a test must reach a service, run a smoke check first and abort the run with a clear message
  when the service is down.

**Time.**
- Never call `datetime.now`, `time.time` or `date.today` directly in code under test. Wrap the
  clock and inject it; freeze it in tests and re-initialize it in every test.
- A cheap build check (a grep for direct clock calls in `src/`) keeps the rule enforced.
- Test date logic around midnight, month end and leap days. Running the whole suite just before
  and after midnight catches tests that still read the real clock.
- When test data and clock seeds have to move forward, make that the only change in the commit.

**Randomness.**
- Fixed inputs, or a seed set in a fixture for every source (`random`, `numpy`, `torch`, and
  `torch.use_deterministic_algorithms` where the test needs bitwise repeatability).
- Randomized edge-case hunting (fuzzing, Hypothesis without a fixed profile) and performance
  measurements are not regression tests; keep them out of the main suite, and pin what they find
  as example tests.
- Sometimes tighten instead: stub a random generator to a constant to surface collision bugs.

**Resource leaks.**
- If random tests fail rather than one, suspect a leak (file handles, threads, processes, GPU
  memory, pool connections).
- In tests, size pools to 1 and raise on exhaustion, so the leaking test is the one that fails.

**External tools.** A test that needs an installed tool (a compiler, TensorRT, a CLI) checks for it
and fails with a message naming the tool, or skips with that message only where the team has
agreed the tool is optional.

## Admitting a new test

Run a new test several times (Meta used 5 out of 5 passes) before accepting it, especially a
generated one, e.g. `pytest path::test_name --count=5` with `pytest-repeat`, or a shell loop.
