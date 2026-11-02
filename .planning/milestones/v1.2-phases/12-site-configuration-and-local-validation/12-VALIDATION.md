# Phase 12 Validation

**Phase:** 12-site-configuration-and-local-validation
**Status:** Ready for execution

## Validation Strategy
Phase 12 validation focuses on the structural and functional integrity of the generated pkgdown site. We use `pkgdown::check_pkgdown()` for schema and consistency checks, and a full local build followed by manual audit for functional verification.

## Requirement Coverage

| Requirement | Validation approach | Command / check |
|-------------|---------------------|-----------------|
| SITE-02 | check_pkgdown + manual URL/BS5 check | `Rscript -e 'pkgdown::check_pkgdown()'` |
| SITE-03 | reference group audit | `Rscript -e 'site <- pkgdown::as_pkgdown("."); stopifnot(length(site$reference) == 5)'` |
| SITE-04 | article order audit | `Rscript -e 'site <- pkgdown::as_pkgdown("."); stopifnot(site$articles[[1]]$name == "getting-started")'` |
| SITE-05 | navbar manual wiring check | `grep "intro" _pkgdown.yml` |
| SHIP-01 | dev badge mode check | `grep "mode: release" _pkgdown.yml` |
| SHIP-02 | ignore file and DESCRIPTION audit | `grep "docs/" .gitignore && grep "_pkgdown.yml" .Rbuildignore` |

## Execution Order
1. Run housekeeping and verify ignore files (Plan 12-01).
2. Configure `_pkgdown.yml` and run `pkgdown::check_pkgdown()` (Plan 12-02).
3. Execute full site build and perform manual navbar/link audit (Plan 12-03).

## Phase Gate
Phase 12 is complete only when:
- `pkgdown::check_pkgdown()` returns zero warnings.
- `pkgdown::build_site()` completes without errors.
- Manual audit confirms Home, Get Started, Reference groups, and Articles order are correct.
- No "dev" badge is visible on the home page.
