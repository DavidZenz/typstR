# Phase 1: Skeleton and Pipeline - Context

**Gathered:** 2026-03-22
**Status:** Ready for planning

<domain>
## Phase Boundary

CRAN-ready R package skeleton with Quarto extension bundled in inst/, a `create_working_paper()` scaffolding function that generates a complete project directory, and `render_pub()` / `render_working_paper()` wrappers that produce a real PDF. This phase proves the end-to-end pipeline: R package → extension copy → Quarto render → PDF output.

</domain>

<decisions>
## Implementation Decisions

### Starter template content
- Rich example template: scaffolded template.qmd includes placeholder title, author block, abstract, sections (Introduction, Data and Methods, Results, Conclusion), and a bibliography citation
- references.bib ships with 1-2 dummy entries; template.qmd cites them so bibliography renders on first build
- `create_working_paper()` accepts a `title` argument that pre-fills the YAML title field (like usethis::create_package() patterns)
- Scaffolded project includes a `_quarto.yml` project file for proper Quarto project behavior

### Overwrite/conflict behavior
- `create_working_paper()` errors with a clear message if the target directory already exists — no overwrite, no force argument
- Extension is copied into `_extensions/typstR/` only during scaffolding, not on render
- `_extensions/` directory is created silently if it doesn't exist (expected for new projects)
- Scaffolding prints a cli-styled success summary showing all created files/directories (usethis-style checkmarks)

### Phase 1 Typst template scope
- Renders title, author names, abstract placeholder, and body text — enough to show the document has structure
- Single monolithic `typst-template.typ` file (plus `typst-show.typ` for Quarto's show rule) — no modular .typ files yet; refactor to modular structure in Phase 3
- Minimal academic styling: serif body font, ~1 inch margins, page numbers, clear title hierarchy — looks intentional, not broken

### Render wrapper behavior
- `render_pub()` checks Quarto availability before rendering; gives clear error message if Quarto is not installed
- Auto-detects input file: if input is a directory, finds the .qmd; if NULL, looks in current directory
- Opens PDF in system viewer after render, controlled by `open = interactive()` argument
- `quiet = FALSE` by default (shows Quarto output); `quiet = TRUE` suppresses it
- Renders any Quarto document — no format gatekeeping
- Does NOT return output path invisibly (not selected)
- `render_working_paper()` is a thin alias: calls `render_pub(input, output_format = "typstR-workingpaper")` with no additional logic

### Claude's Discretion
- Exact placeholder text content in the template.qmd (lorem-style vs instructional)
- Dummy .bib entry topics/content
- Exact _quarto.yml content (minimal project config)
- Specific serif font choice and exact margin values for Phase 1 Typst template
- Error message wording for scaffolding conflicts and missing Quarto
- Internal helper function organization (utils.R structure)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project architecture
- `.planning/PROJECT.md` — Core value, constraints, key decisions (three-layer architecture, CRAN target, YAML-driven branding)
- `.planning/REQUIREMENTS.md` — Phase 1 requirements: FOUN-01 through FOUN-05, SCAF-01
- `.planning/ROADMAP.md` — Phase 1 success criteria and dependency chain

### Design specifications
- `BLUEPRINT.md` — Proposed exported functions with signatures, YAML interface example, MVP feature set
- `STRUCTURE.md` — Target file/directory structure for the complete package
- `BRANDIN_HOOKS.md` — Branding customization hooks (Phase 3, but informs extension structure)

### Research
- `.planning/research/ARCHITECTURE.md` — Three-layer architecture patterns, extension bundling in inst/
- `.planning/research/PITFALLS.md` — Extension copy mechanism gotchas, CRAN vignette guards, Quarto working directory behavior
- `.planning/research/STACK.md` — Tech stack: R 4.1.0+, Quarto 1.4+, dependencies (cli, yaml, fs, rlang, quarto)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- None — codebase is empty. Phase 1 creates everything from scratch.

### Established Patterns
- No existing patterns. Phase 1 establishes the conventions for the project:
  - R file organization (one file per concern vs grouped)
  - cli messaging style
  - Template interpolation approach (whisker or string replacement)

### Integration Points
- `quarto::quarto_render()` — primary render backend
- `quarto::quarto_available()` — Quarto detection (needed for pre-render check)
- `fs::dir_copy()` or `file.copy()` — extension copy mechanism from inst/ to user project
- `cli::cli_alert_success()` family — user-facing messages

</code_context>

<specifics>
## Specific Ideas

- Scaffolding should feel like `usethis::create_package()` — cli-styled output with checkmarks for each created artifact
- First render must produce a PDF that looks like an intentional academic document, not a raw Typst default
- The rich template should demonstrate the full metadata surface (title, subtitle, author, affiliation, abstract, keywords, JEL, acknowledgements, report number) even though most won't render styled until Phase 2-3

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 01-skeleton-and-pipeline*
*Context gathered: 2026-03-22*
