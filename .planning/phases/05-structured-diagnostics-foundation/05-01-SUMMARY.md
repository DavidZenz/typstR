---
phase: 05-structured-diagnostics-foundation
plan: 01
subsystem: diagnostics
tags: [r, testthat, diagnostics, cli]
requires:
  - phase: 04-tests-documentation-and-cran-hardening
    provides: Existing render/input guard patterns and testthat conventions
provides:
  - Canonical internal diagnostics constructor with required schema enforcement
  - Immutable diagnostics codebook with format, uniqueness, and reassignment guards
  - Deterministic diagnostics ordering and classed aggregate emitter for multi-issue payloads
affects: [phase-06-validation, render-guards, input-resolution]
tech-stack:
  added: []
  patterns: [contract-first diagnostics, stable-code registry, deterministic sorting]
key-files:
  created:
    - R/diagnostics.R
    - tests/testthat/helper-diagnostics.R
    - tests/testthat/test-diagnostics-contract.R
    - tests/testthat/test-diagnostics-codebook.R
    - tests/testthat/test-diagnostics-ordering.R
  modified:
    - R/diagnostics.R
    - tests/testthat/test-diagnostics-contract.R
    - tests/testthat/test-diagnostics-codebook.R
    - tests/testthat/test-diagnostics-ordering.R
key-decisions:
  - "Treat diagnostics as an internal contract object first; call sites integrate in 05-02."
  - "Lock code stability with explicit reference mapping validation, not convention-only comments."
  - "Emit aggregate failures as classed conditions carrying sorted diagnostics payloads."
patterns-established:
  - "new_diagnostic(): required code/severity/location/hint with optional message/details"
  - "sort_diagnostics(): severity -> location(file/field) -> code -> insertion index"
requirements-completed: [DIAG-01]
duration: 4m
completed: 2026-04-01
---

# Phase 05 Plan 01: Structured Diagnostics Foundation Summary

**Contract-locked diagnostics substrate in `R/diagnostics.R` with stable codebook, deterministic ordering, and classed aggregate emission tests.**

## Performance

- **Duration:** 4m
- **Started:** 2026-04-01T08:15:30Z
- **Completed:** 2026-04-01T08:19:39Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments
- Added canonical diagnostics primitives that enforce required fields, optional metadata retention, and strict `error|warning` severity semantics.
- Added immutable Phase 05 codebook mappings (`DIAG-RUNTIME-001`, `DIAG-INPUT-001/002/003`) with format, uniqueness, and no-reassignment validation.
- Added deterministic sorting plus `typstR_diagnostics_error` aggregate emission carrying sorted multi-diagnostic payloads.

## Task Commits

Each task was committed atomically:

1. **Task 1: Define diagnostics schema and stable codebook per D-01 through D-08** - `27fb919` (test), `c73e89f` (feat)
2. **Task 2: Implement deterministic ordering and aggregate diagnostics emission per D-09 through D-11** - `dd0cac9` (test), `c841d84` (feat)

_Plan metadata commit: pending at summary creation time._

## Files Created/Modified
- `R/diagnostics.R` - Internal diagnostics constructor, codebook validator, ordering helper, and aggregate condition emitter.
- `tests/testthat/helper-diagnostics.R` - Shared helper to source diagnostics internals in direct `test_file()` runs.
- `tests/testthat/test-diagnostics-contract.R` - Contract assertions for required fields, severity restrictions, and location support.
- `tests/testthat/test-diagnostics-codebook.R` - Stable mapping, format enforcement, uniqueness, and reassignment-guard assertions.
- `tests/testthat/test-diagnostics-ordering.R` - Deterministic ordering and aggregate condition payload assertions.

## Decisions Made
- Kept all diagnostics APIs internal in this plan; export/public wiring deferred to call-site integration plan 05-02.
- Enforced code stability with runtime validator against canonical reference map so repurposed codes fail explicitly.
- Used classed condition payloads (`typstR_diagnostics_error`) to preserve user-facing abort behavior while exposing machine-readable diagnostics.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Added diagnostics test helper for `test_file()` path resolution**
- **Found during:** Task 1 (TDD GREEN verification)
- **Issue:** Direct `testthat::test_file()` execution resolved working directory differently, causing `R/diagnostics.R` sourcing failures.
- **Fix:** Added `tests/testthat/helper-diagnostics.R` with robust diagnostics source path discovery used by all new diagnostics tests.
- **Files modified:** `tests/testthat/helper-diagnostics.R`, diagnostics test files
- **Verification:** Re-ran plan verify commands successfully for contract, codebook, and ordering tests.
- **Committed in:** `c73e89f` (part of Task 1 implementation commit)

---

**Total deviations:** 1 auto-fixed (Rule 3 blocking)
**Impact on plan:** Deviation was necessary to make planned verification commands reliable; no scope expansion.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Diagnostics contract substrate is now in place for 05-02 call-site integration (`render_pub()` and `resolve_input()`).
- Existing no-Quarto-safe behavior remains untouched in this plan.

---
*Phase: 05-structured-diagnostics-foundation*
*Completed: 2026-04-01*


## Self-Check: PASSED

- Verified required files exist: `R/diagnostics.R`, diagnostics tests/helper, and `05-01-SUMMARY.md`
- Verified task commits exist in git history: `27fb919`, `c73e89f`, `dd0cac9`, `c841d84`