# Phase 17 Research: Dependency Review and Cleanup

## Overview
Phase 17 focuses on ensuring the `DESCRIPTION` file accurately reflects the package's true dependency needs. A lean dependency tree is a strong positive signal for CRAN submissions.

## Key Research Findings

### Current Dependencies (`DESCRIPTION`)
**Imports:**
- `cli (>= 3.6.0)`: Used for console output/diagnostics. Required.
- `fs (>= 1.6.0)`: Used for file system operations (scaffolding). Required.
- `quarto (>= 1.4)`: Used for `quarto_render` and `quarto_available`. Required.

**Suggests:**
- `bench`: Used for performance testing. Correct scope.
- `knitr`: Used for vignette building. Correct scope.
- `pkgdown`: Used for website generation. Correct scope.
- `rmarkdown`: Used for vignette building. Correct scope.
- `testthat (>= 3.0.0)`: Used for unit testing. Correct scope.
- `withr`: Used for safe state changes in tests. Correct scope.
- `yaml`: Currently in `Suggests`. **ACTION REQUIRED**: `yaml::read_yaml()` is called in `R/validation_environment.R` (line 228). Since this is core package logic, `yaml` MUST be moved from `Suggests` to `Imports`.

### Missing or Unused Dependencies
- `rlang`: Mentioned in `PROJECT.md` constraints but not found via `grep` in `R/` and not in `DESCRIPTION`. It can remain omitted if not used.

## Implementation Strategy
1. **Move `yaml` to `Imports`**: Since `yaml::read_yaml()` is critical for parsing the extension manifest during environment validation, it must be a hard dependency.
2. **Namespace Management**: Ensure `yaml` is properly imported in the Roxygen comments if functions are used without the `yaml::` prefix, though `yaml::read_yaml()` explicit calls are fine as long as `yaml` is in `Imports`.
3. **Verify via `devtools::check()`**: After adjusting dependencies, a local check will confirm if any other dependencies are missing or miscategorized.
