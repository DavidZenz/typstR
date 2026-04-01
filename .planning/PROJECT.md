# typstR

## What This Is

An R package for creating publication-ready scientific documents using Quarto + Typst. typstR builds on top of Quarto's native Typst support to provide opinionated scientific publication formats, manuscript scaffolding, metadata helpers, institutional branding hooks, and reusable Typst templates. It targets researchers, economists, policy analysts, and institutes producing working papers, articles, and policy briefs.

## Core Value

Users can go from `create_working_paper("my-paper")` to a polished, branded PDF in minutes — no Typst or LaTeX knowledge required.

## Current State

- **Version:** v1.1 (Planning started 2026-03-31)
- **Status:** Phase 06 complete in v1.1; Phase 07 (first-run onboarding reliability) is next.
- **Previous Release:** v1.0 (Released 2026-03-23)
- **Milestone Archive:** [.planning/milestones/v1.0-ROADMAP.md](.planning/milestones/v1.0-ROADMAP.md)

## Current Milestone: v1.1 Reliability and Onboarding Polish

**Goal:** Make common setup/manuscript mistakes fail fast with actionable guidance while keeping typstR release-ready and easier for first-time users.

**Target features:**
- Expand pre-render validation coverage for common manuscript and setup errors.
- Add structured diagnostics with concrete remediation hints.
- Improve scaffold defaults and starter content for higher first-run success.
- Apply targeted performance improvements in helper/render paths where measurable.

## Requirements

### Validated

- [x] Quarto extension bundled inside the R package
- [x] Three publication formats: workingpaper, article, policy-brief
- [x] Modular Typst template layer (base, titleblock, authors, abstract, bibliography, floats, appendix, branding)
- [x] Project scaffolding functions: create_working_paper(), create_article(), create_policy_brief()
- [x] Metadata helpers: author(), affiliation(), manuscript_meta(), funding(), data_availability(), code_availability()
- [x] Publication helpers: jel_codes(), keywords(), fig_note(), tab_note(), appendix_title(), report_number()
- [x] Validation/diagnostics: check_typst(), check_quarto(), check_typstR(), validate_manuscript()
- [x] Render wrappers: render_pub(), render_working_paper()
- [x] Branding hooks: logo, fonts, colors, margins, footer, disclaimer page — configurable via YAML
- [x] Anonymized/review mode for article format
- [x] YAML-driven metadata interface (typstR: block in front matter)
- [x] Examples and starter templates for each format
- [x] CRAN-ready package structure (R CMD check clean)
- [x] Documentation: README, 3 vignettes (getting-started, working-papers, customizing-branding)
- [x] Test suite covering metadata, validation, render helpers, and project creation
- [x] Structured diagnostics contract for validation failures (stable `code`/`severity`/`location`/`hint`, deterministic ordering) — validated in Phase 05
- [x] Pre-render environment validation reports Quarto/Typst readiness, version-floor compatibility, and extension presence before render (VAL-01) — validated in Phase 06

### Active

- [ ] Catch common setup/manuscript mistakes before Quarto render with actionable fixes
- [ ] Expand `validate_manuscript()` checks for metadata, file inputs, and consistency
- [ ] Improve scaffolding defaults/starter documents for smoother onboarding
- [ ] Reduce avoidable helper/render overhead without changing output semantics

### Out of Scope

- Full journal submission compatibility for many publishers — too broad for v0.1, revisit after base formats mature
- Direct import of LaTeX .cls or .sty files — fundamentally different system, not a conversion tool
- Low-level Typst parser — unnecessary complexity, rely on Quarto's Typst integration
- Universal LaTeX-to-Typst conversion — out of mission
- Extensive HTML/Word output support — Typst PDF is the focus
- Custom table engine — delegate to typstable, gt, tinytable; typstR handles layout conventions only

## Context

- Quarto already supports Typst output natively; typstR extends this with opinionated defaults
- Existing ecosystem: `typr` and `typstable` exist but don't provide a complete manuscript framework
- The package has three layers: R package (helpers), Quarto extension (format defs), Typst templates (layout)
- Target: CRAN submission eventually — must follow R CMD check conventions from the start
- Tables: rely on standard Quarto figure handling, markdown tables, and compatibility with typstable/gt/tinytable
- Rendering: Quarto is the primary backend; optional Typst CLI checks where useful

## Constraints

- **Tech stack**: R package + Quarto extension + Typst templates — three layers that must integrate cleanly
- **Dependencies**: cli, yaml, fs, rlang, quarto — keep lightweight for CRAN
- **Compatibility**: Must work with current Quarto (1.4+) and its bundled Typst
- **CRAN**: R CMD check must pass cleanly; proper DESCRIPTION, NAMESPACE, roxygen2 docs
- **Design**: Prefer Quarto conventions; metadata should be declarative; minimize magic; sensible defaults out of the box

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| All three formats in v1.0 (workingpaper, article, brief) | They share most Typst template layer; shipping together was marginal extra work | ✓ Satisfied |
| Depend on quarto R package | Needed for render wrappers; natural integration point | ✓ Satisfied |
| Target CRAN from the start | Enforces good package hygiene; broader distribution | ✓ Satisfied |
| Modular Typst templates | Separate .typ files for each concern — easier to maintain and customize | ✓ Satisfied |
| Branding via YAML, not Typst editing | Users should adapt output without touching Typst internals | ✓ Satisfied |
| Structured diagnostics foundation first in v1.1 | Locking schema and codes before broader validation prevents drift and brittle tests | ✓ Satisfied (Phase 05) |
| Shared preflight validator across standalone + render paths in v1.1 | One validation path prevents drift between `validate_render_environment()` and `render_pub()` and preserves stable diagnostics semantics | ✓ Satisfied (Phase 06) |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `$gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `$gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-04-01 after completing Phase 06*
