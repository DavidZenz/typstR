# Domain Pitfalls: pkgdown Site + Onboarding Docs for typstR

**Domain:** R package documentation site (pkgdown) + onboarding doc polish
**Package:** typstR v1.2
**Researched:** 2026-06-01
**Scope:** pkgdown integration, GitHub Pages deployment, vignette/README coherence, and docs-surface polish for an existing R + Quarto + Typst package.

---

## Critical Pitfalls

Mistakes that cause site build failures, broken deployments, or force rework.

---

### Pitfall C1: `man/*.Rd` Files Excluded from Git

**What goes wrong:** `.gitignore` currently excludes `man/*.Rd`. pkgdown builds
all Reference pages from `.Rd` files. If CI/CD clones the repo without running
`devtools::document()` first, the GitHub Actions workflow fails immediately with
"no such file" errors for every reference page — not a warning, a hard stop.

**Why it matters here:** This repo has `.gitignore: man/*.Rd`. The `.Rd` files
exist locally but are not committed. A fresh `git clone` + `pkgdown::build_site()`
produces an empty or broken Reference section.

**Consequences:** Silent partial site (no Reference pages), or full build failure
in CI with confusing error output.

**Prevention:**
- **Option A (recommended):** Remove `man/*.Rd` from `.gitignore`. Committing
  generated `.Rd` files is the standard convention for CRAN packages and every
  other pkgdown-deploying package does this.
- **Option B:** Add `devtools::document()` as the first step in the GitHub
  Actions workflow, before `pkgdown::build_site()`. But use Option A too —
  Option B alone means `pkgdown::build_site()` fails in local dev for anyone
  who just cloned without running `devtools::document()` first.

**Detection:** Run `pkgdown::build_reference()` in a directory freshly cloned
from GitHub (without running `devtools::document()`). Missing pages = this issue.

**Owning phase:** Must be resolved in the earliest phase that touches pkgdown
setup, before any CI/CD workflow is written.

---

### Pitfall C2: No `NEWS.md` → Broken Changelog Tab

**What goes wrong:** pkgdown auto-generates a Changelog page from `NEWS.md`.
typstR currently has no `NEWS.md`. The default pkgdown navbar includes a
"Changelog" link that resolves to `news/index.html`. Without `NEWS.md`, that
page either throws a build warning or renders as an empty stub — leaving a dead
link in the navigation bar on every page of the site.

**Why it matters here:** The project has shipped v1.0 and v1.1 with substantive
changes documented only in planning artifacts (`.planning/milestones/`). There
is changelog content to surface — it just isn't in `NEWS.md` yet.

**Consequences:** Dead nav link; site looks unfinished; the milestone history
that was carefully tracked internally is invisible to users.

**Prevention:**
- Create `NEWS.md` before or in the same phase as pkgdown setup.
- Backfill v1.0 and v1.1 entries from the milestone roadmap archives in
  `.planning/milestones/`.
- Follow the format pkgdown expects (heading = version):
  ```markdown
  # typstR 1.1.0
  ## New features
  - Structured diagnostics contract with stable codes/severity/location
  - Pre-render environment validation
  # typstR 1.0.0
  - Initial release.
  ```
- `NEWS.md` is a standard R package file — do **not** add it to `.Rbuildignore`.

**Detection:** Run `pkgdown::build_news()` — it errors or produces nothing if
`NEWS.md` is absent.

**Owning phase:** Same phase as `_pkgdown.yml` creation — never merge the
pkgdown scaffold without a `NEWS.md`.

---

### Pitfall C3: `pkgdown/` and `_pkgdown.yml` Not in `.Rbuildignore`

**What goes wrong:** pkgdown creates a `pkgdown/` directory (for logos, favicons,
extra CSS) and a `_pkgdown.yml` config file at the repo root. Neither is a
standard R package file. If they are not in `.Rbuildignore`:
- They inflate the installed package tarball.
- `R CMD check` emits a NOTE about non-standard top-level files.
- CRAN submission is blocked if the tarball contains `pkgdown/` artifacts.

**Why it matters here:** typstR targets CRAN submission and already maintains a
careful `.Rbuildignore`. `pkgdown/` and `_pkgdown.yml` need the same treatment
as the existing planning files.

**Consequences:** `R CMD check` NOTE; CRAN rejection; tarball bloated by favicon
PNGs and HTML output if `docs/` strategy is used.

**Prevention:** Add these lines to `.Rbuildignore` in the same commit that
introduces the pkgdown files:
```
^_pkgdown\.yml$
^pkgdown$
^docs$
```
The `^docs$` entry covers the `docs/` folder deployment strategy. Include it
even if using `gh-pages` branch — it is harmless and prevents accidents.

`usethis::use_pkgdown()` adds these automatically — prefer it over manual file creation.

**Detection:** Run `devtools::build()` and inspect the tarball:
```bash
tar -tzf typstR_*.tar.gz | grep -E "pkgdown|_pkgdown"
```
Any pkgdown artifact in the tarball means `.Rbuildignore` is incomplete.

**Owning phase:** pkgdown scaffold phase — same commit as `_pkgdown.yml`.

---

### Pitfall C4: GitHub Actions Lacks `contents: write` Permission → Silent Deploy Failure

**What goes wrong:** The standard pkgdown GitHub Actions workflow deploys to a
`gh-pages` branch. The default `GITHUB_TOKEN` permissions in GitHub Actions are
read-only for repository contents unless explicitly granted. Without
`contents: write`, the `git push` to `gh-pages` silently fails or throws a 403
— but the R build steps succeed, making the failure hard to diagnose (the error
appears only in the git push log, not in the pkgdown output).

**Why it matters here:** typstR has no `.github/` directory yet. The workflow
must be created from scratch. Getting permissions wrong is the #1 cause of
"my pkgdown workflow runs but the site never updates" in the R community.

**Consequences:** Site never deploys; stale or 404 site with no error surfaced
in the R build log.

**Prevention:**
- Use `usethis::use_pkgdown_github_pages()` — it generates the correct workflow
  with `permissions: contents: write` already set.
- After running that command, **manually enable GitHub Pages** in the repo
  Settings → Pages → Source: "Deploy from branch: gh-pages, / (root)".
- Do not replace the generated push mechanism with a custom `git push` unless
  you understand token scoping.

**Detection:** If the Actions run shows all R steps green but the site URL
returns 404 or shows old content, look for "Permission denied" or
"remote: Permission to ... denied" in the workflow log's push step.

**Owning phase:** GitHub Actions setup phase. Do not merge the workflow PR until
GitHub Pages is enabled in repo Settings and a test deploy succeeds.

---

## Moderate Pitfalls

Cause broken features, confusing UX, or significant wasted work — but not hard
build failures.

---

### Pitfall M1: `getting-started.Rmd` Does Not Auto-Wire as "Get Started" Navbar Link

**What goes wrong:** pkgdown promotes a vignette to a top-level "Get started"
navbar link only when its file is named `<package-name>.Rmd` (i.e., `typstR.Rmd`).
The current vignette is named `getting-started.Rmd`, so pkgdown treats it as a
regular article — buried under an "Articles" dropdown.

**Why it matters here:** The v1.2 goal is "guide users from install to scaffold
to render." The getting-started vignette is the most important page on the site.
Burying it under Articles directly contradicts the onboarding goal.

**Consequences:** New users land on the homepage (README) and have to discover
the onboarding content rather than being led to it.

**Prevention — Option A (recommended):** Wire the navbar manually in
`_pkgdown.yml` (avoids renaming, which would break existing
`vignette("getting-started", package = "typstR")` calls):
```yaml
navbar:
  structure:
    left: [intro, articles, reference, news]
  components:
    intro:
      text: Get started
      href: articles/getting-started.html
```

**Prevention — Option B:** Rename `getting-started.Rmd` to `typstR.Rmd` and
update all cross-references in README and the other two vignettes. Cleaner
long-term but requires a coordinated update sweep.

**Detection:** Build the site locally and look at the navbar. If "Get started"
is not a prominent top-level link, the wiring is missing.

**Owning phase:** `_pkgdown.yml` configuration phase.

---

### Pitfall M2: DESCRIPTION `URL` Field Has Only GitHub URL — Canonical Links Break

**What goes wrong:** pkgdown reads `URL:` from DESCRIPTION to set canonical
link tags on every page. If DESCRIPTION lists only the GitHub URL, the canonical
URL on every pkgdown page points to GitHub instead of the docs site. The
"View on GitHub" and "Browse source" links in the navbar also break or misbehave.

**Why it matters here:** Current DESCRIPTION has one URL:
`https://github.com/DavidZenz/typstR`. The docs site will be at a different URL
(`https://davidzenz.github.io/typstR/`).

**Consequences:** Wrong canonical links; SEO pointing at GitHub not the docs
site; pkgdown may warn about URL mismatch between DESCRIPTION and `_pkgdown.yml`.

**Prevention:** Use the two-URL convention — docs URL first, GitHub second:
```
URL: https://davidzenz.github.io/typstR/, https://github.com/DavidZenz/typstR
BugReports: https://github.com/DavidZenz/typstR/issues
```
pkgdown uses the first URL as canonical and auto-detects the second as the
GitHub repo for the navbar GitHub icon.

**Detection:** Run `pkgdown::check_pkgdown()` — it warns if the URL in
DESCRIPTION doesn't match `url:` in `_pkgdown.yml`.

**Owning phase:** pkgdown scaffold phase — same commit as `_pkgdown.yml`.

---

### Pitfall M3: Version `0.0.0.9000` Triggers "dev" Mode Badge on Every Page

**What goes wrong:** pkgdown auto-detects development mode from the DESCRIPTION
version. The `.9000` suffix marks a development version, so pkgdown displays a
colored "dev" badge in the navbar on every page. This is correct behavior
technically, but looks unpolished when the intent is to publish a user-facing
docs site for what is functionally a stable v1.1 package.

**Why it matters here:** typstR's internal milestone tracking describes it as
"v1.1 shipped," but DESCRIPTION still says `0.0.0.9000` — signaling "pre-release
toy" to every new visitor.

**Consequences:** Confusing version signaling; site looks unfinished; undermines
the user adoption goal of v1.2.

**Prevention:** Decide on version strategy before deploying:
- If publishing the docs site during active v1.2 development: explicitly pin
  `development: mode: release` in `_pkgdown.yml` to suppress the badge, OR
  bump DESCRIPTION to `1.2.0.9000` to signal ongoing work toward a real version.
- If publishing the site only when v1.2 is complete: ensure DESCRIPTION is
  `1.2.0` at site launch.

**Detection:** Build the site locally. A colored "dev" badge next to the package
name in the navbar means dev mode is active.

**Owning phase:** Final "publish-ready" phase after version is bumped to
reflect the milestone.

---

### Pitfall M4: Vignettes Missing from `_pkgdown.yml` Articles Index

**What goes wrong:** If `_pkgdown.yml` defines an `articles:` section that does
not list all three vignettes, pkgdown warns at build time:
"N vignettes missing from index."
Unlisted vignettes still render but are unreachable from the Articles nav —
users can only find them via direct URL or `vignette()` call.

**Why it matters here:** The v1.2 requirement is "clear install / getting-started
/ reference / articles navigation." Accidentally omitting a vignette from the
index defeats this.

**Consequences:** Inaccessible vignettes; pkgdown build warnings in CI logs;
navigation dead-ends.

**Prevention:** When writing `_pkgdown.yml`, list all three vignettes explicitly:
```yaml
articles:
  - title: "Using typstR"
    contents:
      - getting-started
      - working-papers
      - customizing-branding
```
After adding any future vignette, update `_pkgdown.yml` in the same PR.

**Detection:** pkgdown prints a clear warning during `build_articles()` if any
vignette is missing from the index. Also surfaced by `pkgdown::check_pkgdown()`.

**Owning phase:** `_pkgdown.yml` configuration phase.

---

### Pitfall M5: Reference Index Is a Flat 20-Function Alphabetical Dump

**What goes wrong:** Without a `reference:` section in `_pkgdown.yml`, pkgdown
lists all exported functions alphabetically in one block. typstR exports ~20
functions across five conceptual groups (scaffolding, metadata helpers,
publication helpers, render wrappers, diagnostics). An ungrouped flat list
makes the API surface look overwhelming and obscures the mental model new users
need to onboard.

**Why it matters here:** Onboarding clarity is the stated v1.2 goal. A
well-grouped reference is the difference between "I can see what this package
does" and "I'll just look at the README."

**Consequences:** Reduced discoverability; cognitive overload for new users;
no visual cue for which functions belong to the core workflow.

**Prevention:** Define reference groups in `_pkgdown.yml`:
```yaml
reference:
  - title: "Project scaffolding"
    contents: [create_working_paper, create_article, create_policy_brief]
  - title: "Metadata helpers"
    contents: [author, affiliation, manuscript_meta, funding,
               data_availability, code_availability]
  - title: "Publication helpers"
    contents: [keywords, jel_codes, report_number, fig_note, tab_note,
               appendix_title]
  - title: "Rendering"
    contents: [render_pub, render_working_paper]
  - title: "Diagnostics"
    contents: starts_with("check_"), validate_manuscript
```
Every exported function must appear in exactly one group, or pkgdown warns.

**Detection:** Build locally without a `reference:` section first, see the flat
list, then define groups before shipping.

**Owning phase:** `_pkgdown.yml` configuration phase.

---

### Pitfall M6: README Relative Links Break on pkgdown Homepage

**What goes wrong:** pkgdown uses `README.md` as the site homepage verbatim.
Relative links that work in GitHub's markdown renderer (e.g.,
`[vignette](vignettes/getting-started.Rmd)`) break on the pkgdown site because
the built site's URL structure differs — articles live at
`articles/getting-started.html`, not `vignettes/getting-started.Rmd`.

**Why it matters here:** The current README uses `vignette(...)` R calls rather
than URLs, which render safely as inline code. The risk is during v1.2 README
polish — any new cross-doc links added as relative markdown paths will break.

**Consequences:** Broken links on the homepage; 404s from in-page navigation;
link rot that's invisible on GitHub but visible on the deployed site.

**Prevention:**
- Use absolute URLs for any cross-doc link added during v1.2 README polish:
  `[Get started](https://davidzenz.github.io/typstR/articles/getting-started.html)`
- Or use pkgdown-aware relative paths (relative to site root):
  `[Get started](articles/getting-started.html)` — these work in pkgdown but
  not on the GitHub README. Pick one audience.
- Never link from README directly to `.Rmd` source files.
- After each README edit, run `pkgdown::build_home()` locally and click every
  link on the homepage.

**Owning phase:** README polish phase. Link audit required before merging.

---

### Pitfall M7: pkgdown Tries to Re-Execute Vignettes Without Package Installed

**What goes wrong:** pkgdown builds articles by executing the `.Rmd` in a fresh
R session against the *installed* package (not the source tree). The
`working-papers.Rmd` vignette calls `library(typstR)` and runs live metadata
helper calls. If pkgdown is run in CI before the install step, or locally by a
contributor who just cloned without installing, it fails with:
"there is no package called 'typstR'."

**Why it matters here:** The package has no `.github/` workflows yet. Getting the
install order right in the GitHub Actions workflow is not automatic — it requires
explicit sequencing.

**Consequences:** CI article build fails on every PR with a confusing error that
looks like a code problem but is actually a setup problem.

**Prevention:**
- In the GitHub Actions workflow, ensure the package is installed before
  `pkgdown::build_site()`. The workflow generated by
  `usethis::use_pkgdown_github_pages()` handles this via
  `r-lib/actions/setup-r-dependencies@v2`.
- For local development, document in README or CONTRIBUTING that
  `devtools::install(quick = TRUE)` must precede `pkgdown::build_site()`.

**Owning phase:** GitHub Actions setup phase.

---

## Minor Pitfalls

Cosmetic or easy to fix after launch — but worth front-loading awareness.

---

### Pitfall m1: Favicon Generation Requires a Package Logo

**What goes wrong:** `pkgdown::build_favicons()` calls `realfavicongenerator.net`
to generate favicon variants. It fails with a clear error if no logo PNG or SVG
is found at `man/figures/logo.png`. Without favicons, the browser shows a
generic default — not a blocker, but looks unfinished.

**Why it matters here:** typstR has no `man/figures/logo.png` yet.

**Prevention:** Either create a logo (`usethis::use_logo()`) or skip the favicon
step entirely and accept the browser default. Do not let favicon absence block
the site launch — add a logo as incremental polish after the site is live.

**Owning phase:** Post-launch polish, or the site-setup phase if a logo already
exists.

---

### Pitfall m2: Using `docs/` Folder Strategy Pollutes Main Branch Git History

**What goes wrong:** pkgdown can deploy to a `docs/` folder on the main branch
(simpler setup) or to a dedicated `gh-pages` branch (cleaner). Using `docs/`
means every site rebuild commits hundreds of generated HTML files to main,
polluting `git log` and making diffs unreadable.

**Prevention:** Use the `gh-pages` branch strategy via
`usethis::use_pkgdown_github_pages()` from the start. Changing strategies
later requires manual branch cleanup.

**Owning phase:** GitHub Actions setup phase — decide strategy before first deploy.

---

### Pitfall m3: `_pkgdown.yml` Schema Errors Are Silent Until Build Time

**What goes wrong:** `_pkgdown.yml` has strict schema requirements (e.g.,
`contents:` must be a list, not a string; `articles` must be a list of lists).
A typo produces a cryptic R error during build, not a clear YAML parse error.
The error message points to pkgdown internals, not to the offending YAML key.

**Prevention:** Run `pkgdown::check_pkgdown()` after every edit to
`_pkgdown.yml` before running the full build. This validates the schema cheaply.
Do not rely on text-editor YAML linting alone — pkgdown's schema is more
specific than basic YAML validation.

**Owning phase:** `_pkgdown.yml` configuration phase.

---

### Pitfall m4: Three-Surface Story Drift (README ↔ Vignettes ↔ Site)

**What goes wrong:** During v1.2, when README, three vignettes, and the
pkgdown homepage are all touched, it is easy to update one surface and forget
the others. If the README example uses `create_working_paper("my-paper")` and a
vignette example drifts to `create_working_paper("my_paper_2024")`, new users
get confused about what the canonical workflow looks like.

**Why it matters here:** The v1.2 requirement is explicitly "align README,
vignettes, and site structure so the docs surface tells one coherent story."
This pitfall is the failure mode for that requirement.

**Consequences:** Confused first-time users; "which example is correct?"
support questions; trust erosion in documentation quality.

**Prevention:**
- Define the canonical "golden path" once:
  `create_working_paper("my-paper")` → edit `template.qmd` → `render_working_paper(...)`
  and verify it appears identically across README Quick Start, `getting-started`
  vignette intro, and the site homepage.
- Any function rename or signature change must update all three surfaces in the
  same PR — no partial updates.
- Final milestone gate: read README → getting-started → reference in sequence
  as a first-time user before closing the milestone.

**Owning phase:** Final validation / milestone-close phase. Also: audit during
any phase that edits README or vignettes.

---

### Pitfall m5: Quarto Vignette Support Requires pkgdown ≥ 2.0.9

**What goes wrong:** pkgdown added `.qmd` article support in version 2.0.9
(requiring Quarto ≥ 1.5). typstR's current vignettes are `.Rmd`, so this is
not an immediate problem. The risk is if a `.qmd` article is added during v1.2
(e.g., an interactive Quarto+Typst demo) on an environment with an older pkgdown.

**Prevention:** Pin `pkgdown (>= 2.0.9)` in the GitHub Actions install step
if any `.qmd` vignettes are added. Check pkgdown version before authoring
`.qmd` articles.

**Owning phase:** Only relevant if `.qmd` vignettes are added — flag it in
that phase if it comes up.

---

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|---|---|---|
| pkgdown scaffold + `_pkgdown.yml` creation | C3 (`.Rbuildignore`), C2 (no `NEWS.md`), M2 (DESCRIPTION URL), M1 (Get Started wiring) | Use `usethis::use_pkgdown()`; create `NEWS.md` in same phase |
| GitHub Actions setup | C1 (`man/*.Rd` not in git), C4 (token permissions), M7 (package not installed before build) | Decide on `.Rd` git strategy first; use `usethis::use_pkgdown_github_pages()` |
| `_pkgdown.yml` configuration (navbar, reference, articles) | M4 (unlisted vignettes), M5 (flat reference), m3 (YAML schema errors) | Run `pkgdown::check_pkgdown()` after every edit; list all three vignettes explicitly |
| README + vignette polish | M6 (broken relative links on homepage), m4 (three-surface drift) | Test all homepage links after every README edit; do final cross-read before milestone close |
| Site launch / version bump | M3 (dev mode badge) | Bump DESCRIPTION version or set `development: mode: release` in `_pkgdown.yml` before publishing |
| Logo / branding | m1 (missing favicon) | Defer favicon to post-launch if no logo exists; don't block site launch on it |

---

## Sources

- pkgdown documentation (Context7 `/r-lib/pkgdown`, HIGH confidence): configuration schema,
  Quarto support, deployment mechanics, favicon generation, dev mode detection,
  URL handling, navbar structure
- Direct inspection of typstR repo state: `.gitignore`, `.Rbuildignore`, `DESCRIPTION`,
  `vignettes/`, `man/`, `inst/` (HIGH confidence — verified at research time)
- pkgdown `NEWS.md` changelog: Quarto article support added in 2.0.9,
  `deploy_to_branch()` permission improvements, dev mode override via env var
- Community-observed patterns (MEDIUM confidence): `contents: write` permissions
  requirement in GitHub Actions, two-URL DESCRIPTION convention for docs + GitHub

