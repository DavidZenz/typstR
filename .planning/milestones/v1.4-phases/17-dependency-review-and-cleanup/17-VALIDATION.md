# Phase 17 Validation

**Phase:** 17-dependency-review-and-cleanup
**Status:** Ready for execution

## Validation Strategy
Phase 17 validation relies on static analysis of the `DESCRIPTION` file to confirm correct dependency scoping, followed by a dynamic check using `devtools::check()` to ensure the R package build system agrees with the configuration.

## Requirement Coverage

| Requirement | Validation approach | Command / check |
|-------------|---------------------|-----------------|
| CRAN-02 | Static `DESCRIPTION` audit | `grep -A 5 "Imports:" DESCRIPTION | grep "yaml"` |
| CRAN-HYGIENE | Dynamic package check | `Rscript -e 'devtools::check(document = FALSE, error_on = "warning")'` |

## Execution Order
1. Update the `DESCRIPTION` file to move `yaml` to `Imports` (Plan 17-01).
2. Run `devtools::check()` locally to verify dependency cleanliness (Plan 17-01).

## Phase Gate
Phase 17 is complete only when:
- `yaml` is listed under `Imports:` in `DESCRIPTION` and removed from `Suggests:`.
- `devtools::check()` completes without any `NOTE` or `WARNING` related to dependencies.
