---
phase: 25-release-handoff
status: passed
verified: "2026-10-17T20:19:12.518111+00:00"
requirements_completed: [CRAN-05]
verification_method: inline source-test-artifact-and-hosted-CI audit
covered_files: [".Rbuildignore", ".github/workflows/R-CMD-check.yaml", ".github/workflows/benchmark.yaml", ".github/workflows/pkgdown.yaml", ".github/workflows/render-assurance.yaml", ".planning/phases/25-release-handoff/25-01-PLAN.md", ".planning/phases/25-release-handoff/25-01-SUMMARY.md", "DESCRIPTION", "NAMESPACE", "NEWS.md", "R/create_article.R", "R/create_policy_brief.R", "R/create_working_paper.R", "R/diagnostics.R", "R/metadata_helpers.R", "R/notes_helpers.R", "R/pub_helpers.R", "R/render.R", "R/scaffold_helpers.R", "R/typstR-package.R", "R/utils.R", "R/validation_environment.R", "R/validation_manuscript.R", "README.md", "RELEASE_CHECKLIST.md", "VALID_STRATEGY.md", "cran-comments.md", "inst/.DS_Store", "inst/quarto/extensions/typstR/_extension.yml", "inst/quarto/extensions/typstR/formats/article.typ", "inst/quarto/extensions/typstR/formats/brief.typ", "inst/quarto/extensions/typstR/formats/workingpaper.typ", "inst/quarto/extensions/typstR/templates/CLAUDE.md", "inst/quarto/extensions/typstR/templates/abstract.typ", "inst/quarto/extensions/typstR/templates/appendix.typ", "inst/quarto/extensions/typstR/templates/authors.typ", "inst/quarto/extensions/typstR/templates/base.typ", "inst/quarto/extensions/typstR/templates/branding.typ", "inst/quarto/extensions/typstR/templates/disclaimer.typ", "inst/quarto/extensions/typstR/templates/titleblock.typ", "inst/quarto/extensions/typstR/typst-show.typ", "inst/quarto/extensions/typstR/typst-template.typ", "inst/templates/article/_quarto.yml", "inst/templates/article/references.bib", "inst/templates/article/template.qmd", "inst/templates/policy-brief/_quarto.yml", "inst/templates/policy-brief/references.bib", "inst/templates/policy-brief/template.qmd", "inst/templates/workingpaper/_quarto.yml", "inst/templates/workingpaper/references.bib", "inst/templates/workingpaper/template.qmd", "man/affiliation.Rd", "man/appendix_title.Rd", "man/author.Rd", "man/code_availability.Rd", "man/create_article.Rd", "man/create_policy_brief.Rd", "man/create_working_paper.Rd", "man/data_availability.Rd", "man/fig_note.Rd", "man/figures/logo.svg", "man/funding.Rd", "man/jel_codes.Rd", "man/keywords.Rd", "man/manuscript_meta.Rd", "man/print.typstR_affiliation.Rd", "man/print.typstR_author.Rd", "man/print.typstR_meta.Rd", "man/render_pub.Rd", "man/render_working_paper.Rd", "man/report_number.Rd", "man/tab_note.Rd", "man/typstR-package.Rd", "man/validate_manuscript.Rd", "man/validate_render_environment.Rd", "tests/testthat.R", "tests/testthat/derive-v1-baseline.R", "tests/testthat/helper-diagnostics.R", "tests/testthat/helper-performance.R", "tests/testthat/helper-validation.R", "tests/testthat/perf-baseline.yml", "tests/testthat/perf-scenario-map.yml", "tests/testthat/perf-v1-baseline.yml", "tests/testthat/test-diagnostics-codebook.R", "tests/testthat/test-diagnostics-contract.R", "tests/testthat/test-diagnostics-ordering.R", "tests/testthat/test-documentation-reference.R", "tests/testthat/test-input-diagnostics.R", "tests/testthat/test-manuscript-validation.R", "tests/testthat/test-metadata-helpers.R", "tests/testthat/test-notes-helpers.R", "tests/testthat/test-performance-baseline-contract.R", "tests/testthat/test-performance-gain.R", "tests/testthat/test-performance-micro.R", "tests/testthat/test-performance-regression.R", "tests/testthat/test-pub-helpers.R", "tests/testthat/test-render-context.R", "tests/testthat/test-render-guards.R", "tests/testthat/test-scaffolding.R", "tests/testthat/test-validation-environment.R", "tests/testthat/test-yaml-integration.R", "tools/benchmark.R", "tools/render-assurance.R", "tools/run-render-assurance.sh", "vignettes/advanced-examples.Rmd", "vignettes/customizing-branding.Rmd", "vignettes/format-comparison.Rmd", "vignettes/getting-started.Rmd", "vignettes/working-papers.Rmd"]
covered_digest: v2:sha256:5d146ecc0e23e0b57da0f32e7908dc2b9e841df4870d749746f2c7914b1ddcd6
---

# Release verification ledger

Package version: **0.1.0**. Planning milestone: **v1.5 First Release Reliability**.
Branch: codex/first-release-reliability. No CRAN submission is authorized or recorded.

## Current local evidence

| Gate | Command/evidence | Result |
|---|---|---|
| Full tests | `Rscript --vanilla -e 'roxygen2::roxygenise(); testthat::test_local()'` | 462 passes, 0 failures, 0 warnings; nine timing assertions explicitly opt-in; real Quarto integration ran |
| Checks without Quarto | `QUARTO_PATH=/tmp/typstR-no-quarto Rscript --vanilla -e 'stopifnot(!quarto::quarto_available()); testthat::test_local()'` | Pass; 15 expected skips (nine timing, six real-tool checks) |
| Required prerequisites | Same unavailable Quarto with tools/render-assurance.R | Exit 1: Required Quarto CLI is unavailable; no skipped-success result |
| Documentation | pkgdown::check_pkgdown + build_site, Pandoc 3.6.4 | Pass without warnings |
| Source build | `R CMD build .` | Pass; vignettes built |
| Source tarball check | `R CMD check --as-cran --output=artifacts/release artifacts/release-final/typstR_0.1.0.tar.gz` | 0 errors, 0 warnings, 2 notes |
| Clean installed package | `R CMD INSTALL --library=/tmp/typstR-release-library artifacts/release-final/typstR_0.1.0.tar.gz` | Pass |
| Clean-session public-helper PDFs | `R_LIBS_USER=/tmp/typstR-release-library bash tools/run-render-assurance.sh artifacts/final-render` | Six required renders, zero skips/warnings; defaults + representative working paper/article/brief; spaces, outside-project and nested article contexts |
| PDF contents | Required runner extracts text and checks titles, author affiliation markers, resolved citation, table estimate, equation section, footer and disclaimer | Pass |
| Visual review | All representative pages reviewed; final PNGs identical to reviewed attempt-5 and release-render pages | No clipping/overlap; affiliation numbering, logo, accent headings, table, math and disclaimer readable |
| Benchmark | tools/benchmark.R + same-host historical scaffold comparison | Measured; stored scaffold baseline discrepancy investigated; no speed claims; see ../23-render-and-performance-assurance/PERFORMANCE.md |

## Tarball provenance

`artifacts/release-final/typstR_0.1.0.tar.gz`

SHA-256: `b778c267725d626e2668e516fec63bac5c852adbb8456d6c830ce61d903ba758`

Built from package-code commit ceac7a5 after the format-inheritance follow-up.
Byte comparison matched 94 current source files in R, inst, man, tests, vignettes,
README, NEWS and NAMESPACE. No differences. Development tools, artifacts and
planning files are excluded from the package archive. DESCRIPTION remains 0.1.0.
See artifacts/release-final/tarball-source-comparison.json. Later handoff/planning-only
commits do not alter that package source.

## Check notes

1. New submission: expected incoming-feasibility note for an unlisted package.
2. HTML Tidy: local system Tidy is too old, so R skipped HTML manual validation.
   Rd checks, PDF manual generation and vignette rebuilds passed. Do not claim
   completed Tidy validation. A current runner may validate it independently.

## Hosted evidence and remaining maintainer actions

- Hosted five-target matrix passed for ceac7a5: https://github.com/DavidZenz/typstR/actions/runs/39065294234
- Hosted required six-PDF assurance passed: https://github.com/DavidZenz/typstR/actions/runs/39065294207
- Hosted documentation build passed: https://github.com/DavidZenz/typstR/actions/runs/39065294285
- CI checkout uses the synthetic PR merge commit (recorded in toolchain.txt); run head SHA is ceac7a5. Hosted PDFs/logs/page images are retained as render-evidence and downloaded to artifacts/ci-render. Representative hosted pages were inspected without layout defects.
- Existing 18 public signatures and DESCRIPTION are unchanged; validate_manuscript is the sole added export. See api-compatibility.json.
- Current live website deployment from historical phase 13 remains explicitly
  unverified; verify when publishing release documentation.
- Maintainer final review and explicit authorization precede submission; reviewer
  responses, acceptance and release publication remain checklist steps, not claims.

Complete raw logs are retained under artifacts/release; six PDFs, text, toolchain,
page PNGs and runner logs under artifacts/final-render (local ignored artifacts).
