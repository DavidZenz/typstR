# Roadmap: typstR

## Overview

typstR ships as four sequential phases that respect a strict dependency chain: the render pipeline must work before YAML wiring can be tested; YAML wiring must be stable before the Typst template layer is meaningful; and additional formats are thin overlays once the base template exists. Phase 4 closes the loop with tests, documentation, and CRAN compliance after the full feature surface is defined.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Skeleton and Pipeline** - CRAN-ready package skeleton, extension bundling, scaffolding for working papers, and an end-to-end render that produces a PDF (completed 2026-03-22)
- [x] **Phase 2: Metadata Helpers and YAML Interface** - All R metadata helper functions and systematic YAML-to-Typst wiring via typst-show.typ (completed 2026-03-23)
- [ ] **Phase 3: Typst Templates, Branding, and Additional Formats** - Modular Typst template layer, full branding YAML roundtrip, article and policy-brief formats, and format-specific scaffolding
- [ ] **Phase 4: Tests, Documentation, and CRAN Hardening** - Full test suite, all vignettes, roxygen2 docs, and R CMD check clean across environments without Quarto

## Phase Details

### Phase 1: Skeleton and Pipeline
**Goal**: Researchers can scaffold a working paper project with one function call and render it to a real PDF
**Depends on**: Nothing (first phase)
**Requirements**: FOUN-01, FOUN-02, FOUN-03, FOUN-04, FOUN-05, SCAF-01
**Success Criteria** (what must be TRUE):
  1. `library(typstR)` loads without errors in a clean R session and R CMD check passes
  2. `create_working_paper("my-paper")` creates a project directory with template.qmd, _quarto.yml, references.bib, and a populated _extensions/typstR/ tree
  3. `render_pub("my-paper/template.qmd")` produces a PDF without errors on any machine with Quarto installed
  4. `render_working_paper("my-paper/template.qmd")` works as a convenience alias and produces the same PDF
  5. The extension is discovered by Quarto from _extensions/ in the user project, not from the R package install path
**Plans:** 3/3 plans complete

Plans:
- [x] 01-01-PLAN.md -- Package skeleton and Quarto extension with Typst template
- [ ] 01-02-PLAN.md -- Scaffolding function and template files
- [ ] 01-03-PLAN.md -- Render wrappers (render_pub, render_working_paper)

### Phase 2: Metadata Helpers and YAML Interface
**Goal**: Users can express all manuscript metadata in R or YAML and have it appear correctly in the rendered PDF
**Depends on**: Phase 1
**Requirements**: META-01, META-02, META-03, META-04, META-05, META-06, META-07, META-08, META-09, META-10, YAML-01, YAML-02, YAML-03
**Success Criteria** (what must be TRUE):
  1. `author()` and `affiliation()` produce R objects that serialize to valid Quarto author YAML, with ORCID, corresponding-author marker, and shared-affiliation edge cases all handled correctly
  2. `manuscript_meta()` combining authors, JEL codes, keywords, funding, and report number writes a valid YAML block that renders all fields in the PDF without silent data loss
  3. `fig_note()` and `tab_note()` produce styled notes below figures and tables in the rendered PDF
  4. All `typstR:` namespace fields in YAML front matter survive the Pandoc metadata pipeline and appear in the Typst template output for Quarto >= 1.4.11
  5. Standard Quarto fields (toc, fig-cap-location, etc.) continue to work alongside typstR: namespace fields without conflict
**Plans:** 4/4 plans complete

Plans:
- [ ] 02-01-PLAN.md -- Core metadata helpers: author(), affiliation(), manuscript_meta()
- [ ] 02-02-PLAN.md -- Publication and notes helpers: keywords, jel_codes, fig_note, tab_note, etc.
- [ ] 02-03-PLAN.md -- YAML wiring: typst-show.typ, typst-template.typ, template.qmd
- [ ] 02-04-PLAN.md -- Integration tests and human PDF verification

### Phase 3: Typst Templates, Branding, and Additional Formats
**Goal**: Users can produce polished, institutionally branded PDFs across all three formats using only YAML — no Typst editing required
**Depends on**: Phase 2
**Requirements**: TMPL-01, TMPL-02, TMPL-03, TMPL-04, TMPL-05, TMPL-06, TMPL-07, TMPL-08, TMPL-09, TMPL-10, TMPL-11, TMPL-12, TMPL-13, SCAF-02, SCAF-03
**Success Criteria** (what must be TRUE):
  1. The working paper PDF renders a complete title page (title, subtitle, report number, date), multi-author block with affiliations and ORCID, abstract with keywords and JEL codes, acknowledgements, bibliography, and appendix with separate lettered numbering
  2. Setting `typstR: logo:`, `accent-color:`, `primary-font:`, `footer:`, and `margins:` in YAML changes the rendered PDF without opening any .typ file
  3. Setting `typstR: disclaimer-page: true` appends a disclaimer page in working paper format
  4. `create_article()` scaffolds a project that renders a typstR-article PDF; setting `typstR: anonymized: true` strips author and affiliation blocks from the output
  5. `create_policy_brief()` scaffolds a project that renders a typstR-brief PDF with policy-brief layout
**Plans**: TBD

### Phase 4: Tests, Documentation, and CRAN Hardening
**Goal**: typstR passes R CMD check cleanly, is fully documented, and has a test suite that runs safely on CRAN machines without Quarto
**Depends on**: Phase 3
**Requirements**: DOCS-01, DOCS-02, DOCS-03, DOCS-04, DOCS-05, DOCS-06, TEST-01, TEST-02, TEST-03, TEST-04
**Success Criteria** (what must be TRUE):
  1. `R CMD check --as-cran` produces zero errors, zero warnings, and zero notes on a machine without Quarto installed
  2. All metadata helper functions have testthat tests that run in an isolated tempdir and do not require Quarto; render-dependent tests are guarded with `skip_if_not(quarto::quarto_available())`
  3. The getting-started vignette can be read without executing render calls (pre-rendered or guarded), and reproduces the full workflow from `create_working_paper()` to a rendered PDF
  4. Every exported function has roxygen2 documentation with at least one runnable example
  5. A user landing on the README can install the package and produce a working paper PDF by following the quick-start section alone
**Plans**: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Skeleton and Pipeline | 3/3 | Complete    | 2026-03-22 |
| 2. Metadata Helpers and YAML Interface | 4/4 | Complete    | 2026-03-23 |
| 3. Typst Templates, Branding, and Additional Formats | 0/TBD | Not started | - |
| 4. Tests, Documentation, and CRAN Hardening | 0/TBD | Not started | - |
