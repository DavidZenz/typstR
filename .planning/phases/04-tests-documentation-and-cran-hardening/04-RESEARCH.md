# Phase 04 Research: Tests, Documentation, and CRAN Hardening

**Date:** 2026-03-23
**Phase:** 04-tests-documentation-and-cran-hardening
**Goal:** Plan Phase 4 well enough to deliver CRAN-safe tests, documentation, examples, and final package hardening without adding new product scope.

## Research Question

What does this specific `typstR` codebase still need in order to:

1. pass `R CMD check --as-cran` cleanly on machines without Quarto,
2. meet all Phase 4 documentation and testing requirements,
3. preserve the working-paper-first onboarding decisions captured in `04-CONTEXT.md`, and
4. decompose cleanly into executable plans with minimal rework?

## Current Baseline

### What already exists

- Exported R API is already implemented across:
  - `R/create_working_paper.R`
  - `R/create_article.R`
  - `R/create_policy_brief.R`
  - `R/render.R`
  - `R/metadata_helpers.R`
  - `R/pub_helpers.R`
  - `R/notes_helpers.R`
- `NAMESPACE` already exports the current public surface.
- `DESCRIPTION` already includes `testthat`, `withr`, and `yaml` in `Suggests`, with `Config/testthat/edition: 3`.
- Local `testthat` baseline exists:
  - `tests/testthat/test-metadata-helpers.R`
  - `tests/testthat/test-pub-helpers.R`
  - `tests/testthat/test-notes-helpers.R`
  - `tests/testthat/test-yaml-integration.R`
- Quarto-dependent integration tests already use the right CRAN-safe pattern:
  - `skip_if_not(quarto::quarto_available())`
  - isolated tempdir execution via `withr::with_tempdir()`
- Local `R CMD check` evidence exists in `typstR.Rcheck/00check.log`, but that run used `--no-vignettes`, so vignette safety is still unproven.

### What is missing or incomplete

- No tracked `README.md` in the source tree.
- No tracked `vignettes/` directory in the source tree.
- No tracked `man/` source tree in the repo snapshot that was inspected here, even though generated `.Rd` artifacts exist in `typstR.Rcheck/00_pkg_src/`.
- Current tests cover helpers and some YAML/render smoke paths, but Phase 4 still needs explicit coverage for:
  - project scaffolding behavior (`TEST-03`)
  - validation/no-Quarto-safe behavior (`TEST-02`)
  - broader exported-function documentation and examples (`DOCS-05`)
  - article and policy-brief example/docs coverage
- README/vignette/example policy is now decided in context, but not yet reflected in files.

## Phase-Specific Constraints

### Locked by context and roadmap

- README install path is GitHub-only for now:
  - `remotes::install_github("DavidZenz/typstR")`
- README quick-start must lead with the working-paper path, not a three-format matrix.
- Vignettes should be concise and task-oriented.
- Example `.qmd` materials should be one polished starter per format, realistic but compact.
- Render-dependent tests and examples must remain safe on machines without Quarto.

### Existing technical constraints

- `quarto` is an `Imports` dependency and `SystemRequirements: quarto` is declared in `DESCRIPTION`, but the roadmap still requires check/test/doc behavior that is robust when Quarto is unavailable at runtime.
- `render_pub()` hard-errors when Quarto is unavailable, so any examples using it must be guarded.
- The package’s core user story remains:
  - scaffold project,
  - edit `.qmd`,
  - render PDF.
  Documentation should preserve this sequence.

## Main Risks and Planning Implications

### 1. README and vignette work can silently break CRAN

The largest Phase 4 risk is not writing the docs themselves, but writing examples or vignettes that execute render paths during `R CMD check` on systems without Quarto.

**Implication for planning:**
- README, roxygen examples, and vignette code examples should be handled together, not as unrelated tasks.
- Any render/scaffold examples must be intentionally guarded (`\\dontrun{}`, conditional checks, or vignette chunk guards), while pure-R helpers should remain runnable.

### 2. Test coverage is present but uneven

The current tests are a useful baseline, but they are not yet organized around the explicit Phase 4 requirements. In particular:

- metadata helper coverage exists,
- publication/note helper coverage exists,
- YAML integration coverage exists,
- project scaffolding coverage is missing or implicit,
- article/policy-brief render paths are not obviously covered in the checked-in tests reviewed here.

**Implication for planning:**
- A dedicated testing/hardening plan should extend existing files rather than rewrite them.
- Scaffolding tests and no-Quarto-safe tests should likely be grouped together because they share tempdir/file-system concerns.

### 3. Documentation artifacts are missing entirely

The absence of tracked `README.md` and `vignettes/` means the documentation work is greenfield at the file level but not at the content level, because requirements and tone decisions are already settled.

**Implication for planning:**
- Documentation should be split into at least:
  - README + onboarding examples
  - vignettes
  - roxygen/example completion
- This separation reduces merge risk and keeps each plan verifiable.

### 4. CRAN hardening is an integration task, not just a final command

A clean `R CMD check --as-cran` result depends on:

- docs being safe,
- examples being safe,
- tests being guarded,
- package metadata being complete,
- generated docs being up to date.

**Implication for planning:**
- The final plan should be an explicit hardening/integration pass, not an assumption that earlier plans will naturally converge.
- That plan should run the full documentation generation and final checks after the docs/tests are in place.

## Recommended Plan Decomposition

The cleanest decomposition for this repo is four execution plans:

### Plan A: Test suite expansion and CRAN-safe test infrastructure

Focus:
- extend existing `tests/testthat/` files,
- add missing scaffolding tests,
- ensure all Quarto-dependent tests are guarded,
- verify helper tests remain Quarto-free.

Why first:
- It locks in verification scaffolding before docs are added.
- It directly addresses `TEST-01` through `TEST-04`.

### Plan B: README and example-material onboarding

Focus:
- add `README.md`,
- write GitHub-only install instructions,
- build the working-paper-first quick-start,
- mention article/policy-brief later in the file,
- align starter examples with the compact-per-format decision.

Why second:
- README is a self-contained artifact with clear acceptance criteria.
- It anchors the package’s public-facing narrative before vignettes elaborate it.

### Plan C: Vignettes and package documentation completion

Focus:
- create `vignettes/getting-started.Rmd`,
- create `vignettes/working-papers.Rmd`,
- create `vignettes/customizing-branding.Rmd`,
- ensure each exported function has adequate roxygen docs and at least one example,
- make render-dependent examples guarded.

Why third:
- Vignettes depend on the agreed README story and example policy.
- This work will likely touch multiple `R/*.R` roxygen blocks plus new vignette files.

### Plan D: Final CRAN hardening and documentation generation

Focus:
- regenerate `man/` and `NAMESPACE` if needed,
- verify `.Rbuildignore` / vignette/package metadata alignment,
- run final test and check commands,
- fix residual notes/warnings/errors,
- confirm no-Quarto-safe behavior for docs/tests/examples.

Why last:
- This is the integration sweep that validates the combined result rather than one feature slice.

## File-Level Opportunities for Reuse

### Existing tests to extend

- `tests/testthat/test-metadata-helpers.R`
  - already close to `TEST-01`
  - likely needs edge-case additions, but should remain the main metadata test file
- `tests/testthat/test-pub-helpers.R`
  - should be extended to finish helper coverage, especially exported typed wrappers
- `tests/testthat/test-notes-helpers.R`
  - good template for output/assertion style
- `tests/testthat/test-yaml-integration.R`
  - should remain the home for guarded render smoke tests
  - likely needs article/policy-brief/scaffold coverage additions or a sibling file

### Existing code/docs to read before planning

- `R/create_working_paper.R`
- `R/create_article.R`
- `R/create_policy_brief.R`
- `R/render.R`
- `R/metadata_helpers.R`
- `R/pub_helpers.R`
- `R/notes_helpers.R`
- `DESCRIPTION`
- `NAMESPACE`
- `.planning/phases/04-tests-documentation-and-cran-hardening/04-CONTEXT.md`

## CRAN-Safe Documentation Strategy

### README

- Safe to include shell/R commands as fenced code blocks; not executed by check.
- Should lead with:
  - install from GitHub,
  - `create_working_paper()`,
  - `render_working_paper()`.
- Should mention article/policy-brief lower in the page instead of front-loading them.

### Roxygen examples

- Pure helper examples should be runnable where possible:
  - `author()`
  - `affiliation()`
  - `keywords()`
  - `jel_codes()`
  - `report_number()`
  - `funding()`
  - `data_availability()`
  - `code_availability()`
  - `manuscript_meta()`
- Render/scaffold examples should be guarded because they rely on Quarto and filesystem side effects.
- Notes helpers may keep `\\dontrun{}` or carefully written examples because they are designed for Quarto chunk contexts.

### Vignettes

- Should be readable without executing render calls.
- Best fit for this phase is chunk-level guarding and narrative screenshots/output expectations, not mandatory live rendering during build.
- The getting-started vignette must still narrate the full workflow from scaffold to render, per roadmap success criteria.

## Validation Architecture

Phase 4 has a strong automated validation surface and does not require human-only UI review.

Recommended validation contract:

- **Quick command:** `Rscript -e 'testthat::test_dir("tests/testthat", reporter = "summary")'`
- **Full command:** `R CMD check --as-cran typstR_*.tar.gz`
- **Feedback cadence:**
  - after each test/docs task: run focused `testthat` or doc-generation check
  - after each wave: run package-level tests
  - before phase verification: run full build/check path

Manual verification remains limited to:
- reading README quick-start for clarity,
- skimming vignettes for tone and flow.

## Planning Recommendations

1. Keep test expansion ahead of final hardening.
2. Treat README, vignettes, and roxygen as separate deliverables with separate acceptance criteria.
3. Reserve one final plan for generated docs + `R CMD check --as-cran` cleanup.
4. Make every plan grep-verifiable with concrete file/content expectations, because most work here is file-content heavy rather than algorithmic.

## Suggested Acceptance Targets for Plans

- `README.md` contains GitHub install instructions for `DavidZenz/typstR`
- `README.md` contains a quick-start section centered on `create_working_paper()`
- `vignettes/getting-started.Rmd` exists and documents scaffold -> render flow
- `vignettes/working-papers.Rmd` exists
- `vignettes/customizing-branding.Rmd` exists
- each exported function has at least one roxygen example
- scaffolding tests exist for working paper, article, and policy brief creation
- Quarto-dependent tests are guarded with `skip_if_not(quarto::quarto_available())`
- final `R CMD check --as-cran` path is documented and passes

## RESEARCH COMPLETE
