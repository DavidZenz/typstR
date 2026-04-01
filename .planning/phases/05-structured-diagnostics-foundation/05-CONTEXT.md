# Phase 5: Structured Diagnostics Foundation - Context

**Gathered:** 2026-03-31
**Status:** Ready for planning

<domain>
## Phase Boundary

Define the diagnostics contract used by validation so failures are reported as stable structured entries rather than prose-only errors. This phase establishes fields, severity semantics, code stability rules, and multi-issue aggregation behavior. It does **not** add new validation capability scope from later phases.

</domain>

<decisions>
## Implementation Decisions

### Diagnostics schema contract
- **D-01:** Every diagnostic entry MUST include `code`, `severity`, `location`, and `hint`.
- **D-02:** Every diagnostic entry SHOULD also include a human-facing `message` and MAY include structured `details` for debugging context.
- **D-03:** `location` SHOULD support both file-level and field-level pointers (e.g., file path + YAML key path) so downstream checks can be precise.

### Severity semantics
- **D-04:** Use exactly two severity levels in v1.1 foundation: `error` and `warning`.
- **D-05:** Severity meaning is contract-level: `error` = blocking issue, `warning` = non-blocking issue that still needs user visibility.

### Diagnostic code system
- **D-06:** Codes follow a stable namespace format: `DIAG-<AREA>-<NNN>` (example: `DIAG-INPUT-001`).
- **D-07:** Once assigned, a code is never repurposed for a different issue class.
- **D-08:** New issue classes get new codes; historical codes remain valid for compatibility with tests/docs.

### Aggregation and ordering
- **D-09:** Validation diagnostics are collect-all per run (no fail-fast for first issue).
- **D-10:** Output ordering is deterministic: errors first, then warnings; within each severity sort by location, then code.
- **D-11:** Repeated runs over unchanged inputs MUST emit identical code sets and ordering.

### the agent's Discretion
- Exact wording templates for `message` and `hint`, as long as semantics stay stable.
- Internal representation details for `location`/`details` beyond the required external contract.
- Whether diagnostics formatting helpers live in one file or split into small internal helpers.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Milestone and phase contract
- `.planning/ROADMAP.md` — Phase 5 goal and success criteria (required fields, stable codes, multi-issue structure).
- `.planning/REQUIREMENTS.md` — `DIAG-01` plus deferred diagnostics requirements (`DIAG-02` to `DIAG-04`) that must not be silently pulled into this phase.
- `.planning/PROJECT.md` — v1.1 milestone goal and constraints (reliability/onboarding focus, no major format expansion).

### Research constraints for this milestone
- `.planning/research/SUMMARY.md` — diagnostics-first sequencing and risk controls.
- `.planning/research/ARCHITECTURE.md` — recommended integration points (`R/diagnostics.R`, `R/validation.R`, `R/render.R`).
- `.planning/research/PITFALLS.md` — false-confidence risks and validator/render drift hazards.

### Existing implementation references
- `R/render.R` — current preflight error handling entry point and wrapper behavior.
- `R/utils.R` — current input-resolution errors and message style.
- `R/metadata_helpers.R` — established argument-validation error patterns.
- `tests/testthat/test-render-guards.R` — current error assertion style used by tests.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `R/render.R::render_pub()` and `quarto_available()` provide the current preflight choke point where structured diagnostics can eventually be surfaced.
- `R/utils.R::resolve_input()` already centralizes input-path failure cases and is a natural source of file/location diagnostics.
- `tests/testthat/test-render-guards.R` provides a reusable pattern for testing error behavior under mocked Quarto availability.

### Established Patterns
- Errors are currently emitted via `cli::cli_abort(...)` with bullet-style guidance across R helpers.
- Validation-style checks are distributed and message-centric today (no shared diagnostics schema object).
- Test expectations currently match message strings/regex; introducing stable codes can reduce brittleness.

### Integration Points
- Introduce diagnostics contract in a dedicated internal layer, then adapt `render_pub()`/`resolve_input()` call paths to emit/consume it.
- Keep compatibility with existing helper validation style while migrating from prose-only aborts to structured entries.
- Coordinate with Phase 6 planning so environment validation consumes the same diagnostics contract instead of creating a parallel one.

</code_context>

<specifics>
## Specific Ideas

No specific requirements — user delegated implementation choices for this phase.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---
*Phase: 05-structured-diagnostics-foundation*
*Context gathered: 2026-03-31*
