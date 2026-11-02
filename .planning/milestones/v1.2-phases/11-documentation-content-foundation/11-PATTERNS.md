# Phase 11: Documentation Content Foundation - Pattern Map

**Mapped:** 2026-06-01  
**Files analyzed:** 13  
**Analogs found:** 12 / 13

Locked choice applied: use `pkgdown/index.md` as the dedicated pkgdown home-page source.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `README.md` | component | transform | `README.md` | exact |
| `pkgdown/index.md` | component | transform | `README.md` | role-match |
| `vignettes/getting-started.Rmd` | component | transform | `vignettes/getting-started.Rmd` | exact |
| `vignettes/working-papers.Rmd` | component | transform | `vignettes/working-papers.Rmd` | exact |
| `vignettes/customizing-branding.Rmd` | component | transform | `vignettes/customizing-branding.Rmd` | exact |
| `R/create_working_paper.R` | service | file-I/O | `R/create_working_paper.R` | exact |
| `R/render.R` | service | file-I/O | `R/render.R` | exact |
| `R/validation_environment.R` | utility | request-response | `R/render.R` | role-match |
| `R/typstR-package.R` | utility | transform | `R/typstR-package.R` | exact |
| `man/*.Rd` | utility | transform | `man/create_working_paper.Rd` | role-match |
| `NEWS.md` | component | transform | — | none |
| `.gitignore` | config | transform | `.gitignore` | exact |
| `.Rbuildignore` | config | transform | `.Rbuildignore` | exact |

## Pattern Assignments

### `README.md` (component, transform)

**Analog:** `README.md`

**Outcome-first opener** (lines 1-3):
```markdown
# typstR

`typstR` is an R package for researchers and policy teams who want a fast path from a Quarto manuscript to a polished Typst PDF.
```

**Install block** (lines 5-9):
```r
## Installation

remotes::install_github("DavidZenz/typstR")
```

**Canonical scaffold -> edit -> render flow** (lines 11-31):
```markdown
## Quick start

Create a new working paper project:

library(typstR)
create_working_paper("my-paper")

This creates a project directory with `template.qmd`, `_quarto.yml`, `references.bib`, and the bundled `typstR` Quarto extension.

Edit the manuscript in `my-paper/template.qmd`...

render_working_paper("my-paper/template.qmd")
```

**Follow-on formats stay secondary** (lines 33-42):
```r
create_article("my-article")
create_policy_brief("my-brief")
```

**Prerequisite wording should match package metadata**  
Primary source: `DESCRIPTION` lines 13-17
```text
SystemRequirements: quarto
Imports:
    cli (>= 3.6.0),
    fs (>= 1.6.0),
    quarto (>= 1.4)
```

---

### `pkgdown/index.md` (component, transform)

**Closest analog:** `README.md`  
**Secondary analog:** `vignettes/getting-started.Rmd`

**Use the README tone, not the full depth** (from `README.md` lines 1-3, 11-21):
```markdown
`typstR` is an R package for researchers and policy teams who want a fast path from a Quarto manuscript to a polished Typst PDF.

Create a new working paper project:
...
This creates a project directory with `template.qmd`, `_quarto.yml`, `references.bib`, and the bundled `typstR` Quarto extension.
```

**Use the getting-started file list and article handoff** (from `vignettes/getting-started.Rmd` lines 32-38, 114-120):
```markdown
This creates a small project with:

- `template.qmd` for the manuscript
- `_quarto.yml` for project settings
- `references.bib` for bibliography entries
- the bundled `typstR` extension used by the template

- `vignette("working-papers", package = "typstR")`
- `vignette("customizing-branding", package = "typstR")`
```

**Planner note:** keep `pkgdown/index.md` lighter than the article; it should orient and link, not absorb the full walkthrough.

---

### `vignettes/getting-started.Rmd` (component, transform)

**Analog:** `vignettes/getting-started.Rmd`

**Vignette header + chunk setup** (lines 1-15):
```yaml
---
title: "Getting Started"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Getting Started}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---
```

```r
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
```

**Canonical onboarding narrative** (lines 17-38):
```markdown
`typstR` is built around one fast path: scaffold a working paper, edit one
Quarto file, and render a PDF when Quarto is available.

- `template.qmd`
- `_quarto.yml`
- `references.bib`
- the bundled `typstR` extension
```

**Concrete YAML example** (lines 39-56):
```yaml
typstR:
  keywords:
    - supply chains
    - trade policy
  jel:
    - F14
    - F13
  report-number: "WP 001"
  funding: |
    This research was supported by the Applied Trade Policy Programme.
```

**Quarto-safe render pattern** (lines 91-112):
```r
render_working_paper("my-paper/template.qmd")

quarto_ready <- quarto::quarto_available()
quarto_ready

if (quarto::quarto_available()) {
  render_working_paper("my-paper/template.qmd")
}
```

---

### `vignettes/working-papers.Rmd` (component, transform)

**Analog:** `vignettes/working-papers.Rmd`

**Specialized intro, not a full re-intro** (lines 19-21):
```markdown
This vignette focuses on the metadata surface of the working paper format. The
goal is to keep the Quarto file readable while still capturing the fields that
usually appear on an academic title page.
```

**Metadata-helper example pattern** (lines 23-47):
```r
authors <- list(
  author(
    "Elena Fischer",
    email = "elena.fischer@example.org",
    corresponding = TRUE,
    affiliation = "1"
  ),
  author(
    "Martin Kovac",
    affiliation = c("1", "2")
  )
)

affiliations <- list(
  affiliation("1", "Centre for European Industrial Analysis"),
  affiliation("2", "University of Bratislava")
)

manuscript_meta(authors = authors, affiliations = affiliations)
```

**Working-paper-specific YAML depth** (lines 49-70):
```yaml
abstract: |
  This working paper studies how manufacturing firms adjust supplier networks
  after trade policy shocks.
typstR:
  keywords:
    - supply chains
    - trade policy
    - firm adjustment
  jel:
    - F14
    - F13
  report-number: "WP 001"
```

**Link-back pattern** (lines 103-104):
```markdown
For the full scaffold-to-render flow, see
`vignette("getting-started", package = "typstR")`.
```

---

### `vignettes/customizing-branding.Rmd` (component, transform)

**Analog:** `vignettes/customizing-branding.Rmd`

**Practical YAML-first framing** (lines 17-24):
```markdown
`typstR` exposes branding through YAML fields in `template.qmd`. The intended
workflow is to edit those fields in Quarto, not to patch the shipped Typst
template.

## Start from the commented branding block
```

**Commented starter-block pattern** (lines 25-33):
```yaml
typstR:
  # logo: "logo.png"
  # accent-color: "#0A5DA6"
  # primary-font: "Linux Libertine"
  # footer: "Working Paper Series"
  # disclaimer-page: true
```

**Small, isolated YAML knob examples** (lines 41-45, 68-74):
```yaml
typstR:
  logo: "logo.png"
  accent-color: "#0A5DA6"
```

```yaml
typstR:
  margins:
    x: 1.1in
    y: 1in
  disclaimer-page: true
```

**Do not evaluate render in-vignette** (lines 79-86):
```r
render_working_paper("my-paper/template.qmd")
```

---

### `R/create_working_paper.R` (service, file-I/O)

**Analog:** `R/create_working_paper.R`

**Roxygen block pattern** (lines 1-19):
```r
#' Create a working paper project
#'
#' Scaffolds a new working paper project directory with a Quarto document,
#' bibliography, project configuration, and the typstR Quarto extension.
#'
#' @param path Path to the new project directory. Must not already exist.
#' @param title Optional title to pre-fill in the template YAML.
#' @param open Whether to open the project directory. Defaults to `TRUE`
#'   in interactive sessions.
#' @return The project path, invisibly.
#' @examples
#' \dontrun{
#' create_working_paper(
#'   "my-working-paper",
#'   title = "Trade, Policy, and Growth",
#'   open = FALSE
#' )
#' }
#' @export
```

**Tiny wrapper implementation** (lines 20-27):
```r
create_working_paper <- function(path, title = NULL, open = interactive()) {
  scaffold_project_from_template(
    path = path,
    template_dir = "workingpaper",
    success_label = "working paper",
    title = title
  )
}
```

---

### `R/render.R` (service, file-I/O)

**Analog:** `R/render.R`

**Base render-doc block** (lines 1-24):
```r
#' Render a Quarto document to PDF
#'
#' Renders a Quarto document using the Quarto CLI after running shared
#' pre-render environment validation checks.
#'
#' @param input Path to a `.qmd` file, a directory containing a `.qmd` file,
#'   or `NULL` to look in the current directory.
#' @param output_format Quarto output format name (e.g., `"typstR-typst"`).
#'   If `NULL`, uses the format specified in the document YAML.
#' @param quiet If `TRUE`, suppresses Quarto output. Defaults to `FALSE`.
#' @param open If `TRUE`, opens the rendered PDF in the system viewer.
#'   Defaults to `TRUE` in interactive sessions.
```

**Core render flow** (lines 25-47):
```r
validate_render_environment(if (is.null(input)) "." else input)
resolved_input <- resolve_input(input)

quarto::quarto_render(
  input = resolved_input,
  output_format = output_format,
  quiet = quiet
)

if (open) {
  pdf_path <- fs::path_ext_set(resolved_input, "pdf")
  open_file(pdf_path)
}
```

**Convenience-wrapper pattern** (lines 49-69):
```r
#' Render a working paper to PDF
#'
#' Convenience wrapper that renders a document using the `typstR-workingpaper`
#' format.
#' @inheritParams render_pub
#' @return `NULL`, invisibly.
#' @examples
#' \dontrun{
#' render_working_paper("my-working-paper/template.qmd", quiet = TRUE, open = FALSE)
#' }
```

---

### `R/validation_environment.R` (utility, request-response)

**Closest analog:** `R/render.R` for example style  
**Self analog:** `R/validation_environment.R` for return/diagnostic wording

**User-facing roxygen contract** (lines 1-10):
```r
#' Validate render environment prerequisites
#'
#' Runs pre-render environment checks for Quarto/Typst/runtime prerequisites and
#' confirms the typstR extension is present in the target project.
#'
#' @param path Project path to validate. Defaults to current directory.
#' @return A `typstR_validation_report` object when all checks pass.
#'   On failure, aborts with class `typstR_diagnostics_error` and structured
#'   diagnostics payload.
#' @export
```

**Success object shape** (lines 15-23):
```r
return(structure(
  list(
    ok = TRUE,
    path = normalized_path,
    checks = checks
  ),
  class = c("typstR_validation_report", "list")
))
```

**Prerequisite/error wording to mirror in docs** (lines 274-291):
```r
hint = "Install Quarto from https://quarto.org and ensure it is on PATH.",
message = "Quarto is not installed or not on PATH.",
...
hint = "Run `quarto typst --version` and reinstall Quarto if Typst support is missing.",
message = "Typst is not available through the Quarto CLI.",
```

**Example convention to copy in this file:** use the `\dontrun{}` style from `R/render.R` lines 14-23 for any new `@examples` block, because this function depends on local environment state.

---

### `R/typstR-package.R` (utility, transform)

**Analog:** `R/typstR-package.R`

**Package narrative pattern** (lines 1-12):
```r
#' typstR: Typst-Based Quarto Output Formats for Research Publications
#'
#' Helpers for scaffolding and rendering working papers, articles, and policy
#' briefs with shipped Typst-based Quarto formats.
#'
#' The package centers a YAML-driven workflow: create a starter project, edit
#' the `template.qmd`, and render a polished PDF without editing Typst source.
#'
#' @docType package
#' @name typstR-package
```

---

### `man/*.Rd` (utility, transform)

**Closest analogs:** `man/create_working_paper.Rd`, `man/render_pub.Rd`, `man/typstR-package.Rd`

**Generated-file header: do not hand-edit** (from `man/create_working_paper.Rd` lines 1-2):
```text
% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_working_paper.R
```

**Standard function-page structure** (from `man/create_working_paper.Rd` lines 3-33):
```text
\name{create_working_paper}
\alias{create_working_paper}
\title{Create a working paper project}
\usage{...}
\arguments{...}
\value{...}
\description{...}
\examples{...}
```

**Package-page structure** (from `man/typstR-package.Rd` lines 3-15):
```text
\docType{package}
\name{typstR-package}
\alias{typstR}
\title{typstR: Typst-Based Quarto Output Formats for Research Publications}
\description{...}
\details{...}
```

**Multi-call example block** (from `man/render_pub.Rd` lines 33-43):
```text
\examples{
\dontrun{
render_pub("my-working-paper/template.qmd", quiet = TRUE, open = FALSE)
render_pub(
  "my-article/template.qmd",
  output_format = "typstR-article",
  quiet = TRUE,
  open = FALSE
)
}
}
```

---

### `NEWS.md` (component, transform)

**No codebase analog exists. Use research guidance plus current markdown heading style.**

**Fallback source:** `.planning/phases/11-documentation-content-foundation/11-RESEARCH.md` lines 48-52
```markdown
`NEWS.md` is absent, and pkgdown expects version sections from level-one or level-two headings matching forms such as `{package name} 1.3.0` or `{package name} v1.3.0`.
```

**Package heading style source:** `README.md` line 1
```markdown
# typstR
```

**Planner note:** use the locked Phase 11 format `# typstR X.Y` for the v1.0, v1.1, and v1.2 milestone entries.

---

### `.gitignore` (config, transform)

**Analog:** `.gitignore`

**One-pattern-per-line glob style** (lines 1-10):
```gitignore
.Rproj.user
.Rhistory
.Rdata
.httr-oauth
.DS_Store
*.Rproj
src/*.o
src/*.so
src/*.dll
man/*.Rd
```

**Planner note:** preserve this plain-glob style and remove only the `man/*.Rd` ignore so generated Rd files can be committed.

---

### `.Rbuildignore` (config, transform)

**Analog:** `.Rbuildignore`

**Anchored-regex style** (lines 1-19):
```text
^\.claude$
^\.planning$
^BLUEPRINT\.md$
^BRANDIN_HOOKS\.md$
...
^\.github$
^LICENSE\.md$
^_extensions$
^.*\.Rproj$
^\.Rproj\.user$
```

**Planner note:** add pkgdown-only artifacts using this same anchored-regex pattern style (for example `^docs$`, and any pkgdown-only source dir if needed).

## Shared Patterns

### Onboarding story stays in one order
**Sources:** `README.md` lines 11-31; `vignettes/getting-started.Rmd` lines 17-38, 91-120; `vignettes/working-papers.Rmd` lines 103-104  
**Apply to:** `README.md`, `pkgdown/index.md`, all three vignettes, scaffold/render help pages
```markdown
create_working_paper("my-paper")
...
Edit `template.qmd`
...
render_working_paper("my-paper/template.qmd")
...
For the full scaffold-to-render flow, see
`vignette("getting-started", package = "typstR")`.
```

### Render-time prerequisite note
**Sources:** `DESCRIPTION` lines 13-17; `R/validation_environment.R` lines 274-291  
**Apply to:** `README.md`, `pkgdown/index.md`, `vignettes/getting-started.Rmd`, `R/render.R`, `R/validation_environment.R`
```text
SystemRequirements: quarto
...
message = "Quarto is not installed or not on PATH."
...
message = "Typst is not available through the Quarto CLI."
```

### Safe examples for file-system/render actions
**Sources:** `R/create_working_paper.R` lines 11-18; `R/render.R` lines 14-23, 56-59; `vignettes/customizing-branding.Rmd` lines 79-86  
**Apply to:** roxygen for scaffold/render/validation functions; any vignette render calls
```r
#' @examples
#' \dontrun{
#' create_working_paper("my-working-paper", open = FALSE)
#' }

#' \dontrun{
#' render_working_paper("my-working-paper/template.qmd", quiet = TRUE, open = FALSE)
#' }
```

### Source-driven reference docs
**Sources:** `man/create_working_paper.Rd` lines 1-2; `man/typstR-package.Rd` lines 3-15  
**Apply to:** all `R/*.R` roxygen edits and regenerated `man/*.Rd`
```text
% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_working_paper.R
```

### Ignore-vs-build-ignore split
**Sources:** `.gitignore` lines 1-10; `.Rbuildignore` lines 1-19  
**Apply to:** `.gitignore`, `.Rbuildignore`, generated `man/*.Rd`, pkgdown build outputs
```text
.gitignore      -> git tracking rules using plain glob lines
.Rbuildignore   -> source tarball exclusions using anchored regex lines
```

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `NEWS.md` | component | transform | No existing changelog file in the repo; use `.planning/phases/11-documentation-content-foundation/11-RESEARCH.md` lines 48-52 for pkgdown heading rules. |

## Metadata

**Analog search scope:** repo root docs, `vignettes/`, `R/`, `man/`, root ignore files, `DESCRIPTION`, `NAMESPACE`  
**Files scanned:** 20  
**Pattern extraction date:** 2026-06-01
