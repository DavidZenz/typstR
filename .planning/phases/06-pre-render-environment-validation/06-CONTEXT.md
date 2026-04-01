# Phase 6: Pre-render Environment Validation - Context

**Gathered:** 2026-04-01
**Status:** Ready for planning

<domain>
## Phase Boundary

Add a pre-render validation flow users can run before rendering so environment readiness is reported truthfully. This phase covers Quarto/Typst availability and versions, version-floor compatibility checks, and required typstR extension presence checks. It does not add new manuscript semantic validation rules from future phases.

</domain>

<decisions>
## Implementation Decisions

### Validation entrypoint and user contract
- **D-01:** Provide a user-invokable pre-render validation entrypoint that can be run before `render_pub()` and reports a clear pass/fail outcome.
- **D-02:** Validation MUST emit structured diagnostics via the Phase 5 contract (`typstR_diagnostics_error`) on failure, not prose-only aborts.
- **D-03:** Validation success SHOULD return a structured report object containing check outcomes and detected version values (for Quarto and Typst) so callers can inspect results programmatically.

### Check coverage and truthfulness
- **D-04:** Minimum checks in this phase are: Quarto availability, Typst availability and detected version, Quarto version-floor compatibility, and typstR extension presence in the target project.
- **D-05:** Checks are collect-all where feasible in one run; users should receive a complete issue set for known blockers rather than failing on the first issue.
- **D-06:** Every failing check maps to stable diagnostics codes in the existing codebook namespace rules (`DIAG-<AREA>-<NNN>`) and keeps deterministic ordering.

### Render integration behavior
- **D-07:** `render_pub()` preflight behavior should be driven by the shared validation primitives introduced in this phase (no parallel preflight logic).
- **D-08:** Existing user-facing guidance text should remain compatible where possible while payload/class assertions become the primary test contract.

### the agent's Discretion
- Exact public function naming and helper decomposition, provided one clear user entrypoint exists and aligns with existing package naming conventions.
- Exact Quarto version-floor value and comparison implementation, provided the floor is explicit, test-covered, and surfaced in diagnostics.
- Exact structure of successful validation report class/print behavior, provided pass/fail and version evidence are unambiguous.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Milestone and phase contract
- `.planning/ROADMAP.md` — Phase 6 goal and success criteria (pre-render invocation, version detection, version floor, extension presence).
- `.planning/REQUIREMENTS.md` — `VAL-01` requirement definition and phase mapping.
- `.planning/PROJECT.md` — v1.1 reliability/onboarding milestone constraints.
- `.planning/STATE.md` — carry-forward decisions from Phase 5 diagnostics contract and ordering behavior.

### Prior phase decisions to carry forward
- `.planning/phases/05-structured-diagnostics-foundation/05-CONTEXT.md` — locked diagnostics schema, code stability, and deterministic ordering decisions.
- `.planning/phases/05-structured-diagnostics-foundation/05-VERIFICATION.md` — verified behavioral truths for diagnostics payload contract and no-Quarto-safe test posture.

### Existing implementation references
- `R/diagnostics.R` — canonical diagnostics constructors, codebook, ordering, and emitter.
- `R/render.R` — current Quarto preflight path and render wrappers to unify with new validation primitives.
- `R/utils.R` — established input diagnostics emission pattern and codebook usage.
- `tests/testthat/test-render-guards.R` — payload-first guard testing pattern for runtime preflight errors.
- `tests/testthat/test-yaml-integration.R` — guarded Quarto-dependent integration test behavior.

### Legacy design intent references
- `BLUEPRINT.md` — validation API intent (`check_typst`, `check_quarto`, `check_typstR`, `validate_manuscript`).
- `VALID_STRATEGY.md` — early validation scope draft (environment + required-file checks).

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `R/diagnostics.R` already provides strict, stable diagnostics primitives that Phase 6 should reuse directly.
- `R/render.R::quarto_available()` is a clean seam for no-Quarto testing and can be reused or replaced by a shared validation probe.
- `tests/testthat/test-render-guards.R` already sources package modules directly in tests, enabling package-uninstalled harness execution.

### Established Patterns
- Error contracts are now class + diagnostics payload first, with message text retained for compatibility checks.
- Quarto-dependent tests are CRAN-safe via explicit skip guards when Quarto is unavailable.
- Scaffolded projects place extension files at `_extensions/typstR`, which is the expected extension-presence check target.

### Integration Points
- Add an internal validation module that both `render_pub()` and the exported pre-render validator consume.
- Extend diagnostics codebook with stable environment-validation issue keys before wiring callsites.
- Add dedicated validation tests and update guard tests so render preflight and standalone validation share one truth path.

</code_context>

<specifics>
## Specific Ideas

- Preserve Phase 5’s payload-first error contract as the canonical interface for failure handling.
- Prefer deterministic, inspectable output so automation (CI/preflight scripts) can rely on stable pass/fail and issue codes.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 06-pre-render-environment-validation*
*Context gathered: 2026-04-01*