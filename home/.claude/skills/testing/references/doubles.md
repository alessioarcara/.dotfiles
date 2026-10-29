# Doubles, boundaries and mock-heavy suites

Read this when choosing or placing a double, testing a wrapper around a library or service,
converting a mock-heavy suite, or explaining classical versus mockist style.

## Classical versus mockist

Fowler, *Mocks Aren't Stubs*:

- **Classical (Detroit)**: real collaborators where possible, a double only for an awkward one,
  state verification.
- **Mockist (London)**: a mock for every collaborator with interesting behaviour, behaviour
  verification.

Where they differ:

- **Driving design**: mockists go outside-in, discovering collaborators through expectations.
- **Fixtures**: classical tests build real object graphs; mockists set up only the mocks.
- **Failures**: a classical bug fails many tests (ripple), but those tests are mini-integration
  tests that catch interaction bugs. A mockist bug fails only its own test.
- **Coupling**: mock tests are coupled to the implementation, so a refactor breaks them.
- **Design style**: mockists favour tell-don't-ask and avoid getters.

Fowler is classical. Beck, DHH, Shore, Khorikov and Dodds go further in the same direction: heavy
mocks make refactoring painful, and every mock removes confidence in that integration.
Interaction tests still fit two kinds of code (Clemson, *Testing Strategies in a Microservice
Architecture*):

- **Coordination code**, whose job is to send the right messages: verify the messages.
- **Gateway or plumbing code**, which maps requests and responses: a double that forces error
  responses is the easiest way to test the error paths.

Classical risks and their remedies (Fowler):

- Keep sociable clusters small (about half a dozen objects).
- When failures are hard to localise, add finer tests while debugging.
- Keep a few coarse tests across the whole system.

## When to verify a call

Khorikov's rule, consistent with Fowler and Shore:

- **Queries** (calls that return data): never assert that they happened. Assert on the result.
  Asserting a call to a stub is overspecification.
- **Commands between your own in-process objects**: implementation detail; do not verify.
- **Commands to systems you do not own** (mail sent, message published, file handed to another
  program, metric emitted): observable behaviour; verify them, preferably as recorded domain
  actions (`[{"to": ..., "subject": ...}]`), not as call lists.
- **Your own private resources** (files only this program reads, its own local database):
  use them for real in integration tests, do not mock them.

Specify only what the test is about: match arguments loosely where another test already pins
them, so one change breaks one test. Avoid adding query methods to production code only for
tests; a recording double or a tracked output usually replaces them.

## Where to put the double: wrap the boundary

Shore, *Testing Without Mocks*. The idea is to keep the chain of sociable tests unbroken down to
the last line of your code:

- **One wrapper per external system** (a file format, a subprocess, an HTTP API, a model hub),
  exposing only what the application needs, in its terms.
- **Narrow integration tests for the wrapper against the real thing**: real files, a real local
  process, the same configuration as production, including failures and hangs.
- **The double sits below your wrapper**, at the third-party call (Shore's *Embedded Stub*), so
  tests above it run all of your real code. If the double replaces your own wrapper, nothing
  checks how the callers use the real wrapper.
- **A test that runs the same scenario against the real library and the stub** keeps the stub
  faithful.
- **Configurable responses in the dependency's domain terms**: `Client.create_null(email=...,
  verified=True)`, not raw HTTP payloads. Accept one value (returned forever) or a list (one
  per call, error when exhausted).
- **Output tracking** records writes as domain objects (`{"alert": "info", "message": ...}`). It
  records behaviour, not function calls, so refactoring does not break it.
- **Behaviour simulation** (`simulate_message(...)`) for pushed events, sharing code with the
  real handler.

Shore puts these factories (`create_null`) and trackers in production code and tests them as
such. Putting test code in production modules is a design decision for the team;
without it, write the doubles in `tests/helpers/` and place them the same way. The cost of the
whole approach: one
bug can fail many tests. When a dependency's output is irrelevant to the test, build the
expected value by asking the dependency (`"Report for " + address.one_line()`), but only
sparingly, because it couples the test to the implementation.

## Remote services

- Use a double in the main suite: record the real responses once and replay them (Fowler's
  *Self Initializing Fake*). Drop volatile request parameters (timestamps, nonces) from the
  recording key.
- A contract test, run outside the commit pipeline on the service's own rhythm, checks that the
  double still has the essential structure of the real responses (fields and types, not equal
  values). A failure opens a task and a conversation with the provider; it need not break the
  build.
- A consumer asserts only the fields it uses.
- If you provide an API that others consume, run their contract tests in your pipeline
  (consumer-driven contracts). Evolve it with Postel's law and Parallel Change.

## Object Mother and test data

- One mother per kind of object (`ConfigMother`, `GraphMother`), with a small set of named,
  familiar instances.
- In a test, tweak an existing instance rather than adding a new canned one. Changing mother
  data ripples through many tests: budget for it.
- Pass every value the test depends on explicitly, even if the default would do, so a change to
  the mother does not silently change the test.
- Value objects with required fields get no silent defaults in production. Use a test factory
  with obviously fake defaults (`"irrelevant-path"`) instead.

## Testability without design damage

- Move logic out of things that are hard to test (CLI framework callbacks, async plumbing, UI)
  into plain functions, and leave a thin shell (Humble Object). The shell still gets one wiring
  test through the framework's test helper (e.g. a CLI runner).
- No significant work in constructors: connect, load or start in an explicit method, so tests
  can build objects cheaply (Zero-Impact Instantiation).
- Logic and infrastructure as peers: read through infrastructure, compute in pure logic, write
  through infrastructure (Logic Sandwich); test the logic in memory.
- Do not add ports, layers or injected interfaces only to isolate a unit. DHH calls it
  test-induced design damage, and Beck warns "you may think you're decoupled, but you're
  really, really not". First look for a design insight: an intermediate result that is both a
  better design and a natural test point.

## Converting a mock-heavy suite

Work incrementally. Leave code that is already easy to maintain alone.

1. Pick a test that gets in the way of a change. Inline its setup if that helps.
2. Replace one double at a time with the real object (or the wrapper-level double above),
   keeping the test green after each step:
   - query/config doubles first, turned into real objects or configurable responses;
   - event doubles next, turned into simulation;
   - call-verification doubles last, turned into assertions on tracked outputs or state.
3. Large dependency tree: convert one class and its direct dependencies at a time (*Descend the
   Ladder*). Small tree: convert bottom-up (*Climb the Ladder*).
4. For untestable legacy code, use `mock.patch` only to write characterization tests. Then
   refactor (extract function, inject the collaborator) and rewrite the tests against the new
   seams.
