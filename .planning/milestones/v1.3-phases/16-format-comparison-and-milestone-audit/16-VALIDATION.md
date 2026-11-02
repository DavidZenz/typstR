# Phase 16 Validation

**Phase:** 16-format-comparison-and-milestone-audit
**Status:** Ready for execution

## Validation Strategy
Phase 16 validation ensures the comparison matrix is accurate and accessible, and that the entire milestone v1.3 meets its defined requirements through a formal audit.

## Requirement Coverage

| Requirement | Validation approach | Command / check |
|-------------|---------------------|-----------------|
| EXT-02 | Content presence and site integration | `grep "Format Comparison" _pkgdown.yml && test -f vignettes/format-comparison.Rmd` |
| SITE-BUILD | Zero-warning build | `Rscript -e 'pkgdown::check_pkgdown()'` |
| MILESTONE-AUDIT | Requirement evidence check | `test -f .planning/v1.3-MILESTONE-AUDIT.md` |

## Execution Order
1. Draft the "Format Comparison" vignette and wire into `_pkgdown.yml` (Plan 16-01).
2. Validate local site build (Plan 16-01).
3. Perform Milestone v1.3 Audit and update project state (Plan 16-02).

## Phase Gate
Phase 16 is complete only when:
- `pkgdown::check_pkgdown()` returns zero warnings.
- `pkgdown::build_site()` completes without errors.
- Manual audit confirms "Format Comparison" is reachable and accurate.
- `v1.3-MILESTONE-AUDIT.md` shows 100% requirement coverage.
