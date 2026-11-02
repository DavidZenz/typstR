# Phase 11: Documentation Content Foundation - Research

**Researched:** 2026-06-01
**Domain:** R package documentation sources for pkgdown, roxygen2, and onboarding content
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
### Canonical onboarding split
- **D-01:** README should prove value quickly and show install; the pkgdown home page should act as the polished overview and navigation hub; `vignettes/getting-started.Rmd` should own the full walkthrough.
- **D-02:** The canonical onboarding example should use the **working paper** scaffold only. Article and policy brief paths should appear as follow-on options rather than equal first-run branches.
- **D-03:** `getting-started` should explicitly name and explain the roles of `template.qmd`, `_quarto.yml`, and `references.bib`; README and home-page content should keep that step lighter.

### First-screen README message
- **D-04:** The first screenful of README must contain the package value proposition, the install command, an explicit Quarto/system-requirement note, and a very short scaffold -> render preview.
- **D-05:** The Quarto note should be direct: users can install `typstR` in R immediately, but Quarto is required when they render.
- **D-06:** README opening copy should be adoption-focused and outcome-oriented, not written like a technical reference page.

### Vignette roles and order
- **D-07:** Articles should have an intentional journey: `getting-started` first, `working-papers` second, `customizing-branding` third.
- **D-08:** `working-papers` should deepen the metadata/title-page story rather than reintroduce the package from scratch.
- **D-09:** `customizing-branding` should be a practical guide to the YAML/front-matter knobs users are most likely to change first.
- **D-10:** The later two articles should link back to `getting-started` for the base scaffold/render flow instead of duplicating the full intro.

### Reference and example style
- **D-11:** Help-page examples should stay short and runnable; they should reinforce the main workflow without becoming mini-vignettes.
- **D-12:** Example refresh should prefer real scaffold/edit/render actions and only use helper-only examples when that is the clearest fit.
- **D-13:** Phase 11 should prioritize the highest-traffic user-facing functions first; lower-level helpers can remain lighter if they already meet the minimum quality bar.

### the agent's Discretion
- Exact README wording, section titles, and line-level ordering inside the chosen first-screen structure
- The precise boundary between what lives in README versus pkgdown home-page prose, as long as the split above is preserved
- Which lower-level helper pages receive expanded examples after the scaffold/render entrypoints are brought up to standard
- Final `NEWS.md` phrasing for v1.0, v1.1, and v1.2 entries

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| DOCS-01 | New users can understand typstR's value, installation path, and system requirements from the README homepage without leaving the first screenful. | README already has value/install/quick-start material, but it does not yet put an explicit Quarto/render-time note into the opening screen; Phase 11 should restructure, not rewrite from zero. [VERIFIED: codebase view] |
| DOCS-02 | New users can follow one canonical install -> scaffold -> render onboarding flow that is presented consistently across the README, pkgdown home page, and getting-started article. | pkgdown uses `pkgdown/index.md`, `index.md`, or `README.md` as the home-page source in that order, and this repo currently has no dedicated home-page source, so a separate home-page artifact is needed if README and site home must do different jobs. [CITED: https://pkgdown.r-lib.org/reference/build_home.html] [VERIFIED: codebase view] |
| DOCS-03 | Users can rely on all existing vignettes to build successfully in pkgdown without requiring Quarto or Typst on the docs build runner. | `pkgdown::build_articles()` renders `vignettes/` and uses the currently installed package when run directly; local validation failed before `typstR` was installed and passed after `R CMD INSTALL .` with Quarto removed from `PATH`. [CITED: https://pkgdown.r-lib.org/reference/build_articles.html] [VERIFIED: local commands 2026-06-01] |
| DOCS-04 | Users can browse public function documentation with meaningful titles, descriptions, parameter docs, and runnable examples for every exported help page included in the site. | `devtools::check_man()` currently returns clean after regenerating docs, but a direct man-page audit shows `validate_render_environment` still lacks an `\\examples{}` block, so Phase 11 needs a stricter exported-help-page audit than `check_man()` alone. [CITED: https://devtools.r-lib.org/reference/check_man.html] [VERIFIED: local commands 2026-06-01] |
| DOCS-05 | Users can view a changelog page that summarizes shipped milestones through v1.2. | `NEWS.md` is absent, and pkgdown expects version sections from level-one or level-two headings matching forms such as `{package name} 1.3.0` or `{package name} v1.3.0`. [CITED: https://pkgdown.r-lib.org/reference/build_news.html] [VERIFIED: codebase view] |
| SHIP-04 | Maintainers can keep the site build CRAN-safe by excluding pkgdown-only artifacts from the package tarball while preserving all required source docs in git. | `.gitignore` currently ignores `man/*.Rd`, `.Rbuildignore` does not exclude `docs/`, and an R-exts manual states `.Rbuildignore` controls files excluded from the built package. [CITED: https://cran.r-project.org/doc/manuals/r-release/R-exts.html] [VERIFIED: codebase view] |
</phase_requirements>

## Summary

Phase 11 should be planned as a documentation-source alignment phase, not a site-configuration phase: the repo already has the core content surfaces (`README.md`, three vignette `.Rmd` files, roxygen comments in `R/*.R`), but those surfaces do not yet support the locked README/home/getting-started split because there is no dedicated pkgdown home-page source, no `NEWS.md`, and generated `man/*.Rd` files are still excluded from git. [VERIFIED: codebase view] [CITED: https://pkgdown.r-lib.org/reference/build_home.html]

The biggest planning trap is validation: `pkgdown::build_articles()` uses the currently installed package when run directly, so a local docs-build gate must install the current source first; once `typstR` was installed locally, all three vignettes built successfully with Quarto removed from `PATH`, which means the present docs risk is build harness setup and narrative alignment more than Quarto execution inside the vignettes. [CITED: https://pkgdown.r-lib.org/reference/build_articles.html] [VERIFIED: local commands 2026-06-01]

Reference docs are close but not complete enough for the phase contract: `devtools::check_man()` is clean, yet `validate_render_environment` still lacks examples and `render_working_paper` still documents the stale format name `typstR-workingpaper` while the code and starter templates use `typstR-typst`. [CITED: https://devtools.r-lib.org/reference/check_man.html] [VERIFIED: codebase view] [VERIFIED: local commands 2026-06-01]

**Primary recommendation:** Plan four workstreams: onboarding-surface split, vignette narrative cleanup, source-driven reference refresh, and changelog/hygiene hardening. [VERIFIED: codebase view] [CITED: https://pkgdown.r-lib.org/reference/build_home.html]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| GitHub-facing README onboarding proof | CDN / Static | Browser / Client | README is authored in-package and consumed as static content by GitHub/CRAN, with browser rendering only after generation. [VERIFIED: codebase view] |
| pkgdown home page narrative hub | CDN / Static | Browser / Client | pkgdown builds the home page from markdown sources into static HTML; no application server owns this flow. [CITED: https://pkgdown.r-lib.org/reference/build_home.html] |
| Articles / vignette onboarding flow | CDN / Static | Browser / Client | `build_articles()` renders vignette `.Rmd` files to `articles/` HTML for static-site consumption. [CITED: https://pkgdown.r-lib.org/reference/build_articles.html] |
| Reference/help-page content | CDN / Static | — | roxygen2 generates `man/*.Rd`, and pkgdown consumes those generated docs into static reference pages. [CITED: https://roxygen2.r-lib.org/] [VERIFIED: codebase view] |
| Changelog publication | CDN / Static | Browser / Client | pkgdown builds news pages from `NEWS.md` headings into static HTML. [CITED: https://pkgdown.r-lib.org/reference/build_news.html] |

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| pkgdown | 2.2.0 (published 2025-11-06 UTC) | Build home, articles, reference, and news pages from package sources. [VERIFIED: CRAN package db] | Official site generator for R package docs, and Phase 11 artifacts are defined in pkgdown terms. [CITED: https://pkgdown.r-lib.org/reference/build_home.html] [CITED: https://pkgdown.r-lib.org/reference/build_articles.html] |
| roxygen2 | 8.0.0 (published 2026-05-01 UTC) | Generate `.Rd` files and `NAMESPACE` from source comments. [VERIFIED: CRAN package db] | Official source-driven pattern; the repo already uses roxygen blocks on exported functions. [CITED: https://roxygen2.r-lib.org/] [VERIFIED: codebase view] |
| devtools | 2.5.2 (published 2026-04-30 UTC) | Run documentation checks with `check_man()`. [VERIFIED: CRAN package db] | Closest built-in check to the phase’s help-page quality gate. [CITED: https://devtools.r-lib.org/reference/check_man.html] |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| rmarkdown | 2.31 (published 2026-03-26 UTC) | Render vignette `.Rmd` sources during pkgdown article builds. [VERIFIED: CRAN package db] | Required for article rendering because all three current vignettes are `.Rmd`. [VERIFIED: codebase view] |
| knitr | 1.51 (published 2025-12-20 UTC) | Execute vignette chunks and drive vignette engine metadata. [VERIFIED: CRAN package db] | Required for the current `knitr::rmarkdown` vignette engine declarations. [VERIFIED: codebase view] |
| testthat | 3.3.2 (published 2026-01-11 UTC) | Existing test harness for any smoke checks or helper audits added in this phase. [VERIFIED: CRAN package db] | Already configured and active in the repo. [VERIFIED: codebase view] |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| README-only home page source | Dedicated `index.md` or `pkgdown/index.md` | pkgdown explicitly supports a separate home-page source when the website should differ from the README; Phase 11’s locked split strongly favors this. [CITED: https://pkgdown.r-lib.org/reference/build_home.html] |
| Hand-edited `man/*.Rd` | roxygen2 source comments | Hand edits drift and are overwritten; roxygen2 is the documented source-of-truth workflow. [CITED: https://roxygen2.r-lib.org/] |
| Ad hoc changelog markdown page | `NEWS.md` | pkgdown has first-class news parsing rules; using `NEWS.md` avoids custom site plumbing. [CITED: https://pkgdown.r-lib.org/reference/build_news.html] |

**Installation:**
```r
install.packages(c("pkgdown", "roxygen2", "devtools", "rmarkdown", "knitr", "testthat"))
```

**Version verification:** Verify with `tools::CRAN_package_db()` or `available.packages()` before execution; the versions above were confirmed in-session from CRAN metadata. [VERIFIED: CRAN package db]

## Workstream Decomposition

1. **Onboarding surface split** — reshape `README.md`, add a dedicated pkgdown home-page source, and keep one canonical working-paper install -> scaffold -> render narrative across the three onboarding surfaces. [VERIFIED: codebase view] [CITED: https://pkgdown.r-lib.org/reference/build_home.html]
2. **Vignette narrative cleanup** — add YAML `description` fields, enforce article order/roles, link later articles back to `getting-started`, and keep Quarto-dependent chunks non-evaluated. [CITED: https://pkgdown.r-lib.org/reference/build_articles.html] [VERIFIED: codebase view]
3. **Reference refresh from source** — update roxygen comments for high-traffic user-facing functions first, regenerate `man/*.Rd`, and add an audit that verifies examples on every exported help page. [CITED: https://roxygen2.r-lib.org/] [CITED: https://devtools.r-lib.org/reference/check_man.html] [VERIFIED: local commands 2026-06-01]
4. **Changelog and docs hygiene** — add `NEWS.md`, stop ignoring `man/*.Rd`, and exclude pkgdown build artifacts from source tarballs. [CITED: https://pkgdown.r-lib.org/reference/build_news.html] [CITED: https://cran.r-project.org/doc/manuals/r-release/R-exts.html] [VERIFIED: codebase view]

## Architecture Patterns

### System Architecture Diagram

```text
R/*.R roxygen comments -----> roxygen2 -----> man/*.Rd ----\
                                                          \
README.md -------------------------------> build_home -----> docs/*.html (Phase 12 site build)
pkgdown/index.md or index.md -----------> build_home ----->/
vignettes/*.Rmd ------------------------> build_articles --> docs/articles/*.html
NEWS.md --------------------------------> build_news -----> docs/news/*.html
DESCRIPTION ----------------------------> build_home/ref --> sidebar, metadata, site text

User follows:
README quick proof -> pkgdown home overview -> getting-started full walkthrough -> create_working_paper() -> edit template.qmd/_quarto.yml/references.bib -> render_working_paper()
```

The current repo already has README, vignettes, roxygen sources, and `DESCRIPTION`, but it lacks a dedicated home-page source and `NEWS.md`. [VERIFIED: codebase view]

### Recommended Project Structure
```text
README.md                 # GitHub/CRAN-facing quick proof + install
pkgdown/
└── index.md              # Recommended dedicated pkgdown home-page source [ASSUMED]
vignettes/
├── getting-started.Rmd   # Canonical full walkthrough
├── working-papers.Rmd    # Metadata/title-page depth
└── customizing-branding.Rmd # YAML/front-matter customization guide
R/
├── create_working_paper.R
├── render.R
├── validation_environment.R
└── typstR-package.R      # Package-level narrative alignment
man/                      # Generated, committed reference sources
NEWS.md                   # pkgdown news source
```

### Pattern 1: Split onboarding by job, not by duplicated prose
**What:** README proves value and install, pkgdown home orients, `getting-started` teaches the full flow. [VERIFIED: context file] [CITED: https://pkgdown.r-lib.org/reference/build_home.html]
**When to use:** Whenever GitHub-facing copy and site-home copy need different depth. [CITED: https://pkgdown.r-lib.org/reference/build_home.html]
**Example:**
```markdown
<!-- Source: https://pkgdown.r-lib.org/reference/build_home.html -->
README.md         # quick proof + install
pkgdown/index.md  # polished site home
vignettes/getting-started.Rmd  # full walkthrough
```

### Pattern 2: Keep reference docs source-driven
**What:** Edit roxygen in `R/*.R`, regenerate `man/*.Rd`, and commit generated Rd files. [CITED: https://roxygen2.r-lib.org/] [VERIFIED: codebase view]
**When to use:** For all help-page fixes in this phase. [CITED: https://roxygen2.r-lib.org/]
**Example:**
```r
# Source: /Users/davidzenz/R/typstR/R/create_working_paper.R
#' @examples
#' \dontrun{
#' create_working_paper("my-working-paper", open = FALSE)
#' }
```

### Pattern 3: Put article summaries in vignette YAML
**What:** pkgdown article indexes use vignette `title` and `description` metadata. [CITED: https://pkgdown.r-lib.org/reference/build_articles.html]
**When to use:** For all three vignettes before Phase 12 navigation work. [CITED: https://pkgdown.r-lib.org/reference/build_articles.html]
**Example:**
```yaml
# Source: https://pkgdown.r-lib.org/reference/build_articles.html
---
title: "Getting Started"
description: "Install typstR, scaffold a working paper, edit the generated files, and render."
---
```

### File-Level Impact Map

| File | Why it likely changes |
|------|------------------------|
| `README.md` | Must satisfy first-screen value/install/system-note/preview contract. [VERIFIED: codebase view] |
| `pkgdown/index.md` or `index.md` | Needed to decouple pkgdown home from README because the locked split requires different jobs for those surfaces. [CITED: https://pkgdown.r-lib.org/reference/build_home.html] [ASSUMED] |
| `vignettes/getting-started.Rmd` | Must own the canonical working-paper flow and explicitly explain `template.qmd`, `_quarto.yml`, and `references.bib`. [VERIFIED: context file] |
| `vignettes/working-papers.Rmd` | Should deepen metadata/title-page content and keep linking back to getting-started instead of duplicating it. [VERIFIED: context file] |
| `vignettes/customizing-branding.Rmd` | Should focus on first-change YAML knobs and add a link-back to getting-started. [VERIFIED: context file] [VERIFIED: codebase view] |
| `R/create_working_paper.R` | Highest-traffic scaffold help page; examples already exist but may need wording alignment. [VERIFIED: context file] [VERIFIED: codebase view] |
| `R/render.R` | `render_working_paper` roxygen still names stale `typstR-workingpaper` format. [VERIFIED: codebase view] |
| `R/validation_environment.R` | Exported function is missing examples, so Phase 11 must add one. [VERIFIED: local man-page audit 2026-06-01] [VERIFIED: codebase view] |
| `R/typstR-package.R` | Package-level narrative should stay aligned with the canonical scaffold -> edit -> render story. [VERIFIED: codebase view] |
| `man/*.Rd` | Must be regenerated and committed after roxygen edits. [CITED: https://roxygen2.r-lib.org/] [VERIFIED: codebase view] |
| `NEWS.md` | Does not exist and is required for pkgdown changelog generation. [CITED: https://pkgdown.r-lib.org/reference/build_news.html] [VERIFIED: codebase view] |
| `.gitignore` | Currently ignores `man/*.Rd`, which conflicts with the locked Phase 11 requirement. [VERIFIED: codebase view] |
| `.Rbuildignore` | Needs pkgdown-artifact exclusions such as `^docs$`; it currently lacks them. [CITED: https://cran.r-project.org/doc/manuals/r-release/R-exts.html] [VERIFIED: codebase view] |
| `DESCRIPTION` | Help regeneration may touch documentation metadata; home/sidebar text also draws from this file. [CITED: https://pkgdown.r-lib.org/reference/build_home.html] [VERIFIED: local commands 2026-06-01] |

### Pattern Mapping Recommendation

Yes — a short pattern-mapping step adds value because the same canonical flow must stay synchronized across three prose surfaces and two reference entry points. [VERIFIED: context file] [VERIFIED: codebase view]

**Files that need analogs:**
- `README.md` ↔ dedicated home-page source (`pkgdown/index.md` recommended) ↔ `vignettes/getting-started.Rmd` for the install -> scaffold -> render storyline. [CITED: https://pkgdown.r-lib.org/reference/build_home.html] [ASSUMED]
- `R/create_working_paper.R` ↔ `R/render.R` ↔ the same onboarding prose, so help examples reinforce the same path. [VERIFIED: codebase view]
- `vignettes/working-papers.Rmd` and `vignettes/customizing-branding.Rmd` ↔ `getting-started` link-backs so specialized articles do not fork the intro. [VERIFIED: context file] [VERIFIED: codebase view]

### Anti-Patterns to Avoid
- **README and site home doing the same job:** pkgdown already allows a dedicated home-page source; duplicating README prose into the site home wastes Phase 11 effort. [CITED: https://pkgdown.r-lib.org/reference/build_home.html]
- **Editing `.Rd` files by hand:** roxygen2 treats source comments as the authority and generated Rd files as outputs. [CITED: https://roxygen2.r-lib.org/]
- **Using `check_man()` as the only reference gate:** it did not flag the missing example on `validate_render_environment`, so the phase needs an extra exported-help-page audit. [CITED: https://devtools.r-lib.org/reference/check_man.html] [VERIFIED: local commands 2026-06-01]
- **Testing `build_articles()` against an uninstalled package:** pkgdown documents that direct article builds use the installed package version, and this repo failed in that exact state. [CITED: https://pkgdown.r-lib.org/reference/build_articles.html] [VERIFIED: local commands 2026-06-01]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Reference pages | Hand-edited `.Rd` files | roxygen2-generated `man/*.Rd` | Generated docs stay aligned with source and are the documented workflow. [CITED: https://roxygen2.r-lib.org/] |
| Home-page routing logic | Custom duplication between README and site home | pkgdown’s built-in `pkgdown/index.md` / `index.md` / `README.md` precedence | pkgdown already solves the home-page source selection problem. [CITED: https://pkgdown.r-lib.org/reference/build_home.html] |
| News page rendering | Custom changelog HTML | `NEWS.md` + pkgdown news builder | pkgdown already parses release headings and builds the changelog surface. [CITED: https://pkgdown.r-lib.org/reference/build_news.html] |
| Tarball exclusion rules | Manual post-build cleanup | `.Rbuildignore` | R’s build tool already supports source exclusions via `.Rbuildignore`. [CITED: https://cran.r-project.org/doc/manuals/r-release/R-exts.html] |

**Key insight:** In this phase, “custom” usually means “content drift later.” The cheapest plan is to use pkgdown and roxygen2 exactly where they already define source-of-truth boundaries. [CITED: https://pkgdown.r-lib.org/reference/build_home.html] [CITED: https://roxygen2.r-lib.org/]

## Common Pitfalls

### Pitfall 1: Assuming README can stay the only home-page source
**What goes wrong:** README and pkgdown home end up with the same depth even though the locked split requires different jobs. [VERIFIED: context file]
**Why it happens:** pkgdown falls back to `README.md` when no dedicated `index` source exists. [CITED: https://pkgdown.r-lib.org/reference/build_home.html]
**How to avoid:** Add a dedicated home-page source in Phase 11, then keep README adoption-first and home navigation-first. [CITED: https://pkgdown.r-lib.org/reference/build_home.html] [ASSUMED]
**Warning signs:** No `index.md` or `pkgdown/index.md` exists, and planned README edits try to satisfy both audiences at once. [VERIFIED: codebase view]

### Pitfall 2: False-negative article builds from package-install state
**What goes wrong:** `build_articles()` fails with `there is no package called 'typstR'` or uses stale installed code. [VERIFIED: local commands 2026-06-01]
**Why it happens:** pkgdown documents that direct `build_articles()` calls use the currently installed package version. [CITED: https://pkgdown.r-lib.org/reference/build_articles.html]
**How to avoid:** Make `R CMD INSTALL .` or equivalent part of the validation sequence before the no-Quarto article build. [CITED: https://pkgdown.r-lib.org/reference/build_articles.html]
**Warning signs:** Vignettes contain `library(typstR)` and local article builds are run straight from source. [VERIFIED: codebase view] [VERIFIED: local commands 2026-06-01]

### Pitfall 3: Thinking `check_man()` proves all exported help pages have examples
**What goes wrong:** Phase 11 appears complete while exported help pages still miss `@examples`. [VERIFIED: local commands 2026-06-01]
**Why it happens:** `check_man()` aims to approximate R CMD check documentation checks, not the stricter content standard defined for this phase. [CITED: https://devtools.r-lib.org/reference/check_man.html]
**How to avoid:** Add a direct audit over exported Rd files for `\\title{}`, `\\description{}`, `\\arguments{}`, and `\\examples{}`. [VERIFIED: local commands 2026-06-01]
**Warning signs:** `check_man()` is green, but man-page inspection still shows missing blocks such as `validate_render_environment`. [VERIFIED: local commands 2026-06-01]

### Pitfall 4: Shipping pkgdown artifacts or losing generated man pages
**What goes wrong:** `man/*.Rd` never enter git, or `docs/` leaks into the package tarball. [VERIFIED: codebase view]
**Why it happens:** `.gitignore` and `.Rbuildignore` currently enforce the opposite split from the Phase 11 target state. [VERIFIED: codebase view]
**How to avoid:** Remove `man/*.Rd` from `.gitignore`, add pkgdown artifact exclusions to `.Rbuildignore`, and verify with `R CMD build`. [CITED: https://cran.r-project.org/doc/manuals/r-release/R-exts.html]
**Warning signs:** `git check-ignore man/foo.Rd` still matches, or `docs/` appears in tarball listings. [VERIFIED: codebase view]

### Pitfall 5: Letting docs drift from actual format names and validation behavior
**What goes wrong:** Users read one format name in help pages and another in templates or code. [VERIFIED: codebase view]
**Why it happens:** roxygen prose can lag implementation changes even when generated Rd files exist. [VERIFIED: codebase view]
**How to avoid:** Cross-check README/vignette/help text against actual template YAML and render wrappers before regenerating docs. [VERIFIED: codebase view]
**Warning signs:** `render_working_paper` still mentions `typstR-workingpaper` while templates use `typstR-typst`. [VERIFIED: codebase view]

## Code Examples

Verified patterns from official sources and the repo:

### Local article-build validation sequence
```bash
# Source: https://pkgdown.r-lib.org/reference/build_articles.html
R CMD INSTALL .
env PATH=/opt/homebrew/bin:/usr/bin:/bin Rscript -e 'pkgdown::build_articles(quiet = FALSE, lazy = FALSE, preview = FALSE)'
```

### Short, runnable scaffold example for help pages
```r
# Source: /Users/davidzenz/R/typstR/R/create_working_paper.R
#' @examples
#' \dontrun{
#' create_working_paper("my-working-paper", open = FALSE)
#' }
```

### Canonical scaffold -> render flow already present in the repo
```r
# Source: /Users/davidzenz/R/typstR/README.md
library(typstR)
create_working_paper("my-paper")
render_working_paper("my-paper/template.qmd")
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| README doubles as site home by default | Use a dedicated `index.md` / `pkgdown/index.md` when the site should differ from README | Current pkgdown 2.2.0 docs describe this behavior. [CITED: https://pkgdown.r-lib.org/reference/build_home.html] | Lets Phase 11 honor the locked README/home split without overloading one file. [CITED: https://pkgdown.r-lib.org/reference/build_home.html] |
| Hand-maintained Rd pages | roxygen2 comments generate Rd/NAMESPACE | Current roxygen2 workflow. [CITED: https://roxygen2.r-lib.org/] | Documentation fixes belong in `R/*.R`, then regenerate and commit outputs. [CITED: https://roxygen2.r-lib.org/] |
| Custom changelog page | `NEWS.md` consumed by pkgdown | Current pkgdown news builder docs. [CITED: https://pkgdown.r-lib.org/reference/build_news.html] | Phase 11 can ship changelog content without adding site-specific markdown plumbing. [CITED: https://pkgdown.r-lib.org/reference/build_news.html] |

**Deprecated/outdated:**
- Editing generated `man/*.Rd` directly is outdated for this repo because roxygen2 is already the established source pattern. [CITED: https://roxygen2.r-lib.org/] [VERIFIED: codebase view]
- Relying on `README.md` alone for both GitHub and pkgdown home is outdated for this phase because the locked split requires distinct roles and pkgdown already supports dedicated home-page sources. [CITED: https://pkgdown.r-lib.org/reference/build_home.html] [VERIFIED: context file]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Prefer `pkgdown/index.md` over root `index.md` so the dedicated site-home source stays out of the package root. [ASSUMED] | Architecture Patterns / File-Level Impact Map | Low — either supported location works, but file-placement tasks may change. |

## Open Questions (RESOLVED)

1. **Which dedicated home-page path should Phase 11 choose?**
   - Resolved choice: use `pkgdown/index.md`. [VERIFIED: user choice during plan-phase 2026-06-01]
   - Why: it preserves the dedicated pkgdown home-page split without adding a root-level content file to the package source tree. [CITED: https://pkgdown.r-lib.org/reference/build_home.html]

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| R / Rscript | All validation commands | ✓ [VERIFIED: local command] | 4.6.0 [VERIFIED: local command] | — |
| pkgdown | `build_articles()` / future site build | ✓ [VERIFIED: local command] | 2.2.0 [VERIFIED: local command] | — |
| devtools | `check_man()` | ✓ [VERIFIED: local command] | 2.5.2 [VERIFIED: local command] | — |
| roxygen2 | Rd regeneration | ✓ [VERIFIED: local command] | 8.0.0 [VERIFIED: local command] | — |
| rmarkdown | Article rendering | ✓ [VERIFIED: local command] | 2.31 [VERIFIED: local command] | — |
| knitr | Vignette engine | ✓ [VERIFIED: local command] | 1.51 [VERIFIED: local command] | — |
| pandoc | HTML output during article builds | ✓ [VERIFIED: local command] | 3.9.0.2 [VERIFIED: local command] | — |
| Quarto CLI | Render-time examples only | ✓ [VERIFIED: local command] | 1.9.38 [VERIFIED: local command] | For DOCS-03 validation, intentionally hide it from `PATH` to prove docs builds do not require it. [VERIFIED: local commands 2026-06-01] |

**Missing dependencies with no fallback:**
- None. [VERIFIED: local commands 2026-06-01]

**Missing dependencies with fallback:**
- None. [VERIFIED: local commands 2026-06-01]

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | testthat 3.3.2 [VERIFIED: codebase view] [VERIFIED: local command] |
| Config file | `tests/testthat.R` and `Config/testthat/edition: 3` in `DESCRIPTION`. [VERIFIED: codebase view] |
| Quick run command | `Rscript -e 'devtools::check_man()'` [CITED: https://devtools.r-lib.org/reference/check_man.html] |
| Full suite command | `Rscript -e 'testthat::test_dir(\"tests/testthat\")'` plus the doc smoke commands below. [VERIFIED: codebase view] |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| DOCS-01 | README first screen includes value, install, Quarto note, and scaffold -> render preview | manual-only | `sed -n '1,30p' README.md` for reviewer check [VERIFIED: codebase view] | ✅ |
| DOCS-02 | README, home page, and getting-started tell one canonical working-paper story | manual-only | `grep -RIn \"create_working_paper\\|render_working_paper\" README.md pkgdown index.md vignettes/getting-started.Rmd` after edits [ASSUMED] | ❌ Wave 0 for dedicated home source |
| DOCS-03 | All three vignettes build with no Quarto in PATH | smoke | `R CMD INSTALL . && env PATH=/opt/homebrew/bin:/usr/bin:/bin Rscript -e 'pkgdown::build_articles(quiet = FALSE, lazy = FALSE, preview = FALSE)'` [CITED: https://pkgdown.r-lib.org/reference/build_articles.html] [VERIFIED: local commands 2026-06-01] | ✅ |
| DOCS-04 | Every exported help page has title, description, params, and examples | smoke | `Rscript -e 'devtools::check_man()'` **and** an exported-Rd audit script for `\\examples{}` presence because `check_man()` alone is insufficient. [CITED: https://devtools.r-lib.org/reference/check_man.html] [VERIFIED: local commands 2026-06-01] | ❌ Wave 0 for explicit examples audit |
| DOCS-05 | `NEWS.md` exists with pkgdown-readable release headings | smoke | `grep -n '^# typstR ' NEWS.md` [CITED: https://pkgdown.r-lib.org/reference/build_news.html] | ❌ Wave 0 |
| SHIP-04 | `man/*.Rd` tracked, pkgdown artifacts excluded from tarball | smoke | `git check-ignore man/create_working_paper.Rd || true; R CMD build . && tar -tf typstR_*.tar.gz | grep -E '(^typstR/docs/|^typstR/pkgdown/)'` [CITED: https://cran.r-project.org/doc/manuals/r-release/R-exts.html] [ASSUMED] | ❌ Wave 0 for tarball-inspection command |

### Sampling Rate
- **Per task commit:** `Rscript -e 'devtools::check_man()'` after any roxygen/doc-source edit. [CITED: https://devtools.r-lib.org/reference/check_man.html]
- **Per wave merge:** `R CMD INSTALL . && env PATH=/opt/homebrew/bin:/usr/bin:/bin Rscript -e 'pkgdown::build_articles(quiet = FALSE, lazy = FALSE, preview = FALSE)'`. [CITED: https://pkgdown.r-lib.org/reference/build_articles.html] [VERIFIED: local commands 2026-06-01]
- **Phase gate:** Run README/home/getting-started manual review, exported-help-page audit, and tarball inspection before `/gsd-verify-work`. [VERIFIED: local commands 2026-06-01] [ASSUMED]

### Wave 0 Gaps
- [ ] Dedicated home-page source file (`pkgdown/index.md` or `index.md`) — required to separate README and site-home roles. [CITED: https://pkgdown.r-lib.org/reference/build_home.html] [ASSUMED]
- [ ] Exported-help-page audit script or test — `check_man()` alone did not catch a missing examples block. [VERIFIED: local commands 2026-06-01]
- [ ] `NEWS.md` — required for DOCS-05. [CITED: https://pkgdown.r-lib.org/reference/build_news.html] [VERIFIED: codebase view]
- [ ] Tarball inspection step for `.Rbuildignore` coverage — existing repo has no explicit validation command for docs artifacts. [CITED: https://cran.r-project.org/doc/manuals/r-release/R-exts.html] [ASSUMED]

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | Docs-only phase; no auth surface changes. [VERIFIED: phase scope] |
| V3 Session Management | no | Docs-only phase; no session surface changes. [VERIFIED: phase scope] |
| V4 Access Control | no | Docs-only phase; no access-control surface changes. [VERIFIED: phase scope] |
| V5 Input Validation | no | No new runtime input handlers are planned; keep examples aligned with existing validated package entry points. [VERIFIED: phase scope] [VERIFIED: codebase view] |
| V6 Cryptography | no | Docs-only phase; no crypto changes. [VERIFIED: phase scope] |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Docs instruct a flow that bypasses actual validation behavior | Tampering | Keep README/vignette/help text aligned with `validate_render_environment()` and render wrappers before publishing. [VERIFIED: codebase view] |
| pkgdown build artifacts leak into release tarballs | Information Disclosure | Enforce `.Rbuildignore` exclusions and verify with `R CMD build`. [CITED: https://cran.r-project.org/doc/manuals/r-release/R-exts.html] |

## Sources

### Primary (HIGH confidence)
- [CITED: https://pkgdown.r-lib.org/reference/build_home.html] - home-page source precedence and home-page generation behavior
- [CITED: https://pkgdown.r-lib.org/reference/build_articles.html] - article build behavior, installed-package note, article metadata rules
- [CITED: https://pkgdown.r-lib.org/reference/build_news.html] - `NEWS.md` heading formats and changelog generation
- [CITED: https://devtools.r-lib.org/reference/check_man.html] - `check_man()` scope
- [CITED: https://roxygen2.r-lib.org/] - source-driven `.Rd` / `NAMESPACE` generation model
- [CITED: https://cran.r-project.org/doc/manuals/r-release/R-exts.html] - `.Rbuildignore` behavior
- [VERIFIED: codebase view] - `README.md`, `vignettes/*.Rmd`, `R/*.R`, `.gitignore`, `.Rbuildignore`, `DESCRIPTION`, `NAMESPACE`
- [VERIFIED: local commands 2026-06-01] - CRAN package versions, `devtools::check_man()`, `pkgdown::build_articles()` before/after install, environment availability

### Secondary (MEDIUM confidence)
- None.

### Tertiary (LOW confidence)
- None.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - versions, tooling roles, and package behavior were verified from CRAN metadata, installed docs, and local commands.
- Architecture: HIGH - the split between README/home/articles/reference/news is directly documented by pkgdown and confirmed against repo state.
- Pitfalls: HIGH - each listed pitfall was either reproduced locally or derived from current repo/files plus official docs.

**Research date:** 2026-06-01
**Valid until:** 2026-07-01
