# Phase 2: Metadata Helpers and YAML Interface - Context

**Gathered:** 2026-03-23
**Status:** Ready for planning

<domain>
## Phase Boundary

All R metadata helper functions (author, affiliation, manuscript_meta, keywords, jel_codes, report_number, fig_note, tab_note, appendix_title, funding, data_availability, code_availability) and systematic YAML-to-Typst wiring via typst-show.typ. After this phase, users can express all manuscript metadata in R and have it appear correctly in the rendered PDF.

</domain>

<decisions>
## Implementation Decisions

### Helper return types and usage
- All metadata helpers return structured R lists that serialize to valid YAML via yaml::as.yaml()
- Each helper returns an S3-classed object (typstR_author, typstR_affiliation, typstR_meta, etc.) for type checking and custom print methods
- manuscript_meta() returns a combined R list — pure function, no side effects, no file writing
- Simple helpers (keywords, jel_codes, funding, etc.) use light validation: keywords checks inputs are character, jel_codes validates [A-Z][0-9]{1,2} pattern, funding/data_availability/code_availability wrap text

### Author/affiliation data model
- ID-based reference model following Quarto's native schema: author(affiliation = "1") links by ID, affiliations are separate objects
- author() supports: name, affiliation (character vector of IDs), email, orcid, corresponding (logical)
- affiliation() supports full fields: id, name, department, address, country (all optional except id and name)
- ORCID format validation: checks XXXX-XXXX-XXXX-XXXX pattern, no registry lookup
- manuscript_meta() cross-validates: every affiliation ID referenced by an author must have a matching affiliation() object; errors with clear message if dangling reference found

### fig_note / tab_note mechanism
- R functions called in code chunks with `#| output: asis`
- Return markdown strings via cat() — "*Note:* {text}" format
- No Lua filter needed; relies on Pandoc's markdown-to-Typst pipeline
- fig_note() and tab_note() are separate functions (not unified), allowing divergent styling in Phase 3
- appendix_title() follows the same pattern: R function, output: asis, emits markdown header with appendix formatting

### typst-show.typ wiring scope
- Claude's Discretion — not discussed explicitly. Phase 2 must wire all typstR: namespace fields (keywords, JEL, acknowledgements, report-number, funding, etc.) through typst-show.typ to the Typst template. The existing monolithic typst-template.typ will be extended to accept and render these new fields. Full modular refactor deferred to Phase 3.

### Claude's Discretion
- Exact S3 class names and print method formatting
- typst-show.typ Pandoc variable interpolation syntax for nested YAML fields
- How much of the Typst template to extend for Phase 2 rendering vs Phase 3 styling
- Internal helper function organization across R files
- Error message wording for validation failures
- Whether to add a `as.yaml()` S3 method or rely on yaml::as.yaml() with unclass()

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project architecture
- `.planning/PROJECT.md` — Core value, constraints, key decisions
- `.planning/REQUIREMENTS.md` — Phase 2 requirements: META-01 through META-10, YAML-01 through YAML-03
- `.planning/ROADMAP.md` — Phase 2 success criteria and dependency chain

### Design specifications
- `BLUEPRINT.md` §7 — Proposed function signatures for all metadata and publication helpers
- `BLUEPRINT.md` §8 — Suggested YAML interface with typstR: namespace example
- `STRUCTURE.md` — Target file/directory structure including R/ file layout

### Existing implementation (Phase 1)
- `R/create_working_paper.R` — Established patterns: cli messaging, fs usage, error handling style
- `R/utils.R` — Internal helper patterns (resolve_input, open_file)
- `R/render.R` — Quarto integration patterns
- `inst/quarto/extensions/typstR/typst-show.typ` — Current Pandoc variable bridge (title, authors, abstract only)
- `inst/quarto/extensions/typstR/typst-template.typ` — Current monolithic template accepting title, authors, abstract
- `inst/templates/workingpaper/template.qmd` — Current YAML structure in scaffolded template

### Research
- `.planning/research/PITFALLS.md` — YAML→Pandoc→Typst wiring gotchas, typstR: namespace behavior at Quarto 1.6 boundary
- `.planning/research/FEATURES.md` — Feature analysis including metadata helper patterns
- `.planning/research/ARCHITECTURE.md` — Three-layer architecture, extension structure

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `R/utils.R` — Internal helper pattern (resolve_input, open_file) establishes convention for non-exported functions
- `R/create_working_paper.R` — cli messaging pattern with cli_abort and cli_alert_success
- `inst/quarto/extensions/typstR/typst-show.typ` — Pandoc `$variable$` bridge syntax already working for title/authors/abstract

### Established Patterns
- **Error handling**: cli::cli_abort() with structured error messages (bullet points)
- **File operations**: fs package (fs::dir_copy, fs::file_copy, fs::path)
- **Package exports**: NAMESPACE generated by roxygen2 with @export
- **Quarto integration**: quarto::quarto_render(), quarto::quarto_available()
- **Template interpolation**: sub() for simple string replacement in template.qmd

### Integration Points
- `typst-show.typ` must be extended to wire new YAML fields (keywords, JEL, acknowledgements, etc.) to Typst template arguments
- `typst-template.typ` must be extended to accept and render the new metadata fields
- `inst/templates/workingpaper/template.qmd` YAML should be updated to demonstrate all typstR: namespace fields
- `NAMESPACE` needs new exports for all metadata helper functions

</code_context>

<specifics>
## Specific Ideas

- Helpers should feel like building blocks: author() + affiliation() + keywords() → manuscript_meta() → YAML
- The API should be familiar to users of Quarto's native author/affiliation schema — don't reinvent, extend
- JEL code validation pattern [A-Z][0-9]{1,2} catches common typos without being overly strict
- fig_note/tab_note via `output: asis` is the lightest-weight approach — no Lua filters, no custom Pandoc extensions

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 02-metadata-helpers-and-yaml-interface*
*Context gathered: 2026-03-23*
