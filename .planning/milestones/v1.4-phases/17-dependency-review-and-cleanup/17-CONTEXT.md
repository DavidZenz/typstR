# Phase 17 Context: Dependency Review and Cleanup

## Goal
Minimize the package dependency footprint and ensure all declared dependencies in `DESCRIPTION` are justified, correctly scoped (Imports vs Suggests), and actively utilized in the package codebase to reduce the CRAN installation burden.

## Requirements
- CRAN-02: Dependency footprint is minimized (Review Imports/Suggests).

## Success Criteria
1. Unused or unnecessary packages are removed from `Imports` and `Suggests` in `DESCRIPTION`.
2. Remaining dependencies are justified and actively utilized.
3. Packages used in core logic (e.g., `yaml`) are correctly moved to `Imports` if they are currently in `Suggests`.
4. R CMD check runs cleanly without dependency warnings.

## Constraints
- Keep `Imports` as lean as possible.
- If a package is only used in tests or vignettes, it belongs in `Suggests`.
- If a package is called in the `R/` directory for core functionality, it belongs in `Imports` and must be imported in `NAMESPACE` (via `#' @import` or `#' @importFrom`).
