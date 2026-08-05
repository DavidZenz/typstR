# Phase 18 Research: Cross-Platform Test Hardening

## Overview
Phase 18 establishes the formal CI pipeline for R CMD check and ensures the package tests are resilient enough to pass on machines without Quarto installed (which mirrors CRAN's incoming check environments).

## Key Research Findings

### 1. Current CI State
- The `.github/workflows/` directory currently only contains `pkgdown.yaml`.
- There is **no automated test or R CMD check workflow** configured.

### 2. Workflow Scaffolding
- `usethis::use_github_action_check_standard()` is the canonical way to generate the cross-platform (macOS, Windows, Ubuntu) `R-CMD-check.yaml` workflow.

### 3. Test Resilience (Quarto/Typst dependency)
- CRAN check machines do not guarantee the presence of Quarto or Typst.
- During Phase 17, we fixed path resolution issues in `testthat` helpers.
- The test suite already utilizes a `.skip_if_no_quarto()` guard in files like `test-yaml-integration.R`.
- We need to verify that *all* tests involving `render_pub` or `render_working_paper` properly use testthat's `skip_if_not()` or custom skips when the system dependency is absent.

### Implementation Strategy
1. Scaffold the standard R CMD check workflow using `usethis`.
2. Push the workflow to a new branch or directly to main to trigger the first multi-platform run.
3. If any tests fail on CI due to missing system requirements, patch the tests with `skip_if_not()` guards.
