# Architecture: typstR v1.2 Docs Site Integration

**Domain:** R package documentation — pkgdown static site over an existing R package
**Researched:** 2026-06-01
**Overall confidence:** HIGH (pkgdown is well-documented; all integration mechanics verified via Context7 against r-lib/pkgdown source)

---

## 1. How pkgdown Consumes the Existing Repository

pkgdown is a site generator that reads artifacts already present in a well-formed R package. It does **not** require a parallel content layer — it derives the site from sources that already exist or must be maintained anyway.

| pkgdown Site Section | Source in typstR repo | Transformation |
|---|---|---|
| **Home page** (`index.html`) | `README.md` | Rendered as-is into Bootstrap HTML |
| **Reference index** (`reference/index.html`) | `man/*.Rd` (all 21 files) | Grouped and linked; grouping config in `_pkgdown.yml` |
| **Reference pages** (`reference/<fn>.html`) | Individual `.Rd` files | One HTML per exported topic |
| **Articles index** (`articles/index.html`) | `vignettes/*.Rmd` (3 files) | Auto-discovered by pkgdown |
| **Article pages** (`articles/<name>.html`) | Each `.Rmd` vignette | Rendered via knitr at site-build time |
| **Package metadata** (footer, navbar title) | `DESCRIPTION` (Title, Version, Authors@R, URL, BugReports) | Injected into every page template |
| **Search index** (`search.json`) | All reference + article text | Auto-generated |

**Key fact (verified):** pkgdown's `build_articles()` supports Quarto (`.qmd`) vignettes from pkgdown ≥ 1.5 / Quarto ≥ 1.5, but typstR's existing vignettes are `.Rmd` and use `output: rmarkdown::html_vignette`. These are fully supported by current pkgdown and require no migration.

---

## 2. Complete File Inventory: New vs. Modified

### NEW files (do not exist; must be created)

| File | Purpose | Phase |
|---|---|---|
| `_pkgdown.yml` | Master site config: navbar, reference grouping, bootstrap theme, footer | Core setup |
| `.github/workflows/pkgdown.yaml` | CI workflow: build site on push to main, deploy to `gh-pages` branch | Deployment |
| `man/figures/logo.png` | Package logo — appears in navbar; referenced by README badge | Optional polish |
| `pkgdown/extra.css` | Optional custom CSS overrides (only if visual tweaks are needed) | Optional polish |

### MODIFIED files (exist; need targeted changes)

| File | What Changes | Why |
|---|---|---|
| `DESCRIPTION` | Add `pkgdown` to `Suggests:` | Required for `R CMD check` to not warn when pkgdown is called in CI |
| `DESCRIPTION` | Add second URL entry for docs site (e.g. `https://davidzenz.github.io/typstR`) | Makes pkgdown link to live site and improves CRAN discoverability |
| `.Rbuildignore` | Add `^docs$`, `^_pkgdown\.yml$`, `^pkgdown$` | These must not ship inside the built R package tarball |
| `.gitignore` | Add `docs/` | Local `build_site()` output should not be committed; CI deploys from `gh-pages` branch |
| `README.md` | Polish content and structure (becomes home page verbatim) | The README is the home page — any roughness is visible at the top of the site |
| `vignettes/getting-started.Rmd` | Content polish; verify all render calls are guarded with `eval = FALSE` | Vignettes run at site-build time; Quarto/Typst are not available in CI |
| `vignettes/working-papers.Rmd` | Content polish; same eval guard check | Same constraint |
| `vignettes/customizing-branding.Rmd` | Content polish; same eval guard check | Same constraint |
| `man/*.Rd` (via `R/` edits) | Roxygen doc polish — titles, descriptions, `@examples` sections | Reference pages are generated from these; gaps show on the published site |

### GENERATED artifacts (never hand-edit; gitignored for local builds)

```
docs/                        ← local build output (gitignored; CI deploys from gh-pages branch)
  index.html                 ← from README.md
  reference/
    index.html               ← grouped function listing (grouping from _pkgdown.yml)
    create_working_paper.html
    author.html
    ... (one per Rd file)
  articles/
    index.html
    getting-started.html
    working-papers.html
    customizing-branding.html
  search.json
  pkgdown.js
```

---

## 3. Data / Content Flow

```
                        ┌─────────────────────────────────────────────────────┐
                        │              typstR repository                       │
                        │                                                     │
  Author writes         │  R/              roxygen2         man/*.Rd          │
  @title/@param ──────► │  *.R  ─────────────────────────► *.Rd  ────────────┼──► reference/*.html
  @examples             │                                                     │
                        │  README.md ─────────────────────────────────────────┼──► index.html
                        │                                                     │
  Author writes         │  vignettes/     knitr render      articles/         │
  vignette content ───► │  *.Rmd ─────────────────────────► *.html  ──────────┼──► articles/*.html
                        │                                                     │
  Author configures     │  _pkgdown.yml ──► grouping + navbar + theme         │
                        │                                                     │
                        │  DESCRIPTION ───► metadata (title, version,         │
                        │                  authors, URLs)                     │
                        └────────────────────┬────────────────────────────────┘
                                             │
                                    pkgdown::build_site()
                                             │
                              ┌──────────────▼──────────────┐
                              │     docs/ (static HTML)      │
                              │     (local preview only)     │
                              └──────────────┬──────────────┘
                                             │
                               .github/workflows/pkgdown.yaml
                                             │
                              ┌──────────────▼──────────────┐
                              │  gh-pages branch (GitHub)   │
                              │  Served at:                  │
                              │  davidzenz.github.io/typstR  │
                              └─────────────────────────────┘
```

**Trigger chain for CI:**
Push to `main` → GitHub Actions runs `pkgdown::build_site_github_pages()` → commits built HTML to `gh-pages` branch → GitHub Pages serves it.

---

## 4. `_pkgdown.yml` Structure

This is the single most important new file. Its structure drives the entire site.

```yaml
url: https://davidzenz.github.io/typstR

template:
  bootstrap: 5

navbar:
  structure:
    left:  [intro, reference, articles]
    right: [search, github]
  components:
    intro:
      text: Get started
      href: articles/getting-started.html

reference:
  - title: "Scaffolding"
    desc: "Create new publication projects."
    contents:
      - create_working_paper
      - create_article
      - create_policy_brief

  - title: "Metadata helpers"
    desc: "Build author, affiliation, and manuscript metadata."
    contents:
      - author
      - affiliation
      - manuscript_meta
      - funding
      - data_availability
      - code_availability

  - title: "Publication helpers"
    desc: "Typed fields, annotations, and identifiers."
    contents:
      - keywords
      - jel_codes
      - report_number
      - fig_note
      - tab_note
      - appendix_title

  - title: "Rendering"
    desc: "Render manuscripts to PDF."
    contents:
      - render_pub
      - render_working_paper

  - title: "Validation and diagnostics"
    desc: "Check system readiness and validate manuscript metadata."
    contents:
      - check_typst
      - check_quarto
      - check_typstR
      - validate_manuscript

articles:
  - title: "Guides"
    navbar: ~
    contents:
      - getting-started
      - working-papers
      - customizing-branding
```

**Note on reference grouping:** All 21 `.Rd` files must appear in exactly one `contents:` list or pkgdown warns. The `print.*` S3 method pages (`print.typstR_affiliation`, `print.typstR_author`, `print.typstR_meta`) can be omitted by adding `@keywords internal` to their roxygen source — pkgdown silently omits internal topics from the reference index. This is the preferred approach over listing them in a cluttered "Internals" group.

---

## 5. Ordering Constraints and Build Dependencies

These are hard sequencing constraints — violating them causes build failures or wasted rework.

```
[1] Roxygen doc polish (R/ → man/)
      │
      Depends on: none
      Required before: pkgdown reference build (reference pages come from man/)
      Validation: devtools::document(), check for warnings

[2] README polish
      │
      Depends on: none (independent)
      Required before: pkgdown home page looks right
      Validation: manual review; check that all code blocks use backtick fencing

[3] Vignette eval-guard audit + content polish
      │
      Depends on: none (independent)
      Required before: pkgdown::build_articles() succeeds in CI
      Validation: pkgdown::build_articles() locally with no Quarto/Typst in PATH

[4] DESCRIPTION update (add pkgdown to Suggests, add docs URL)
      │
      Depends on: knowing the final GH Pages URL
      Required before: R CMD check is clean after adding pkgdown dep

[5] _pkgdown.yml creation
      │
      Depends on: [1] (need final function inventory to group correctly)
      Required before: any pkgdown::build_site() call
      Validation: pkgdown::check_pkgdown()

[6] .Rbuildignore + .gitignore updates
      │
      Depends on: [5] (need to know what files pkgdown introduces at root)
      Required before: R CMD check passes cleanly
      Validation: R CMD check --as-cran

[7] Local site build + visual QA
      │
      Depends on: [1]–[6] all complete
      Required before: CI workflow setup (catches problems cheaply)
      Validation: pkgdown::build_site(preview = FALSE); open docs/index.html in browser

[8] .github/workflows/pkgdown.yaml creation
      │
      Depends on: [7] (local build confirmed clean)
      Required before: automated deployment
      Validation: push to main; check Actions tab; verify gh-pages branch populated

[9] GitHub Pages configuration
      │
      Depends on: [8] (gh-pages branch must exist)
      Required before: site is publicly accessible
      Validation: visit https://davidzenz.github.io/typstR
```

---

## 6. Component Boundaries

| Component | Responsibility | Does NOT own |
|---|---|---|
| `R/*.R` + `man/*.Rd` | Function reference content (titles, params, examples, descriptions) | Site structure, navigation |
| `vignettes/*.Rmd` | Long-form narrative documentation (articles on the site) | Short inline examples (those belong in man/) |
| `README.md` | Home page: install path, quick start, one-liner pitch | Deep how-to (that belongs in vignettes) |
| `_pkgdown.yml` | Site structure, navigation, reference grouping, theme | Content (content lives in source files) |
| `.github/workflows/pkgdown.yaml` | CI build and deployment trigger | Content or structure decisions |
| `inst/quarto/`, `inst/templates/` | Quarto extension assets bundled with the R package | Doc site generation (these are package runtime assets, not site sources) |

**Critical boundary:** `inst/` content is **not consumed by pkgdown**. The Quarto extension files in `inst/quarto/extensions/typstR/` and the scaffold templates in `inst/templates/` are R package runtime assets. They do not become site pages automatically. If the site needs to explain these (e.g., a "Template Reference" article), that explanation goes in a vignette — the raw `.typ` files themselves are not rendered by pkgdown.

---

## 7. Validation Points by Phase

| Phase Topic | What to Validate | Tool |
|---|---|---|
| Roxygen polish | All exported functions have title + description + `@param` + at least one `@examples` | `devtools::check_man()` |
| Vignette eval guards | No vignette chunk executes `render_*()`, `create_*()`, `check_typst()` without `eval = FALSE` | `pkgdown::build_articles()` locally (no Quarto in PATH) |
| Reference grouping | Every exported topic appears in exactly one `_pkgdown.yml` reference group | `pkgdown::check_pkgdown()` |
| .Rbuildignore coverage | `docs/`, `_pkgdown.yml`, `pkgdown/`, `.github/` all excluded from tarball | `R CMD build .` + inspect tarball contents |
| Local build | Site builds without warnings or errors | `pkgdown::build_site(preview = FALSE)` |
| CI deployment | Push to main triggers workflow; gh-pages branch updated | GitHub Actions run log |
| Live site | Navigation works; search works; all 3 article pages load | Manual browser review |

---

## 8. Edge Cases and Integration Risks

### Risk: Vignette execution in CI
**Problem:** `vignettes/*.Rmd` are rendered by pkgdown at build time. Any chunk calling `render_*()` without `eval = FALSE` will fail in CI because Quarto and Typst are not installed in the pkgdown build runner.
**Mitigation:** Audit all three vignettes before configuring CI. The existing vignette headers already show `eval = FALSE` on render calls, but all three files need explicit per-chunk verification.

### Risk: S3 print methods polluting the reference index
**Problem:** pkgdown warns if any `.Rd` file is not assigned to a reference group. The three `print.typstR_*` methods (`print.typstR_affiliation`, `print.typstR_author`, `print.typstR_meta`) are low-value reference pages.
**Mitigation:** Add `@keywords internal` to their roxygen source. pkgdown silently omits internal topics from the reference index without warnings.

### Risk: README as home page — mismatched audience tone
**Problem:** The current README is written for GitHub browsing. As the pkgdown home page it becomes the primary landing page for new users arriving from a search or link.
**Mitigation:** Keep the README GitHub-compatible but verify the install-to-quick-start flow is complete and compelling as a standalone landing page. The README is now dual-purpose.

### Risk: `docs/` accidentally committed to `main`
**Problem:** If a developer runs `pkgdown::build_site()` locally without the `docs/` gitignore entry, the generated HTML gets committed and conflicts with the CI `gh-pages` deployment pattern.
**Mitigation:** Add `docs/` to `.gitignore` early — in the same phase as creating `_pkgdown.yml`, not after.

### Risk: `.Rbuildignore` gaps breaking `R CMD check`
**Problem:** `_pkgdown.yml`, `pkgdown/`, `.github/`, and `docs/` at the package root are not standard R package directories. `R CMD check` warns about unknown top-level files if they are absent from `.Rbuildignore`.
**Mitigation:** Update `.Rbuildignore` in the same commit as creating these files. The existing `.Rbuildignore` already follows a good pattern with anchored regex entries.

---

## 9. Recommended Phase Structure for Roadmap

Based on the ordering constraints and risk profile, the work naturally groups into three phases:

**Phase A — Content foundation (prerequisite for everything)**
Polish the artifacts pkgdown consumes: roxygen docs (`R/` → `man/`), vignette content and eval guards, README. No pkgdown dependency. Must land first. Validates with `devtools::check_man()` and `pkgdown::build_articles()` locally.

**Phase B — Site configuration and local build**
Create `_pkgdown.yml`, update DESCRIPTION (`Suggests:` + docs URL), update `.Rbuildignore`/`.gitignore`, run `pkgdown::build_site()` locally. Validates with `pkgdown::check_pkgdown()` and a local browser review.

**Phase C — CI/CD deployment and live site**
Create `.github/workflows/pkgdown.yaml`, configure GitHub Pages (source: `gh-pages` branch), push and verify the live URL. Validates with Actions run log and browser review of the live site.

This order ensures content is polished before it is published, and the publishing infrastructure is only wired up after a clean local build is confirmed — avoiding repeated CI debug cycles.

---

## Sources

- pkgdown documentation: Context7 `/r-lib/pkgdown` (HIGH confidence — verified against r-lib/pkgdown source)
- pkgdown GitHub Actions / `deploy_to_branch()`: Context7 `/r-lib/pkgdown` NEWS.md and README (HIGH confidence)
- pkgdown Bootstrap 5 config: Context7 `/r-lib/pkgdown` (HIGH confidence)
- pkgdown Quarto vignette support (≥ 1.5): Context7 `/r-lib/pkgdown` NEWS (HIGH confidence)
- Existing repo structure: direct inspection of `/Users/davidzenz/R/typstR/` (HIGH confidence)
