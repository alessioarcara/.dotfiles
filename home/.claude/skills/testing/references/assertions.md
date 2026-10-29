# Assertions: what to check and where the expected value comes from

Read this when the exact expected value is not obvious, when writing property tests, when a
test compares tensors or golden files, or when finding the cases for a new function.

## Where expected values come from

The expected value must be derived independently of the code under test: from the
specification, a hand-worked example, a human-supplied fixture or an independent oracle. A test
that calls the implementation (or the formatter, parser or helper the implementation uses) to
compute what it expects cannot fail when that logic is wrong. Agent-written suites at 99-100%
coverage contained exactly these tests, and bugs "enshrined by a test" (Böckeler, *TDD inside
the agent loop*, 2026).

A test written after the code and kept because it passes only pins current behaviour, bugs
included (Meta, TestGen-LLM). Before keeping it, check each expected value against the
requirement, not against the output.

## The oracle ladder

From strongest to weakest. Use the strongest that does not overconstrain (Wayne, *Finding
Property Tests*; *Hypothesis Oracles*):

1. **Exact known answer**: a hand-computed example.
2. **The definition as a check**: assert the postcondition in full, e.g. for `mode(xs)`:
   `xs.count(m) >= xs.count(x) for every x`.
3. **Reference oracle**: a slow, obviously correct implementation, the previous version, or a
   special case with a known answer (`sorted(xs)` for a custom sort).
4. **Metamorphic relation**: how the output must change when the input changes in a known way.
5. **Bounds against an arbitrary element**: `min(xs) <= result <= max(xs)`.
6. **Sanity**: `result in xs`, shape, dtype, no NaN.
7. **No crash**: only as a deliberate fuzz/no-crash test.

A type or shape check alone rarely catches a value bug. Overconstraining is the opposite error:
where the spec leaves freedom (ties, order of equal items, float rounding, which of several
valid answers) assert the spec, not one implementation's choice, or the test fails on correct
changes.

## Finding the cases of a new function

Answer five questions before writing tests (Bland, *Goto Fail, Heartbleed*):

1. What does it promise (contract)?
2. What does it require from callers, and how is that enforced?
3. What does it guarantee on return (postconditions)?
4. Which inputs trigger each behaviour?
5. Which set of tests covers every behaviour and guarantee?

Derive the cases from the contract; use knowledge of the implementation only to probe its
corners. Then:

- One success test plus **one failure test per step that can fail**, each with a distinct,
  assertable result, so a skipped or short-circuited step is visible (goto fail was a duplicated
  `goto` that skipped the last check and returned success).
- For externally supplied data (files, headers, user input, config): a declared size larger
  than the actual data, an empty payload, one byte below the minimum and one above the maximum,
  plus a normal control. Assert that nothing beyond the input is read or returned (Heartbleed).
- A MUST or MUST NOT in a specification is a test.
- A negative assertion is as precise as a positive one: Bland's buggy test checked that `"B"`
  was absent where it should have checked `"B:"`, and passed against the buggy code.

## Property tests with Hypothesis

Not a dependency of every repo: add it with `uv add --dev hypothesis`.

Ways to find a property, in the order to try them (Wayne):

1. Round trip: `decode(encode(x)) == x` (serialization, config load/save, export/import).
2. Definition or postcondition as the assertion (above).
3. Bounds against an arbitrary element.
4. Preserving transformation: shuffling, permuting or re-batching the input leaves the output
   unchanged.
5. Controlled transformation: scaling or shifting the input changes the output predictably.
6. Reference oracle: compare with a simple or previous implementation.
7. Reverse oracle: generate the answer first, build the input from it.
8. Contracts: put cheap `assert`s (pre/postconditions, invariants) in the code, then drive the
   top-level entry point with generated valid inputs and no assertion in the test. Any deeper
   contract violation is a bug in the integration of the units on that path.

Generators matter as much as assertions:

- `st.from_type(T)` when annotations already describe valid data; `st.builds(T, field=...)`
  plus `st.register_type_strategy` for per-field constraints; `@st.composite` for dependent
  fields (lengths that must match, keys that must exist); `st.data()` only when draws depend on
  what happens inside the test.
- `.filter` / `assume` only when invalid draws are rare, otherwise build valid data directly.
- Include the awkward values the function can really receive: empty, `None`, duplicates,
  extremes. A bug the generator cannot produce will not be found.
- Check a non-trivial generator or oracle with a couple of example tests; reverse oracles in
  particular have bugs of their own.
- `hypothesis.extra.numpy.arrays(dtype, shape, elements=...)` for arrays; convert to tensors in
  the test.

Keeping property tests deterministic in the main suite:

- When Hypothesis finds and shrinks a failure, pin it with `@example(...)` on the test (or a
  plain example test) before fixing, so the regression stays in the suite.
- In CI, register a profile with `settings.register_profile("ci", derandomize=True)` and load
  it from `conftest.py` when `CI` is set, so the same inputs run every time.

Stateful code (caches, registries, data structures with a lifecycle): a
`hypothesis.stateful.RuleBasedStateMachine` that applies random operations to the real object
and to a simple model (a dict, a list) and compares them in an `@invariant`. Also assert
transition properties against the previous state: append-only, monotone, only allowed
transitions, unchanged while disabled.

Refactors and optimisations ("rho problems" with no simple property): keep the old function as
`_reference` in the test, or import it from a `git worktree` of the main branch, and assert
`new(x) == _reference(x)` under `@given` (Wayne, *Cross-Branch Testing*).

## Metamorphic relations for numeric, vision and ML code

When the right output is unknown, assert relations between outputs (Wayne, *Metamorphic
Testing*):

- Batch invariance: `f(cat(a, b)) == cat(f(a), f(b))` for per-sample operations (in eval mode).
- Permutation: permuting the batch permutes the output the same way.
- Padding with neutral elements, or a no-op transform, leaves the output unchanged within
  tolerance.
- Flipping the image flips the boxes; scaling the image scales the boxes.
- A small perturbation (noise, brightness) changes a classification only rarely: that is a rate,
  so it belongs in an eval, not in the commit suite.

## Comparing tensors

Use `torch.testing.assert_close(actual, expected, rtol=..., atol=...)` with tolerances in named
constants and a comment on where they come from (dtype, backend). Exact equality only for
integer outputs and for the same code path on the same device. Results differ across CPU/GPU,
cuDNN, TensorRT and ONNX Runtime: compare backends with a tolerance, never bitwise.

## Golden files and approval tests

A golden (approval, snapshot) test compares a complex output with a committed reference.

- Make the output deterministic first: seeds, sorted keys, timestamps and paths scrubbed.
- Keep the snapshot at the level of the domain (the boxes, the config), not incidental formatting.
- They work at any layer for complex outputs, not only e2e.
- A failure first asks: is the code wrong or is the reference stale? Update the reference only
  after reading the diff and confirming the change was intended by a requirement; commit the
  update separately, with the reason. Never regenerate goldens to make a red suite green.
- e2e tests compare with committed goldens on a small input set, never with metric thresholds;
  quality metrics go to evals (`ml-models.md`).

## Logs and telemetry

Logging is usually not worth testing (Google filters it out of mutation testing as noise). When
logging, alerting or metrics *are* the requirement, inject the logger or a domain probe,
record what it receives as structured data, and assert on that data, not on formatted text
(Shore, Output Tracking; Hodgson, *Domain-Oriented Observability*).
