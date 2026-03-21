# Requirements: typstR

**Defined:** 2026-03-21
**Core Value:** Users can go from `create_working_paper("my-paper")` to a polished, branded PDF in minutes — no Typst or LaTeX knowledge required.

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Package Foundation

- [ ] **FOUN-01**: Package has CRAN-ready skeleton (DESCRIPTION, NAMESPACE, roxygen2, R CMD check clean)
- [ ] **FOUN-02**: Quarto extension bundled in inst/quarto/extensions/typstR/ with _extension.yml
- [ ] **FOUN-03**: Extension copy mechanism copies extension into user project's _extensions/ on scaffold
- [ ] **FOUN-04**: render_pub() renders any typstR format to PDF via quarto::quarto_render()
- [ ] **FOUN-05**: render_working_paper() convenience wrapper for working paper format

### Scaffolding

- [ ] **SCAF-01**: create_working_paper() generates project with template.qmd, _quarto.yml, references.bib, and extension
- [ ] **SCAF-02**: create_article() generates project with article template and extension
- [ ] **SCAF-03**: create_policy_brief() generates project with policy brief template and extension

### Typst Templates

- [ ] **TMPL-01**: Base Typst template with page layout, fonts, margins, page numbering
- [ ] **TMPL-02**: Title page with title, subtitle, date
- [ ] **TMPL-03**: Author and affiliation block with corresponding author marker
- [ ] **TMPL-04**: Abstract block with keywords and JEL codes
- [ ] **TMPL-05**: Acknowledgements section
- [ ] **TMPL-06**: Bibliography rendering via Typst
- [ ] **TMPL-07**: Appendix handling with separate numbering
- [ ] **TMPL-08**: Figure and table caption styling with notes support
- [ ] **TMPL-09**: Modular .typ file structure (base, titleblock, authors, abstract, bibliography, floats, appendix, branding)
- [ ] **TMPL-10**: Branding via YAML: logo path, primary font, title font, accent color
- [ ] **TMPL-11**: Branding via YAML: page margins, footer text, report number block
- [ ] **TMPL-12**: Branding via YAML: disclaimer page support
- [ ] **TMPL-13**: Three format definitions: workingpaper, article, policy-brief in _extension.yml

### Metadata Helpers

- [ ] **META-01**: author() creates structured author metadata for YAML
- [ ] **META-02**: affiliation() creates structured affiliation metadata for YAML
- [ ] **META-03**: manuscript_meta() combines all metadata into valid YAML block
- [ ] **META-04**: keywords() helper for keyword metadata
- [ ] **META-05**: jel_codes() helper for JEL classification codes
- [ ] **META-06**: report_number() helper for institute report numbering
- [ ] **META-07**: fig_note() and tab_note() for figure/table notes
- [ ] **META-08**: appendix_title() helper for appendix sections
- [ ] **META-09**: funding() helper for funding statements
- [ ] **META-10**: data_availability() and code_availability() helpers

### YAML Interface

- [ ] **YAML-01**: typstR: namespace in YAML front matter for package-specific fields
- [ ] **YAML-02**: typst-show.typ correctly wires all YAML fields to Typst template variables
- [ ] **YAML-03**: Standard Quarto YAML fields (toc, fig-cap-location, etc.) work as expected

### Documentation

- [ ] **DOCS-01**: README with installation, quick start, minimal example
- [ ] **DOCS-02**: Getting-started vignette
- [ ] **DOCS-03**: Working-papers vignette
- [ ] **DOCS-04**: Customizing-branding vignette
- [ ] **DOCS-05**: roxygen2 documentation for all exported functions
- [ ] **DOCS-06**: Example .qmd files for each format in inst/

### Testing

- [ ] **TEST-01**: Test suite for metadata helper functions
- [ ] **TEST-02**: Test suite for validation functions
- [ ] **TEST-03**: Test suite for project scaffolding (file creation, structure)
- [ ] **TEST-04**: Tests guarded with skip_if_not(quarto_available()) for CRAN

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Validation

- **VALID-01**: check_quarto() verifies Quarto installation and version
- **VALID-02**: check_typst() verifies Typst availability through Quarto
- **VALID-03**: check_typstR() validates full environment setup
- **VALID-04**: validate_manuscript() checks metadata completeness, file existence, format validity

### Advanced Features

- **ADV-01**: Anonymized/review mode for article format (strips author info)
- **ADV-02**: RStudio project file integration in scaffolding
- **ADV-03**: Gallery of rendered examples in pkgdown site

## Out of Scope

| Feature | Reason |
|---------|--------|
| Full journal submission compatibility | Too broad for v0.1; revisit after base formats mature |
| LaTeX .cls/.sty import | Fundamentally different system; not a conversion tool |
| Low-level Typst parser | Unnecessary complexity; rely on Quarto's Typst integration |
| Universal LaTeX-to-Typst conversion | Out of mission |
| HTML/Word output support | Typst PDF is the focus |
| Custom table engine | Delegate to typstable, gt, tinytable; typstR handles layout only |
| Standalone Typst CLI dependency | Quarto bundles Typst; separate install violates CRAN norms |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| FOUN-01 | — | Pending |
| FOUN-02 | — | Pending |
| FOUN-03 | — | Pending |
| FOUN-04 | — | Pending |
| FOUN-05 | — | Pending |
| SCAF-01 | — | Pending |
| SCAF-02 | — | Pending |
| SCAF-03 | — | Pending |
| TMPL-01 | — | Pending |
| TMPL-02 | — | Pending |
| TMPL-03 | — | Pending |
| TMPL-04 | — | Pending |
| TMPL-05 | — | Pending |
| TMPL-06 | — | Pending |
| TMPL-07 | — | Pending |
| TMPL-08 | — | Pending |
| TMPL-09 | — | Pending |
| TMPL-10 | — | Pending |
| TMPL-11 | — | Pending |
| TMPL-12 | — | Pending |
| TMPL-13 | — | Pending |
| META-01 | — | Pending |
| META-02 | — | Pending |
| META-03 | — | Pending |
| META-04 | — | Pending |
| META-05 | — | Pending |
| META-06 | — | Pending |
| META-07 | — | Pending |
| META-08 | — | Pending |
| META-09 | — | Pending |
| META-10 | — | Pending |
| YAML-01 | — | Pending |
| YAML-02 | — | Pending |
| YAML-03 | — | Pending |
| DOCS-01 | — | Pending |
| DOCS-02 | — | Pending |
| DOCS-03 | — | Pending |
| DOCS-04 | — | Pending |
| DOCS-05 | — | Pending |
| DOCS-06 | — | Pending |
| TEST-01 | — | Pending |
| TEST-02 | — | Pending |
| TEST-03 | — | Pending |
| TEST-04 | — | Pending |

**Coverage:**
- v1 requirements: 43 total
- Mapped to phases: 0
- Unmapped: 43

---
*Requirements defined: 2026-03-21*
*Last updated: 2026-03-21 after initial definition*
