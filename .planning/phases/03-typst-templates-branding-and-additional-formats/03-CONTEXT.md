# Phase 3: Typst Templates, Branding, and Additional Formats - Context

**Gathered:** 2026-03-23
**Status:** Ready for planning

<domain>
## Phase Boundary

Refactor the monolithic Typst template into modular .typ files, implement all 9 YAML-driven branding hooks, create article and policy-brief format overlays with format-specific scaffolding functions, add anonymized mode for articles, and fix Phase 2 styling issues (email escaping, affiliation superscripts). After this phase, users can produce polished, institutionally branded PDFs across all three formats using only YAML.

**Key context:** The user's institute is currently redesigning their paper templates. Phase 3 should build flexible infrastructure with sensible defaults, not lock down specific visual designs. The system must be easy to adapt when final templates arrive.

</domain>

<decisions>
## Implementation Decisions

### Branding hook behavior
- Build all 9 branding hooks from BRANDIN_HOOKS.md with sensible defaults: logo, primary-font, title-font, margins, title-page-style, accent-color, report-number-block, footer, disclaimer-page
- Each hook has a clean academic default that works out of the box; users override via typstR: YAML namespace per document
- Branding is per-document (YAML front matter), not per-format — supports multi-institution co-authored papers by changing logo/footer/disclaimer in the document's YAML
- All three formats share the same branding hooks — format differences are structural (which sections appear), not branding
- Infrastructure priority: build flexible hooks now, visual design can be refined later when institute templates are finalized

### Article format
- Minimal differences from working paper: same layout, no report-number block, no disclaimer page by default
- Adds anonymized mode: `typstR: anonymized: true` strips authors, affiliations, ORCID, email, corresponding markers, and acknowledgements. Keeps title, abstract, keywords, JEL, body text
- Shares all branding hooks with working paper

### Policy-brief format
- Shorter, more accessible than working paper: "Summary" label instead of "Abstract", no JEL codes, no appendix lettered numbering, no ORCID display
- Same branding hooks as other formats
- Designed for non-academic readers

### Disclaimer page
- Available for all three formats (not working-paper-only)
- Configurable position: `typstR: disclaimer-position: "first"` or `"last"` (default: "last")
- Customizable text: `typstR: disclaimer-text: "Views expressed..."` with a generic default
- Enabled with `typstR: disclaimer-page: true`

### Modular template architecture
- Shared base modules + thin format overlays: base.typ, titleblock.typ, authors.typ, abstract.typ, bibliography.typ, appendix.typ, branding.typ, disclaimer.typ
- Three thin format files: workingpaper.typ (enables all sections), article.typ (disables report-number, adds anonymized mode), brief.typ ("Summary" label, no JEL, simpler layout)
- Format overlays configure which sections appear/hide, not duplicate shared logic

### Scaffolding for additional formats
- create_article() and create_policy_brief() produce the same file structure as create_working_paper(): template.qmd + _quarto.yml + references.bib + _extensions/typstR/
- Only the template.qmd YAML front matter differs (format-appropriate fields and defaults)
- Same cli-styled success summary pattern as create_working_paper()

### Phase 2 styling fixes (carried forward)
- Fix author email backslash escaping (`\@` → proper `@` in Typst output)
- Implement academic-style affiliation superscripts (Author¹², with numbered affiliations below)

### Claude's Discretion
- Exact default values for each branding hook (font choices, margin sizes, accent color)
- Typst #import patterns for modular file structure
- How the _extension.yml registers multiple formats (or if one format key handles all via configuration)
- Internal Typst function signatures for module interfaces
- Exact disclaimer page styling (font size, spacing, centering)
- How anonymized mode is wired through typst-show.typ (conditional variable passing)
- Default disclaimer text content

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project architecture
- `.planning/PROJECT.md` — Core value, constraints, key decisions (YAML-driven branding, all three formats in v0.1)
- `.planning/REQUIREMENTS.md` — Phase 3 requirements: TMPL-01 through TMPL-13, SCAF-02, SCAF-03
- `.planning/ROADMAP.md` — Phase 3 success criteria and dependency chain

### Design specifications
- `BRANDIN_HOOKS.md` — All 9 branding hooks specification (logo, primary-font, title-font, margins, title-page-style, accent-color, report-number-block, footer, disclaimer-page)
- `BLUEPRINT.md` §7 — Scaffolding function signatures for create_article(), create_policy_brief()
- `STRUCTURE.md` — Target modular .typ file structure

### Existing implementation (Phase 1 + 2)
- `inst/quarto/extensions/typstR/typst-template.typ` — Current monolithic template to be refactored into modules
- `inst/quarto/extensions/typstR/typst-show.typ` — Current Pandoc variable bridge (all metadata fields wired)
- `inst/quarto/extensions/typstR/_extension.yml` — Current extension config (single `typst` format key)
- `R/create_working_paper.R` — Scaffolding pattern to replicate for create_article(), create_policy_brief()
- `R/render.R` — render_working_paper() pattern to replicate for render_article(), render_policy_brief() if needed

### Research
- `.planning/research/PITFALLS.md` — Quarto extension naming, Typst version constraints
- `.planning/research/FEATURES.md` — Feature analysis, format differentiation patterns
- `.planning/phases/02-metadata-helpers-and-yaml-interface/02-RESEARCH.md` — Quarto 1.8 compatibility findings (format key must be 'typst', by-author normalization)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `R/create_working_paper.R` — Scaffolding pattern (error on existing dir, template copy, extension copy, cli summary) to be reused for create_article() and create_policy_brief()
- `inst/quarto/extensions/typstR/typst-template.typ` — All metadata rendering logic to be refactored into modules
- `inst/quarto/extensions/typstR/typst-show.typ` — Complete Pandoc variable bridge; may need extension for branding fields and anonymized mode

### Established Patterns
- **Quarto 1.8 format key**: Must be `typst` in _extension.yml; user-facing format is `typstR-typst`
- **Dictionary access**: `.at('field', default: '')` for safe field access in Typst
- **Author normalization**: `$for(by-author)$` / `it.name.literal` / `it.attributes.corresponding`
- **Content blocks**: `[...]` for free-text Typst fields passed through Pandoc
- **Scaffolding**: fs::file_copy() for templates, fs::dir_copy() for extension

### Integration Points
- `_extension.yml` — May need multiple format entries or configuration to support three formats
- `typst-show.typ` — Must pass branding YAML fields + anonymized flag to Typst template
- `NAMESPACE` — Needs new exports: create_article, create_policy_brief (and possibly render_article, render_policy_brief)
- `inst/templates/` — Needs article/ and policy-brief/ subdirectories with format-specific template.qmd files

</code_context>

<specifics>
## Specific Ideas

- Build for flexibility: sensible defaults now, easy to customize when institute templates finalize
- Per-document YAML branding enables multi-institution co-authored papers without any code changes
- Keep format differences minimal and structural — the three formats share most logic via modules
- Anonymized mode strips authors, affiliations, and acknowledgements (which often reveal identity)

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 03-typst-templates-branding-and-additional-formats*
*Context gathered: 2026-03-23*
