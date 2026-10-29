# testing skill

An [Agent Skill](https://agentskills.io) that teaches coding agents how to write, fix, review and
restructure automated tests (pytest or another xUnit). This file is for the people who maintain
it; agents read `SKILL.md` and never load this file.

## Layout

```
SKILL.md        the rules every run needs, plus a table of when to load each reference
references/     detail loaded on demand: assertions, doubles, flaky tests, mutation testing,
                code with learned models, tradeoffs
evals/          test cases for the skill itself (see below)
```

Claude Code loads the skill automatically when a task matches the `description` in
`SKILL.md`, or explicitly with `/testing`.

## Changing the skill

- Keep `SKILL.md` under 500 lines and 5,000 tokens. Move detail to a reference, and add a row to
  its "References" table that says when to load it.
- Put the corrections to mistakes agents actually make in `SKILL.md`, where they are read before
  the situation arises, not in a reference.
- Write for any repository: project specifics belong in that project's AGENTS.md or README.
- Validate the format after every change:

  ```bash
  uvx --from skills-ref agentskills validate path/to/testing
  ```

## Evals

Each directory in `evals/` is one case:

- `prompt.md` is the request, often in Italian as users write it;
- `place-files.sh` copies the toy `ledger` project from `files/` into a fresh workspace;
- `graders/*.md` hold one LLM-graded expectation each;
- `case.yaml` states the expected outcome.

Some fixture projects are deliberately flawed: do not lint or "fix" them.
When a rule changes, add or update the case that exercises it and compare runs with and without
the change.

## Sources

The rules are distilled from the articles below (October 2026). Re-read one when a rule needs its
original argument, or when a source is updated.

### martinfowler.com/testing (the Testing Guide, all entries)

| Topic | Entries |
|---|---|
| Goal | [Self Testing Code](https://martinfowler.com/bliki/SelfTestingCode.html) · [Test Driven Development](https://martinfowler.com/bliki/TestDrivenDevelopment.html) · [Specification By Example](https://martinfowler.com/bliki/SpecificationByExample.html) |
| Kinds of tests | [Test Pyramid](https://martinfowler.com/bliki/TestPyramid.html) · [The Practical Test Pyramid](https://martinfowler.com/articles/practical-test-pyramid.html) (Vocke) · [Testing Strategies in a Microservice Architecture](https://martinfowler.com/articles/microservice-testing/fallback.html) (Clemson; the infodeck text lives at `fallback.html`) · [On the Diverse and Fantastical Shapes of Testing](https://martinfowler.com/articles/2021-test-shapes.html) |
| Classification | [Unit Test](https://martinfowler.com/bliki/UnitTest.html) · [Integration Test](https://martinfowler.com/bliki/IntegrationTest.html) · [Broad Stack Test](https://martinfowler.com/bliki/BroadStackTest.html) · [Component Test](https://martinfowler.com/bliki/ComponentTest.html) · [Subcutaneous Test](https://martinfowler.com/bliki/SubcutaneousTest.html) · [Story Test](https://martinfowler.com/bliki/StoryTest.html) · [Business Facing Test](https://martinfowler.com/bliki/BusinessFacingTest.html) · [Contract Test](https://martinfowler.com/bliki/ContractTest.html) · [Threshold Test](https://martinfowler.com/bliki/ThresholdTest.html) |
| Implementation | [Test Double](https://martinfowler.com/bliki/TestDouble.html) · [Mocks Aren't Stubs](https://martinfowler.com/articles/mocksArentStubs.html) · [Xunit](https://martinfowler.com/bliki/Xunit.html) · [xUnit Test Patterns](https://martinfowler.com/books/meszaros.html) · [Goto Fail, Heartbleed, and Unit Testing Culture](https://martinfowler.com/articles/testing-culture.html) (Bland) · [Eradicating Non-Determinism in Tests](https://martinfowler.com/articles/nonDeterminism.html) · [Test Cancer](https://martinfowler.com/bliki/TestCancer.html) · [Test Coverage](https://martinfowler.com/bliki/TestCoverage.html) · [The Rise of Test Impact Analysis](https://martinfowler.com/articles/rise-test-impact-analysis.html) (Hammant) · [Is TDD Dead?](https://martinfowler.com/articles/is-tdd-dead/) · [Page Object](https://martinfowler.com/bliki/PageObject.html) · [Self Initializing Fake](https://martinfowler.com/bliki/SelfInitializingFake.html) · [Humble Object](https://martinfowler.com/bliki/HumbleObject.html) · [Modern Mocking Tools and Black Magic](https://martinfowler.com/articles/modernMockingTools.html) · [Clock Wrapper](https://martinfowler.com/bliki/ClockWrapper.html) · [Object Mother](https://martinfowler.com/bliki/ObjectMother.html) · [Testing Resource Pools](https://martinfowler.com/bliki/TestingResourcePools.html) |
| Beyond automation | [QA in Production](https://martinfowler.com/articles/qa-in-production.html) · [Exploratory Testing](https://martinfowler.com/bliki/ExploratoryTesting.html) · [Domain-Oriented Observability](https://martinfowler.com/articles/domain-oriented-observability.html) · [Synthetic Monitoring](https://martinfowler.com/bliki/SyntheticMonitoring.html) |

### Beyond the Testing Guide

| Topic | Sources |
|---|---|
| Shapes and mocks | Kent C. Dodds, [The Testing Trophy](https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications), [Write tests](https://kentcdodds.com/blog/write-tests) · James Shore, [Testing Without Mocks](https://www.jamesshore.com/v2/projects/nullables/testing-without-mocks) · Vladimir Khorikov, enterprisecraftsmanship.com ("When to Mock", "Unit Testing Dependencies") |
| Test quality | Kent Beck, [Test Desiderata](https://testdesiderata.com/) and "Composable Tests" (newsletter, Nov 2025) · Google, [Practical Mutation Testing at Scale](https://homes.cs.washington.edu/~rjust/publ/practical_mutation_testing_tse_2021.pdf) and [Does mutation testing improve testing practices?](https://arxiv.org/abs/2103.07189) · *Software Engineering at Google*, ch. 11 and 14, for test sizes · [ApprovalTests](https://approvaltests.com/) |
| Property-based testing | Hillel Wayne: [Finding Property Tests](https://www.hillelwayne.com/post/contract-examples/), [Property Testing Complex Inputs](https://www.hillelwayne.com/post/property-testing-complex-inputs/), [Hypothesis Oracles](https://www.hillelwayne.com/post/hypothesis-oracles/), [PBT + Contracts](https://www.hillelwayne.com/post/pbt-contracts/), [Metamorphic Testing](https://www.hillelwayne.com/post/metamorphic-testing/), [Cross-Branch Testing](https://www.hillelwayne.com/post/cross-branch-testing/), [A Bunch of Tests](https://www.hillelwayne.com/post/a-bunch-of-tests/), [Unit Tests Are Not Tests](https://www.hillelwayne.com/post/unit-tests-are-not-tests/) |
| Agents writing tests | Kent Beck, [Augmented Coding: Beyond the Vibes](https://tidyfirst.substack.com/p/augmented-coding-beyond-the-vibes) and the [BPlusTree3 CLAUDE.md](https://raw.githubusercontent.com/KentBeck/BPlusTree3/main/rust/docs/CLAUDE.md) · Meta, [TestGen-LLM](https://arxiv.org/abs/2402.09171) · Böckeler et al., [Exploring Generative AI](https://martinfowler.com/articles/exploring-gen-ai.html) memos (TDD with Copilot, TDD inside the agent loop, CCMenu quality, Harness Engineering, Codex example, unreliability, I still care about the code), [How far can we push AI autonomy](https://martinfowler.com/articles/pushing-ai-autonomy.html), [Are Harnesses Worth the Cost?](https://martinfowler.com/articles/are-harnesses-worth-the-cost.html) (Jain), [Maintainability sensors for coding agents](https://martinfowler.com/articles/sensors-for-coding-agents.html) |
| Evals for model outputs | Hamel Husain, [Your AI Product Needs Evals](https://hamel.dev/blog/posts/evals/) and [Evals FAQ](https://hamel.dev/blog/posts/evals-faq/) (with Shreya Shankar) · Husain and Shankar, [Building eval systems](https://www.lennysnewsletter.com/p/building-eval-systems-that-improve) · Eugene Yan, [Evaluating LLM-Evaluators](https://eugeneyan.com/writing/llm-evaluators/), [An LLM-as-Judge Won't Save the Product](https://eugeneyan.com/writing/eval-process/) |
| Testing in production | Charity Majors, [I test in prod](https://increment.com/testing/i-test-in-production/) |

### Out of scope

Covered by the sources but left out of the skill: team testing culture and adoption, test impact
analysis infrastructure, Page Objects for web UIs, synthetic monitoring and production
observability, and the internals of LLM judges.
