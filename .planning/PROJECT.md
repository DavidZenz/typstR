# typstR

## What This Is

An R package for creating publication-ready scientific documents using Quarto + Typst. typstR builds on top of Quarto's native Typst support to provide opinionated scientific publication formats, manuscript scaffolding, metadata helpers, institutional branding hooks, and reusable Typst templates. It targets researchers, economists, policy analysts, and institutes producing working papers, articles, and policy briefs.

## Core Value

Users can go from `create_working_paper("my-paper")` to a polished, branded PDF in minutes — no Typst or LaTeX knowledge required.

## Requirements

### Validated

<!-- Shipped and confirmed valuable. -->

(None yet — ship to validate)

### Active

<!-- Current scope. Building toward these. -->

- [ ] Quarto extension bundled inside the R package (inst/quarto/extensions/typstR/)
- [ ] Three publication formats: workingpaper, article, policy-brief
- [ ] Modular Typst template layer (base, titleblock, authors, abstract, bibliography, floats, appendix, branding)
- [ ] Project scaffolding functions: create_working_paper(), create_article(), create_policy_brief()
- [ ] Metadata helpers: author(), affiliation(), manuscript_meta(), funding(), data_availability(), code_availability()
- [ ] Publication helpers: jel_codes(), keywords(), fig_note(), tab_note(), appendix_title(), report_number()
- [ ] Validation/diagnostics: check_typst(), check_quarto(), check_typstR(), validate_manuscript()
- [ ] Render wrappers: render_pub(), render_working_paper()
- [ ] Branding hooks: logo, fonts, colors, margins, footer, disclaimer page — configurable via YAML
- [ ] Anonymized/review mode for article format
- [ ] YAML-driven metadata interface (typstR: block in front matter)
- [ ] Examples and starter templates for each format
- [ ] CRAN-ready package structure (R CMD check clean, proper DESCRIPTION/NAMESPACE)
- [ ] Documentation: README, vignettes (getting-started, working-papers, customizing-branding)
- [ ] Test suite covering metadata, validation, render helpers, and project creation

### Out of Scope

<!-- Explicit boundaries. Includes reasoning to prevent re-adding. -->

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

<!-- Decisions that constrain future work. Add throughout project lifecycle. -->

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| All three formats in v0.1 (workingpaper, article, brief) | They share most Typst template layer; shipping together is marginal extra work | — Pending |
| Depend on quarto R package | Needed for render wrappers; natural integration point | — Pending |
| Target CRAN from the start | Enforces good package hygiene; broader distribution | — Pending |
| Modular Typst templates | Separate .typ files for each concern (titleblock, authors, etc.) — easier to maintain and customize | — Pending |
| Branding via YAML, not Typst editing | Users should adapt output without touching Typst internals | — Pending |

---
*Last updated: 2026-03-21 after initialization*
