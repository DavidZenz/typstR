# Research Summary — typstR v1.2

**Project:** typstR
**Milestone:** v1.2 — pkgdown Website + Onboarding Documentation Polish
**Synthesized:** 2026-06-01
**Source files:** STACK.md · FEATURES.md · ARCHITECTURE.md · PITFALLS.md
**Overall confidence:** HIGH

---

## Executive Summary

typstR v1.2 is a pure documentation and discoverability milestone. No new R code ships. The goal is a live, polished pkgdown site at `https://davidzenz.github.io/typstR/` — automatically deployed on push to `main` — that lets a researcher land from a link or GitHub search and reach a working scaffold-edit-render workflow within minutes. Research converges unanimously: **pkgdown + GitHub Pages via `r-lib/actions`** is the only realistic choice; there are no credible alternatives worth evaluating. The entire setup is bootstrappable with one `usethis::use_pkgdown_github_pages()` call, and the existing three vignettes and 20 exported functions map cleanly to the standard pkgdown site structure.

The recommended build order is content-before-infrastructure: polish the artifacts pkgdown consumes (roxygen docs, vignette eval guards, README) before writing a single line of site config, and write and validate `_pkgdown.yml` locally before enabling any CI/CD automation. This prevents the most expensive failure mode — repeated CI debug cycles against a partially configured site. The architecture research is explicit: three phases (content foundation → site config + local build → CI/CD deploy), each with hard sequencing constraints and cheap local validation gates that catch problems before they reach GitHub Actions.

The critical risk specific to this repo is that `man/*.Rd` files are currently gitignored. This will silently break the CI reference build on first push. It must be resolved — by removing the gitignore entry and committing the generated `.Rd` files — before any GitHub Actions workflow is created. Every other risk in the pitfalls research is either fully mitigated by using `usethis::use_pkgdown_github_pages()` as the scaffold entry point or is surfaced cleanly by `pkgdown::check_pkgdown()` before the site goes live.

---

## 1. Recommended Milestone Scope

**In scope — gates v1.2 completion:**

| Item | What it is | Why it must ship |
|---|---|---|
| `_pkgdown.yml` | Site config: URL, Bootstrap 5, navbar, reference groupings, article ordering | Foundation of the entire site; nothing else works without it |
| Grouped reference index | 20 exported functions assigned to 5 named sections in `_pkgdown.yml` | Flat alphabetical list makes the API unnavigable for researchers |
| `NEWS.md` | Backfilled v1.0, v1.1, v1.2 entries | pkgdown generates a Changelog page; without it the nav link is broken or dead |
| README polish | Landing-page quality: value prop first, install path clear, system requirements surfaced | README is the pkgdown homepage verbatim; first impression for every new visitor |
| Vignette eval-guard audit | Verify all three `.Rmd` vignettes have `eval = FALSE` on render/scaffold chunks | Vignettes execute at site-build time in CI where Quarto/Typst are not installed |
| `DESCRIPTION` URL update | Add pkgdown site URL as first URL entry | pkgdown reads this for canonical links; breaks nav if absent |
| `DESCRIPTION` `Suggests` update | Add `pkgdown (>= 2.0.0)` | Required for clean `R CMD check` |
| `.Rbuildignore` / `.gitignore` updates | Exclude `_pkgdown.yml`, `docs/`, `pkgdown/` from tarball; gitignore local `docs/` build | CRAN cleanliness; prevents `docs/` pollution on `main` branch |
| `man/*.Rd` git status fix | Remove `man/*.Rd` from `.gitignore`; commit generated `.Rd` files | **Repo-specific blocker:** CI cannot build reference pages from gitignored files |
| GitHub Actions workflow | `r-lib/actions` canonical `pkgdown.yaml`; deploys to `gh-pages` branch | Automated deploy is what makes the site live and non-stale |
| GitHub Pages activation | Repo Settings → Pages → Source: `gh-pages` branch | Without this the GHA deploy succeeds but the URL returns 404 |

**High-value additions — include if time permits (15–30 min each):**

- Hero code block in README (`create_working_paper()` → `render_working_paper()` in first screenful)
- System requirements callout in README pointing to `check_typstR()` as diagnostic entry point
- `desc:` prose on each `_pkgdown.yml` reference section explaining who each function group is for
- Badges row in README (R CMD check, pkgdown deploy, license)
- `development: mode: release` in `_pkgdown.yml` to suppress the "dev" badge while DESCRIPTION version is `0.0.0.9000`

---

## 2. Must-Have Requirements Inputs

### From STACK.md

- `pkgdown (>= 2.0.0)` in `Suggests:` — the only DESCRIPTION change needed.
- Use `r-lib/actions` v2 canonical `pkgdown.yaml` workflow verbatim; do not hand-roll the deploy step.
- CI runner does **not** need Quarto or Typst installed — vignettes are `.Rmd` / knitr only.
- `GITHUB_TOKEN` with `contents: write` permission handles all deploy auth; no PAT secrets needed.
- `docs/` goes in `.gitignore`; site deploys from `gh-pages` branch, not from a committed `docs/` folder.

### From FEATURES.md

- **Table-stakes features** (TS-SITE-01 through TS-DOCS-03) are all required for milestone sign-off; none are optional.
- The "Get Started" navbar entry must be wired **manually** in `_pkgdown.yml` — pkgdown only auto-promotes a vignette named `typstR.Rmd`; `getting-started.Rmd` will not auto-promote.
- All three vignettes must appear explicitly in the `articles:` section of `_pkgdown.yml` or pkgdown warns and they become unreachable via navigation.
- `NEWS.md` must follow the `# typstR X.Y` heading format pkgdown expects; do not commit it to `.Rbuildignore` (it is a standard R package file).
- S3 print methods (`print.typstR_author`, `print.typstR_affiliation`, `print.typstR_meta`) should be marked `@keywords internal` in roxygen so pkgdown omits them from the public reference index without warnings.

### From ARCHITECTURE.md

- Every exported `.Rd` file must appear in exactly one `reference:` group in `_pkgdown.yml`, or pkgdown emits warnings. The 5-group schema (Scaffolding / Metadata helpers / Publication helpers / Rendering / Validation and diagnostics) accounts for all 20+ functions.
- `pkgdown::check_pkgdown()` is the cheapest validation tool — run it after every edit to `_pkgdown.yml` before attempting a full build.
- `pkgdown::build_articles()` run locally **without Quarto in PATH** is the canonical pre-CI vignette guard test.
- `inst/quarto/extensions/` and `inst/templates/` are **not consumed by pkgdown** — they are runtime package assets, not doc site sources. Do not attempt to expose `.typ` files as site pages.

### From PITFALLS.md

- **`man/*.Rd` gitignore removal is the single highest-priority pre-work item.** It must be resolved before the GHA workflow is written or the reference section will silently disappear in CI.
- DESCRIPTION `URL:` must follow the two-URL convention — docs URL first, GitHub second — so pkgdown's canonical links and navbar GitHub icon both resolve correctly.
- `usethis::use_pkgdown_github_pages()` handles most scaffolding correctly (`.Rbuildignore` entries, workflow permissions, deploy target). Prefer it over manual file creation to avoid C3/C4 class pitfalls.
- README cross-doc links must use absolute URLs (pointing to the live site) or pkgdown-site-relative paths — **never** relative paths to `.Rmd` source files.

---

## 3. Proposed Phase Ordering

The architecture research defines a hard 3-phase sequence. Phase ordering is non-negotiable: content must exist before it can be configured, and configuration must be locally validated before CI/CD is enabled.

### Phase A — Content Foundation *(prerequisite for everything)*

**What:** Polish all source files pkgdown consumes. No pkgdown config involved yet.

**Deliverables:**
1. Remove `man/*.Rd` from `.gitignore`; run `devtools::document()` and commit all `.Rd` files.
2. Roxygen audit: every exported function has a title, description, `@param` per arg, and at least one `@examples` entry. Add `@keywords internal` to print methods.
3. Vignette eval-guard pass: verify all three `.Rmd` files have `eval = FALSE` on every chunk that calls `render_*()`, `create_*()`, `check_*()`. Test with `pkgdown::build_articles()` in a shell with no Quarto in `PATH`.
4. README polish: value prop and install path in first screenful; system requirements callout; hero code block showing canonical 3-step workflow.
5. `NEWS.md` creation: backfill v1.0, v1.1, v1.2 entries from `.planning/milestones/` archives.

**Validation:** `devtools::check_man()` clean; `pkgdown::build_articles()` succeeds without Quarto.

**Pitfalls to avoid:** C1 (`.Rd` not committed), C2 (no `NEWS.md`), M6 (broken README relative links), m4 (three-surface drift — README, vignettes, and future site must tell one canonical story).

---

### Phase B — Site Configuration + Local Build

**What:** Create `_pkgdown.yml`, update housekeeping files, run and review a full local build.

**Deliverables:**
1. Run `usethis::use_pkgdown()` (or `use_pkgdown_github_pages()` if doing both phases together) to scaffold `_pkgdown.yml` and add `.Rbuildignore` entries.
2. Edit `_pkgdown.yml`:
   - `url:` set to `https://davidzenz.github.io/typstR/`
   - `template: bootstrap: 5`
   - Explicit `navbar` with `intro` component wired to `articles/getting-started.html`
   - 5-group `reference:` section covering all 20 functions
   - `articles:` section listing all three vignettes in onboarding order
   - `development: mode: release` (suppresses dev badge while version is `0.0.0.9000`)
3. DESCRIPTION: add docs URL as first `URL:` entry; add `pkgdown (>= 2.0.0)` to `Suggests:`.
4. Add `docs/` to `.gitignore`.
5. Run `pkgdown::check_pkgdown()` — zero warnings required.
6. Run `pkgdown::build_site(preview = FALSE)` locally; open `docs/index.html` and manually review every nav link, reference group, and article page.

**Validation:** `pkgdown::check_pkgdown()` clean; local build with zero errors/warnings; manual browser review of all navigation paths.

**Pitfalls to avoid:** C2 (NEWS.md must exist before this build), C3 (`.Rbuildignore` gaps), M1 (Get Started wiring), M2 (DESCRIPTION URL), M3 (dev badge), M4 (unlisted vignettes), M5 (flat reference), m3 (YAML schema errors).

---

### Phase C — CI/CD Deployment + Live Site

**What:** Wire GitHub Actions, activate GitHub Pages, confirm live URL.

**Deliverables:**
1. Run `usethis::use_pkgdown_github_pages()` to generate `.github/workflows/pkgdown.yaml` with correct `permissions: contents: write`.
2. Enable GitHub Pages in repo Settings → Pages → Source: "Deploy from branch: `gh-pages`, `/` (root)."
3. Push to `main`; verify the Actions run completes without errors.
4. Visit `https://davidzenz.github.io/typstR/` and confirm: home page loads, all nav links resolve, search works, all 3 article pages render, reference index shows grouped functions.

**Validation:** Actions log green; live URL accessible; full manual browser smoke test.

**Pitfalls to avoid:** C4 (workflow `contents: write` permission), M7 (package installed before `build_site()` in CI), m2 (deploying to `docs/` on main instead of `gh-pages` branch).

---

### Phase Ordering Rationale

Content before config prevents configuring a site against documentation that will change. Config before CI prevents burning Actions minutes on repeated debug cycles. The most common failure pattern in the R community — "my workflow runs green but the site is wrong" — is entirely avoided by completing Phases A and B locally before Phase C is written.

---

## 4. Key Risks and Mitigations

| Risk | Severity | Phase | Mitigation |
|---|---|---|---|
| `man/*.Rd` files are gitignored → CI reference build silently produces empty or broken Reference section | **Critical** | Must fix before Phase C | Remove `man/*.Rd` from `.gitignore`; commit all `.Rd` files in Phase A |
| Vignette chunk calls `render_*()` or `create_*()` without `eval = FALSE` → site build fails in CI (no Quarto in runner) | **Critical** | Phase A | Run `pkgdown::build_articles()` locally without Quarto in PATH as the acceptance test |
| `contents: write` permission missing from GHA workflow → deploy silently fails; site never updates | **Critical** | Phase C | Use `usethis::use_pkgdown_github_pages()` to generate the workflow; do not hand-roll |
| `_pkgdown.yml` and `pkgdown/` not in `.Rbuildignore` → `R CMD check` NOTE; CRAN tarball bloated | **High** | Phase B | `usethis::use_pkgdown()` adds these automatically; verify with `devtools::build()` + tarball inspect |
| No `NEWS.md` → Changelog nav link broken or 404 | **High** | Phase B | Create `NEWS.md` with v1.0/v1.1/v1.2 entries before first `pkgdown::build_site()` call |
| DESCRIPTION `URL:` single-entry → canonical links and GitHub navbar icon misbehave | **High** | Phase B | Two-URL convention: docs URL first, then GitHub URL |
| `getting-started.Rmd` not auto-promoted to top-level "Get Started" nav | **Medium** | Phase B | Wire manually via `navbar.components.intro` in `_pkgdown.yml`; do not rely on pkgdown auto-detection |
| README relative links to `.Rmd` files break on pkgdown homepage | **Medium** | Phase A | Audit README for any relative doc links; replace with absolute site URLs |
| Dev mode badge (`0.0.0.9000`) signals "pre-release toy" to new visitors | **Medium** | Phase B | Set `development: mode: release` in `_pkgdown.yml`; OR bump version to `1.2.0` at site launch |
| Three-surface story drift: README, vignettes, and site show inconsistent canonical workflow examples | **Medium** | Spans A–C | Define one canonical golden path before editing; enforce it across all surfaces in one pass |
| `_pkgdown.yml` YAML schema errors produce cryptic R errors, not parse failures | **Low** | Phase B | Run `pkgdown::check_pkgdown()` after every edit; do not rely on text-editor YAML linting alone |
| Favicon generation fails (no `man/figures/logo.png`) | **Low** | Out of scope | Defer logo and `build_favicons()` to post-launch; do not block site launch on branding |

---

## 5. Explicit Defer / Out-of-Scope List

The following are **explicitly out of scope for v1.2**. Any of these appearing in requirements is scope creep.

| Item | Reason | If Needed |
|---|---|---|
| **New vignettes or articles** | Writing new content expands scope beyond docs polish; risks delaying site launch | Polish the three existing vignettes; a format comparison table can be added to an existing vignette as a minor patch |
| **Package logo / hex sticker** | Requires design work; `build_favicons()` depends on it but favicon absence doesn't block site launch | Create logo manually post-launch; `pkgdown/extra.css` + favicon generation is a standalone follow-up PR |
| **`pkgdown/extra.css` accent color branding** | Nice-to-have but not critical for first public URL; Bootstrap 5 defaults are clean | Add in a follow-up PR after site is live; 5–10 lines of CSS |
| **Format comparison table (working paper vs article vs policy brief)** | Useful but can land inside an existing vignette as a patch, not a launch gate | Candidate for a targeted vignette edit after v1.2 ships |
| **Multi-version docs (`devel` + release site)** | Premature for a pre-CRAN package; adds deploy complexity | Set `development: mode: auto` when ready for CRAN submission workflow |
| **Algolia DocSearch or custom search** | Built-in pkgdown Bootstrap 5 search is sufficient for this package size | Standard search is enabled by default; accept it |
| **Netlify / Vercel hosting** | Adds account dependency, token management, and zero advantages over GitHub Pages for an R package site | GitHub Pages is the canonical, free, zero-dependency choice |
| **`tidytemplate` or custom Bootstrap theme** | Requires extra dependency; marginal visual gain over Bootstrap 5 defaults | Use Bootstrap 5 defaults + optional `extra.css` |
| **Rendered PDF screenshots or embedded output images** | Requires Quarto + Typst in CI; brittle image artifacts; significant CI complexity | Describe PDF output in prose; show YAML snippets instead |
| **Quarto `.qmd` vignettes** | pkgdown `.qmd` support requires pkgdown ≥ 2.0.9 + Quarto in CI runner; existing `.Rmd` vignettes are fully supported and need no migration | Keep vignettes as `.Rmd`; convert to `.qmd` only if a specific interactive feature requires it |
| **Changelog entries per commit** | `NEWS.md` should summarize user-visible changes per milestone, not per commit | One entry per shipped milestone (`v1.0`, `v1.1`, `v1.2`) is the correct grain |
| **Full `pkgdown::build_site()` as routine dev workflow** | Building the full site locally is slow | Use `pkgdown::build_reference()` or `pkgdown::build_article("getting-started")` for iterative local preview |

---

## Confidence Assessment

| Area | Confidence | Basis |
|------|------------|-------|
| Stack (pkgdown + r-lib/actions + GitHub Pages) | **HIGH** | Unambiguous standard across all r-lib/tidyverse packages; verified against r-lib/actions canonical workflow and pkgdown 2.x docs |
| Features (table stakes and scope boundaries) | **HIGH** | Verified against ggplot2, usethis, renv `_pkgdown.yml` configs as gold-standard references; internal repo survey of all 20 `.Rd` files and 3 vignettes |
| Architecture (phase ordering and component boundaries) | **HIGH** | Derived directly from pkgdown's own content consumption model; constraints are mechanical, not opinion-based |
| Pitfalls (risks and prevention strategies) | **HIGH** | Repo-specific risks (gitignored `.Rd` files, missing `NEWS.md`, single-URL DESCRIPTION) verified against direct inspection of current repo state; community-observed patterns (GHA permissions) have strong corroboration |

**Overall confidence: HIGH.** Research is grounded in direct repo inspection + official pkgdown/r-lib docs + gold-standard config references. No significant unknowns remain. The roadmap can proceed to requirements without a research-phase call on any phase.

### Gaps to Address

- **Version number strategy:** DESCRIPTION currently reads `0.0.0.9000`. Decide before site launch whether to (a) bump to `1.2.0`, (b) bump to `1.2.0.9000` during development and `1.2.0` at release, or (c) leave as-is and suppress the dev badge via `_pkgdown.yml`. This is a product decision, not a technical one.
- **Logo / branding deferred:** The site will launch without a logo or custom CSS. This is intentional scope containment, not an oversight. A follow-up issue should be created for logo creation + `pkgdown::build_favicons()`.

---

## Sources

### Primary (HIGH confidence — verified at research time)
- pkgdown documentation and source: Context7 `/r-lib/pkgdown` — https://pkgdown.r-lib.org/
- r-lib/actions canonical pkgdown workflow: https://github.com/r-lib/actions/tree/v2/examples
- usethis `use_pkgdown_github_pages()`: https://usethis.r-lib.org/reference/use_pkgdown.html
- ggplot2 `_pkgdown.yml` (gold standard): https://github.com/tidyverse/ggplot2/blob/main/_pkgdown.yml
- usethis `_pkgdown.yml` (gold standard): https://github.com/r-lib/usethis/blob/main/_pkgdown.yml
- renv `_pkgdown.yml` (gold standard): https://github.com/rstudio/renv/blob/main/_pkgdown.yml
- Direct repo inspection: `man/` (21 `.Rd` files), `vignettes/` (3 `.Rmd` files), `DESCRIPTION`, `README.md`, `.gitignore`, `.Rbuildignore`

### Secondary (MEDIUM confidence)
- Community-observed patterns: `contents: write` GHA permissions requirement, two-URL DESCRIPTION convention

---
*Research synthesized: 2026-06-01*
*Milestone: v1.2 pkgdown site + onboarding docs*
*Ready for requirements and roadmap: yes*
