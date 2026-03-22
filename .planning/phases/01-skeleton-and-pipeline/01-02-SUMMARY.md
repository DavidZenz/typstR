---
phase: 01-skeleton-and-pipeline
plan: 02
subsystem: infra
tags: [r-package, quarto, scaffolding, template, fs, cli]

requires:
  - phase: 01-01
    provides: Extension in inst/quarto/extensions/typstR/ and CRAN-ready package skeleton

provides:
  - create_working_paper() exported function that scaffolds complete project directories
  - inst/templates/workingpaper/ with template.qmd, _quarto.yml, references.bib
  - Extension copy mechanism from inst/ to user project _extensions/typstR/

affects:
  - 01-03 (render wrappers — create_working_paper() produces the projects that render_pub() renders)
  - Phase 2+ (scaffolded template.qmd is the primary user-facing document structure)

tech-stack:
  added: []
  patterns:
    - "system.file(..., mustWork = TRUE) pattern for locating inst/ resources at runtime"
    - "fs::dir_copy() for extension copy from inst/ to user project _extensions/"
    - "fs::file_copy() for copying individual template files to avoid nesting"
    - "sub() with fixed = TRUE for safe placeholder title replacement"
    - "cli::cli_alert_success() + cli::cli_bullets() for usethis-style output"

key-files:
  created:
    - R/create_working_paper.R
    - inst/templates/workingpaper/template.qmd
    - inst/templates/workingpaper/_quarto.yml
    - inst/templates/workingpaper/references.bib
  modified:
    - NAMESPACE

key-decisions:
  - "system.file with mustWork = TRUE ensures clear error if package is not installed (research pitfall)"
  - "fs::file_copy() (not fs::dir_copy()) for template files to avoid wrapping in a subdirectory"
  - "open parameter accepted but not wired in Phase 1 — IDE project opening deferred"

patterns-established:
  - "Template scaffolding: copy individual files, then copy extension directory separately"
  - "Extension copy pattern: system.file('quarto/extensions/typstR') -> _extensions/typstR/"

requirements-completed: [FOUN-03, SCAF-01]

duration: included in 01-03 execution session
completed: 2026-03-22
---

# Phase 1 Plan 02: Scaffolding Function Summary

**create_working_paper() function scaffolding complete project directories with rich Quarto template, bibliography, and bundled typstR-workingpaper extension via fs::dir_copy()**

## Performance

- **Duration:** (executed as part of 01-03 session — prior work found in repo)
- **Started:** 2026-03-22
- **Completed:** 2026-03-22T19:15:01Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments

- inst/templates/workingpaper/ with three template files (template.qmd, _quarto.yml, references.bib) using typstR-workingpaper format
- create_working_paper() exported function scaffolding complete project with error-on-existing-dir guard
- Extension copy from inst/quarto/extensions/typstR/ to project _extensions/typstR/ via fs::dir_copy()
- Title pre-fill via sub() replacement; cli-styled success summary

## Task Commits

Each task was committed atomically:

1. **Task 1: Create template files for working paper scaffold** - `6785d37` (feat)
2. **Task 2: Create create_working_paper() scaffolding function** - `b331359` (feat)

## Files Created/Modified

- `R/create_working_paper.R` - Exported scaffolding function with directory guard, template copy, extension copy, title pre-fill
- `inst/templates/workingpaper/template.qmd` - Rich starter template with typstR-workingpaper format and academic sections
- `inst/templates/workingpaper/_quarto.yml` - Minimal Quarto project config
- `inst/templates/workingpaper/references.bib` - Dummy @article entry matching template citation
- `NAMESPACE` - Updated with export(create_working_paper)

## Decisions Made

- Used `system.file(..., mustWork = TRUE)` to ensure a clear error if package is not installed (vs. silently returning empty string)
- Used `fs::file_copy()` for individual template files to avoid nesting the templates subdirectory inside the destination
- `open` parameter accepted but not implemented in Phase 1 — IDE project opening is a future enhancement

## Deviations from Plan

None — plan executed exactly as written.

## Issues Encountered

- `devtools` unavailable in verification environment; used `pkgload::load_all()` instead (same underlying function)

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

- create_working_paper() exports and loads cleanly — Plan 03 render wrappers can be built and tested
- Scaffolded projects include extension and template.qmd with typstR-workingpaper format — end-to-end pipeline ready to close
- All DESCRIPTION imports remain unchanged — no new dependencies introduced

## Self-Check: PASSED

Files 6785d37 (templates), b331359 (function) confirmed in git log. All template files verified on disk.

---
*Phase: 01-skeleton-and-pipeline*
*Completed: 2026-03-22*
