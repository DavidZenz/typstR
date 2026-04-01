# Phase 8: Measured Performance Optimization - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-01
**Phase:** 08-measured-performance-optimization
**Areas discussed:** Hotspot targeting, Benchmark scenario design, Semantics-preservation guardrails, Performance regression policy

---

## Hotspot targeting

| Option | Description | Selected |
|--------|-------------|----------|
| Broad opportunistic cleanup | Apply many small performance tweaks across helpers without strict hotspot ranking | |
| **Measured top-hotspot-first (recommended)** | Profile/benchmark first, then optimize only the highest-cost helper/render hotspots | ✓ |
| Caching-first strategy | Introduce memoization across validation/render paths to reduce repeated work | |

**User's choice:** Measured top-hotspot-first strategy.
**Notes:** [auto] Selected recommended default. Keeps scope tied to measurable wins and avoids speculative churn.

---

## Benchmark scenario design

| Option | Description | Selected |
|--------|-------------|----------|
| Micro-bench only | Benchmark individual helper functions only, no integration timing | |
| **Two-layer benchmark strategy (recommended)** | Use focused micro-benchmarks for hotspots plus guarded integration timing scenarios for stable end-to-end paths | ✓ |
| Integration-only timing | Time full flows only without function-level hotspot attribution | |

**User's choice:** Two-layer benchmark strategy (micro + guarded integration).
**Notes:** [auto] Selected recommended default. Balances attribution quality with user-visible flow measurement.

---

## Semantics-preservation guardrails

| Option | Description | Selected |
|--------|-------------|----------|
| Best-effort semantic checks | Validate only high-level success/failure while optimizing for speed | |
| **Strict contract preservation (recommended)** | Require diagnostics/output semantic equivalence assertions for every optimized path | ✓ |
| Defer correctness checks | Land perf edits first, add semantic checks later | |

**User's choice:** Strict contract-preservation guardrails.
**Notes:** [auto] Selected recommended default. Maintains locked behavior from Phases 5-7 while optimizing internals.

---

## Performance regression policy

| Option | Description | Selected |
|--------|-------------|----------|
| Manual ad-hoc perf checks | Measure occasionally during development only | |
| **Lightweight regression checks with calibrated tolerance (recommended)** | Add stable benchmark scenarios and variance-aware thresholds to detect backslides | ✓ |
| Hard strict benchmark gate everywhere | Enforce one global strict threshold on every environment | |

**User's choice:** Lightweight regression checks with calibrated tolerance.
**Notes:** [auto] Selected recommended default. Detects regressions without introducing flaky CI behavior.

---

## the agent's Discretion

- Exact benchmark fixture implementation details (loop counts, warmup policy, fixture composition) once baseline variance is measured.
- Exact location and naming of benchmark helper utilities/tests, as long as they remain phase-scoped and traceable.

## Deferred Ideas

None.
