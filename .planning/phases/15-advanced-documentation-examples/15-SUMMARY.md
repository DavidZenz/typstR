# Phase 15 Summary: Advanced Documentation Examples

**Phase:** 15
**Status:** Complete
**Completed:** 2026-06-01

## Phase Goal
Provide users with deeper technical guidance on using typstR for complex academic documents by creating an "Advanced Examples" article.

## Accomplishments
- **Content Drafting (15-01):** Created `vignettes/advanced-examples.Rmd` covering complex academic requirements:
    - Tabular data using `gt` with native Typst output (`as_typst()`).
    - Mathematical notation (multi-line, numbered equations).
    - Quarto's native cross-referencing syntax (`@fig`, `@tbl`, `@eq`).
    - Review and submission features (anonymization, disclaimers).
- **Site Wiring & Validation (15-02):**
    - Integrated the new article into the `pkgdown` navigation via `_pkgdown.yml`.
    - Validated the configuration using `pkgdown::check_pkgdown()` (zero warnings).
    - Confirmed the article renders correctly in a full local `pkgdown::build_site()` run.

## Requirements Covered
- **EXT-01:** Users can reference an "Advanced Examples" article that demonstrates complex tables, multi-line equations, and cross-reference patterns.

## Key Decisions
- **gt as Primary Table Choice:** Recommended `gt` with `as_typst()` as the canonical way to handle complex tables in `typstR` manuscripts, as it offers the best balance of R-side power and Typst-side output quality.
- **CI Safety via Eval-Guards:** Strictly enforced `eval = FALSE` for all Quarto-dependent code chunks to maintain the documentation build strategy established in v1.2.

## Next Steps
- **Phase 16:** Create the "Format Comparison" matrix and perform the final milestone audit for v1.3.
