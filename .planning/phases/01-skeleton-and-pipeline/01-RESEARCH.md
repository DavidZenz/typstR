# Phase 1: Skeleton and Pipeline - Research

**Researched:** 2026-03-22
**Domain:** R package skeleton (CRAN-ready), Quarto extension bundling, Typst minimal template, scaffolding + render wrappers
**Confidence:** HIGH (core R toolchain, extension structure); MEDIUM (Typst syntax for minimal template, typst-show.typ wiring patterns)

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Starter template content**
- Rich example template: scaffolded template.qmd includes placeholder title, author block, abstract, sections (Introduction, Data and Methods, Results, Conclusion), and a bibliography citation
- references.bib ships with 1-2 dummy entries; template.qmd cites them so bibliography renders on first build
- `create_working_paper()` accepts a `title` argument that pre-fills the YAML title field (like usethis::create_package() patterns)
- Scaffolded project includes a `_quarto.yml` project file for proper Quarto project behavior

**Overwrite/conflict behavior**
- `create_working_paper()` errors with a clear message if the target directory already exists — no overwrite, no force argument
- Extension is copied into `_extensions/typstR/` only during scaffolding, not on render
- `_extensions/` directory is created silently if it doesn't exist (expected for new projects)
- Scaffolding prints a cli-styled success summary showing all created files/directories (usethis-style checkmarks)

**Phase 1 Typst template scope**
- Renders title, author names, abstract placeholder, and body text — enough to show the document has structure
- Single monolithic `typst-template.typ` file (plus `typst-show.typ` for Quarto's show rule) — no modular .typ files yet; refactor to modular structure in Phase 3
- Minimal academic styling: serif body font, ~1 inch margins, page numbers, clear title hierarchy — looks intentional, not broken

**Render wrapper behavior**
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

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| FOUN-01 | Package has CRAN-ready skeleton (DESCRIPTION, NAMESPACE, roxygen2, R CMD check clean) | usethis::create_package() + devtools workflow; DESCRIPTION SystemRequirements field for Quarto |
| FOUN-02 | Quarto extension bundled in inst/quarto/extensions/typstR/ with _extension.yml | _extension.yml structure verified; named format via contributes.formats.workingpaper (inherits typst); extension must physically live in user project _extensions/ |
| FOUN-03 | Extension copy mechanism copies extension into user project's _extensions/ on scaffold | fs::dir_copy() from system.file("quarto/extensions/typstR") into path/_extensions/typstR; verified pattern from open source R+Quarto packages |
| FOUN-04 | render_pub() renders any typstR format to PDF via quarto::quarto_render() | quarto::quarto_render() signature verified (quiet, output_format args exist); quarto_available() for pre-flight guard |
| FOUN-05 | render_working_paper() convenience wrapper for working paper format | Thin wrapper: calls render_pub(input, output_format = "typstR-workingpaper") |
| SCAF-01 | create_working_paper() generates project with template.qmd, _quarto.yml, references.bib, and extension | fs + system.file copy pattern; title interpolation in template.qmd; cli messaging |
</phase_requirements>

---

## Summary

Phase 1 creates an R package from scratch with a CRAN-ready skeleton, a bundled Quarto extension declaring the `typstR-workingpaper` format, a project scaffolding function, and two render wrappers. The critical architectural insight is that Quarto's extension resolution is strictly per-project — the extension must be physically copied from `inst/quarto/extensions/typstR/` into the user's project `_extensions/typstR/` directory at scaffold time. There is no global extension registry; `system.file()` alone is not sufficient.

The extension declares its format via `contributes.formats.workingpaper` in `_extension.yml`, which Quarto resolves as `typstR-workingpaper` (extension name + format key). The `typst-show.typ` file bridges YAML front matter fields to Typst function arguments using Pandoc's `$variable$` interpolation syntax. For Phase 1, the Typst template can be a single monolithic file (`typst-template.typ`) — the modular refactor is deferred to Phase 3.

The render wrappers are thin: `render_pub()` calls `quarto::quarto_render()` after a Quarto availability check and optional input auto-detection. `render_working_paper()` is an alias that passes `output_format = "typstR-workingpaper"`. The package has no existing code; everything is built from scratch.

**Primary recommendation:** Use `usethis::create_package()` to initialize the skeleton, then add all components incrementally with `devtools::load_all()` / `devtools::check()` as the verification loop. Build the extension files manually (not via `quarto install`) and verify the end-to-end render from a `tempdir()` before declaring Phase 1 complete.

---

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| R | >= 4.1.0 | Runtime minimum | Required by quarto R pkg; native pipe available |
| quarto (R pkg) | 1.5.1 (on CRAN) | Render wrappers, Quarto availability check | Official Posit package; `quarto_render()`, `quarto_available()`, `find_project_root()`; only CRAN option for Quarto CLI integration |
| cli | 3.6.5 (on CRAN) | User-facing messages, errors, success banners | r-lib standard; `cli_abort()`, `cli_alert_success()`, `cli_bullets()`; already installed |
| rlang | 1.1.6 (on CRAN; 1.1.7 latest) | Error conditions, `%||%`, defensive programming | Required by cli; classed conditions for testable errors |
| fs | 1.6.6 (on CRAN; 1.6.7 latest) | Path ops, dir creation, file copy | Cross-platform; `fs::dir_copy()`, `fs::dir_create()`, `fs::path()`; already installed |
| yaml | 2.3.10 (on CRAN) | YAML read/write for template interpolation | Already a quarto R pkg dependency; already installed |

### Development

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| devtools | 2.5.0 | load_all, check, install | Primary dev workflow loop |
| usethis | 3.2.1 | Package skeleton creation, CI, license | Package initialization; `use_package()`, `use_r()`, `use_testthat()` |
| testthat | 3.2.3 (on machine; 3.3.2 latest) | Unit testing | All R logic tests; withr integration for tempdir tests |
| withr | 3.0.2 | Isolated temp state in tests | `withr::local_tempdir()` for scaffold tests |
| roxygen2 | 7.3.3 | Rd documentation + NAMESPACE | Required for CRAN; run via `devtools::document()` |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| quarto R pkg | processx direct CLI calls | quarto pkg already wraps processx; no reason to go lower level |
| fs::dir_copy | base file.copy recursive | fs is already installed; cross-platform path handling is better |
| cli for messages | base message() / cat() | cli gives styled, suppressible, testable output matching usethis UX |

**Installation:**
```r
# Runtime (add to DESCRIPTION Imports:)
install.packages(c("cli", "rlang", "fs", "yaml", "quarto"))

# Development
install.packages(c("devtools", "usethis", "testthat", "withr", "roxygen2"))
```

**Verified versions (2026-03-22):**
- quarto: 1.5.1 (installed from CRAN on this machine)
- cli: 3.6.5, rlang: 1.1.6, fs: 1.6.6, yaml: 2.3.10 (all installed)
- testthat: 3.2.3, withr: 3.0.2, roxygen2: 7.3.3 (all installed)

---

## Architecture Patterns

### Recommended Project Structure (Phase 1 scope)

```
typstR/
├── DESCRIPTION                    # Package metadata + SystemRequirements: quarto
├── NAMESPACE                      # Generated by roxygen2
├── R/
│   ├── create_working_paper.R     # SCAF-01: scaffolding function
│   ├── render.R                   # FOUN-04, FOUN-05: render_pub() + render_working_paper()
│   └── utils.R                    # Internal helpers: find_qmd(), open_pdf()
│
├── inst/
│   ├── quarto/
│   │   └── extensions/
│   │       └── typstR/            # FOUN-02: the bundled Quarto extension
│   │           ├── _extension.yml
│   │           ├── typst-template.typ   # Phase 1: monolithic Typst template
│   │           └── typst-show.typ       # YAML → Typst variable bridge
│   └── templates/
│       └── workingpaper/          # SCAF-01: project skeleton files
│           ├── template.qmd
│           ├── _quarto.yml
│           └── references.bib
│
├── man/                           # FOUN-01: generated by roxygen2
└── tests/
    └── testthat/
        ├── test-create-working-paper.R
        └── test-render.R
```

Note: `logo.png` is NOT included in Phase 1 templates — the Typst template has no logo support yet. The Phase 1 template is minimal.

### Pattern 1: Extension-Copy Scaffolding (FOUN-02, FOUN-03, SCAF-01)

**What:** `create_working_paper()` uses `system.file()` to locate the bundled extension and `fs::dir_copy()` to copy it into the user's project `_extensions/typstR/` directory. This is the only mechanism Quarto supports — there is no global extension path.

**When to use:** Any `create_*()` function. Must happen at scaffold time, not at render time.

**Example:**
```r
# Source: ARCHITECTURE.md + verified against quartotemplate package pattern
create_working_paper <- function(path, title = NULL, open = interactive()) {
  # Guard: error if directory exists (locked decision)
  if (fs::dir_exists(path)) {
    cli::cli_abort(c(
      "Directory {.path {path}} already exists.",
      "i" = "Choose a different path or remove the existing directory."
    ))
  }

  # Create project directory
  fs::dir_create(path)

  # Copy starter template files
  template_src <- system.file("templates/workingpaper", package = "typstR",
                               mustWork = TRUE)
  fs::dir_copy(template_src, path, overwrite = FALSE)

  # Copy extension into _extensions/ within the new project (FOUN-03)
  ext_src <- system.file("quarto/extensions/typstR", package = "typstR",
                          mustWork = TRUE)
  ext_dest <- fs::path(path, "_extensions", "typstR")
  fs::dir_create(fs::path(path, "_extensions"))
  fs::dir_copy(ext_src, ext_dest, overwrite = FALSE)

  # Optionally pre-fill title in template.qmd (Claude's discretion: simple string replace)
  if (!is.null(title)) {
    qmd_path <- fs::path(path, "template.qmd")
    lines <- readLines(qmd_path)
    lines <- gsub("title: .*", paste0('title: "', title, '"'), lines)
    writeLines(lines, qmd_path)
  }

  # cli success summary (locked decision: usethis-style checkmarks)
  cli::cli_alert_success("Created working paper project at {.path {path}}")
  cli::cli_bullets(c(
    "*" = "{.file template.qmd}",
    "*" = "{.file _quarto.yml}",
    "*" = "{.file references.bib}",
    "*" = "{.file _extensions/typstR/}"
  ))

  invisible(path)
}
```

### Pattern 2: Quarto Extension Format Declaration (_extension.yml)

**What:** The `_extension.yml` declares the `workingpaper` format under `contributes.formats`. Quarto resolves this as `typstR-workingpaper` (extension directory name + format key). The extension must live in `_extensions/typstR/` for Quarto to find it.

**Critical:** The format key in `contributes.formats` is NOT `typst` — it is `workingpaper`. Quarto constructs the user-facing format name as `{extension-name}-{format-key}`.

**Example (_extension.yml):**
```yaml
# Source: Quarto extension format documentation + AMS template reference
title: typstR
author: typstR authors
version: "0.1.0"
quarto-required: ">=1.4.11"
contributes:
  formats:
    workingpaper:
      template-partials:
        - typst-template.typ
        - typst-show.typ
```

Users then write `format: typstR-workingpaper` in their document YAML.

### Pattern 3: typst-show.typ Variable Wiring

**What:** `typst-show.typ` uses Pandoc's `$variable$` template syntax to map YAML front matter fields to Typst function arguments. Conditional blocks (`$if()$`) handle optional fields. The `$body$` variable receives the rendered document body.

**Critical caveat:** Standard Quarto fields (`toc`, `fig-cap-location`, etc.) are consumed by Pandoc and do NOT pass through to `typst-show.typ`. Only fields in the `typstR:` namespace and non-standard fields reach this file. This is a Phase 2 concern — Phase 1 only needs `title`, `author`, `abstract`.

**Example (typst-show.typ for Phase 1 minimal template):**
```typst
// Source: AMS template pattern (github.com/quarto-ext/typst-templates) + Quarto docs
#import "typst-template.typ": working-paper

#show: working-paper.with(
  $if(title)$
  title: "$title$",
  $endif$
  $if(author)$
  authors: (
    $for(author)$
    (name: "$it.name.literal$"),
    $endfor$
  ),
  $endif$
  $if(abstract)$
  abstract: [$abstract$],
  $endif$
)
```

### Pattern 4: render_pub() Pre-flight + Quarto Delegation (FOUN-04)

**What:** `render_pub()` checks Quarto availability, auto-detects the input .qmd file, calls `quarto::quarto_render()`, then optionally opens the PDF.

**Do NOT:** call `quarto_render()` at package load time, do NOT shell out via `system()` or `processx` directly.

**Example:**
```r
# Source: quarto R pkg documentation; quarto_render() signature verified
render_pub <- function(input = NULL, output_format = NULL, quiet = FALSE,
                       open = interactive()) {
  # Pre-flight: Quarto availability (locked decision)
  if (!quarto::quarto_available()) {
    cli::cli_abort(c(
      "Quarto is not installed or not on PATH.",
      "i" = "Install Quarto from {.url https://quarto.org}."
    ))
  }

  # Input auto-detection (locked decision)
  input <- resolve_input(input)  # finds .qmd in directory or current dir

  # Render
  quarto::quarto_render(input = input, output_format = output_format,
                        quiet = quiet)

  # Open PDF (locked decision)
  if (open) {
    pdf_path <- fs::path_ext_set(input, "pdf")
    if (fs::file_exists(pdf_path)) utils::browseURL(pdf_path)
  }

  invisible(NULL)  # locked decision: does NOT return output path
}

render_working_paper <- function(input = NULL, quiet = FALSE,
                                 open = interactive()) {
  # Thin alias (locked decision)
  render_pub(input = input, output_format = "typstR-workingpaper",
             quiet = quiet, open = open)
}
```

### Pattern 5: Phase 1 Typst Template (typst-template.typ)

**What:** A single monolithic Typst file that defines a `working-paper` function with minimal academic styling. Phase 1 scope: renders title, authors, abstract, and body with serif font, ~1 inch margins, and page numbers.

**Critical:** Write Typst syntax compatible with the version bundled in Quarto 1.4.11 (minimum supported). Avoid `@preview` package imports (require network access). Avoid the `context` keyword if it was introduced in a later Typst version.

**Example (minimal typst-template.typ):**
```typst
// Phase 1: monolithic template — refactored to modular in Phase 3
// Compatible with Typst version bundled in Quarto >= 1.4.11

#let working-paper(
  title: none,
  authors: (),
  abstract: none,
  body,
) = {
  // Page setup
  set page(
    paper: "us-letter",
    margin: (x: 1in, y: 1in),
    numbering: "1",
  )

  // Typography
  set text(font: "Linux Libertine", size: 11pt)
  set par(justify: true, leading: 0.65em)
  set heading(numbering: "1.1")

  // Title block
  if title != none {
    align(center)[
      #text(size: 16pt, weight: "bold")[#title]
    ]
    v(0.5em)
  }

  // Authors
  if authors.len() > 0 {
    align(center)[
      #authors.map(a => a.name).join(", ")
    ]
    v(1em)
  }

  // Abstract
  if abstract != none {
    pad(x: 1.5cm)[
      *Abstract.* #abstract
    ]
    v(1em)
  }

  // Body
  body
}
```

### Anti-Patterns to Avoid

- **Registering extension globally:** Never tell users to `quarto install extension typstR/typstR`. Always copy into each project's `_extensions/` via `create_working_paper()`.
- **Skipping `mustWork = TRUE`:** Always pass `mustWork = TRUE` to `system.file()` for critical extension/template paths. Silent path failures produce cryptic render errors.
- **Calling `quarto_available()` at package load:** Never check Quarto in `.onLoad()` or `.onAttach()`. Only check lazily inside `render_pub()`.
- **Placing extension at `inst/extdata/_extensions/`:** Use `inst/quarto/extensions/typstR/` for explicit purpose signaling. `extdata/` can trigger CRAN size checks.
- **Using `format: typst` in _extension.yml:** The Phase 1 format key must be `workingpaper` so users write `format: typstR-workingpaper`, not `format: typstR-typst`.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| File path manipulation | Custom path string ops | `fs::path()`, `fs::dir_copy()`, `fs::path_ext_set()` | Cross-platform; handles edge cases on Windows |
| Quarto CLI invocation | `system()` / `processx` directly | `quarto::quarto_render()` | Official wrapper; handles path quoting, process lifecycle, error propagation |
| Quarto availability check | `Sys.which("quarto")` | `quarto::quarto_available()` | Handles PATH edge cases; returns logical cleanly |
| User-facing error messages | `stop()` / `message()` | `cli::cli_abort()` / `cli::cli_alert_success()` | Styled, class-able conditions; suppressible; usethis UX pattern |
| Package skeleton creation | Manual file creation | `usethis::create_package()` + `usethis::use_*()` | Correct DESCRIPTION, NAMESPACE boilerplate; CI setup |
| Test tempdir management | `tempdir()` + `on.exit(unlink())` | `withr::local_tempdir()` | Automatic cleanup even on test failure |

**Key insight:** The quarto R package and fs already do everything needed for the R layer. Never shell out directly — `quarto::quarto_render()` is the only correct path for rendering.

---

## Common Pitfalls

### Pitfall 1: Extension Not Copied — "Unknown format: typstR-workingpaper"
**What goes wrong:** If `_extensions/typstR/` is missing from the user project, Quarto produces "Unknown format: typstR-workingpaper" at render time. The package installs cleanly and R-side tests pass, but renders fail.
**Why it happens:** Developers test from the source repo where `_extensions/` may exist, or confuse `system.file()` paths with Quarto-reachable paths.
**How to avoid:** Always copy via `fs::dir_copy()` in `create_working_paper()`. Add a testthat test that runs `create_working_paper(withr::local_tempdir())` and asserts `_extensions/typstR/_extension.yml` exists. Test render from the tempdir if Quarto is available.
**Warning signs:** Works in source checkout, fails after `devtools::install()`.

### Pitfall 2: Typst Version Mismatch with Quarto 1.4.11
**What goes wrong:** Typst syntax written against current Typst 0.12+ may not compile with the Typst bundled in Quarto 1.4.11 (our minimum). Specific risks: `context` keyword semantics, revised `show` rule syntax in 0.11+.
**Why it happens:** Typst docs track latest release. Quarto 1.4.11 bundles an older Typst version.
**How to avoid:** Keep Phase 1 template syntax minimal and conservative: `set page()`, `set text()`, `set par()`, `align()`, `v()`, `pad()` — all stable primitives. Avoid `@preview` imports. If unsure about a construct, test against `quarto --version` 1.4.x.
**Warning signs:** Template renders with current Quarto but reported broken with older installs.

### Pitfall 3: CRAN Check Fails Without Quarto
**What goes wrong:** `R CMD check` runs vignettes and examples on CRAN machines that don't have Quarto. Any call to `render_pub()`, `quarto::quarto_render()`, or `quarto::quarto_available()` that isn't guarded will fail.
**Why it happens:** Phase 1 render functions work locally but CRAN has no Quarto.
**How to avoid:** Phase 1 has no vignettes yet (Phase 4), but examples in roxygen2 docs must be wrapped in `\dontrun{}` if they render, or guarded with `if (quarto::quarto_available())`. Add `SystemRequirements: quarto` to DESCRIPTION. Tests with render calls must use `testthat::skip_if_not(quarto::quarto_available())`.
**Warning signs:** CI passes on developer machine, fails on fresh Ubuntu runner.

### Pitfall 4: `quarto_render()` quiet Parameter Inverted
**What goes wrong:** The `quiet` parameter in `render_pub()` is `FALSE` by default (locked decision — show output). `quarto::quarto_render()` also has `quiet = FALSE` by default. Make sure to pass through correctly — don't invert the logic.
**Why it happens:** Easy to write `quiet = !quiet` when wiring through.
**How to avoid:** Pass `quiet = quiet` directly to `quarto_render()`. Write a test that captures output and verifies `quiet = TRUE` suppresses it.

### Pitfall 5: format Key in _extension.yml Must Be `workingpaper` Not `typst`
**What goes wrong:** If the format key in `contributes.formats` is set to `typst`, the user-facing format name becomes `typstR-typst`, not `typstR-workingpaper`. All scaffolded `template.qmd` files would need updating.
**Why it happens:** Most tutorial examples use `typst` as the format key because they define a single unnamed Typst format.
**How to avoid:** Set `contributes.formats.workingpaper:` in `_extension.yml`. Verify that `format: typstR-workingpaper` in `template.qmd` produces a valid render, not "Unknown format".

### Pitfall 6: `system.file()` Returns "" For Missing Files Without `mustWork`
**What goes wrong:** If extension files are missing from the installed package (e.g., a partial install, .Rbuildignore misconfiguration), `system.file()` returns `""` without error. Downstream `fs::dir_copy()` fails with a confusing path error.
**Why it happens:** `mustWork = FALSE` is the default.
**How to avoid:** Always pass `mustWork = TRUE` to `system.file()` for all `inst/` asset lookups in `create_working_paper()`. This converts a silent path failure into an immediate informative error.

---

## Code Examples

Verified patterns from official/reviewed sources:

### _extension.yml (named Typst format)
```yaml
# Source: Quarto extensions format documentation + AMS template reference
# Format key 'workingpaper' → user writes 'format: typstR-workingpaper'
title: typstR
author: typstR authors
version: "0.1.0"
quarto-required: ">=1.4.11"
contributes:
  formats:
    workingpaper:
      template-partials:
        - typst-template.typ
        - typst-show.typ
```

### Scaffolded template.qmd (rich Phase 1 starter)
```yaml
# Source: locked decision in CONTEXT.md; YAML fields match Phase 1 typst-show.typ
---
title: "Working Paper Title"
author:
  - name: "Author One"
  - name: "Author Two"
abstract: |
  Replace this placeholder with your abstract. This paper examines...
bibliography: references.bib
format:
  typstR-workingpaper: default
---

## Introduction

Introduce the research question here. @smith2020 provide relevant background.

## Data and Methods

Describe data sources and empirical strategy.

## Results

Present main findings.

## Conclusion

Summarize contributions and implications.

## References
```

### Scaffolded _quarto.yml (minimal project config)
```yaml
# Source: Quarto project documentation; minimal config needed for project behavior
project:
  type: default
```

### references.bib (1-2 dummy entries so first build renders bibliography)
```bibtex
@article{smith2020,
  title   = {An Example Working Paper},
  author  = {Smith, Jane},
  journal = {Journal of Example Studies},
  year    = {2020},
  volume  = {1},
  pages   = {1--20}
}
```

### quarto_render() call pattern (verified from quarto 1.5.1)
```r
# Source: quarto::quarto_render() function signature verified on machine
quarto::quarto_render(
  input          = input,           # path to .qmd
  output_format  = output_format,   # e.g. "typstR-workingpaper" or NULL
  quiet          = quiet            # logical, default FALSE per locked decision
)
```

### Testing scaffold output (withr + testthat pattern)
```r
# Source: STACK.md withr pattern; testthat 3 edition
test_that("create_working_paper() creates expected files", {
  tmp <- withr::local_tempdir()
  path <- file.path(tmp, "my-paper")

  create_working_paper(path, title = "Test Paper")

  expect_true(file.exists(file.path(path, "template.qmd")))
  expect_true(file.exists(file.path(path, "_quarto.yml")))
  expect_true(file.exists(file.path(path, "references.bib")))
  expect_true(file.exists(file.path(path, "_extensions", "typstR", "_extension.yml")))
})

test_that("create_working_paper() errors if directory exists", {
  tmp <- withr::local_tempdir()
  path <- file.path(tmp, "my-paper")
  dir.create(path)

  expect_error(create_working_paper(path), class = "rlang_error")
})
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `inst/extdata/_extensions/` for bundled extensions | `inst/quarto/extensions/` (explicit namespace) | Emerging pattern 2024+ | Clearer intent; avoids extdata tooling assumptions |
| Single `typst-template.typ` monolith | Modular `.typ` files per concern | Recommended practice as of Quarto 1.4+ Typst support | Phase 1 intentionally monolithic; Phase 3 refactors |
| `quarto add` / `quarto install extension` workflow | R package bundles extension; `create_*()` copies it | R package ecosystem pattern | Tighter version coupling between R helpers and extension |
| `stop()` / `message()` for errors | `cli::cli_abort()` / `cli::cli_inform()` | r-lib standard, widely adopted ~2022 | Classed conditions; testable; styled output |
| Base `file.copy()` for scaffolding | `fs::dir_copy()` | fs package matured ~2020 | Cross-platform; clear semantics |
| `quarto_render(quiet = TRUE)` in wrappers | Expose `quiet` parameter; default FALSE | User preference | Shows progress to researcher by default |

**Deprecated/outdated:**
- `devtools::use_*()`: Deprecated; use `usethis::use_*()` instead
- `Rscript -e "install.packages()"` in package code: Never; dependencies go in DESCRIPTION
- `system("quarto render ...")`: Never; use `quarto::quarto_render()`

---

## Open Questions

1. **Typst version in Quarto 1.4.11**
   - What we know: Quarto 1.9 bundles Typst ~0.12-0.13; Quarto 1.4.11 is the minimum
   - What's unclear: Exact Typst version bundled with Quarto 1.4.11 — not confirmed from available sources
   - Recommendation: Keep Phase 1 Typst syntax ultra-conservative (only primitives available since Typst 0.9): `set page()`, `set text()`, `set par()`, `align()`, `v()`, `#let`. Verify with `quarto --version` + known Typst changelog if possible. The STATE.md flagged this concern.

2. **Title interpolation in template.qmd**
   - What we know: Locked decision is to pre-fill YAML title field; Claude has discretion on mechanism
   - What's unclear: Whether to use `whisker` package or simple `gsub()` — whisker is a dep just for one field
   - Recommendation: Use `gsub()` on a single placeholder string (`"UNTITLED WORKING PAPER"`) in template.qmd. No additional dependency needed for this narrow use.

3. **PDF auto-open mechanism**
   - What we know: `open = interactive()` and opens PDF after render (locked); no specific mechanism specified
   - What's unclear: Cross-platform PDF open; `utils::browseURL()` vs `rstudioapi`
   - Recommendation: `utils::browseURL(pdf_path)` is base R and works cross-platform for files. No additional dependency.

---

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | testthat 3.2.3 |
| Config file | None yet — Wave 0 creates `tests/testthat.R` and `tests/testthat/` |
| Quick run command | `devtools::test(filter = "create")` |
| Full suite command | `devtools::test()` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| FOUN-01 | Package loads, R CMD check passes | check | `devtools::check()` | ❌ Wave 0 |
| FOUN-02 | `_extension.yml` exists at correct inst/ path | unit | `devtools::test(filter = "extension")` | ❌ Wave 0 |
| FOUN-03 | `create_working_paper()` copies `_extensions/typstR/` into project | unit | `devtools::test(filter = "create")` | ❌ Wave 0 |
| FOUN-04 | `render_pub()` errors cleanly without Quarto | unit | `devtools::test(filter = "render")` | ❌ Wave 0 |
| FOUN-04 | `render_pub()` calls `quarto_render()` with correct args | unit (mock) | `devtools::test(filter = "render")` | ❌ Wave 0 |
| FOUN-05 | `render_working_paper()` passes `output_format = "typstR-workingpaper"` | unit (mock) | `devtools::test(filter = "render")` | ❌ Wave 0 |
| SCAF-01 | `create_working_paper()` creates all 4 required artifacts | unit | `devtools::test(filter = "create")` | ❌ Wave 0 |
| SCAF-01 | `create_working_paper()` errors if directory exists | unit | `devtools::test(filter = "create")` | ❌ Wave 0 |
| SCAF-01 | `create_working_paper(title = "X")` pre-fills title in template.qmd | unit | `devtools::test(filter = "create")` | ❌ Wave 0 |
| End-to-end | Full render from tempdir produces PDF | integration (guarded) | `devtools::test(filter = "render-integration")` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `devtools::test(filter = "{changed-file}")` — fast targeted run
- **Per wave merge:** `devtools::test()` — full suite
- **Phase gate:** `devtools::check()` zero errors/warnings before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `tests/testthat.R` — testthat bootstrap file (`usethis::use_testthat()` generates)
- [ ] `tests/testthat/test-create-working-paper.R` — covers FOUN-03, SCAF-01
- [ ] `tests/testthat/test-render.R` — covers FOUN-04, FOUN-05 (unit with `local_mocked_bindings`)
- [ ] `tests/testthat/test-render-integration.R` — covers end-to-end with `skip_if_not(quarto_available())`
- [ ] `tests/testthat/test-extension.R` — covers FOUN-02 (extension files in correct inst/ path)
- [ ] Framework install: `usethis::use_testthat()` — not yet run

---

## Sources

### Primary (HIGH confidence)
- ARCHITECTURE.md (`.planning/research/ARCHITECTURE.md`) — Three-layer architecture, extension bundling pattern, all data flows; written 2026-03-21
- PITFALLS.md (`.planning/research/PITFALLS.md`) — Extension copy pitfall, Typst version lock, CRAN vignette guards; written 2026-03-21
- STACK.md (`.planning/research/STACK.md`) — Verified library versions, quarto R pkg 1.5.1, function signatures; written 2026-03-21
- quarto R package DESCRIPTION (installed 1.5.1) — `quarto_render()` signature with `quiet` and `output_format` params verified
- `quarto::quarto_render()` function signature — confirmed `input`, `output_format`, `quiet` params
- `quarto::quarto_available()` — confirmed returns logical
- `quarto::find_project_root()` — confirmed exists in 1.5.1
- Quarto Custom Typst Formats: https://quarto.org/docs/output-formats/typst-custom.html — extension structure

### Secondary (MEDIUM confidence)
- AMS Typst template _extension.yml (quarto-ext/typst-templates) — confirmed format key naming convention and template-partials structure
- typst-show.typ AMS pattern (github.com/quarto-ext/typst-templates) — `$variable$` syntax, `$if()$` conditionals, `$for()$` iteration, `$it.name.literal$` nested access
- Spencer Schien's R+Quarto bundling post — `file.copy(recursive=TRUE)` from `system.file("extdata/_extensions/")` pattern; note we use `inst/quarto/extensions/` not `inst/extdata/`
- Quarto Extension Formats docs (https://quarto.org/docs/extensions/formats.html) — named format suffix convention (`extensionname-formatkey`)

### Tertiary (LOW confidence — flag for validation)
- Typst 0.9+ primitive syntax compatibility with Quarto 1.4.11 — assumed conservative but exact version bundled in 1.4.11 not verified

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all package versions verified by `npm view` / CRAN / machine install
- Architecture (extension bundling): HIGH — verified against multiple official sources and ARCHITECTURE.md
- Extension format naming: MEDIUM — confirmed `extensionname-formatkey` pattern from docs + AMS example; should be validated with a smoke-render before declaring done
- Typst template syntax: MEDIUM — Phase 1 uses only stable Typst primitives; exact Typst version in Quarto 1.4.11 not pinned
- Pitfalls: HIGH — sourced from PITFALLS.md which was researched 2026-03-21 with citations

**Research date:** 2026-03-22
**Valid until:** 2026-04-22 (stable ecosystem; quarto R pkg, cli, fs are slow-moving)
