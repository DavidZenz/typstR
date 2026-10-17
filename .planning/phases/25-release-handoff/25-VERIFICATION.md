---
phase: 25-release-handoff
status: human_needed
verified: 2026-10-17
requirements_completed: []
---

# Release verification ledger

Package version: **0.1.0**. Planning milestone: **v1.5 First Release Reliability**.
Branch: codex/first-release-reliability. No CRAN submission is authorized or recorded.

## Current local evidence

| Gate | Command/evidence | Result |
|---|---|---|
| Full tests | `Rscript --vanilla -e 'roxygen2::roxygenise(); testthat::test_local()'` | Pass; nine timing assertions explicitly opt-in; real Quarto integration ran |
| Checks without Quarto | `QUARTO_PATH=/tmp/typstR-no-quarto Rscript --vanilla -e 'stopifnot(!quarto::quarto_available()); testthat::test_local()'` | Pass; 15 expected skips (nine timing, six real-tool checks) |
| Required prerequisites | Same unavailable Quarto with tools/render-assurance.R | Exit 1: Required Quarto CLI is unavailable; no skipped-success result |
| Documentation | pkgdown::check_pkgdown + build_site, Pandoc 3.6.4 | Pass without warnings |
| Source build | `R CMD build .` | Pass; vignettes built |
| Source tarball check | `R CMD check --as-cran --output=artifacts/release artifacts/release/typstR_0.1.0.tar.gz` | 0 errors, 0 warnings, 2 notes |
| Clean installed package | `R CMD INSTALL --library=/tmp/typstR-release-library artifacts/release/typstR_0.1.0.tar.gz` | Pass |
| Clean-session public-helper PDFs | `R_LIBS_USER=/tmp/typstR-release-library bash tools/run-render-assurance.sh artifacts/release-render` | Six required renders, zero skips/warnings; defaults + representative working paper/article/brief; spaces, outside-project and nested article contexts |
| PDF contents | Required runner extracts text and checks titles, author affiliation markers, resolved citation, table estimate, equation section, footer and disclaimer | Pass |
| Visual review | All representative pages reviewed; final PNGs identical to reviewed attempt-5 pages | No clipping/overlap; affiliation numbering, logo, accent headings, table, math and disclaimer readable |
| Benchmark | tools/benchmark.R + same-host historical scaffold comparison | Measured; stored scaffold baseline discrepancy investigated; no speed claims; see ../23-render-and-performance-assurance/PERFORMANCE.md |

## Tarball provenance

`artifacts/release/typstR_0.1.0.tar.gz`

SHA-256: `8e750a36d763f512ec8c589bf6d876100f033ab3355a758f0e574521803113a1`

Byte comparison matched 94 current source files in R, inst, man, tests, vignettes,
README, NEWS and NAMESPACE. No differences. Development tools, artifacts and
planning files are excluded from the package archive. DESCRIPTION remains 0.1.0.
See artifacts/release/tarball-source-comparison.json. Later handoff/planning-only
commits do not alter that package source.

## Check notes

1. New submission: expected incoming-feasibility note for an unlisted package.
2. HTML Tidy: local system Tidy is too old, so R skipped HTML manual validation.
   Rd checks, PDF manual generation and vignette rebuilds passed. Do not claim
   completed Tidy validation. A current runner may validate it independently.

## Remaining gates

- Hosted five-target checks and required PDF workflow for this review branch need
  current run links/results before final handoff is accepted.
- Current live website deployment from historical phase 13 remains explicitly
  unverified; verify when publishing release documentation.
- Maintainer final review and explicit authorization precede submission; reviewer
  responses, acceptance and release publication remain checklist steps, not claims.

Complete raw logs are retained under artifacts/release; six PDFs, text, toolchain,
page PNGs and runner logs under artifacts/release-render (local ignored artifacts).
