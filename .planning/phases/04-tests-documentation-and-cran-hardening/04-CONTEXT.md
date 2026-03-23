# Phase 4: Tests, Documentation, and CRAN Hardening - Context

**Gathered:** 2026-03-23
**Status:** Ready for planning

<domain>
## Phase Boundary

Complete the package's CRAN-facing finish work: expand the test suite, finalize user-facing documentation, add the required vignettes and example materials, and harden checks so `typstR` passes `R CMD check --as-cran` cleanly on machines without Quarto installed. This phase documents and validates the feature surface built in Phases 1-3; it does not add new publishing capabilities.

</domain>

<decisions>
## Implementation Decisions

### README and quick-start flow
- **D-01:** Installation in the README should be GitHub-only for now, using `remotes::install_github("DavidZenz/typstR")`.
- **D-02:** The README quick-start should center on the fastest single happy path: scaffold a working paper with `create_working_paper()`, edit the generated project, and render one PDF.
- **D-03:** Article and policy-brief support should be mentioned in the README, but not given equal weight in the opening quick-start section.

### Vignette depth and tone
- **D-04:** Vignettes should be task-oriented and concise rather than tutorial-heavy or theory-heavy.
- **D-05:** The getting-started vignette should walk through the full workflow from project creation to rendered PDF, but any render-dependent steps must be guarded or otherwise CRAN-safe.
- **D-06:** The vignette set should stay close to the roadmap requirements: getting started, working papers, and customizing branding.

### Example materials
- **D-07:** Provide one polished starter example per format (`workingpaper`, `article`, `policy-brief`), each realistic but compact and designed to render cleanly.
- **D-08:** Do not add separate showcase-heavy examples in this phase; keep example files focused on clarity, onboarding, and reliable rendering.

### Test and CRAN hardening posture
- **D-09:** Preserve the existing CRAN-safe testing rule: tests that require Quarto or rendering must be guarded with `skip_if_not(quarto::quarto_available())`.
- **D-10:** Phase 4 should raise confidence beyond the current partial baseline by covering metadata helpers, notes/publication helpers, project scaffolding, and no-Quarto-safe paths explicitly.
- **D-11:** Documentation, examples, and vignettes must be written so `R CMD check --as-cran` can pass on machines without Quarto installed.

### the agent's Discretion
- Exact README section ordering after the opening quick-start, as long as the first-run path stays working-paper-first
- Exact vignette prose, heading structure, and level of detail within the chosen concise/task-oriented tone
- Exact organization of tests across `tests/testthat/` files and helper utilities
- Exact roxygen example wording and whether examples are runnable inline or guarded, provided every exported function is documented appropriately
- Exact level of smoke-test coverage for article and policy-brief render paths, provided Quarto-dependent checks remain guarded and CRAN-safe

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project scope and requirements
- `.planning/PROJECT.md` — Core value, package constraints, CRAN target, and the user experience promise that docs should reinforce
- `.planning/REQUIREMENTS.md` — Phase 4 requirements: `DOCS-01` through `DOCS-06`, `TEST-01` through `TEST-04`
- `.planning/ROADMAP.md` — Phase 4 success criteria, especially the explicit requirement that checks pass cleanly without Quarto installed
- `.planning/STATE.md` — Current project state and carry-forward decisions from Phases 1-3

### Documentation planning
- `DOCUMENTATION_PLAN.md` — Planned documentation surfaces and intended vignette topics
- `BLUEPRINT.md` §6 — Intended user workflow that README/vignettes should reflect
- `BLUEPRINT.md` §7 — Exported function surface that roxygen docs and examples must cover
- `EXAMPLE_API.md` — Minimal target usage flow for scaffold + render onboarding
- `STRUCTURE.md` — Intended package structure, including `README.md`, `vignettes/`, and `tests/testthat/`

### Validation and CRAN behavior
- `VALID_STRATEGY.md` — Validation/hardening goals that inform Phase 4 test coverage and CRAN-safe behavior
- `DESCRIPTION` — Current package metadata, dependencies, and `Suggests`/testthat configuration
- `NAMESPACE` — Exported API surface that must be fully documented

### Existing implementation to extend
- `R/create_working_paper.R` — Primary onboarding path that README quick-start should feature
- `R/create_article.R` — Existing article scaffolding to document and test
- `R/create_policy_brief.R` — Existing policy-brief scaffolding to document and test
- `R/render.R` — Render wrappers and Quarto-availability behavior that docs/tests must treat carefully
- `R/metadata_helpers.R` — Exported metadata helper functions needing robust docs/examples/tests
- `R/pub_helpers.R` — Publication helper functions needing robust docs/examples/tests
- `R/notes_helpers.R` — Note/appendix helpers with current roxygen examples and test patterns
- `tests/testthat/test-metadata-helpers.R` — Existing metadata unit-test baseline
- `tests/testthat/test-pub-helpers.R` — Existing publication-helper unit-test baseline
- `tests/testthat/test-notes-helpers.R` — Existing note-helper unit-test baseline
- `tests/testthat/test-yaml-integration.R` — Existing guarded Quarto integration-test baseline

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `tests/testthat/test-metadata-helpers.R` — Solid baseline for pure-R helper testing; can be expanded rather than replaced
- `tests/testthat/test-pub-helpers.R` — Existing pattern for lightweight validation tests of typed helper wrappers
- `tests/testthat/test-notes-helpers.R` — Existing assertions around `cat()`-style helpers and invisible returns
- `tests/testthat/test-yaml-integration.R` — Existing guarded render smoke tests and tempdir helper pattern for Quarto-dependent checks
- `R/*.R` roxygen blocks — Most exported functions already have documentation stubs and some examples, so Phase 4 can refine/complete instead of starting from scratch
- `inst/templates/{workingpaper,article,policy-brief}/template.qmd` — Existing starter materials that can anchor the per-format example strategy

### Established Patterns
- Quarto-dependent behavior is already guarded in tests with `skip_if_not(quarto::quarto_available())`
- The package favors lightweight, tempdir-based tests over heavyweight fixtures or external services
- User-facing errors use `cli::cli_abort()` with clear messages; docs/examples should stay aligned with that style
- The package's central onboarding path is scaffold -> edit `.qmd` -> render PDF, and the docs should preserve that mental model
- Existing local `R CMD check` evidence is positive, but vignettes were skipped in that run, so Phase 4 must close that remaining gap

### Integration Points
- `DESCRIPTION` and `NAMESPACE` define the exact exported/documented surface for roxygen and examples
- `tests/testthat.R` is the entry point for the expanded test suite
- `README.md` does not yet exist in the tracked source tree and must be added as a first-class user entry point
- `vignettes/` does not yet exist in the tracked source tree and must be created in a CRAN-safe way
- Existing starter templates and render wrappers are the key bridge between docs, examples, and guarded integration tests

</code_context>

<specifics>
## Specific Ideas

- Installation docs should point to `remotes::install_github("DavidZenz/typstR")`
- The README should feel fast and confidence-building: one clear working-paper path first, not a feature catalog
- Vignettes should read like short task guides, not long conceptual essays
- Example `.qmd` files should be polished enough to feel real, but compact enough to stay readable and reliable

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 04-tests-documentation-and-cran-hardening*
*Context gathered: 2026-03-23*
