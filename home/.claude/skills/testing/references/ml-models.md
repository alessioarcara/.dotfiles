# Testing code that contains learned models

Read this when the repository contains neural networks or another learned component: what goes
in unit, integration, e2e and evals, and how to handle outputs that are only statistically right.

The method comes from the LLM-evals literature (Husain and Shankar; Yan); the vision examples
apply it to computer-vision code.

## Two different questions

- **Is the code correct?** Deterministic, pass or fail, in the test suite.
- **Is the model good enough?** A rate over many examples, measured in an eval. A pass rate below
  100% can be acceptable; where to draw the line is a product decision. An eval that always
  passes 100% is not challenging the system.

Do not mix them. A metric threshold in the commit suite is flaky by construction, which is why
e2e tests compare with committed golden outputs on a small input set and never with metric
thresholds. Model quality then needs its own place.

## Where each check goes

| Check | Layer | Example (vision) |
|---|---|---|
| Shapes, dtypes, device moves, parameter counts of a randomly initialised model | unit | backbone output is `B x C x H/32 x W/32` |
| Pure pre/post-processing (resize, normalisation, box decoding, NMS) with hand-worked values and properties | unit | decoded boxes lie inside the image |
| Metamorphic relations on the model in `eval()` mode | unit or integration | batch split, flip, padding invariance |
| Loading real weights, exporting (ONNX, torch.export), backend parity within tolerance | integration, one point each | ONNX Runtime output close to PyTorch within `atol` |
| A documented journey through the CLI | e2e, golden files | `<cli> run config.yaml` on 2 images |
| Accuracy, recall, error rates per failure mode, on real weights | `evals/`, outside the suite | recall per object size on the curated set |

A model built without weights checks plumbing, not quality: a random model passes every shape
test while quality regresses. Tests do not replace an eval run on real weights.

## The eval layer

- A curated, versioned set: about 100 or more examples covering the core cases, every past
  failure, and known edge cases. Version it with the code, weights and config that produced each
  result.
- It runs on a cadence or on a significant change (new weights, new preprocessing, an export
  change), with its own command, not in `pytest`.
- Results are stored outside CI and tracked over time: per failure mode, never a single
  composite number. A single mAP hides a regression on one slice.
- Gate a release on the release-blocking checks. With few examples, report a confidence interval
  and act when its lower bound crosses the threshold.
- Retire or harden evals that always pass; scores across a changed eval set are not comparable,
  and that is fine.

## Start from error analysis, not from imagined metrics

Husain and Shankar spend 60-80% of eval effort here:

1. Look at about 100 outputs: random ones first, then outliers (for vision, prediction overlays).
2. Write a free-form note on the first thing that went wrong in each (open coding).
3. Group the notes into fewer than 10 failure modes (axial coding) and count them.
4. Fix plain bugs first (preprocessing, resize, label mapping). A deterministic bug gets a
   classic regression test.
5. Write an eval only for failures that persist and that you will iterate on. Add the simplest
   input that still fails to the eval set.

## When the oracle is itself a model or a metric

An automatic judge (a metric, an auto-labeller, a classifier, an LLM judge) is a test double for
a human expert, and must be validated like one:

- 100-200 expert labels per failure mode, split train 10-20% / dev 40-45% / test 40-45%, with
  30-50 examples of each class in dev and test.
- Report true-positive and true-negative rates (or precision/recall, Cohen's kappa), never raw
  accuracy on imbalanced data.
- If the test score is far below dev, assume overfitting and get a fresh test set.
- Correct the measured rate for the judge's known error rates.
- Never let a model produce the labels used to validate the judge.

## Overfitting to the eval set

Tuning a threshold, a post-processing parameter (NMS IoU, score cut-off) or a prompt on the
examples you report on overfits, even without training on them. Keep a held-out set, and replace
it once it has been used for decisions.

## Runtime checks

Inputs and outputs of a model in production can be validated inline: shape, range, NaN, empty
detections where some are required. These checks are deterministic, versioned and fast; a false
positive is a bug. Keep them separate from evals, which run asynchronously and never block.
