# Domain Pitfalls

**Domain:** typstR v1.1 (reliability, diagnostics, onboarding polish in an existing R + Quarto + Typst package)  
**Researched:** 2026-03-31  
**Scope:** New v1.1 risk surface only (validation/diagnostics/onboarding/performance), not re-research of shipped v1.0 core features.

## Critical Pitfalls

### Pitfall 1: Validator/Renderer Drift (Checks pass, `quarto render` still fails)
**What goes wrong:** Pre-render validation rules diverge from Quarto/Typst runtime behavior, so diagnostics claim “ready” while render fails on real projects.

**Why it happens:**
- Validation logic is implemented as an independent rule set instead of being anchored to real render invariants.
- Rules are duplicated across helpers, diagnostics, and tests.
- Brownfield evolution: templates/extension change, validator is not updated in lockstep.

**Consequences:** False confidence, support load spike, trust loss in diagnostics.

**Prevention:**
- Define a single validation contract sourced from actual render inputs (resolved input file, effective project root, extension presence, metadata wiring expectations).
- Add fixture tests that run **both** validator and render and assert agreement (`validator fails` <-> `render fails`).
- Treat any validator/render disagreement as a regression class with dedicated test fixtures.

**Detection (warning signs):**
- Bug reports saying “validation passed but Quarto failed.”
- Frequent hotfixes to diagnostic messages after render failures.
- New rules added without corresponding end-to-end fixtures.

---

### Pitfall 2: “Looks green” diagnostics because skipped checks are reported as success
**What goes wrong:** Dependency-dependent checks (Quarto/Typst availability, version compatibility) get skipped but summary still reports pass.

**Why it happens:** Binary pass/fail model with no explicit `skipped/unknown` state.

**Consequences:** Users on constrained machines (CI/CRAN/no-Quarto) get misleading readiness signals.

**Prevention:**
- Use structured diagnostics with explicit status: `pass | warn | fail | skip`.
- Introduce gate semantics in requirements: render wrappers can proceed only when no `fail` and no required check is `skip`.
- Make summary counts by severity/status mandatory.

**Detection (warning signs):**
- Reports like “No issues found” when Quarto is unavailable.
- Any check that swallows tool invocation errors and still returns success.

---

### Pitfall 3: Path-resolution mismatch (CRAN + Quarto + Typst integration edge)
**What goes wrong:** Validator checks files relative to caller cwd, but Quarto renders relative to project root/doc context. Logos, bibliography, and `_extensions/` appear valid in one context and fail in another.

**Why it happens:** Render-context resolution is not centralized.

**Consequences:** Intermittent failures, especially in nested directories and CI runners.

**Prevention:**
- Requirement: one canonical “effective render root” resolver used by validator and render wrapper.
- Validate `_extensions/typstR`, bibliography paths, and branding assets relative to that resolved root.
- Add fixtures for: file input path, directory input path, nested project, and `_quarto.yml` root detection.

**Detection (warning signs):**
- `Unknown format` or missing asset errors only in CI/subdirectories.
- Validation passes from package root but fails from project folder.

---

### Pitfall 4: CRAN-safe behavior regresses while improving diagnostics/onboarding
**What goes wrong:** New diagnostics or onboarding examples invoke external tooling unguarded during checks/docs/tests.

**Why it happens:** Local dev machines have Quarto; CRAN machines often do not.

**Consequences:** `R CMD check` failures, delayed release, patch churn.

**Prevention:**
- Keep Quarto-dependent paths lazily evaluated and guard examples/vignettes/tests.
- Ensure diagnostics degrade truthfully when Quarto is absent (clear `skip/warn`, not hard crash in package load paths).
- Maintain a CRAN-like CI job (no Quarto installed) as a release gate.

**Detection (warning signs):**
- Local checks pass; CRAN/win-builder fails on missing Quarto.
- New vignette chunk or test starts rendering by default.

---

### Pitfall 5: Quarto-bundled Typst version incompatibility masked by diagnostics
**What goes wrong:** Diagnostics verify “Quarto exists” but not whether its bundled Typst version supports syntax/features used by templates.

**Why it happens:** Availability checks are implemented without version constraints.

**Consequences:** Users pass checks but hit cryptic Typst compile errors.

**Prevention:**
- Check and report Quarto version and effective Typst compatibility expectations.
- Fail early when below minimum supported Quarto/Typst compatibility floor.
- Include min-supported and latest-supported Quarto in CI matrix.

**Detection (warning signs):**
- Version-specific bug reports (“works on my Quarto, fails on yours”).
- Syntax-related Typst failures after Quarto upgrades.

---

### Pitfall 6: False confidence from existence-only tests (diagnostics miss semantic failures)
**What goes wrong:** Tests assert “PDF exists” or “render did not error,” but do not verify critical metadata/diagnostic truthfulness.

**Why it happens:** Existence checks are cheap; semantic assertions are deferred.

**Consequences:** Missing author metadata, wrong report number, dropped acknowledgements, or broken remediation hints can ship unnoticed.

**Prevention:**
- Add semantic regression fixtures for required v1.1 diagnostics and top onboarding fields.
- Assert machine-readable diagnostic codes and locations.
- Add at least one content-level verification path (e.g., text extraction-based checks for key fields) for first-run templates.

**Detection (warning signs):**
- Test suite passes while users report missing metadata in output.
- Diagnostic message text changes without any failing tests.

---

### Pitfall 7: Performance work that invalidates correctness guarantees
**What goes wrong:** Caching, shortcutting, or memoization in helper/render paths returns stale diagnostics after file or config changes.

**Why it happens:** Performance changes applied before defining invalidation keys and correctness invariants.

**Consequences:** Fast but wrong checks; intermittent “fixed but still failing/passing” behavior.

**Prevention:**
- Requirement: no optimization without measurable baseline + correctness guardrails.
- Cache keys must include file path + mtime/hash + relevant tool/version context.
- Add invalidation tests (modify YAML/assets and ensure diagnostics update immediately).

**Detection (warning signs):**
- Re-running validation without restart gives outdated results.
- Performance PRs with no benchmark and no invalidation tests.

## Moderate Pitfalls

### Pitfall 1: Diagnostics become prose-only (not machine-testable)
**What goes wrong:** Messages are human-readable but lack stable diagnostic IDs, severity, and location fields.

**Prevention:** define a minimal diagnostic schema (`id`, `severity`, `summary`, `details`, `location`, `remediation`, `evidence`) and enforce in tests.

### Pitfall 2: Validation rules overfit starter templates
**What goes wrong:** Rules assume only shipped scaffold structure; valid user manuscripts are flagged incorrectly.

**Prevention:** include “custom layout” fixtures and enforce that validators focus on invariants, not cosmetic preferences.

### Pitfall 3: Remediation hints are generic/non-actionable
**What goes wrong:** Hints say “fix metadata” without pointing to exact key/path/value.

**Prevention:** each fail-level rule must include concrete next action and target location (file + YAML key).

## Minor Pitfalls

### Pitfall 1: Non-deterministic diagnostic ordering
**What goes wrong:** Diagnostics appear in different order across runs, causing flaky snapshots and noisy reviews.

**Prevention:** stable sort by severity, file, line, rule id.

### Pitfall 2: Micro-optimizing unmeasured paths
**What goes wrong:** Complexity added to cold paths with no real user impact.

**Prevention:** define measurable v1.1 performance targets and benchmark only hottest helper/render paths.

## Current Repo Signals to Treat as v1.1 Risk Inputs

- `tests/testthat/test-yaml-integration.R` is currently dominated by render-success/file-exists assertions; semantic output checks are limited.  
- `R/render.R` currently gates on Quarto availability but has no integrated `validate_manuscript()` path yet, increasing risk of validator/render drift if added ad hoc.  
- No dedicated `R/validation.R` implementation is present in current tree, so v1.1 adds a new reliability surface that needs explicit contract-first design.

## Pitfall-to-Planning Mapping (requirements → roadmap → phase verification)

| Pitfall | Address in Requirements | Address in Roadmap | Mandatory Phase Verification |
|---|---|---|---|
| Validator/renderer drift | Add requirement for shared render-context contract and validator/render agreement fixtures | Early phase: diagnostics contract + rule engine before broad rule expansion | Matrix of fixtures asserting validator outcome matches render outcome |
| Skipped checks reported as success | Add status model (`pass/warn/fail/skip`) and gate semantics | Same early diagnostics phase | Unit tests for status aggregation; fail release if required checks are `skip` |
| Path-resolution mismatch | Require canonical render-root resolver used by all checks | Validation expansion phase | Nested-path integration tests (`input` as file, dir, project root) |
| CRAN safety regression | Require CRAN-safe behavior when Quarto absent; no hard failures in load-time paths | Hardening phase before milestone close | CI job without Quarto + `R CMD check` clean |
| Quarto/Typst version mismatch | Require version floor checks tied to extension compatibility | Validation expansion phase | Version-matrix tests (minimum + current supported Quarto) |
| Existence-only false confidence | Require semantic assertions for key onboarding/metadata invariants | Verification phase after rule implementation | Content-level regression tests + diagnostic ID snapshots |
| Performance optimization breaks correctness | Require benchmark + correctness invariant for each optimization | Final performance phase | Before/after benchmarks + cache invalidation tests |
| Prose-only diagnostics | Require structured diagnostic schema with stable IDs | Diagnostics contract phase | Schema conformance tests and snapshot by diagnostic ID |
| Overfit validation to starter template | Require invariant-focused rules with custom-manuscript fixtures | Validation expansion phase | Mixed fixture set: scaffolded + non-scaffolded projects |
| Weak remediation hints | Require file/key-specific remediation text for fail-level diagnostics | Diagnostics UX phase | Rule-level tests asserting presence of actionable remediation fields |

## Phase-Specific Warnings for v1.1 Planning

| Phase Topic | Likely Pitfall | Mitigation |
|---|---|---|
| Diagnostics contract | Prose-only messages, no stable IDs | Lock schema first; reject rules without IDs/severity/location |
| Validation coverage expansion | Rule count grows faster than confidence | Add one fixture per new fail-level rule; require render agreement tests |
| Onboarding scaffold polish | Template edits break first render path | First-run smoke test for each `create_*()` scaffold on clean tempdir |
| Performance tuning | Caching introduces stale outputs | Add invalidation tests and benchmark gates before merge |
| Milestone closure | “Most tests pass” but blind spots remain | Run cross-phase audit focused on false-confidence classes |

## Sources

### Official / High-confidence
- Quarto extension management (`_extensions` project-local model): https://quarto.org/docs/extensions/managing.html
- Quarto Typst format docs: https://quarto.org/docs/output-formats/typst.html
- Quarto custom Typst formats (template partial workflow): https://quarto.org/docs/output-formats/typst-custom.html
- Quarto author/affiliation metadata model: https://quarto.org/docs/journals/authors.html
- Typst format options reference (including citation/processing options): https://quarto.org/docs/reference/formats/typst.html
- R Extensions manual (CRAN check behavior, package checks): https://cran.r-project.org/doc/manuals/r-release/R-exts.html
- CRAN Repository Policy: https://cran.r-project.org/web/packages/policies.html

### Ecosystem evidence / Medium-confidence but directly relevant
- Quarto discussion on extension path scope (no global extension install): https://github.com/quarto-dev/quarto-cli/discussions/8098
- Quarto discussion on bundled Typst upgrade cadence/version lock concerns: https://github.com/orgs/quarto-dev/discussions/11956
- Quarto discussion on YAML argument/Typst template passthrough gotchas: https://github.com/quarto-dev/quarto-cli/discussions/11459
- Quarto discussion on Typst citations/citeproc behavior nuances: https://github.com/orgs/quarto-dev/discussions/9761

### Internal codebase evidence (this repo)
- `R/render.R`
- `R/utils.R`
- `tests/testthat/test-yaml-integration.R`
- `tests/testthat/test-render-guards.R`
- `inst/quarto/extensions/typstR/typst-show.typ`

