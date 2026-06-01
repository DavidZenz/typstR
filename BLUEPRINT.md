# typstR — Package Blueprint

## 1. Vision

**typstR** is an R package for creating publication-ready scientific
documents in **Quarto + Typst** with an R-native workflow.

It does **not** try to replace Quarto’s built-in Typst support. Instead,
it builds on top of it and provides:

- opinionated scientific publication formats
- manuscript scaffolding
- metadata helpers
- institutional branding hooks
- reusable Typst templates
- convenience wrappers for rendering and validation

## 2. Positioning

### Core value proposition

> “A polished R workflow for scientific and institutional PDF publishing
> with Quarto and Typst.”

### Why this package is useful

Quarto already supports Typst output and custom Typst formats, so the
gap is not basic compatibility. The gap is a cohesive, reusable,
R-friendly package that turns Quarto + Typst into a practical
publication workflow. Existing related tools such as `typr` and
`typstable` show that the ecosystem is real, but they do not by
themselves provide a complete manuscript framework.

### Primary target users

- researchers writing working papers
- economists and policy analysts
- institutes producing reports and briefs
- R users who want LaTeX-quality PDFs with a cleaner authoring
  experience
- teams that already use Quarto and want a more polished PDF workflow

## 3. Scope

## In scope for v0.1

- Quarto extension bundled inside an R package
- one high-quality base Typst format
- one or two publication presets
- manuscript scaffolding helpers
- metadata helpers
- render diagnostics
- examples and templates

## Out of scope initially

- full journal submission compatibility for many publishers
- direct import of LaTeX `.cls` or `.sty`
- a low-level Typst parser
- universal conversion from LaTeX to Typst
- extensive HTML/Word output support

## 4. Product concept

`typstR` consists of three layers:

### A. R package layer

Provides helpers such as: - project creation - metadata generation -
validation - render wrappers - utility functions for notes, appendices,
affiliations, etc.

### B. Quarto extension layer

Lives inside `inst/` and contains: - `_extension.yml` - format
definitions - partials - template assets - bundled Typst template files

### C. Typst template layer

Contains reusable Typst building blocks for: - title page - author and
affiliation block - abstract and keywords - bibliography - table and
figure styling - appendix handling - institutional branding

## 5. MVP

The first release should be intentionally narrow.

### Suggested MVP format

- `workingpaper_typst`

### Optional second format

- `article_typst`

### MVP feature set

- title
- subtitle
- authors and affiliations
- corresponding author
- abstract
- keywords
- JEL codes
- acknowledgements
- bibliography
- figure and table captions
- figure/table notes
- appendix
- report number
- logo support
- basic review/anonymized mode

## 6. User experience

The package should feel simple:

### Example workflow

1.  Create a project with
    [`create_working_paper()`](https://davidzenz.github.io/typstR/reference/create_working_paper.md)
2.  Edit the generated `.qmd`
3.  Fill metadata in YAML or helper functions
4.  Render with `quarto_render()` or
    [`typstR::render_pub()`](https://davidzenz.github.io/typstR/reference/render_pub.md)
5.  Get a polished Typst PDF

## 7. Proposed exported functions

### Project scaffolding

- `create_working_paper(path, title = NULL, open = interactive())`
- `create_article(path, title = NULL, open = interactive())`
- `create_policy_brief(path, title = NULL, open = interactive())`

### Metadata helpers

- `author(name, affiliation = NULL, email = NULL, orcid = NULL, corresponding = FALSE)`
- `affiliation(id, name, department = NULL, address = NULL, country = NULL)`
- `manuscript_meta(...)`
- `funding(text)`
- `data_availability(text)`
- `code_availability(text)`

### Publication helpers

- `jel_codes(...)`
- `keywords(...)`
- `fig_note(...)`
- `tab_note(...)`
- `appendix_title(...)`
- `report_number(...)`

### Validation and diagnostics

- `check_typst()`
- `check_quarto()`
- `check_typstR()`
- `validate_manuscript(path = ".")`

### Rendering

- `render_pub(input = NULL, output_format = NULL, quiet = FALSE)`
- `render_working_paper(input = NULL, quiet = FALSE)`

## 8. Suggested YAML interface

The package should support plain Quarto YAML with a small set of
`typstR` fields.

### Example

## \`\`\`yaml

title: “Trade Fragmentation and Industrial Policy” subtitle: “Evidence
from Central and Eastern Europe” author: - name: “Jane Doe” affiliation:
“1” email: “<jane@example.org>” corresponding: true - name: “John Smith”
affiliation: “2” affiliations: - id: “1” name: “Vienna Institute for
International Economic Studies” - id: “2” name: “University of
Somewhere” format: typstR-workingpaper: toc: true appendix: true logo:
“logo.png” typstR: abstract: \| This paper studies… keywords: \[“trade”,
“industrial policy”, “CEE”\] jel: \[“F10”, “F13”, “L52”\]
acknowledgements: \| We thank… report-number: “WP 001” —
