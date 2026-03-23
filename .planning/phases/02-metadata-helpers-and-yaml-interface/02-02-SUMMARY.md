---
phase: 02-metadata-helpers-and-yaml-interface
plan: "02"
subsystem: api
tags: [r, s3, cli, testthat, tdd, metadata, keywords, jel, notes]

# Dependency graph
requires:
  - phase: 01-skeleton-and-pipeline
    provides: cli error patterns, roxygen2 style, DESCRIPTION imports established

provides:
  - keywords() S3 helper — character-validated typstR_keywords list
  - jel_codes() S3 helper — regex-validated typstR_jel list with [A-Z][0-9]{1,2} pattern
  - report_number() scalar wrapper with typstR_report_number S3 class
  - funding() scalar wrapper with typstR_funding S3 class
  - data_availability() scalar wrapper with typstR_data_availability S3 class
  - code_availability() scalar wrapper with typstR_code_availability S3 class
  - fig_note() cat()-based markdown note emitter for output:asis chunks
  - tab_note() cat()-based markdown note emitter (separate from fig_note for Phase 3 styling)
  - appendix_title() cat()-based appendix header emitter with {.appendix} Quarto class
  - 52 passing unit tests across two test files

affects:
  - 02-03 (manuscript_meta must accept keywords/jel/funding/etc. S3 objects)
  - 03-typst-template-wiring (fig_note/tab_note output format must match Typst styling)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Per-argument validation: use list(...) + vapply for keywords/jel to avoid c() coercion false-pass"
    - "Scalar wrapper pattern: structure(text, class = c('typstR_X', 'character')) with is.character(text) && length(text) == 1L guard"
    - "cat() output functions return invisible(text) for testability"
    - "capture.output() for testing cat() side effects in testthat"

key-files:
  created:
    - R/pub_helpers.R
    - R/notes_helpers.R
    - tests/testthat/test-pub-helpers.R
    - tests/testthat/test-notes-helpers.R
  modified:
    - NAMESPACE

key-decisions:
  - "keywords() validates per-argument via list(...) + vapply, not c(...), to prevent R coercion silencing type errors"
  - "fig_note and tab_note are kept as separate functions (not aliases) to allow divergent styling in Phase 3"
  - "appendix_title validates title is character(1) even though it is a cat() function, not a metadata constructor"

patterns-established:
  - "Scalar wrapper: structure(text, class = c('typstR_X', 'character')) with single-string guard"
  - "Variadic character helper: list(...) + vapply(args, is.character) for type-safe multi-arg collection"
  - "TDD order: write failing tests, commit, write implementation, verify all pass, commit"

requirements-completed: [META-04, META-05, META-06, META-07, META-08, META-09, META-10]

# Metrics
duration: 3min
completed: 2026-03-23
---

# Phase 2 Plan 02: Publication and Notes Helpers Summary

**Nine S3-classed helper functions (keywords, jel_codes, report_number, funding, data_availability, code_availability, fig_note, tab_note, appendix_title) with full validation and 52 passing TDD tests**

## Performance

- **Duration:** 3 min
- **Started:** 2026-03-23T08:41:54Z
- **Completed:** 2026-03-23T08:45:49Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments
- Six publication metadata helpers in `R/pub_helpers.R` with S3 classes and cli error messages
- Three notes output helpers in `R/notes_helpers.R` using cat()/invisible pattern for output:asis chunks
- 52 unit tests covering validation edge cases, S3 class assertions, and cat() output format

## Task Commits

Each task was committed atomically:

1. **Task 1 RED: pub_helpers tests** - `efab13e` (test)
2. **Task 1 GREEN: pub_helpers implementation** - `6306a96` (feat)
3. **Task 2 RED: notes_helpers tests** - `ede31f7` (test)
4. **Task 2 GREEN: notes_helpers implementation** - `524a90d` (feat)

_Note: TDD tasks have two commits each (test -> feat)_

## Files Created/Modified
- `R/pub_helpers.R` - keywords(), jel_codes(), report_number(), funding(), data_availability(), code_availability() with print S3 methods
- `R/notes_helpers.R` - fig_note(), tab_note(), appendix_title() with roxygen2 docs
- `tests/testthat/test-pub-helpers.R` - 38 tests for publication helpers
- `tests/testthat/test-notes-helpers.R` - 14 tests for notes helpers
- `NAMESPACE` - updated by roxygen2 with all 9 exports and 4 S3 methods

## Decisions Made
- Used `list(...) + vapply(args, is.character)` for keywords() and jel_codes() validation rather than `c(...)` — R's `c("trade", 456)` silently coerces to character, so type checking after `c()` would allow mixed inputs without error
- Kept `fig_note()` and `tab_note()` as separate functions (not one function with a `type` argument) per locked Phase 2 decision to allow divergent Typst styling in Phase 3
- Added input validation to `appendix_title()` (character(1) guard) even though it's an output function, because an invalid title would silently produce malformed markdown

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed keywords() coercion false-pass**
- **Found during:** Task 1 GREEN (first test run showed `keywords("trade", 456)` not erroring)
- **Issue:** `c("trade", 456)` coerces to `c("trade", "456")` in R, so `is.character(codes)` returned TRUE even with numeric input
- **Fix:** Changed from `codes <- c(...); if (!is.character(codes))` to `args <- list(...); vapply(args, is.character, logical(1))` to check each argument before coercion
- **Files modified:** R/pub_helpers.R
- **Verification:** `keywords("trade", 456)` now errors; `keywords("trade", "policy")` passes; all 38 tests pass
- **Committed in:** `6306a96` (Task 1 feat commit)

---

**Total deviations:** 1 auto-fixed (Rule 1 - Bug)
**Impact on plan:** Essential fix for type safety. No scope creep.

## Issues Encountered
- `devtools` not installed in this R environment; used `roxygen2::roxygenise()` for document generation and `testthat::test_file()` directly for test runs. R CMD check run via `rcmdcheck::rcmdcheck()`. No functional impact.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- All 9 pub/notes helper functions exported and tested, ready for use in manuscript_meta() (plan 02-01 or later)
- `R/metadata_helpers.R` (author, affiliation, manuscript_meta) already exists in working tree from plan 02-01 research/scaffolding
- NAMESPACE is clean — 0 errors, 0 warnings from R CMD check (2 pre-existing NOTEs: .claude directory and rlang/yaml unused imports — both expected until manuscript_meta() is complete)

---
*Phase: 02-metadata-helpers-and-yaml-interface*
*Completed: 2026-03-23*

## Self-Check: PASSED

- R/pub_helpers.R: FOUND
- R/notes_helpers.R: FOUND
- tests/testthat/test-pub-helpers.R: FOUND
- tests/testthat/test-notes-helpers.R: FOUND
- 02-02-SUMMARY.md: FOUND
- Commit efab13e (test RED pub_helpers): FOUND
- Commit 6306a96 (feat GREEN pub_helpers): FOUND
- Commit ede31f7 (test RED notes_helpers): FOUND
- Commit 524a90d (feat GREEN notes_helpers): FOUND
