---
phase: 04
slug: tests-documentation-and-cran-hardening
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-23
---

# Phase 04 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | testthat (edition 3) |
| **Config file** | `DESCRIPTION` (`Config/testthat/edition: 3`) |
| **Quick run command** | `Rscript -e 'testthat::test_dir("tests/testthat", reporter = "summary")'` |
| **Full suite command** | `R CMD check --as-cran typstR_*.tar.gz` |
| **Estimated runtime** | ~60-180 seconds |

---

## Sampling Rate

- **After every task commit:** Run `Rscript -e 'testthat::test_dir("tests/testthat", reporter = "summary")'`
- **After every plan wave:** Run `Rscript -e 'testthat::test_dir("tests/testthat", reporter = "summary")'`
- **Before `$gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 180 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 04-01-01 | 01 | 2 | TEST-01, TEST-02 | unit | `Rscript -e 'testthat::test_file("tests/testthat/test-metadata-helpers.R"); testthat::test_file("tests/testthat/test-pub-helpers.R"); testthat::test_file("tests/testthat/test-notes-helpers.R"); testthat::test_file("tests/testthat/test-render-guards.R")'` | ✅ / ❌ W0 | ⬜ pending |
| 04-01-02 | 01 | 2 | TEST-03, TEST-04 | unit/integration | `Rscript -e 'testthat::test_file("tests/testthat/test-scaffolding.R"); testthat::test_file("tests/testthat/test-yaml-integration.R")'` | ✅ / ❌ W0 | ⬜ pending |
| 04-02-01 | 02 | 1 | DOCS-01 | content | `rg -n 'install_github\\("DavidZenz/typstR"\\)|^## Quick start$|create_working_paper\\("my-paper"\\)|render_working_paper\\("my-paper/template.qmd"\\)' README.md` | ❌ W0 | ⬜ pending |
| 04-02-02 | 02 | 1 | DOCS-06 | content | `rg -n 'format-variant: article|format-variant: brief|report-number|## Key Findings|## Introduction' inst/templates/workingpaper/template.qmd inst/templates/article/template.qmd inst/templates/policy-brief/template.qmd` | ✅ | ⬜ pending |
| 04-03-01 | 03 | 2 | DOCS-02, DOCS-03, DOCS-04 | vignette | `test -f vignettes/getting-started.Rmd && test -f vignettes/working-papers.Rmd && test -f vignettes/customizing-branding.Rmd` | ❌ W0 | ⬜ pending |
| 04-04-01 | 04 | 3 | DOCS-05 | source-docs | `rg -n '^#'\\'' @examples|create_working_paper <-|create_article <-|create_policy_brief <-|render_pub <-|render_working_paper <-|author <-|affiliation <-|manuscript_meta <-|keywords <-|jel_codes <-|report_number <-|funding <-|data_availability <-|code_availability <-|fig_note <-|tab_note <-|appendix_title <-' R/create_working_paper.R R/create_article.R R/create_policy_brief.R R/render.R R/metadata_helpers.R R/pub_helpers.R R/notes_helpers.R R/typstR-package.R` | ✅ | ⬜ pending |
| 04-05-01 | 05 | 4 | DOCS-05 | generated-docs | `Rscript -e 'roxygen2::roxygenise(); tools::checkRdContents("man")'` | ❌ W0 | ⬜ pending |
| 04-05-02 | 05 | 4 | DOCS-05 | build | `Rscript -e 'roxygen2::roxygenise(); tools::checkRdContents("man")' && R CMD build .` | ❌ W0 | ⬜ pending |
| 04-06-01 | 06 | 5 | TEST-01, TEST-02, TEST-03, TEST-04 | fast-gate | `Rscript -e 'testthat::test_dir("tests/testthat", reporter = "summary")' && Rscript -e 'tools::checkRdContents("man")'` | ✅ / ❌ W0 | ⬜ pending |
| 04-06-02 | 06 | 5 | DOCS-01, DOCS-02, DOCS-03, DOCS-04, DOCS-05, TEST-01, TEST-02, TEST-03, TEST-04 | full check | `R CMD check --as-cran typstR_*.tar.gz` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `tests/testthat/test-scaffolding.R` — explicit scaffolding tests for `create_working_paper()`, `create_article()`, `create_policy_brief()`
- [ ] `README.md` — working-paper-first onboarding document
- [ ] `vignettes/getting-started.Rmd` — concise full workflow guide
- [ ] `vignettes/working-papers.Rmd` — focused working-paper guide
- [ ] `vignettes/customizing-branding.Rmd` — focused branding guide
- [ ] `man/` — generated documentation after roxygen pass
- [ ] source package tarball for `R CMD check --as-cran`

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| README quick-start is easy to follow | DOCS-01 | Clarity and narrative flow are editorial, not purely mechanical | Read the first quick-start section top to bottom and confirm it leads with GitHub install -> `create_working_paper()` -> render |
| Vignette tone stays concise and task-oriented | DOCS-02, DOCS-03, DOCS-04 | Tone/verbosity is subjective | Skim each vignette and confirm it reads like a short workflow guide rather than a long conceptual tutorial |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 180s
- [ ] `04-VALIDATION.md` matches the current 6-plan / 10-task phase structure
- [ ] `nyquist_compliant: true` set in frontmatter once the contract is confirmed accurate

**Approval:** pending
