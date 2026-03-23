---
phase: 03-typst-templates-branding-and-additional-formats
plan: "03"
subsystem: typst-templates
tags: [typst, format-variants, article, policy-brief, orcid, anonymized]

# Dependency graph
requires:
  - phase: 03-typst-templates-branding-and-additional-formats
    plan: "01"
    provides: shared Typst modules (base, titleblock, authors, abstract, appendix) and workingpaper.typ
provides:
  - article.typ format overlay (no report-number, anonymized mode)
  - brief.typ format overlay (Summary label, no JEL, no ORCID)
  - format-variant routing in workingpaper.typ
  - show-orcid parameter in render-author-block
affects:
  - 03-04-scaffolding (create_article() and create_policy_brief() use format-variant YAML field)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Format variant dispatch: if format-variant == 'brief' { override-defaults } at function entry"
    - "Thin format overlay: same parameter signature as working-paper() with different defaults"
    - "show-orcid gate: authors.typ filters orcid-authors to empty list when show-orcid is false"
    - "Anonymized suppression: article.typ passes report-number: none unconditionally; acknowledgements gated on not anonymized"

key-files:
  created:
    - inst/quarto/extensions/typstR/formats/article.typ
    - inst/quarto/extensions/typstR/formats/brief.typ
  modified:
    - inst/quarto/extensions/typstR/formats/workingpaper.typ
    - inst/quarto/extensions/typstR/templates/authors.typ

key-decisions:
  - "format-variant routing in workingpaper.typ via parameter-driven branching at function entry — avoids Pandoc template conditional complexity; typst-show.typ unchanged"
  - "article.typ and brief.typ are thin wrappers with format-appropriate defaults; typst-show.typ always calls working-paper via single format key"
  - "show-orcid parameter added to render-author-block with default true — backward compatible; brief sets false"
  - "article.typ passes report-number: none unconditionally regardless of show-report-number parameter value"

requirements-completed: [TMPL-13]

# Metrics
duration: 8min
completed: 2026-03-23
---

# Phase 3 Plan 03: Article and Policy-Brief Format Overlays Summary

**article.typ and brief.typ format overlays with format-variant dispatch in workingpaper.typ; show-orcid parameter added to render-author-block; all three formats share branding hooks via single _extension.yml typst format key**

## Performance

- **Duration:** 8 min
- **Completed:** 2026-03-23
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- `article.typ` exports `article()` function with `show-report-number: false` default; passes `report-number: none` unconditionally to `render-title-block`; suppresses acknowledgements when `anonymized: true`
- `brief.typ` exports `policy-brief()` function with `abstract-label: "Summary"`, `show-jel: false`, `show-orcid: false` defaults; no `start-appendix()` call (normal numbering for briefs)
- `workingpaper.typ` updated with format-variant dispatch block at function entry: maps `"brief"` to Summary/no-JEL/no-ORCID defaults and `"article"` to no-report-number default
- `authors.typ` `render-author-block()` gains `show-orcid: true` parameter; ORCID section conditionally suppressed — backward compatible (default true)
- `typst-show.typ` and `_extension.yml` required no changes: `format-variant` passthrough was already wired in Plan 01; single `typst` format key serves all three variants

## Task Commits

1. **Task 1: Create article and policy-brief format overlays** - `498c17e` (feat)
2. **Task 2: Wire format-variant routing and show-orcid support** - `2a11dfa` (feat)

## Files Created/Modified

- `inst/quarto/extensions/typstR/formats/article.typ` - Article overlay: no report-number, anonymized suppresses authors+acknowledgements
- `inst/quarto/extensions/typstR/formats/brief.typ` - Policy brief overlay: "Summary" label, no JEL, no ORCID, no lettered appendix
- `inst/quarto/extensions/typstR/formats/workingpaper.typ` - Added format-variant dispatch block and show-orcid pass-through
- `inst/quarto/extensions/typstR/templates/authors.typ` - Added show-orcid parameter to render-author-block

## Decisions Made

- Parameter-driven format-variant dispatch in `workingpaper.typ` chosen over Pandoc template conditionals in `typst-show.typ` — simpler, no Pandoc template syntax uncertainty, `typst-show.typ` stays unchanged
- `article.typ` and `brief.typ` exist as standalone thin wrappers usable as alternative entry points if multi-format _extension.yml becomes viable in a future Quarto version; currently not called by `typst-show.typ`
- `show-orcid` default is `true` in `render-author-block` to maintain backward compatibility with existing working paper documents that already render ORCID

## Deviations from Plan

None - plan executed exactly as written. The "FINAL APPROACH" from the plan was followed: workingpaper.typ as single entry point with parameter-driven branching, article.typ/brief.typ as thin wrappers with format-appropriate defaults.

## Issues Encountered

None

## User Setup Required

None

## Next Phase Readiness

- All three format variants fully functional via `typstR: format-variant:` YAML field
- `create_article()` and `create_policy_brief()` scaffolding (Plan 04) can use `format-variant: article` / `format-variant: brief` in template.qmd YAML
- `show-orcid` parameter available for any future scaffolding that wants to pre-set ORCID visibility

---
*Phase: 03-typst-templates-branding-and-additional-formats*
*Completed: 2026-03-23*

## Self-Check: PASSED

All files confirmed present. All commit hashes confirmed in git history.
