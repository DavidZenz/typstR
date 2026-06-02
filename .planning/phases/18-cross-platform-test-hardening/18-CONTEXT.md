# Phase 18 Context: Cross-Platform Test Hardening

## Goal
Ensure the test suite executes reliably on all target platforms (macOS, Windows, Linux) without false failures, and establish automated cross-platform CI checking.

## Requirements
- CRAN-04: Test coverage is sufficient for CRAN and runs robustly across platforms without Quarto/Typst failures.

## Success Criteria
1. Standard cross-platform `R-CMD-check` GitHub Actions workflow is present.
2. The CI workflow executes successfully on macOS, Windows, and Linux.
3. Tests skip appropriately or fail gracefully in CI environments where Quarto or Typst are missing, rather than crashing the build.

## Constraints
- Use standard `r-lib/actions` workflows.
- Do not forcibly install Quarto in the CI check environment; the package tests must be resilient enough to pass (by skipping render tests) when Quarto is absent, as this simulates a standard CRAN check machine.
