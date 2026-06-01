# Feature Landscape

**Domain:** typstR v1.2 (Documentation & Website Polish — pkgdown site + onboarding docs)
**Researched:** 2026-06-01
**Confidence:** HIGH (pkgdown is stable, well-documented, widely used; patterns verified against Context7 + ggplot2/usethis/renv gold-standard configs)

## Milestone Scope Boundary (v1.2)

This milestone makes typstR **discoverable and easy to adopt** for researchers landing on the GitHub page or a shared link for the first time.

**In scope:**
- `_pkgdown.yml` configuration with structured reference index, article navigation, and homepage narrative
- GitHub Actions workflow deploying the site to GitHub Pages on push to main
- `NEWS.md` changelog file (required for the site's Changelog page)
- Documentation polish: README as a coherent landing page, vignette cross-links, installation clarity
- Minor copy improvements to existing vignettes where friction is found

**Out of scope for this milestone:**
- Net-new vignettes or articles beyond the three already written
- Branding changes to the package's own output formats
- Custom pkgdown themes beyond Bootstrap 5 defaults
- Multi-version documentation (devel + release sites)
- Screenshot or rendered-PDF embeds in the site

---

## Table Stakes

Features that must be present for the site to be considered "published" — missing any of these makes the site feel incomplete or broken for first-time visitors.

| ID | Category | Feature | Why Expected | Complexity | Dependency Notes |
|---|---|---|---|---|---|
| TS-SITE-01 | pkgdown Config | **`_pkgdown.yml` with `url`, `template: bootstrap: 5`, and explicit navbar** (Home, Get Started, Reference, Articles, Changelog, GitHub) | Every serious R package site has this exact nav structure; absence signals an unmaintained project | LOW | Foundation for all other site features |
| TS-SITE-02 | pkgdown Config | **Grouped reference index** — scaffold functions, render wrappers, metadata helpers, publication helpers, validation/diagnostics, print methods as named sections with `desc:` | Alphabetical dump is unnavigable for a package with 20+ exported names; grouped reference is standard practice (ggplot2, usethis, renv all do this) | LOW-MEDIUM | Requires surveying the 20 exported `.Rd` files and assigning each to a logical group |
| TS-SITE-03 | pkgdown Config | **"Get Started" nav entry** pointing to `getting-started` vignette | pkgdown auto-promotes a vignette named after the package; `getting-started.Rmd` does NOT auto-promote — must be configured explicitly in `navbar.components` | LOW | Without this, new users land on the homepage and have no obvious next step |
| TS-SITE-04 | pkgdown Config | **Articles navbar** listing all three vignettes in onboarding order: getting-started → working-papers → customizing-branding | Vignette ordering tells the learning path; random ordering breaks the narrative | LOW | Three vignettes already exist; this is purely configuration |
| TS-SITE-05 | Deployment | **GitHub Actions workflow** running `pkgdown::deploy_to_branch()` on push to main, deploying to `gh-pages` branch | Without automated deploy, the site goes stale; `usethis::use_pkgdown_github_pages()` generates this scaffold automatically | LOW | Requires `gh-pages` branch created and Pages enabled in repo settings |
| TS-SITE-06 | Deployment | **`DESCRIPTION` `URL:` field updated** to include the pkgdown site URL (e.g., `https://davidzenz.github.io/typstR`) | pkgdown reads this for canonical links; CRAN displays it; critical for discoverability | LOW | The current `DESCRIPTION` `URL:` only has the GitHub source URL |
| TS-DOCS-01 | README Polish | **README is landing-page quality** — opens with the core value prop, shows the 3-line scaffold-edit-render workflow in the first screenful, has a clear install section | The README is the pkgdown homepage; if it buries the key workflow below the fold, first visitors bounce | LOW-MEDIUM | README already has the right pieces; needs tightening and ordering |
| TS-DOCS-02 | Changelog | **`NEWS.md` file exists** with at least v1.0, v1.1, and v1.2 entries | pkgdown generates a Changelog page from `NEWS.md`; without it, the Changelog nav link 404s or the link must be removed | LOW | Simple to create; each entry should be a brief bulleted summary of the milestone |
| TS-DOCS-03 | Vignette Polish | **Vignettes render cleanly** on the site (no broken code chunks, `eval = FALSE` correctly placed, cross-links between vignettes work as `vignette()` calls or article links) | Broken vignette pages are the most common first-impression failure on R package sites | LOW | Vignettes are well-structured already; light review for cross-link correctness |

---

## Differentiators

Features that make the site feel polished and purposeful rather than just "pkgdown defaults applied." None are required for launch, but each meaningfully improves first-time adoption.

| ID | Category | Feature | Value Proposition | Complexity | Notes |
|---|---|---|---|---|---|
| DF-SITE-01 | Homepage | **Hero code block on homepage** — the 3-line scaffold/render workflow shown prominently as a README code snippet that renders into a callout or highlighted block on the site | typstR's core value is speed-to-PDF; a visitor should see `create_working_paper()` + `render_working_paper()` within 5 seconds of landing | LOW | Achieved through README copy changes, not pkgdown config |
| DF-SITE-02 | Reference Index | **`desc:` fields on every reference section** explaining who each function group is for and when to use it | Researchers who don't know R package conventions need a sentence of context before diving into function signatures | LOW | Pure YAML copy work in `_pkgdown.yml` |
| DF-SITE-03 | Branding | **Package logo** (`man/figures/logo.png`) and **auto-generated favicons** via `pkgdown::build_favicon()` | Logo in the navbar signals a maintained, professional project; absence reads as "draft"; typstR's own branding story makes this especially congruent | MEDIUM | Requires creating a logo asset; `pkgdown::build_favicon()` handles the rest |
| DF-SITE-04 | Branding | **`pkgdown/extra.css`** with one or two CSS variables that align the site accent color to typstR's own theme | Subtle consistency signal; easy win given the package already has a strong branding identity | LOW | 5–10 lines of CSS; does not require `tidytemplate` or custom Bootstrap |
| DF-SITE-05 | README | **System requirements callout** in README** — explicit note that Quarto and Typst must be installed, with a link to `check_typstR()` as the diagnostic entry point | Currently the most common first-run friction; surfacing this before "Quick start" saves the most support burden | LOW | One paragraph / callout addition to README |
| DF-DOCS-01 | Vignette Copy | **Format comparison table** in `getting-started.Rmd` or a new article — side-by-side of workingpaper vs article vs policy-brief showing which fields/features each format uses | Researchers need to choose a format before scaffolding; a comparison table saves them from creating the wrong type | LOW-MEDIUM | Could be a table in getting-started or a lightweight standalone article |
| DF-DOCS-02 | README | **Badges row** in README: R CMD check status, pkgdown deploy status, license | Standard signal of project health; CRAN badge deferred until submission | LOW | GitHub Actions provides badge URLs automatically |

---

## Anti-Features

Features to explicitly exclude from v1.2. Each has a clear reason and a stated alternative.

| Anti-Feature | Why Avoid | What To Do Instead |
|---|---|---|
| **`tidytemplate` or custom Bootstrap theme** | Requires installing an extra dependency (`pak::pak("tidyverse/tidytemplate")`); visual benefit is marginal over Bootstrap 5 defaults for a first launch; adds complexity with no onboarding payoff | Use `template: bootstrap: 5` in `_pkgdown.yml`; add `pkgdown/extra.css` for minimal accent color if desired |
| **Multi-version docs (`devel` + release site)** | `development: mode: auto` is sufficient for a pre-CRAN package; a separate `/dev` site adds deploy complexity without benefit at this user-base size | Set `development: mode: auto` and let pkgdown version-label the dev build automatically |
| **New vignettes or "cookbook" articles** | Writing new content is a scope expansion beyond docs polish; risks delaying site launch while content is perfected | Polish the three existing vignettes; a format comparison table (DF-DOCS-01) can be added to an existing vignette rather than as a standalone article |
| **Rendered PDF screenshots or embedded outputs** | Requires a Quarto + Typst environment in CI, adds render time, and produces brittle image artifacts; significant CI complexity for a docs-polish milestone | Describe the PDF output in prose; link to example repos or show YAML snippets |
| **Search customization or Algolia DocSearch** | pkgdown's built-in client-side search (Bootstrap 5 default) is sufficient for a package of this size; Algolia requires a separate account and crawl setup | Accept the default `search` component in the navbar; it works out of the box |
| **`NEWS.md` with full prose release notes or blog-post links** | Excessive for a pre-CRAN package; the usethis pattern of linking to blog posts for major releases is appropriate for tidyverse packages with large audiences | Use a simple bullet-list `NEWS.md` following the standard `# typstR vX.Y` header format |
| **Changelog entries for every internal commit** | NEWS.md should summarize user-visible changes per milestone, not per commit; granular entries add noise without user benefit | One entry per shipped milestone (v1.0, v1.1, v1.2) is correct grain |
| **pkgdown site as the primary dev workflow** | Building the full site locally is slow; it should be for final review only | Use `pkgdown::build_reference()` or `pkgdown::build_article()` for iterative local preview |

---

## Feature Dependencies

```text
_pkgdown.yml created (TS-SITE-01)
  -> required before any other site features are testable
  -> defines navbar (TS-SITE-03, TS-SITE-04)
  -> defines reference groupings (TS-SITE-02)

NEWS.md created (TS-DOCS-02)
  -> required for Changelog page to not 404
  -> should exist before GitHub Actions first deploys (TS-SITE-05)

README polish (TS-DOCS-01)
  -> feeds directly into pkgdown homepage; do before first deploy
  -> hero code block (DF-SITE-01) lives here

GitHub Actions workflow (TS-SITE-05)
  -> depends on _pkgdown.yml and NEWS.md being correct first
  -> requires DESCRIPTION URL updated (TS-SITE-06) to point at published site

Logo (DF-SITE-03)
  -> prerequisite for build_favicon()
  -> optional but should be created before first public share of the URL
```

### Ordering Note

Do `_pkgdown.yml` + `NEWS.md` + README polish **before** enabling GitHub Actions deploy. The first automated build sets the public-facing impression; don't let an incomplete site go live.

---

## MVP Recommendation (v1.2)

### Must ship (gate milestone completion)

1. **TS-SITE-01** — `_pkgdown.yml` scaffold with url, Bootstrap 5, navbar
2. **TS-SITE-02** — Grouped reference index (scaffold / render / metadata / pub helpers / validation / print)
3. **TS-SITE-03 + TS-SITE-04** — "Get Started" entry + articles in order
4. **TS-SITE-05 + TS-SITE-06** — GitHub Actions deploy + DESCRIPTION URL
5. **TS-DOCS-01** — README polish (landing-page quality)
6. **TS-DOCS-02** — `NEWS.md` with three milestone entries
7. **TS-DOCS-03** — Vignette review pass (cross-links, eval guards)

### High-value additions (include if time permits)

- **DF-SITE-01** — Hero code block in README (15-min copy edit)
- **DF-SITE-02** — `desc:` on each reference section (30-min YAML edit)
- **DF-SITE-05** — System requirements callout in README
- **DF-DOCS-02** — Badges row in README

### Defer to v1.3 or later

- **DF-SITE-03** — Package logo (requires design work)
- **DF-SITE-04** — `pkgdown/extra.css` accent color (nice but not critical for launch)
- **DF-DOCS-01** — Format comparison table (useful but can land in a vignette patch)

---

## Reference Index Groupings (for `_pkgdown.yml`)

The 20 exported names in `man/` map cleanly to five functional groups:

| Section Title | Functions | User Need |
|---|---|---|
| **Create a project** | `create_working_paper`, `create_article`, `create_policy_brief` | Start a new manuscript |
| **Render** | `render_pub`, `render_working_paper` | Produce the PDF |
| **Metadata helpers** | `author`, `affiliation`, `manuscript_meta`, `funding`, `data_availability`, `code_availability` | Build author and publication metadata |
| **Publication helpers** | `keywords`, `jel_codes`, `report_number`, `fig_note`, `tab_note`, `appendix_title` | Annotate the manuscript |
| **Validation and diagnostics** | `check_typst`, `check_quarto`, `check_typstR`, `validate_manuscript` | Diagnose environment and manuscript issues |
| **Internal print methods** *(internal: true)* | `print.typstR_author`, `print.typstR_affiliation`, `print.typstR_meta` | S3 display; keep out of user-facing index |

---

## Sources

### Context7 / official docs (HIGH confidence)
- pkgdown configuration reference: Context7 `/r-lib/pkgdown` (verified June 2026)
- pkgdown GitHub Pages deploy: `pkgdown::deploy_to_branch()` docs, `usethis::use_pkgdown_github_pages()` — https://pkgdown.r-lib.org
- pkgdown bootstrap 5 template: default since pkgdown 2.0

### Gold-standard config references (HIGH confidence — verified directly)
- ggplot2 `_pkgdown.yml`: https://github.com/tidyverse/ggplot2/blob/main/_pkgdown.yml (grouped reference, custom navbar, Bootstrap 5)
- usethis `_pkgdown.yml`: https://github.com/r-lib/usethis/blob/main/_pkgdown.yml (explicit "Setup" nav entry pattern, `development: mode: auto`)
- renv `_pkgdown.yml`: https://github.com/rstudio/renv/blob/main/_pkgdown.yml (focused package, clean section titles pattern)

### Internal codebase evidence (HIGH confidence)
- `man/` — 20 `.Rd` files surveyed for grouping decisions
- `vignettes/` — 3 vignettes confirmed present and cross-linked
- `DESCRIPTION` — confirmed current `URL:` only lists GitHub source; pkgdown URL field missing
- `README.md` — reviewed; core workflow present but system requirements not surfaced prominently
