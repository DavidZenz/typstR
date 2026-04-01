# Phase 8: Measured Performance Optimization - Research

**Researched:** 2026-04-01  
**Domain:** R helper/render performance optimization with semantic contract preservation  
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

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

### Claude's Discretion
None specified in `08-CONTEXT.md`.

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| PERF-01 | User sees measurable improvement in selected helper/render hotspots with no output semantics changes. | Hotspot shortlist in `R/render.R`, `R/validation_environment.R`, and `R/create_*.R`; two-layer benchmark design; semantic-equivalence regression map against Phase 5–7 contracts. |
</phase_requirements>

## Summary

Phase 8 should optimize only measured hotspots in the preflight/render and scaffolding paths, with semantics locked by prior phases. Existing code points to three concrete candidate clusters: (1) preflight probe orchestration in `collect_environment_checks()`, (2) render preflight + input resolution handoff in `render_pub()`, and (3) duplicated scaffolding workflows across `create_working_paper()`, `create_article()`, and `create_policy_brief()`. The major cost risk is not raw CPU; it is repeated filesystem/process/version work that compounds across helper-driven workflows.

Carry-forward contracts are strict: diagnostics payload shape/codes/order from Phase 5, shared validator semantics from Phase 6, and helper-driven onboarding matrix behavior from Phase 7 must remain unchanged. Optimization is therefore constrained to internal work elimination and structure simplification, not behavior changes. Any change that affects emitted diagnostics, skip behavior, or wrapper outputs is out-of-contract for PERF-01.

Benchmarking should be split into deterministic micro-benchmarks (always runnable, no Quarto dependency) and guarded integration timing benchmarks (Quarto-dependent, skip-safe). This aligns with CRAN-safe posture and prevents noisy/flaky gates. The current environment lacks Quarto CLI and the `bench` package, so planning should include explicit dependency setup or guarded fallback paths.

**Primary recommendation:** Baseline and optimize `collect_environment_checks()` + `render_pub()` preflight pipeline first, then add calibrated regression checks that gate on relative slowdown while reusing existing semantic test suites.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| bench | 1.1.4 (Published 2025-01-16 UTC) | Deterministic micro-benchmarking (`mark`, memory/gc metrics) | R ecosystem standard for reproducible perf measurement; supports variance-aware analysis. |
| testthat | 3.3.2 (Published 2026-01-11 UTC) | Contract and regression checks | Existing project framework; already encodes Quarto-optional skip posture and diagnostics assertions. |
| withr | 3.0.2 (Published 2024-10-28 UTC) | Isolated tempdir and env control for low-noise scenarios | Already used in repo; avoids cross-test state leakage. |
| quarto (R pkg) | 1.5.1 (Published 2025-09-04 UTC) | Quarto availability/version checks and render integration | Existing dependency; integration benchmarks should reflect real wrapper path behavior. |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| fs | 2.0.1 (Published 2026-03-24 UTC) | Fast path/file operations for fixture setup | Creating deterministic benchmark fixtures and measuring I/O-heavy helper paths. |
| cli | 3.6.5 (Published 2025-04-23 UTC) | Diagnostics emission/assertion surface | Semantic parity checks on error classes/messages/hints when optimizing error paths. |
| yaml | 2.3.12 (Published 2025-12-10 UTC) | Extension manifest floor parsing behavior | Benchmarking/optimizing `required_quarto_floor()` and related manifest reads. |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `bench::mark()` | `system.time()` loops | `system.time()` is acceptable for quick ad-hoc local checks, but lacks robust iteration control, memory/gc metrics, and richer comparison output for regression gating. |
| Quarto-guarded integration timing | Always-on integration timing | Always-on timing is invalid on Quarto-missing environments and would break CRAN-safe posture. |
| Relative thresholds calibrated by variance | Hard absolute millisecond budgets | Absolute budgets are brittle across machines/runners and produce flaky performance gates. |

**Installation:**
```bash
Rscript -e 'install.packages(c("bench"))'
```

**Version verification (executed):**
```bash
Rscript -e 'db <- tools::CRAN_package_db(); pkgs <- c("cli","fs","quarto","yaml","testthat","withr","bench"); print(db[match(pkgs, db$Package), c("Package","Version","Published")], row.names = FALSE)'
```

## Architecture Patterns

### Recommended Project Structure
```text
tests/
├── testthat/
│   ├── helper-performance.R              # shared fixture builders + timing helpers
│   ├── test-performance-micro.R          # deterministic micro-bench scenarios
│   ├── test-performance-regression.R     # calibrated slowdown guardrails
│   ├── test-render-guards.R              # existing semantic contract checks
│   ├── test-validation-environment.R     # existing semantic contract checks
│   └── test-yaml-integration.R           # existing Quarto-guarded integration contract
└── testthat.R
```

### Pattern 1: Probe-Cluster Baseline Before Optimization
**What:** Benchmark `collect_environment_checks()` and sub-probes as one hotspot cluster before editing internals.  
**When to use:** First optimization wave; any change in `R/validation_environment.R`.  
**Example:**
```r
# Source: https://bench.r-lib.org/reference/mark.html
bench::mark(
  current = collect_environment_checks(path_fixture),
  iterations = 200,
  min_iterations = 50,
  check = FALSE
)
```

### Pattern 2: In-Call De-duplication, No Long-Lived Cache
**What:** Reuse computed values within a single call (normalized path, namespace checks, resolved manifest data), but do not persist across calls unless invalidation is explicit and tested.  
**When to use:** Optimizing validation/render preflight functions where stale cache risk is high.  
**Example:**
```r
# Source: repo pattern in R/validation_environment.R + Phase 8 D-03
# Do once per call, pass forward:
normalized_path <- normalize_validation_path(path)
checks <- collect_environment_checks(normalized_path)
# Avoid global memoise() or package-level cache without invalidation tests.
```

### Pattern 3: Semantic Equivalence Guard Around Perf Changes
**What:** Pair every optimization in render/validation paths with assertions on diagnostics class/code/order and behavior.  
**When to use:** Any edit touching `render_pub()`, `validate_render_environment()`, or diagnostics plumbing.  
**Example:**
```r
# Source: tests/testthat/test-validation-environment.R
standalone_codes <- vapply(standalone_condition$diagnostics, `[[`, character(1), "code")
render_codes <- vapply(render_condition$diagnostics, `[[`, character(1), "code")
expect_identical(render_codes, standalone_codes)
```

### Pattern 4: Quarto-Guarded Integration Timing
**What:** Time scaffold→validate→render paths only when Quarto is available; otherwise skip deterministically.  
**When to use:** Integration-tier perf checks and local calibration on supported setups.  
**Example:**
```r
# Source: https://testthat.r-lib.org/reference/skip.html and tests/testthat/test-yaml-integration.R
skip_if_not(requireNamespace("quarto", quietly = TRUE) && quarto::quarto_available())
```

### Anti-Patterns to Avoid
- **Unmeasured optimization refactors:** refactoring without baseline numbers creates churn and unverifiable claims.
- **Global memoized probe caches:** stale environment truth (especially Quarto/extension state) violates diagnostics correctness.
- **Hard fixed performance gate:** absolute thresholds cause cross-machine flakiness and hide true regressions.
- **Perf-only tests without semantic assertions:** can ship faster but incorrect diagnostics/output behavior.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Benchmark harness | Manual `for` loops with `system.time()` as the only artifact | `bench::mark()` + structured regression assertions | Better iteration control, memory/gc visibility, and comparable outputs for CI/PR review. |
| Quarto-dependent gating logic | Custom env-variable heuristics | testthat skip helpers (`skip_if_not`, `skip_on_cran`) | Preserves CRAN-safe, Quarto-optional posture already established in this repo. |
| Diagnostics parity checks | Message-string-only comparison | Existing class+payload assertions (`typstR_diagnostics_error`, code vectors, order) | Message text can evolve; payload contracts are locked by Phase 5/6. |
| Version/floor comparison | Regex-only version ordering logic | `quarto::quarto_available(min=...)` and structured floor evidence | Reduces custom parser bugs and keeps behavior aligned with Quarto package semantics. |

**Key insight:** For PERF-01, the unsafe path is custom infrastructure (timing harnesses, caching, and ad-hoc equivalence checks). Reuse existing stack/patterns and optimize only where measurable.

## Common Pitfalls

### Pitfall 1: Measuring failure-path speed instead of real hotspots
**What goes wrong:** Benchmarks run in environments without Quarto and mostly time early failure paths.  
**Why it happens:** Quarto CLI absence short-circuits probe and render behavior.  
**How to avoid:** Keep micro-benchmarks dependency-light; guard integration timing with Quarto checks and report skipped status explicitly.  
**Warning signs:** Integration benchmark always skipped; “speedup” only observed in no-Quarto mode.

### Pitfall 2: Breaking diagnostics contract while simplifying internals
**What goes wrong:** Faster code changes code order/class/details semantics.  
**Why it happens:** Optimizer focuses on control flow and removes/reorders checks without contract assertions.  
**How to avoid:** Re-run and extend Phase 5/6 payload-first tests whenever perf edits touch validation/render code.  
**Warning signs:** Failing code-vector equality assertions or changed deterministic ordering.

### Pitfall 3: Cache-induced stale correctness
**What goes wrong:** Cached probe results remain after filesystem/tool state changes.  
**Why it happens:** Persistent caches are introduced without invalidation design/tests.  
**How to avoid:** Restrict to in-call deduplication unless explicit invalidation contract is added and tested.  
**Warning signs:** Re-running validation after environment changes returns identical stale details.

### Pitfall 4: Flaky regression gates from absolute thresholds
**What goes wrong:** CI fails due to host variance, not true regressions.  
**Why it happens:** Hard-coded runtime budgets ignore machine jitter and external load.  
**How to avoid:** Use ratio-based thresholds calibrated from baseline variance, plus minimum sample size.  
**Warning signs:** High variance between adjacent runs, frequent non-reproducible perf failures.

## Code Examples

Verified patterns from official sources and current repo:

### Deterministic micro-benchmark with bounded iteration
```r
# Source: https://bench.r-lib.org/reference/mark.html
bench::mark(
  preflight = collect_environment_checks(project_path),
  min_iterations = 50,
  min_time = 0.5,
  check = FALSE
)
```

### Parameterized scenario matrix for benchmark coverage
```r
# Source: https://bench.r-lib.org/reference/press.html
bench::press(
  scenario = c("single-qmd", "missing-extension", "scaffolded-workingpaper"),
  {
    bench::mark(run_scenario(scenario), min_iterations = 30, check = FALSE)
  }
)
```

### Semantic equivalence assertion for optimized render path
```r
# Source: tests/testthat/test-validation-environment.R
standalone_condition <- expect_error(validate_render_environment(path), class = "typstR_diagnostics_error")
render_condition <- expect_error(render_pub(path, open = FALSE), class = "typstR_diagnostics_error")
expect_identical(
  vapply(render_condition$diagnostics, `[[`, character(1), "code"),
  vapply(standalone_condition$diagnostics, `[[`, character(1), "code")
)
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Ad-hoc helper/render timing without explicit PERF guardrails | Two-layer benchmark strategy (micro + guarded integration) with variance-calibrated regression checks | Phase 8 context (2026-04-01) | Enables measurable and reproducible optimization claims. |
| Message-centric failure checks as primary evidence | Payload-first deterministic diagnostics assertions (class + code + ordering) | Phases 5-6 (2026-03-31 to 2026-04-01) | Makes semantic regression detection robust during perf refactors. |
| Template-centric onboarding smoke tests | Helper-driven scaffold→validate→render matrix | Phase 7 (2026-04-01) | Provides realistic integration surfaces for Phase 8 timing scenarios. |

**Deprecated/outdated:**
- Broad opportunistic “cleanup for speed” without benchmark evidence.
- Long-lived cache-first optimization strategy for validation/render checks without correctness safeguards.

## Open Questions

1. **What exact baseline artifact should PERF-01 compare against?**
   - What we know: Requirement and roadmap reference v1.0 baseline; git tag `v1.0` exists.
   - What's unclear: Whether to compare against raw `v1.0` or phase-7-complete pre-optimization baseline in same environment.
   - Recommendation: Record both (`v1.0` historical + current pre-change baseline) and gate regressions against current pre-change baseline for CI stability.

2. **Where should tolerance thresholds be persisted?**
   - What we know: D-10 requires variance-calibrated thresholds and documentation.
   - What's unclear: Inline constants in tests vs dedicated benchmark-baseline artifact file.
   - Recommendation: Store thresholds in a small benchmark artifact (CSV/JSON) versioned with tests and referenced by regression checks.

3. **Should integration timing run in default CI or opt-in job?**
   - What we know: Current environment lacks Quarto CLI; Quarto-dependent tests are intentionally guarded.
   - What's unclear: CI availability of Quarto across all runners.
   - Recommendation: Keep integration timing in a dedicated Quarto-enabled job; keep micro-bench/perf regression logic runnable without Quarto.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Rscript | Micro benchmarks + test execution | ✓ | 4.5.3 | — |
| quarto R package | Validator/render wrappers and version checks | ✓ | 1.5.1 | — |
| Quarto CLI binary (`quarto`) | Guarded integration timing scenarios and real render flow timing | ✗ | — | Skip integration timing; run micro benchmarks + semantic guards only |
| bench package | Standard micro-benchmark harness for PERF-01 evidence | ✗ | — | Temporary local-only `system.time()` exploration (non-gating) |
| testthat | Regression and semantic parity checks | ✓ | 3.3.2 | — |
| withr | Fixture isolation for deterministic scenarios | ✓ | 3.0.2 | — |

**Missing dependencies with no fallback:**
- None (phase can proceed with guarded subset), but full PERF-01 evidence quality is reduced without `bench` + Quarto CLI.

**Missing dependencies with fallback:**
- Quarto CLI (integration timing can be skipped safely).
- bench package (use non-gating exploratory timing until installed).

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | testthat 3.3.2 |
| Config file | `DESCRIPTION` (`Config/testthat/edition: 3`) + `tests/testthat.R` |
| Quick run command | `Rscript -e 'testthat::test_file("tests/testthat/test-performance-micro.R")'` |
| Full suite command | `Rscript -e 'testthat::test_local(".", filter = "performance|render-guards|validation-environment|yaml-integration|scaffolding")'` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| PERF-01 | Selected hotspots show measurable runtime improvement vs baseline | benchmark regression | `Rscript -e 'testthat::test_file("tests/testthat/test-performance-regression.R")'` | ❌ Wave 0 |
| PERF-01 | Optimized validation/render paths preserve diagnostics class+codes+ordering | unit/integration | `Rscript -e 'testthat::test_file("tests/testthat/test-validation-environment.R"); testthat::test_file("tests/testthat/test-render-guards.R")'` | ✅ |
| PERF-01 | Helper-driven scaffold→validate→render semantics unchanged under Quarto-enabled conditions | guarded integration | `Rscript -e 'testthat::test_file("tests/testthat/test-yaml-integration.R")'` | ✅ (guarded) |

### Sampling Rate
- **Per task commit:** `Rscript -e 'testthat::test_file("tests/testthat/test-validation-environment.R"); testthat::test_file("tests/testthat/test-render-guards.R")'`
- **Per wave merge:** `Rscript -e 'testthat::test_local(".", filter = "validation-environment|render-guards|yaml-integration|scaffolding|performance")'`
- **Phase gate:** Quarto-enabled run of perf regression + integration timing + semantic suites must pass before `/gsd:verify-work`.

### Wave 0 Gaps
- [ ] `tests/testthat/helper-performance.R` — shared deterministic fixture/timing helpers.
- [ ] `tests/testthat/test-performance-micro.R` — hotspot micro-bench scenarios for preflight/render helper paths.
- [ ] `tests/testthat/test-performance-regression.R` — calibrated slowdown guardrails with documented tolerance.
- [ ] Framework install: `Rscript -e 'install.packages("bench")'`.

## Sources

### Primary (HIGH confidence)
- Repo context and contracts:
  - `.planning/phases/08-measured-performance-optimization/08-CONTEXT.md`
  - `.planning/REQUIREMENTS.md`
  - `.planning/ROADMAP.md`
  - `.planning/STATE.md`
  - `.planning/phases/05-structured-diagnostics-foundation/05-CONTEXT.md`
  - `.planning/phases/06-pre-render-environment-validation/06-CONTEXT.md`
  - `.planning/phases/06-pre-render-environment-validation/06-VERIFICATION.md`
  - `.planning/phases/07-first-run-onboarding-reliability/07-CONTEXT.md`
  - `.planning/phases/07-first-run-onboarding-reliability/07-VERIFICATION.md`
- Repo implementation and tests:
  - `R/render.R`
  - `R/validation_environment.R`
  - `R/create_working_paper.R`
  - `R/create_article.R`
  - `R/create_policy_brief.R`
  - `R/diagnostics.R`
  - `tests/testthat/test-validation-environment.R`
  - `tests/testthat/test-render-guards.R`
  - `tests/testthat/test-yaml-integration.R`
  - `tests/testthat/test-scaffolding.R`
- Official docs:
  - https://bench.r-lib.org/reference/mark.html
  - https://bench.r-lib.org/reference/press.html
  - https://testthat.r-lib.org/reference/skip.html
  - https://quarto-dev.github.io/quarto-r/reference/quarto_available.html
  - https://quarto-dev.github.io/quarto-r/reference/quarto_version.html
  - https://cran.r-project.org/web/packages/policies.html
- Version verification command output (executed):
  - `Rscript -e 'db <- tools::CRAN_package_db(); ...'` for cli/fs/quarto/yaml/testthat/withr/bench

### Secondary (MEDIUM confidence)
- Existing milestone research artifacts:
  - `.planning/research/STACK.md`
  - `.planning/research/ARCHITECTURE.md`
  - `.planning/research/FEATURES.md`
  - `.planning/research/PITFALLS.md`
  - `.planning/research/SUMMARY.md`

### Tertiary (LOW confidence)
- None.

## Metadata

**Confidence breakdown:**
- Standard stack: **HIGH** — versions validated via CRAN package DB command and aligned with current repo.
- Architecture: **HIGH** — directly grounded in current code/test structure and locked phase decisions.
- Pitfalls: **MEDIUM-HIGH** — strongly supported by current contracts and environment audit; exact tolerance values still require empirical baseline runs.

**Research date:** 2026-04-01  
**Valid until:** 2026-05-01 (30 days; benchmark tooling and package versions can drift)
