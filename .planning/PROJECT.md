# typstR

## What This Is

An R package for creating publication-ready scientific documents using Quarto + Typst. typstR builds on top of Quarto's native Typst support to provide opinionated scientific publication formats, manuscript scaffolding, metadata helpers, institutional branding hooks, and reusable Typst templates. It targets researchers, economists, policy analysts, and institutes producing working papers, articles, and policy briefs.

## Core Value

Users can go from `create_working_paper("my-paper")` to a polished, branded PDF in minutes — no Typst or LaTeX knowledge required.

## Current State

- **Latest shipped release:** v1.1 (2026-05-06)
- **Status:** Milestone v1.2 is active and currently defining requirements.
- **Previous Release:** v1.0 (Released 2026-03-23)
- **Milestone Archives:** [v1.0-ROADMAP.md](/Users/davidzenz/R/typstR/.planning/milestones/v1.0-ROADMAP.md), [v1.1-ROADMAP.md](/Users/davidzenz/R/typstR/.planning/milestones/v1.1-ROADMAP.md)

## Current Milestone

### v1.2 Documentation and Website Polish

**Goal:** Make typstR easier for new users to adopt with a publishable docs surface that guides them from install to scaffold to render.

**Target features:**
- Publishable pkgdown website
- Clear install / getting-started / reference / articles navigation
- Documentation polish centered on the onboarding flow

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
- [x] First-run onboarding reliability contract across workingpaper/article/brief scaffold paths (ONB-01) — validated in Phase 07, with Quarto-enabled human UAT persisted
- [x] Measured performance optimization contract with baseline-mapped gain/no-backslide assertions (PERF-01) — validated in Phase 08, with supported-environment human UAT persisted

- [x] Reliability/onboarding polish milestone archived with passed milestone audit and shipped supported-environment evidence — v1.1

### Active

- [ ] Publish a pkgdown website for typstR with clear navigation across installation, onboarding, reference, and articles.
- [ ] Strengthen onboarding documentation so new users can follow install -> scaffold -> render without friction.
- [ ] Align README, vignettes, and site structure so the docs surface tells one coherent story.

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
| Helper-driven onboarding matrix across all formats in v1.1 | Testing scaffold → validate → render through real create/render helpers reduces false confidence from template-only smoke checks | ✓ Satisfied (Phase 07) |
| Baseline-mapped performance contract for v1.1 | Explicit v1.0/current baseline artifacts plus executable gain/no-backslide assertions make optimization claims auditable and regression-safe | ✓ Satisfied (Phase 08) |
| Close milestone only after supported-environment evidence is captured | Runtime-gated claims for onboarding and performance should not archive on trust alone | ✓ Satisfied (Phases 09-10) |
| Focus v1.2 on docs discoverability and onboarding | Existing README/vignettes exist, but a publishable docs site is the fastest way to improve first-use adoption | — Pending |

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
*Last updated: 2026-06-01 after starting milestone v1.2*
