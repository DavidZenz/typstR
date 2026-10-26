# Phase 12 Context: Site Configuration and Local Validation

## Goal
Build and locally validate a fully configured pkgdown site for typstR with zero warnings and a polished navigation structure.

## Requirements
- SITE-02: Fully configured `_pkgdown.yml` with URL, Bootstrap 5, and explicit navbar.
- SITE-03: Reference index with 5 named function groups covering all exported functions.
- SITE-04: Onboarding-first article ordering in the Articles section.
- SITE-05: Manual "Get Started" navbar entry wired to the getting-started vignette.
- SHIP-01: Development mode badge suppressed in site build.
- SHIP-02: Housekeeping files (DESCRIPTION, .gitignore, .Rbuildignore) aligned with pkgdown requirements.

## Success Criteria
1. `pkgdown::check_pkgdown()` returns zero warnings.
2. `pkgdown::build_site(preview = FALSE)` completes locally without errors.
3. Navbar exposes: Home, Get Started, Reference, Articles, Changelog with no dead links.
4. Reference index shows 5 groups; all exported functions mapped exactly once.
5. All 3 vignettes appear in Articles section in order.
6. Site renders without "dev" badge.

## Constraints
- Use Bootstrap 5.
- Do not use custom CSS/Logo (deferred to post-v1.2).
- URL must be `https://davidzenz.github.io/typstR/`.
- Must use `usethis` helpers for scaffolding where possible.
