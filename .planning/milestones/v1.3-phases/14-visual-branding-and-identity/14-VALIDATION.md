# Phase 14 Validation

**Phase:** 14-visual-branding-and-identity
**Status:** Ready for execution

## Validation Strategy
Phase 14 validation is primarily visual, but includes automated gates for asset presence, configuration schema, and R package hygiene.

## Requirement Coverage

| Requirement | Validation approach | Command / check |
|-------------|---------------------|-----------------|
| BRAND-01 | Asset presence and site-build integration | `test -f man/figures/logo.svg && test -d pkgdown/favicon && grep "logo" docs/index.html` |
| BRAND-02 | CSS accent application | `grep "bslib" _pkgdown.yml && test -f pkgdown/extra.css && grep "Oxford Blue" pkgdown/extra.css` |
| SITE-HYGIENE | .Rbuildignore alignment | `grep "^pkgdown/" .Rbuildignore` |

## Execution Order
1. Create logo and generate favicons (Plan 14-01).
2. Configure theming and extra CSS (Plan 14-02).
3. Execute full site build and perform manual visual audit (Plan 14-03).

## Phase Gate
Phase 14 is complete only when:
- `pkgdown::check_pkgdown()` returns zero warnings.
- `pkgdown::build_site()` completes without errors.
- Visual audit confirms logo in navbar, favicon in tab, and primary colors applied correctly.
- `.Rbuildignore` correctly excludes `pkgdown/`.
