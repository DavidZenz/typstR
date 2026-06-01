# Technology Stack — typstR v1.2 (Documentation and Website Polish)

**Project:** typstR  
**Milestone:** v1.2 (Documentation and Website Polish)  
**Researched:** 2026-06-01  
**Scope:** pkgdown website publishing, onboarding documentation polish, CI-based site deployment  
**Overall confidence:** HIGH (pkgdown/usethis/r-lib/actions are the unambiguous standard for this domain)

---

## v1.2 Stack Decisions (Opinionated)

1. **pkgdown + GitHub Actions is the only realistic choice.** It is the canonical R package docs system; used by every tidyverse/r-lib package; zero lock-in.
2. **No new runtime dependencies.** Everything documentation-related is dev-only (`Suggests`).
3. **Bootstrap 5 from day one.** Bootstrap 3 is legacy; pkgdown current default uses Bootstrap 5.
4. **usethis one-liner bootstraps the entire setup.** `use_pkgdown_github_pages()` creates `_pkgdown.yml`, the GHA workflow, and configures the repo in one call.
5. **Existing vignettes remain `.Rmd` / knitr.** pkgdown picks them up as Articles automatically — no format migration needed.
6. **DESCRIPTION gets `pkgdown` in `Suggests` only.** Users never need pkgdown; it is a maintainer tool.

---

## Recommended Stack Changes for v1.2

### New Dev/Tooling Additions

| Tool | Where | Version Constraint | Purpose | Integration Note |
|---|---|---|---|---|
| **pkgdown** | `Suggests` | `>= 2.0.0` | Builds the static HTML docs site from roxygen man pages, README, and vignettes | Place `_pkgdown.yml` at repo root; `docs/` is the build output dir |
| **usethis** | dev (one-time setup, not in DESCRIPTION) | current CRAN | `use_pkgdown_github_pages()` wires up `_pkgdown.yml` + GHA workflow + GitHub repo settings | Run once locally; not a persistent dependency |
| **r-lib/actions pkgdown.yaml** | `.github/workflows/pkgdown.yaml` | v2 | Official GitHub Actions workflow: installs R, builds site, pushes to `gh-pages` branch | `.github/` already in `.Rbuildignore`; safe |

### No Changes to Runtime DESCRIPTION Imports

The following already-shipped `Imports` are **unchanged**:

```
cli (>= 3.6.0), fs (>= 1.6.0), quarto (>= 1.4), yaml (>= 2.3.10)
```

The following already-present `Suggests` are **unchanged** (and serve double duty for pkgdown):

```
knitr, rmarkdown   ← vignette builder; also used by pkgdown article rendering
testthat, withr, bench, yaml
```

### DESCRIPTION delta for v1.2

```yaml
Suggests:
  bench,
  knitr,
  pkgdown (>= 2.0.0),   # ← ADD; dev/docs only
  rmarkdown,
  testthat (>= 3.0.0),
  withr,
  yaml
```

That is the only DESCRIPTION change needed.

---

## New Files to Create

| File | Content | Notes |
|---|---|---|
| `_pkgdown.yml` | Site config: URL, Bootstrap 5 template, navbar, reference groupings | Root of repo; excluded from package build via `.Rbuildignore` entry `^_pkgdown\\.yml$` |
| `.github/workflows/pkgdown.yaml` | r-lib/actions canonical workflow | Already have `^\.github$` in `.Rbuildignore`; no change needed |
| `pkgdown/extra.css` (optional) | Minor brand tweaks (colors matching typstR visual identity) | Only if visual polish is in scope; not required for functional site |

---

## Publishing Workflow

### Canonical Approach: GitHub Pages via `gh-pages` branch

```
push to main
  → GHA pkgdown.yaml triggers
  → installs R + pandoc + package deps
  → pkgdown::build_site_github_pages()
  → JamesIves/github-pages-deploy-action pushes docs/ → gh-pages branch
  → site live at https://davidzenz.github.io/typstR/
```

**The complete GHA workflow (r-lib canonical):**

```yaml
# .github/workflows/pkgdown.yaml
on:
  push:
    branches: [main, master]
  pull_request:
  release:
    types: [published]
  workflow_dispatch:

name: pkgdown.yaml

permissions: read-all

jobs:
  pkgdown:
    runs-on: ubuntu-latest
    concurrency:
      group: pkgdown-${{ github.event_name != 'pull_request' || github.run_id }}
    env:
      GITHUB_PAT: ${{ secrets.GITHUB_TOKEN }}
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4
      - uses: r-lib/actions/setup-pandoc@v2
      - uses: r-lib/actions/setup-r@v2
      - uses: r-lib/actions/setup-r-dependencies@v2
        with:
          extra-packages: any::pkgdown, local::.
          needs: website
      - name: Build site
        run: pkgdown::build_site_github_pages(new_process = FALSE, install = FALSE)
        shell: Rscript {0}
      - name: Deploy to GitHub Pages
        if: github.event_name != 'pull_request'
        uses: JamesIves/github-pages-deploy-action@v4
        with:
          clean: false
          branch: gh-pages
          folder: docs
```

**Note on Quarto/Typst in CI:** The pkgdown build does NOT render `.qmd` documents — only `.Rmd` vignettes via knitr. The existing vignettes are already `.Rmd`. This means the GHA pkgdown runner **does not need Quarto or Typst installed**, keeping the CI image lean and reproducible.

### Alternative: Netlify
Rejected. Adds a third-party dependency, requires account/token management, and provides no meaningful advantage over GitHub Pages for an R package documentation site. GitHub Pages is zero-cost, version-controlled, and the universal standard.

---

## `_pkgdown.yml` Site Structure

```yaml
url: https://davidzenz.github.io/typstR

template:
  bootstrap: 5

navbar:
  structure:
    left: [intro, articles, reference]
    right: [search, github]
  components:
    intro:
      text: Get Started
      href: articles/getting-started.html
    articles:
      text: Articles
      menu:
        - text: Working Papers
          href: articles/working-papers.html
        - text: Customizing Branding
          href: articles/customizing-branding.html
    github:
      icon: fa-github
      href: https://github.com/DavidZenz/typstR

reference:
  - title: "Scaffold"
    desc: "Create new manuscript projects"
    contents:
      - create_working_paper
      - create_article
      - create_policy_brief
  - title: "Metadata helpers"
    desc: "Build structured author and manuscript metadata"
    contents:
      - author
      - affiliation
      - manuscript_meta
      - funding
      - data_availability
      - code_availability
  - title: "Publication helpers"
    desc: "Typed metadata and manuscript annotations"
    contents:
      - keywords
      - jel_codes
      - report_number
      - fig_note
      - tab_note
      - appendix_title
  - title: "Render"
    desc: "Render manuscripts to PDF"
    contents:
      - render_pub
      - render_working_paper
  - title: "Validation and diagnostics"
    desc: "Pre-render environment checks and validation"
    contents:
      - starts_with("check_")
      - starts_with("validate_")
```

---

## Integration Points with Current Repo

| Existing Asset | pkgdown Behavior | Action Needed |
|---|---|---|
| `README.md` | Becomes the site home page (`index.html`) verbatim | Polish prose/links for web rendering; ensure no raw file paths |
| `vignettes/getting-started.Rmd` | Article at `/articles/getting-started.html` | Already exists; review for onboarding clarity |
| `vignettes/working-papers.Rmd` | Article at `/articles/working-papers.html` | Already exists |
| `vignettes/customizing-branding.Rmd` | Article at `/articles/customizing-branding.html` | Already exists |
| `man/*.Rd` (roxygen-generated) | All become `/reference/<fn>.html` | Already generated; review `@description` / `@examples` prose |
| `DESCRIPTION` URL field | Used for site header "Source" link | Already set to `https://github.com/DavidZenz/typstR` |
| `.Rbuildignore` | `^_pkgdown\\.yml$` and `^docs$` need entries | Add both; `.github` already present |

---

## What NOT to Add

| Do NOT add | Why not | What to do instead |
|---|---|---|
| **Netlify / Vercel hosting** | Zero advantage over GitHub Pages for an R package site; adds account dependency | GitHub Pages via `gh-pages` branch is canonical and free |
| **bslib custom theming** | Deep visual customization is not the goal; Bootstrap 5 defaults are clean and readable | Use standard `template: bootstrap: 5`; one small `extra.css` for brand color if needed |
| **pkgverse / hexSticker as build dependency** | Logo generation is a one-time manual task, not a build step | Create hex sticker manually outside the CI pipeline |
| **`rmarkdown` move to `Imports`** | Already in `Suggests`; pkgdown only needs it at build time | Leave in `Suggests` |
| **Quarto-rendered articles in pkgdown** | pkgdown does not natively render `.qmd`; would require quarto in CI and adds significant complexity | Keep vignettes as `.Rmd`; link to rendered PDF outputs as external assets if needed |
| **Custom pkgdown templates package** | Creating a separate template package is premature for a single-site use | Use `_pkgdown.yml` config + optional `pkgdown/extra.css` |
| **`downlit` / `memoise` explicit deps** | pkgdown already pulls them in transitively | Do not add to DESCRIPTION |
| **`gh` CLI automation in CI** | `GITHUB_TOKEN` in the r-lib workflow handles all GitHub Pages auth automatically | No PAT secrets needed beyond the built-in `GITHUB_TOKEN` |

---

## `.Rbuildignore` Additions Required

```r
# Add these two lines (^\.github$ already present):
usethis::use_build_ignore("_pkgdown.yml")
usethis::use_build_ignore("docs")
usethis::use_build_ignore("pkgdown")  # if pkgdown/extra.css added
```

Or manually add to `.Rbuildignore`:
```
^_pkgdown\.yml$
^docs$
^pkgdown$
```

---

## Confidence by Area

| Area | Confidence | Why |
|---|---|---|
| pkgdown as the tool | HIGH | Unambiguous standard; used by all r-lib/tidyverse packages; official CRAN docs tooling |
| GitHub Pages via r-lib/actions workflow | HIGH | Canonical workflow from r-lib/actions repo; verified against current workflow file |
| Bootstrap 5 as default | HIGH | pkgdown docs confirm Bootstrap 5 is current standard; Bootstrap 3 is legacy |
| No runtime deps needed | HIGH | Documentation tooling is inherently dev-only in the R ecosystem |
| Vignette `.Rmd` format compatibility | HIGH | pkgdown Article system is built on knitr/.Rmd; matches existing vignette format exactly |
| Reference grouping patterns | HIGH | Verified against pkgdown `reference:` YAML schema |

---

## Sources

- pkgdown documentation (Context7 / r-lib/pkgdown):  
  https://pkgdown.r-lib.org/  
  https://github.com/r-lib/pkgdown
- r-lib/actions canonical pkgdown workflow:  
  https://github.com/r-lib/actions/tree/v2/examples (pkgdown.yaml)
- usethis `use_pkgdown_github_pages()` docs (Context7 / r-lib/usethis):  
  https://usethis.r-lib.org/reference/use_pkgdown.html
- pkgdown Bootstrap 5 configuration:  
  https://pkgdown.r-lib.org/articles/customise.html
- pkgdown `_pkgdown.yml` reference sections:  
  https://pkgdown.r-lib.org/reference/build_reference.html

---

# Technology Stack — typstR v1.1 (Reliability + Onboarding Polish)

**Project:** typstR  
**Milestone:** v1.1 (Reliability and Onboarding Polish)  
**Researched:** 2026-03-31  
**Scope:** pre-render validation, structured diagnostics, scaffold onboarding defaults, measurable helper/render performance  
**Overall confidence:** HIGH (core stack and architecture fit), MEDIUM (point-in-time package version snapshots)

---

## v1.1 Stack Decisions (Opinionated)

1. **Keep runtime dependencies minimal; do not introduce a new validation framework.**
2. **Promote `yaml` to `Imports`** for runtime manuscript/front-matter checks (currently in `Suggests`).
3. **Use `cli` condition metadata for structured diagnostics** (error class + fields + remediation hints), not a new diagnostics package.
4. **Add `bench` as dev/test-only (`Suggests`)** for measurable performance work; never required at runtime.
5. **Keep Quarto-dependent tests explicitly skippable** (already done) so CI/CRAN can run without Quarto.

---

## Recommended Stack for v1.1

### Runtime (user-facing)

| Technology | Version Constraint | Purpose in v1.1 | Integration Notes |
|---|---:|---|---|
| R | `>= 4.1.0` | Baseline runtime | Matches `quarto` package requirement; no change needed. |
| cli | `>= 3.6.0` | Human-readable + structured diagnostics | Keep using `cli::cli_abort()`/`cli_warn()`; attach machine-parseable fields (e.g., `class`, `field`, `hint`, `example`) in condition metadata. |
| fs | `>= 1.6.0` | Fast, cross-platform path/file checks | Continue using for file existence and scaffold checks in pre-render validation. |
| quarto (R pkg) | `>= 1.4` | Render backend + Quarto availability checks | Keep as render entry point (`quarto::quarto_render()`); do **not** shell out directly. |
| yaml | **`>= 2.3.10`** | Runtime parsing of YAML front matter during validation | **Move from `Suggests` to `Imports`** for deterministic pre-render metadata checks and onboarding diagnostics. |

### Dev/Test-only (NOT runtime)

| Tool | Version Constraint | Why in v1.1 | Usage Boundary |
|---|---:|---|---|
| testthat | `>= 3.0.0` | Validation and diagnostics behavior tests | Keep unit tests Quarto-free where possible; integration tests only when rendering is required. |
| withr | current | Isolated temp projects and env control | Keep for scaffold and validation isolation. |
| bench | `>= 1.1.4` | Quantify helper/render overhead before/after changes | Add to `Suggests`; run in perf scripts/tests guarded by opt-in env vars, not on CRAN. |

---

## Version/Compatibility Constraints to Enforce

### 1) Quarto package version vs Quarto CLI version
`DESCRIPTION` currently constrains the **R package** (`quarto >= 1.4`), while extension manifest constrains the **CLI** (`inst/quarto/extensions/typstR/_extension.yml` has `quarto-required: ">=1.4.11"`).

**v1.1 guidance:**
- Keep R package dependency (`quarto >= 1.4`) for API stability.
- Add/maintain explicit runtime CLI version check in validation preflight and diagnostics.
- Error message should clearly separate:
  - "R package installed"
  - "Quarto CLI missing/too old"

### 2) CRAN/CI behavior when Quarto is absent
Quarto is a system requirement; not all CI agents (or CRAN environments) have it.

**v1.1 guidance:**
- Keep current test pattern: `requireNamespace("quarto", quietly = TRUE) && quarto::quarto_available()`.
- Validation logic that does not require rendering must stay runnable without Quarto.
- Render integration tests remain conditionally skipped (not silently passing).

---

## Integration Guidance with Current typstR Architecture

| Layer | Keep | Add/Change for v1.1 |
|---|---|---|
| **R package layer** (`R/`) | Existing render/scaffold architecture | Add a dedicated validation+diagnostic core that returns structured condition metadata and remediation hints. |
| **Quarto extension layer** (`inst/quarto/extensions/typstR/`) | Existing extension packaging model | No new extension framework; only compatibility checks + clearer failure messaging tied to `quarto-required`. |
| **Template/scaffold layer** (`inst/templates/`) | Existing starter templates and copy flow | Improve starter defaults/content only; do not introduce new output format families. |

**Practical integration rules:**
- Run pre-render validation before `quarto::quarto_render()`.
- Emit one canonical diagnostic schema (same fields for setup errors and manuscript errors).
- Keep diagnostics in R layer; Typst templates remain presentation-focused.

---

## What NOT to Add (Scope Creep Guardrails)

| Do NOT add | Why not for v1.1 | Do instead |
|---|---|---|
| New runtime validation frameworks (`checkmate`, `assertthat`, `validate`, etc.) | Duplicates existing domain-specific checks; adds dependency surface without solving remediation quality | Implement typstR-specific checks + structured condition metadata using existing stack (`cli` + base types + `yaml`). |
| Direct process orchestration (`processx`/`callr`) for render path | Splits render behavior and increases platform risk | Keep single render path via `quarto::quarto_render()`. |
| Hard dependency on standalone Typst CLI | Conflicts with current Quarto-first packaging and onboarding simplicity | Continue relying on Quarto-managed Typst toolchain. |
| New output formats / journal-specific engines | Explicitly out of scope for v1.1 | Focus only on reliability/onboarding for existing formats. |
| Runtime profiling/caching frameworks (`profvis`, `memoise`) as defaults | Premature complexity without measured bottleneck evidence | Benchmark first (`bench`), optimize hot paths directly, keep semantics unchanged. |

---

## Suggested DESCRIPTION delta for v1.1

```yaml
Imports:
  cli (>= 3.6.0)
  fs (>= 1.6.0)
  quarto (>= 1.4)
  yaml (>= 2.3.10)   # move from Suggests to Imports

Suggests:
  testthat (>= 3.0.0)
  withr
  bench (>= 1.1.4)   # new, dev/perf only
```

---

## Confidence by Area

| Area | Confidence | Why |
|---|---|---|
| Runtime dependency decisions | HIGH | Directly aligned with current codebase and v1.1 scope. |
| Quarto/CRAN compatibility guidance | HIGH | Matches current test patterns and CRAN policy constraints on external software. |
| Performance tooling choice (`bench`) | MEDIUM-HIGH | Strong ecosystem fit; benchmark thresholds still project-specific. |
| Version snapshots | MEDIUM | Package versions evolve; constraints should use minima + periodic refresh. |

---

## Sources

- Quarto custom format extensions and Typst format docs:  
  https://quarto.org/docs/extensions/formats.html  
  https://quarto.org/docs/output-formats/typst-custom.html
- typstR extension manifest (`quarto-required`):  
  `inst/quarto/extensions/typstR/_extension.yml` (repository)
- CRAN `quarto` package metadata (R version/system requirement/dependencies):  
  https://cran.r-project.org/web/packages/quarto/index.html
- CRAN `yaml` package metadata:  
  https://cran.r-project.org/web/packages/yaml/index.html
- CRAN `bench` package metadata:  
  https://cran.r-project.org/web/packages/bench/index.html
- `cli` conditions API (`cli_abort`):  
  https://cli.r-lib.org/reference/cli_abort.html
- `testthat` skip helpers:  
  https://testthat.r-lib.org/reference/skip.html
- CRAN repository policy and Writing R Extensions (external software/testing constraints):  
  https://cran.r-project.org/web/packages/policies.html  
  https://stat.ethz.ch/R-manual/R-devel/doc/manual/R-exts.html
