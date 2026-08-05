# Plan 17-01 Summary: Dependency Alignment

**Plan:** 17-01
**Status:** Complete
**Completed:** 2026-06-02

## Accomplishments
- **Dependency Re-scoping:** Moved `yaml` from `Suggests` to `Imports` in the `DESCRIPTION` file to accurately reflect its usage in core package logic (`R/validation_environment.R`).
- **Test Suite Hardening:** Diagnosed and fixed path-resolution failures in the test suite that surfaced during `R CMD check` isolation. Specifically, updated `.with_typstR_system_file` and source-resolution helpers to conditionally respect locked environments and correctly locate the `00_pkg_src/typstR` path during package checks.
- **R CMD Check Validation:** Successfully ran `devtools::check(document = FALSE, error_on = 'warning')` resulting in 0 errors, 0 warnings, and 0 notes, verifying the dependency cleanliness and test robustness.

## Requirements Covered
- CRAN-02: Dependency footprint is minimized (Review Imports/Suggests).
