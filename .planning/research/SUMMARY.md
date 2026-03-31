# Project Research Summary

**Project:** typstR
**Domain:** R package + Quarto extension + Typst templates for publication workflows
**Researched:** 2026-03-31
**Confidence:** HIGH

## Executive Summary

typstR v1.1 is a reliability and onboarding polish milestone, not a feature-surface expansion. The research converges on one approach: keep the existing architecture (R wrappers + bundled Quarto extension + Typst templates), then harden it with a diagnostics-first validation layer that runs before render. Expert practice in this space is to fail fast with actionable remediation, keep extension/runtime checks explicit, and avoid introducing new runtime frameworks when existing `cli`/`quarto`/`fs`/`yaml` already cover the domain.

The recommended implementation sequence is contract-first: define structured diagnostics and a shared validation context, then wire validation into render gates, then consolidate scaffolding and template defaults for first-run success, and only then optimize measured hotspots. This order minimizes validator/render drift, reduces false confidence from skipped checks, and keeps brownfield compatibility with existing public entry points (`create_*()`, `render_pub()`, `render_working_paper()`).

Primary risks are truthfulness risks, not syntax risks: validation saying "ready" when render still fails, skipped dependency checks reported as success, and path-resolution mismatches between caller cwd and effective Quarto project root. Mitigation is explicit status modeling (`pass/warn/fail/skip`), canonical render-root resolution reused by both validator and renderer, and fixture tests asserting validator/render agreement.

## Key Findings

### Recommended Stack

v1.1 should stay dependency-light and intentionally reuse the current stack. The only material runtime change is promoting `yaml` to `Imports` so metadata validation is deterministic at runtime. Diagnostics should be structured via `cli` condition metadata rather than adding a new validation/diagnostics package.

**Core technologies:**
- **R >= 4.1.0**: baseline runtime aligned with current package constraints.
- **quarto (R pkg) >= 1.4**: canonical render API (`quarto_render`) and availability/version checks.
- **Quarto CLI >= 1.4.11 (enforced at runtime)**: compatibility floor tied to extension contract.
- **cli >= 3.6.0**: human + machine-parseable diagnostics (`code`, `severity`, `hint`, `context`).
- **fs >= 1.6.0**: cross-platform path and project structure checks.
- **yaml >= 2.3.10 (move to Imports)**: runtime front-matter parsing for validation.
- **bench >= 1.1.4 (Suggests only)**: benchmark-driven optimization guardrails, never runtime-required.

**Stack additions and guardrails:**
- Add runtime CLI-version validation to reconcile R package version vs Quarto CLI floor.
- Keep Quarto-dependent tests explicitly skippable; never fake success when Quarto is absent.
- Do not add new validation frameworks, process orchestration layers, or standalone Typst dependency.

### Expected Features

v1.1 features cluster around reliability and first-run success, not new formats. The must-have set is pre-render validation breadth, structured remediation-focused diagnostics, and scaffold/template hardening so newly created projects validate and render cleanly.

**Must have (table stakes):**
- Pre-render environment and structure checks (Quarto availability/version, extension presence, input resolution).
- YAML metadata consistency checks across existing variants.
- Structured diagnostics with stable codes and actionable fixes.
- First-render-safe scaffolds and clearer onboarding defaults.
- Measured (not speculative) reductions in redundant helper/render overhead.

**Should have (differentiators):**
- Near-miss YAML key suggestions (typo/alias guidance).
- Grouped, stable-ordered diagnostics output (better triage + snapshot stability).
- Validation-first onboarding guidance in starters/docs.
- Lightweight performance regression guardrails for selected stable scenarios.

**Defer (v2+):**
- New major output format families/journal expansion.
- Any silent auto-mutation of user YAML/manuscripts.
- Live preview/watcher subsystem.
- Dependency-heavy auto-install behavior in render path.

### Architecture Approach

Architecture guidance is additive hardening of current boundaries, not redesign. Introduce a dedicated diagnostics model (`R/diagnostics.R`) and validation engine (`R/validation.R`) that build a single shared manuscript context once, then run modular checks. Integrate this gate into `R/render.R` before calling Quarto, and consolidate repeated scaffold logic behind one internal helper used by all `create_*()` functions.

**Major components:**
1. **Diagnostics core (`R/diagnostics.R`)** — canonical issue schema, formatting, severity/status aggregation.
2. **Validation engine (`R/validation.R`)** — runtime/project/metadata/file checks over one shared context.
3. **Render orchestrator (`R/render.R`)** — preflight gate + truthful render/post-render outcome handling.
4. **Scaffold core (new internal helper + `R/create_*.R`)** — one source of truth for template/extension copy and invariant checks.
5. **Templates/extension assets (`inst/templates/*`, `inst/quarto/extensions/typstR/*`)** — onboarding defaults and contract targets for validation rules.

### Critical Pitfalls

1. **Validator/render drift** — Prevent with shared render-context contract and validator/render agreement fixtures.
2. **Skipped checks reported as pass** — Use explicit status model (`pass/warn/fail/skip`) and gate semantics.
3. **Path-resolution mismatch** — Centralize effective render-root resolver; reuse in validator + renderer.
4. **CRAN/CI regressions from unguarded external tooling** — Keep Quarto-dependent paths guarded/skippable and test no-Quarto flows.
5. **Version compatibility blind spots (Quarto-bundled Typst behavior)** — enforce minimum compatibility checks and include version-matrix coverage.

## Implications for Roadmap

Based on combined research, v1.1 should be decomposed into five dependency-ordered phases.

### Phase 1: Diagnostics Contract Foundation
**Rationale:** All downstream checks and UX depend on stable diagnostic semantics.
**Delivers:** Diagnostic schema (`id/code`, severity, status, location, remediation, evidence) + formatter.
**Addresses:** TS-DIAG-01, TS-DIAG-02.
**Avoids:** Prose-only diagnostics, unstable test assertions.

### Phase 2: Validation Engine + Coverage Expansion
**Rationale:** Reliability value comes from complete pre-render truth, not partial checks.
**Delivers:** `validate_manuscript()` with environment, structure, metadata, and file-reference checks over one shared context.
**Uses:** `yaml` runtime parsing, `fs` checks, Quarto version/availability probes.
**Implements:** Validation component boundary and status aggregation.
**Avoids:** Skipped-as-success false confidence; path drift.

### Phase 3: Render Gate Integration and Failure Truthfulness
**Rationale:** Validation only matters if render wrappers enforce it consistently.
**Delivers:** Validation gate in `render_pub()`/`render_working_paper()`, clear abort semantics, post-render artifact verification.
**Addresses:** TS-VAL-01/02/03 and reliability acceptance.
**Avoids:** "Validation passed, render failed" drift class.

### Phase 4: Onboarding/Scaffold Consolidation
**Rationale:** v1.1 must reduce first-run failure rate, not just report failures better.
**Delivers:** Shared scaffold helper, hardened starter templates/defaults, explicit next-step guidance, truthful `open` behavior.
**Addresses:** TS-ONB-01, TS-ONB-02, DF-ONB-01.
**Avoids:** format drift across `create_*()` and silent scaffold invariant failures.

### Phase 5: Measured Performance + Regression Guardrails
**Rationale:** Optimize only after behavior contracts are stable.
**Delivers:** Baseline + post-change benchmarks for hot helper/render paths; keep only measured wins.
**Addresses:** TS-PERF-01/02, optionally DF-PERF-01 if benchmark stability is adequate.
**Avoids:** correctness regressions from premature caching/shortcutting.

### Phase Ordering Rationale

- Diagnostics before checks prevents test churn and incompatible rule outputs.
- Validation before render integration ensures one authoritative preflight model.
- Render hardening before onboarding avoids shipping templates against an unstable execution path.
- Performance last avoids masking correctness defects and preserves reliable benchmark attribution.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 2 (Validation coverage):** verify Quarto CLI floor and bundled Typst compatibility behaviors across supported versions.
- **Phase 5 (Perf gates):** define stable benchmark scenarios/thresholds that won’t cause noisy CI.

Phases with standard patterns (can usually skip research-phase):
- **Phase 1:** structured diagnostics in R conditions (`cli` + classed metadata).
- **Phase 3:** preflight gate pattern in render wrappers.
- **Phase 4:** shared scaffolder extraction and template hardening patterns.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Strong alignment across codebase evidence and official Quarto/CRAN docs. |
| Features | HIGH | Scope is explicit and consistent across milestone artifacts; clusters are clear. |
| Architecture | HIGH | Convergent recommendation: additive hardening with clear boundaries and sequencing. |
| Pitfalls | MEDIUM-HIGH | Risks are well-supported; some version-specific behavior remains environment-sensitive. |

**Overall confidence:** HIGH

### Gaps to Address

- **Quarto CLI ↔ bundled Typst compatibility granularity:** validate exact floor behavior in supported matrix during planning.
- **Benchmark guardrail thresholds:** set realistic pass/fail deltas after collecting project-specific baseline runs.
- **Diagnostic strictness defaults:** confirm whether warnings should gate render in optional strict mode only.

## Sources

### Primary (HIGH confidence)
- `.planning/research/STACK.md`
- `.planning/research/FEATURES.md`
- `.planning/research/ARCHITECTURE.md`
- `.planning/research/PITFALLS.md`
- Quarto docs: https://quarto.org/docs/extensions/formats.html
- Quarto docs: https://quarto.org/docs/output-formats/typst-custom.html
- Quarto R refs: https://quarto-dev.github.io/quarto-r/reference/quarto_available.html
- Quarto R refs: https://quarto-dev.github.io/quarto-r/reference/quarto_version.html
- CRAN policy/docs: https://cran.r-project.org/web/packages/policies.html

### Secondary (MEDIUM confidence)
- testthat docs: https://testthat.r-lib.org/
- cli conditions: https://cli.r-lib.org/reference/cli_abort.html
- Quarto community discussions on version/interpolation/path edge cases (as cited in PITFALLS.md)

---
*Research completed: 2026-03-31*
*Ready for roadmap: yes*
