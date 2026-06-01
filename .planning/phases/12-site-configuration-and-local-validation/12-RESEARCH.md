# Phase 12 Research: Site Configuration and Local Validation

## Overview
Phase 12 focuses on the configuration and local validation of the pkgdown site. Research from `research/SUMMARY.md` provides clear guidance on the configuration schema and build process.

## Key Research Findings
- **Scaffolding:** `usethis::use_pkgdown()` is the standard entry point. It handles `_pkgdown.yml` creation and `.Rbuildignore` additions.
- **Navbar:** The "Get Started" link must be manually wired to `articles/getting-started.html` as pkgdown doesn't auto-promote vignettes with non-package-named titles.
- **Reference Grouping:** A 5-group schema is identified to organize the 21 exported functions:
  1. Scaffolding
  2. Metadata helpers
  3. Publication helpers
  4. Rendering
  5. Validation and diagnostics
- **Development Mode:** `development: mode: release` is required to hide the "dev" badge while the version is `0.0.0.9000`.
- **DESCRIPTION:** The `URL` field must list the docs site first, then the GitHub repo. `Suggests` needs `pkgdown (>= 2.0.0)`.
- **Validation:** `pkgdown::check_pkgdown()` is a high-signal, low-cost gate.

## Pitfalls to Avoid
- **Unmatched Functions:** Every exported function MUST be in a group or pkgdown warns.
- **Unlisted Articles:** All vignettes must be explicitly listed in `_pkgdown.yml` for ordering and to avoid warnings.
- **Relative Links:** README links must be absolute or site-relative, never relative to `.Rmd` source.

## Technical Details
- Bootstrap 5 template is preferred.
- Local build target is `docs/` (gitignored).
- Built site is reviewed via `docs/index.html`.
