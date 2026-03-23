---
phase: 03-typst-templates-branding-and-additional-formats
plan: "04"
subsystem: scaffolding
tags: [r-functions, templates, quarto, typst, article, policy-brief]

requires:
  - phase: 03-02
    provides: branding hooks and extension structure
  - phase: 03-03
    provides: format-variant routing in Typst templates (article/brief)

provides:
  - create_article() scaffolding function exported from R/create_article.R
  - create_policy_brief() scaffolding function exported from R/create_policy_brief.R
  - inst/templates/article/ directory with format-variant: article template
  - inst/templates/policy-brief/ directory with format-variant: brief template

affects:
  - 04-validation-and-tests

tech-stack:
  added: []
  patterns:
    - "Scaffolding functions follow create_working_paper() pattern: dir guard, template copy, extension copy, optional title substitution, cli summary"
    - "Template title placeholder matches function title substitution target exactly ('Article Title', 'Policy Brief Title')"

key-files:
  created:
    - R/create_article.R
    - R/create_policy_brief.R
    - inst/templates/article/template.qmd
    - inst/templates/article/_quarto.yml
    - inst/templates/article/references.bib
    - inst/templates/policy-brief/template.qmd
    - inst/templates/policy-brief/_quarto.yml
    - inst/templates/policy-brief/references.bib
  modified:
    - NAMESPACE

key-decisions:
  - "Article template includes JEL codes (omit report-number) — articles are academic format, brief is policy format without JEL"
  - "Policy brief template includes report-number (PB 001) but no JEL codes or acknowledgements — matches format-variant: brief semantics"
  - "title substitution uses fixed = TRUE in sub() matching exact placeholder strings from template files"

patterns-established:
  - "Scaffolding pattern: copy flat template files + copy _extensions/typstR/ from inst/quarto/extensions/"
  - "format-variant field distinguishes article/brief/workingpaper without separate Quarto format keys"

requirements-completed: [SCAF-02, SCAF-03]

duration: 8min
completed: 2026-03-23
---

# Phase 03 Plan 04: Scaffolding Functions for Article and Policy-Brief Formats Summary

**create_article() and create_policy_brief() scaffolding functions with format-appropriate Quarto templates (format-variant: article / brief, field set differences)**

## Performance

- **Duration:** 8 min
- **Started:** 2026-03-23T11:00:00Z
- **Completed:** 2026-03-23T11:08:00Z
- **Tasks:** 2
- **Files modified:** 9

## Accomplishments
- Created inst/templates/article/ with template.qmd (format-variant: article, JEL codes, no report-number), _quarto.yml, references.bib
- Created inst/templates/policy-brief/ with template.qmd (format-variant: brief, report-number, no JEL codes, policy sections), _quarto.yml, references.bib
- Created R/create_article.R and R/create_policy_brief.R following create_working_paper() pattern exactly
- NAMESPACE updated with export(create_article) and export(create_policy_brief) via roxygen2::roxygenise()

## Task Commits

Each task was committed atomically:

1. **Task 1: Create template directories for article and policy-brief** - `d76ef45` (feat)
2. **Task 2: Create create_article() and create_policy_brief() R functions** - `2fe3315` (feat)

**Plan metadata:** (docs commit below)

## Files Created/Modified
- `inst/templates/article/template.qmd` - Article template with format-variant: article, JEL codes, no report-number
- `inst/templates/article/_quarto.yml` - Project config (type: default)
- `inst/templates/article/references.bib` - Placeholder bibliography
- `inst/templates/policy-brief/template.qmd` - Policy brief template with format-variant: brief, report-number, no JEL, policy sections
- `inst/templates/policy-brief/_quarto.yml` - Project config (type: default)
- `inst/templates/policy-brief/references.bib` - Placeholder bibliography
- `R/create_article.R` - Scaffolding function: dir guard, template copy, extension copy, optional title, cli summary
- `R/create_policy_brief.R` - Scaffolding function: same pattern for policy-brief template
- `NAMESPACE` - Added export(create_article) and export(create_policy_brief)

## Decisions Made
- Article template includes JEL codes but no report-number (academic format distinction)
- Policy brief template has report-number (PB 001) but no JEL and no acknowledgements (policy audience orientation)
- roxygen2::roxygenise() used directly (devtools not installed); man/ files remain gitignored per project convention

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
- devtools not installed; used roxygen2::roxygenise() directly, which is equivalent and produces the same NAMESPACE output

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- All three format scaffolding functions now exist: create_working_paper(), create_article(), create_policy_brief()
- Phase 04 (validation and tests) can now write integration tests covering all three scaffolding paths
- No blockers

---
*Phase: 03-typst-templates-branding-and-additional-formats*
*Completed: 2026-03-23*
