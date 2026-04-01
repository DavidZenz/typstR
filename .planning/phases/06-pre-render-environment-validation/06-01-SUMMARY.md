---
phase: 06-pre-render-environment-validation
plan: 01
subsystem: validation
tags: [quarto, typst, diagnostics, testthat]
requires:
  - phase: 05-structured-diagnostics-foundation
    provides: Immutable diagnostics codebook plus typstR_diagnostics_error payload contract
provides:
  - Standalone validate_render_environment() entrypoint for pre-render pass/fail checks
  - Collect-all Quarto/Typst/floor/extension probing mapped to stable DIAG-ENV diagnostics
  - Direct test_file harness and contract tests for validation report and aggregate failures
affects: [06-02-render-integration-cutover, render preflight, diagnostics consumers]
tech-stack:
  added: []
  patterns:
    - Single shared environment validation primitive with per-check evidence payloads
    - Payload-first tests using helper-based source loading for non-installed package runs
key-files:
  created:
    - R/validation_environment.R
    - tests/testthat/helper-validation.R
    - tests/testthat/test-validation-environment.R
  modified:
    - R/diagnostics.R
    - tests/testthat/test-diagnostics-codebook.R
    - NAMESPACE
key-decisions:
  - "Use DIAG-ENV-001..004 as immutable environment diagnostics while preserving existing runtime/input mappings."
  - "Return typstR_validation_report with explicit checks evidence on success and emit aggregate diagnostics on failure."
  - "Derive Quarto version floor from extension manifest quarto-required to avoid split-brain constants."
patterns-established:
  - "Environment checks are always aggregated first, then converted to diagnostics in one emission path."
  - "Validation tests patch probe helpers in a sourced environment to keep tests deterministic without full package install."
requirements-completed: [VAL-01]
duration: 8m
completed: 2026-04-01
---

# Phase 06 Plan 01: Environment Validation Contract Summary

**Standalone pre-render environment validation now reports Quarto/Typst/floor/extension evidence on success and emits deterministic DIAG-ENV aggregate diagnostics on failure.**

## Performance

- **Duration:** 8m
- **Started:** 2026-04-01T09:09:59Z
- **Completed:** 2026-04-01T09:17:34Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments

- Extended diagnostics codebook with immutable environment issue classes for Quarto unavailable, Typst unavailable, Quarto floor incompatibility, and missing extension.
- Added standalone `validate_render_environment(path = ".")` with collect-all checks and report object output (`typstR_validation_report`).
- Added payload-first validation contract tests and helper harness for deterministic `testthat::test_file()` execution.

## Task Commits

Each task was committed atomically:

1. **Task 1: Extend diagnostics codebook and validation test harness for environment issue classes**
   - `26259df` (test): add failing environment validation contracts
   - `28cc347` (feat): add stable environment diagnostics codebook entries
2. **Task 2: Implement standalone validation entrypoint and collect-all environment probe engine**
   - `51054ca` (feat): implement standalone render environment validation

## Files Created/Modified

- `R/diagnostics.R` - Added DIAG-ENV immutable codebook keys.
- `R/validation_environment.R` - Implemented standalone validation entrypoint, probe engine, floor parsing, and diagnostics mapping.
- `NAMESPACE` - Exported `validate_render_environment`.
- `tests/testthat/test-diagnostics-codebook.R` - Locked stable environment mappings and deterministic ordering assertions.
- `tests/testthat/helper-validation.R` - Added source discovery helpers for diagnostics/validation modules.
- `tests/testthat/test-validation-environment.R` - Added pass/fail/report contract tests for validation behavior.

## Decisions Made

- Reused existing diagnostics primitives (`new_diagnostic`, `emit_diagnostics_error`) for all environment failures to preserve Phase 5 contract invariants.
- Kept check collection and diagnostics emission separate (`collect_environment_checks` + `diagnostics_from_environment_checks`) to support both structured success reports and aggregate failure emission.
- Normalized validation paths to absolute paths for stable diagnostics location fields and deterministic ordering.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- Validation diagnostics order initially differed because mixed absolute path forms (`/var` vs `/private`) produced different sort keys; test fixtures were normalized to absolute paths to keep deterministic ordering assertions truthful.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- `validate_render_environment()` now exists as the canonical primitive for pre-render environment checks.
- Phase 06-02 can cut over `render_pub()` preflight to this shared validator without introducing parallel logic.


## Self-Check: PASSED

- Verified file existence: `R/validation_environment.R`, `tests/testthat/helper-validation.R`, `tests/testthat/test-validation-environment.R`, `.planning/phases/06-pre-render-environment-validation/06-01-SUMMARY.md`.
- Verified commit presence: `26259df`, `28cc347`, `51054ca`.