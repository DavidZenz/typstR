# Stack Research

**Domain:** R package wrapping Quarto extensions and Typst templates for scientific publishing
**Researched:** 2026-03-21
**Confidence:** HIGH (core R toolchain), MEDIUM (Quarto+Typst integration patterns), MEDIUM (inst/ bundling approach)

---

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| R | >= 4.1.0 | Package runtime | Minimum required by quarto R package 1.5.1; native pipe operator available; broad compatibility |
| Quarto CLI | >= 1.4.11 | Document rendering, Typst output | Minimum version for custom Typst format extensions per official docs; current stable is 1.9 |
| Typst | bundled with Quarto | PDF typesetting engine | Do NOT require separate Typst install — Quarto bundles it; typr falls back to this correctly |
| quarto (R pkg) | 1.5.1 | CLI wrapper, render wrappers, path utilities | Official Posit-maintained interface; `quarto_render()`, `project_path()`, version checking; v1.5.0 added `write_yaml_metadata_block()` and path helpers used in render_pub() |

### R Package Layer — Runtime Dependencies

| Library | Version | Purpose | Why This One |
|---------|---------|---------|--------------|
| cli | >= 3.6.0 (current: 3.6.5) | User-facing messages, progress, errors | The r-lib standard; styled output with `cli_abort()`, `cli_inform()`, `cli_bullets()`; CRAN-clean |
| rlang | >= 1.1.0 (current: 1.1.7) | Error handling, tidy eval, `%||%` | Foundation of r-lib ecosystem; `abort()` with classed conditions; required by cli |
| fs | >= 1.6.0 (current: 1.6.7) | File path manipulation, directory creation | Cross-platform; `path_join()`, `dir_create()`, `file_copy()` — used in scaffolding and template copying |
| yaml | >= 2.3.0 | YAML serialization for metadata helpers | Required by quarto R pkg itself; `yaml::as.yaml()` for writing metadata blocks |

### R Package Layer — Development Dependencies

| Library | Version | Purpose | Why This One |
|---------|---------|---------|--------------|
| roxygen2 | 7.3.3 | Documentation generation (Rd files, NAMESPACE) | Industry standard; markdown syntax supported and recommended for all new packages in 2025 |
| devtools | 2.5.0 | Development workflow (load_all, check, install) | Meta-package wrapping usethis, roxygen2, testthat — single install gets the whole toolchain |
| usethis | 3.2.1 | Package scaffolding, CI setup, license, NEWS | `usethis::use_*` functions for consistent CRAN-ready structure |
| testthat | 3.3.2 | Unit testing | The only serious option for CRAN R packages; third edition (test_that 3) required for modern idioms |
| withr | 3.0.2 | Temporary state in tests | Clean teardown of temp dirs, env vars, working directory changes in tests — critical for scaffold tests |
| pkgdown | 2.1.3 | Documentation website | Standard for CRAN packages; auto-generates reference, articles, changelog |

### Quarto Extension Layer

| Component | File | Purpose |
|-----------|------|---------|
| Extension manifest | `inst/quarto/extensions/typstR/_extension.yml` | Declares format names, quarto-required version, extension metadata |
| Format definitions | `inst/quarto/extensions/typstR/formats/*.yml` | Per-format YAML merging Quarto Typst defaults with typstR overrides |
| Typst template entry | `typst-template.typ` | Core Typst template function invoked per document |
| Typst show file | `typst-show.typ` | Maps Quarto metadata variables to Typst template arguments |
| Modular templates | `inst/quarto/extensions/typstR/templates/*.typ` | Separate `.typ` files per concern: base, titleblock, authors, abstract, bibliography, floats, appendix, branding |

### Typst Template Layer

| Component | Why Modular |
|-----------|-------------|
| `base.typ` | Page geometry, fonts, global defaults — shared across all three formats |
| `titleblock.typ` | Title, subtitle, report number, date — format-specific overrides possible |
| `authors.typ` | Author/affiliation blocks, corresponding author, ORCID — reused by all formats |
| `abstract.typ` | Abstract, keywords, JEL codes — suppressed in policy-brief |
| `bibliography.typ` | Citation style, reference section heading |
| `floats.typ` | Figure and table caption style, note rendering |
| `appendix.typ` | Appendix section header, numbering reset |
| `branding.typ` | Logo placement, brand colors, footer, disclaimer — overridden per institution |

---

## Installation

```r
# Runtime dependencies (DESCRIPTION Imports:)
install.packages(c("cli", "rlang", "fs", "yaml", "quarto"))

# Dev dependencies (DESCRIPTION Suggests: or dev only)
install.packages(c("devtools", "usethis", "testthat", "withr", "pkgdown", "roxygen2"))

# Check Quarto CLI is present (>= 1.4.11)
quarto::quarto_version()
```

```yaml
# DESCRIPTION minimum versions
Imports:
  cli (>= 3.6.0),
  rlang (>= 1.1.0),
  fs (>= 1.6.0),
  yaml (>= 2.3.0),
  quarto (>= 1.4.0)
```

---

## Alternatives Considered

| Recommended | Alternative | When Alternative Makes Sense |
|-------------|-------------|------------------------------|
| quarto R pkg for render wrappers | `processx` direct Quarto CLI calls | Only if fine-grained process control is needed; quarto pkg already wraps processx internally |
| Bundle extension in `inst/quarto/extensions/` | Distribute as standalone Quarto extension | Standalone works for Quarto-only users who never use R; bundling in inst/ is the right choice when R helpers and the extension ship together as one package |
| Modular `.typ` files | Single monolithic Typst template | Single file is simpler initially but breaks down once branding overrides are needed; modular scales to institutional customization |
| yaml package for metadata | jsonlite | JSON is less natural for Quarto YAML front matter; yaml package serializes R lists to YAML directly |
| withr for test isolation | manual `on.exit()` teardown | withr is more composable and readable; no functional difference for simple cases, but withr scales better with nested tests |
| testthat 3 | tinytest | testthat 3 is the CRAN default expectation; tinytest has no snapshot testing; devtools integrates testthat natively |

---

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| Standalone Typst CLI as hard dependency | Users should not need to install Typst separately; Quarto bundles it; making typst CLI required breaks CRAN system dependency norms | Rely on Quarto's bundled Typst; use `typr::typst_compile()` only as optional fallback where available |
| `rmarkdown::render()` for Typst output | rmarkdown does not support Typst format; any rmarkdown-based route is a dead end | `quarto::quarto_render()` |
| Lua filters for metadata injection | Lua filters are powerful but add maintenance surface; Quarto's Typst format passes front matter to Typst natively via `typst-show.typ` | Use `typst-show.typ` + `_extension.yml` format variables to pass metadata |
| Hardcoded font names in templates | Breaks on systems that don't have the font; Quarto 1.9 added `mainfont` as a top-level YAML key | Accept `mainfont` / `fontsize` from YAML; provide fallback to Typst defaults |
| `.Rmd` vignettes compiled via LaTeX | Defeats the purpose; vignettes about Typst output should themselves render to HTML or be `.qmd` vignettes using Quarto as the vignette engine | Use `VignetteBuilder: quarto` in DESCRIPTION + `.qmd` vignettes, or conventional `.Rmd` vignettes rendered to HTML |
| `devtools::use_*` (old API) | Deprecated; `usethis` is the canonical replacement | `usethis::use_*` |

---

## Stack Patterns by Variant

**If rendering in tests (checking that scaffold produces valid .qmd):**
- Test only file structure and YAML content, not that Quarto actually renders
- Because rendering requires Quarto CLI installed, adds test time, and is an integration test not a unit test
- Use `withr::local_tempdir()` + `create_working_paper()` + assert file existence and YAML content

**If branding is institution-specific:**
- All branding variables live in `typstR:` YAML block, not in Typst source
- Because Typst source should be untouched by end users; YAML is the designed interface

**If a user needs a raw Typst compile (no Quarto):**
- Defer to `typr::typst_compile()` — it handles the Quarto-bundled Typst fallback
- Do not re-implement this path in typstR; it is out of scope

**If targeting CRAN:**
- No internet access in tests (`CRAN = TRUE` env var during checks)
- No `quarto_render()` calls in tests (requires Quarto CLI system dependency)
- Wrap any optional system-dependency calls with `if (quarto::quarto_available())` guards

---

## Version Compatibility

| Component | Compatible With | Notes |
|-----------|-----------------|-------|
| quarto R pkg 1.5.1 | R >= 4.1.0 | Requires Quarto CLI installed separately; not bundled in R pkg |
| Quarto >= 1.4.11 | Custom Typst extension format | `quarto-required: ">=1.4.11"` in `_extension.yml` |
| Quarto 1.9 (current stable) | Typst ~0.12-0.13 bundled | Active work to upgrade to Typst 0.14.2 per quarto-dev/discussions#13637 |
| testthat 3 | R >= 3.6 | Third edition syntax (`expect_snapshot()`, `local_mocked_bindings()`) requires testthat >= 3.0.0 |
| roxygen2 7.3.x | R >= 3.6 | Markdown documentation enabled via `@md` tag or `Roxygen: list(markdown = TRUE)` in DESCRIPTION |
| fs 1.6.x | R >= 3.6 | No known compatibility issues with the R layer |

---

## Key Integration Pattern: Bundled Extension Discovery

The non-obvious piece of this stack is how the R package exposes its bundled Quarto extension at render time. The pattern is:

```r
# In render_pub() or create_working_paper():
ext_path <- system.file("quarto/extensions", package = "typstR")
# Copy or symlink to project's _extensions/ at render time
# OR: set --resource-path in quarto_render() call
```

`system.file()` is base R — no additional dependency. The scaffold functions must copy or reference `inst/quarto/extensions/typstR/` into the user's project `_extensions/typstR/` directory so Quarto's extension resolution finds it. This is the main architectural constraint the stack imposes.

---

## Sources

- [Quarto Custom Typst Formats](https://quarto.org/docs/output-formats/typst-custom.html) — extension file structure, quarto-required version (HIGH confidence)
- [Quarto 1.9 Release Notes](https://quarto.org/docs/download/release.html) — current stable version, new Typst features (HIGH confidence)
- [quarto R package v1.5.1 on CRAN](https://cran.r-project.org/web/packages/quarto/index.html) — version 1.5.1, R >= 4.1.0 requirement, dependency list (HIGH confidence)
- [quarto R package v1.5.0 blog post](https://quarto.org/docs/blog/posts/2025-07-28-r-package-release-1.5/) — new functions: write_yaml_metadata_block, project_path, find_project_root (HIGH confidence)
- [roxygen2 7.3.3 on CRAN](https://cran.r-project.org/web/packages/roxygen2/index.html) — version confirmed (HIGH confidence)
- [testthat 3.3.2 on CRAN](https://cran.r-project.org/web/packages/testthat/index.html) — version confirmed (HIGH confidence)
- [cli 3.6.5 on CRAN](https://cran.r-project.org/web/packages/cli/index.html) — version confirmed (HIGH confidence)
- [rlang 1.1.7 on CRAN](https://cran.r-project.org/web/packages/rlang/index.html) — version confirmed (HIGH confidence)
- [fs 1.6.7 on CRAN](https://cran.r-project.org/web/packages/fs/index.html) — version confirmed (HIGH confidence)
- [usethis 3.2.1 on CRAN](https://cran.r-project.org/web/packages/usethis/index.html) — version confirmed (HIGH confidence)
- [pkgdown 2.1.3](https://pkgdown.r-lib.org/) — version confirmed via CRAN (HIGH confidence)
- [withr 3.0.2 on CRAN](https://cran.r-project.org/web/packages/withr/) — version confirmed (HIGH confidence)
- [Typst 0.14 upgrade discussion](https://github.com/orgs/quarto-dev/discussions/13637) — active PR to upgrade bundled Typst (MEDIUM confidence — timing uncertain)
- [typr package on CRAN](https://cran.r-project.org/web/packages/typr/index.html) — competitor survey; renders Typst, falls back to Quarto's bundled Typst (MEDIUM confidence)
- [quarto-preprint extension](https://github.com/mvuorre/quarto-preprint) — reference implementation: standalone Quarto extension, Typst 77% of codebase, no R wrapper (HIGH confidence)
- [R Packages (2e) — Function documentation](https://r-pkgs.org/man.html) — roxygen2 markdown best practices (HIGH confidence)

---
*Stack research for: typstR — R package for Quarto + Typst scientific publishing*
*Researched: 2026-03-21*
