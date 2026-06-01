# Phase 15 Context: Advanced Documentation Examples

## Goal
Provide users with deeper technical guidance on using typstR for complex academic documents by creating an "Advanced Examples" article.

## Requirements
- EXT-01: Users can reference an "Advanced Examples" article that demonstrates complex tables, multi-line equations, and cross-reference patterns.

## Success Criteria
1. "Advanced Examples" article exists at `vignettes/advanced-examples.Rmd` (or similar).
2. The article is reachable via the pkgdown navbar under "Articles".
3. Content includes:
    - Complex tables (e.g., using `gt` or `tinytable`).
    - Mathematical equations (multi-line, numbered).
    - Cross-references for figures, tables, and equations.
    - Advanced metadata usage (disclaimers, anonymization).
4. Local build via `pkgdown::build_site()` succeeds with zero errors related to this new article.

## Constraints
- Follow the established tone of existing vignettes.
- Ensure all code chunks that require Quarto/Typst are marked `eval = FALSE` to comply with the Phase 11/12/13 CI build strategy.
- Focus on the PDF/Typst output path.
