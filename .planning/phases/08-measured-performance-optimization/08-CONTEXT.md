# Phase 8: Measured Performance Optimization - Context

**Gathered:** 2026-04-01
**Status:** Ready for planning

<domain>
## Phase Boundary

Improve measurable runtime in selected helper/render hotspots while preserving output semantics, diagnostics semantics, and user-facing behavior for equivalent inputs. This phase is optimization and regression-guard work only; it does not add new features, formats, or validation capabilities.

</domain>

<decisions>
## Implementation Decisions

### Hotspot targeting and optimization scope
- **D-01:** Performance changes MUST start from measured baseline data and target only the top helper/render hotspots with reproducible cost.
- **D-02:** Prioritize hotspots in the existing render preflight and helper paths (`render_pub()` preflight chain, environment probes, scaffold helper duplication) before introducing new abstractions.
- **D-03:** Optimizations MUST remove redundant work in-call (duplicate filesystem/version/probe work) rather than adding long-lived caches that risk stale correctness.

### Benchmark design and evidence standards
- **D-04:** Use a two-layer benchmark strategy: (a) focused helper/preflight micro-bench scenarios and (b) guarded integration timing scenarios for scaffold+validate/render paths where stable.
- **D-05:** Benchmark scenarios MUST be deterministic and low-noise (fixed fixture shape, controlled temp dirs, bounded iteration budget) so before/after comparisons are attributable.
- **D-06:** Keep benchmark tooling in dev/test scope (not runtime-required), consistent with CRAN-safe and Quarto-optional test posture.

### Semantics-preservation contract
- **D-07:** For equivalent inputs, optimized paths MUST preserve diagnostics codes/order/class behavior and rendered output behavior; speed gains cannot change contracts locked in Phases 5-7.
- **D-08:** Any optimization touching validation or render wrappers MUST carry paired regression assertions that prove semantic equivalence under both Quarto-present and Quarto-unavailable conditions.

### Performance regression guardrails
- **D-09:** Add lightweight regression checks for selected stable benchmark scenarios so future backslides are detectable.
- **D-10:** Guard thresholds/tolerances should be calibrated from observed baseline variance and documented in test/benchmark artifacts, avoiding flaky hard gates.

### Auto-mode resolution log
- **A-01:** [auto] Context absent — proceeded with new context capture for Phase 8.
- **A-02:** [auto] Selected all gray areas: hotspot targeting, benchmark scenario design, semantics guardrails, regression gate policy.
- **A-03:** [auto] Hotspot targeting → selected measured top-hotspot-first strategy (recommended default).
- **A-04:** [auto] Benchmark design → selected two-layer micro + guarded integration benchmark strategy (recommended default).
- **A-05:** [auto] Semantics guardrails → selected strict semantic-equivalence contract with paired regression assertions (recommended default).
- **A-06:** [auto] Regression policy → selected lightweight, variance-calibrated performance guardrails (recommended default).

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Milestone and requirement contract
- `.planning/ROADMAP.md` — Phase 8 goal, dependency boundary, and success criteria for measured gains with unchanged semantics.
- `.planning/REQUIREMENTS.md` — `PERF-01` active requirement and deferred performance requirements (`PERF-02`, `PERF-03`) that shape scope boundaries.
- `.planning/PROJECT.md` — v1.1 milestone constraints and explicit helper/render overhead reduction target.
- `.planning/STATE.md` — current sequencing context and explicit note to define low-noise benchmark scenarios/thresholds for Phase 8.

### Carry-forward phase contracts
- `.planning/phases/05-structured-diagnostics-foundation/05-CONTEXT.md` — stable diagnostics payload, code stability, and deterministic ordering constraints that optimizations must preserve.
- `.planning/phases/06-pre-render-environment-validation/06-CONTEXT.md` — shared preflight validator contract and render integration constraints.
- `.planning/phases/07-first-run-onboarding-reliability/07-CONTEXT.md` — helper-driven cross-format reliability contract and starter/render assumptions to avoid regressing.
- `.planning/phases/07-first-run-onboarding-reliability/07-VERIFICATION.md` — verified guarded integration posture and regression suites currently protecting onboarding/validation/render behavior.

### Research and architecture guidance
- `.planning/research/ARCHITECTURE.md` — measured-only optimization guidance, anti-patterns for unmeasured refactors, and validation-overhead cautions.
- `.planning/research/FEATURES.md` — performance requirement decomposition (`TS-PERF-01`, `TS-PERF-02`, `DF-PERF-01`) and benchmark-baseline expectation.
- `.planning/research/PITFALLS.md` — performance-vs-correctness risks (stale-cache hazards) and mitigation expectations.
- `.planning/research/STACK.md` — benchmark tooling posture (`bench` in Suggests) and avoid-default-caching guidance.
- `.planning/research/SUMMARY.md` — sequencing rationale: optimize after contracts stabilize, with measurable gains only.

### Existing implementation references
- `R/render.R` — main wrapper call path (`render_pub()`, `render_working_paper()`) and preflight invocation point.
- `R/validation_environment.R` — environment probe pipeline and diagnostics construction hotspots likely relevant for optimization.
- `R/create_working_paper.R` — scaffold helper flow potentially containing repeated copy/probe patterns.
- `R/create_article.R` — parallel scaffold path for consistency/perf drift checks.
- `R/create_policy_brief.R` — parallel scaffold path for consistency/perf drift checks.
- `tests/testthat/test-render-guards.R` — payload-first guard expectations that performance edits must preserve.
- `tests/testthat/test-yaml-integration.R` — helper-driven cross-format integration matrix and guard patterns for Quarto-dependent paths.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `validate_render_environment()` already returns a structured report on success and emits diagnostics payloads on failure; this provides a stable semantic contract for optimization safety checks.
- `collect_environment_checks()` centralizes preflight checks (`probe_quarto`, `probe_typst`, `probe_quarto_floor`, `probe_extension`), making it a natural hotspot cluster to measure.
- `tests/testthat/test-yaml-integration.R` includes reusable scaffold specs (`.onboarding_scaffold_specs()`) that can seed stable integration benchmark fixtures.

### Established Patterns
- Quarto-dependent behavior is explicitly guarded (`skip_if_not(.quarto_available())`); performance scenarios must preserve this CRAN-safe posture.
- Diagnostics contracts are payload-first and deterministic; faster code must still emit equivalent `typstR_diagnostics_error` structures where applicable.
- Render wrapper behavior is intentionally centralized in `render_pub()`, so optimization should target shared paths once instead of format-specific forks.

### Integration Points
- Preflight call chain in `R/render.R` (`preflight_path` -> `validate_render_environment()` -> `resolve_input()`) is the primary helper/render optimization boundary.
- `R/validation_environment.R` probe functions are candidates for reducing duplicate path/version/process work while preserving check semantics.
- Regression and benchmark assertions should integrate with existing `tests/testthat` structure, adding targeted performance checks without weakening semantic suites.

</code_context>

<specifics>
## Specific Ideas

- Benchmark first, optimize second, then re-measure in the same scenarios; drop changes that do not produce measurable gains.
- Keep optimization edits narrow and explain invariants (what must remain identical) near changed code paths.
- Preserve the existing user truth contract: callers must still receive accurate diagnostics/report outcomes, never plausible-but-wrong fast paths.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 08-measured-performance-optimization*
*Context gathered: 2026-04-01*
