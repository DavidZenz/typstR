---
phase: 23-render-and-performance-assurance
status: passed
verified: "2026-10-17T20:40:10.105302+00:00"
requirements_completed: [RENDER-01, PERF-02]
verification_method: inline source-test-artifact audit
covered_files: [".github/workflows/R-CMD-check.yaml", ".github/workflows/benchmark.yaml", ".github/workflows/pkgdown.yaml", ".github/workflows/render-assurance.yaml", ".planning/phases/23-render-and-performance-assurance/23-01-PLAN.md", ".planning/phases/23-render-and-performance-assurance/23-01-SUMMARY.md", "R/create_article.R", "R/create_policy_brief.R", "R/create_working_paper.R", "R/diagnostics.R", "R/metadata_helpers.R", "R/notes_helpers.R", "R/pub_helpers.R", "R/render.R", "R/scaffold_helpers.R", "R/typstR-package.R", "R/utils.R", "R/validation_environment.R", "R/validation_manuscript.R", "inst/.DS_Store", "inst/quarto/extensions/typstR/_extension.yml", "inst/quarto/extensions/typstR/formats/article.typ", "inst/quarto/extensions/typstR/formats/brief.typ", "inst/quarto/extensions/typstR/formats/workingpaper.typ", "inst/quarto/extensions/typstR/templates/CLAUDE.md", "inst/quarto/extensions/typstR/templates/abstract.typ", "inst/quarto/extensions/typstR/templates/appendix.typ", "inst/quarto/extensions/typstR/templates/authors.typ", "inst/quarto/extensions/typstR/templates/base.typ", "inst/quarto/extensions/typstR/templates/branding.typ", "inst/quarto/extensions/typstR/templates/disclaimer.typ", "inst/quarto/extensions/typstR/templates/titleblock.typ", "inst/quarto/extensions/typstR/typst-show.typ", "inst/quarto/extensions/typstR/typst-template.typ", "inst/templates/article/_quarto.yml", "inst/templates/article/references.bib", "inst/templates/article/template.qmd", "inst/templates/policy-brief/_quarto.yml", "inst/templates/policy-brief/references.bib", "inst/templates/policy-brief/template.qmd", "inst/templates/workingpaper/_quarto.yml", "inst/templates/workingpaper/references.bib", "inst/templates/workingpaper/template.qmd", "tests/testthat/helper-performance.R", "tests/testthat/perf-baseline.yml", "tests/testthat/perf-scenario-map.yml", "tests/testthat/perf-v1-baseline.yml", "tests/testthat/test-performance-baseline-contract.R", "tests/testthat/test-performance-gain.R", "tests/testthat/test-performance-micro.R", "tests/testthat/test-performance-regression.R", "tools/benchmark.R", "tools/render-assurance.R", "tools/run-render-assurance.sh"]
covered_digest: v2:sha256:97bc42a5f6f2f7585904c1b8e23635a0ee5533926425f899547ca3b8fa1e7495
---

# Render/performance assurance

Required PDF runner passed all six fresh installed-tarball renders with zero
skips/warnings. It fails when Quarto is absent (verified exit 1), extracts meaningful
PDF text, records toolchain and rasters all pages. Final representative pages match
visually reviewed output. The nested article exercises inherited logo and
bibliography resources from outside the project; all scaffold paths contain spaces.

Pinned required-render workflow added alongside unchanged five-target package
check matrix; documentation Pandoc is separately pinned. Hosted execution passed for package-code commit 623a8fe:
https://github.com/DavidZenz/typstR/actions/runs/39067210872
The artifact contains six PDFs, logs, toolchain, extracted text and page images.

Manual benchmark workflow and reusable workload runner are present, syntax-checked
and locally executed. Existing contracts and baselines are preserved. Ordinary
timing assertions are opt-in. PERF-02 is satisfied; no speed claims are made.
See PERFORMANCE.md for measured results and regression investigation.
