# Phase 15 Research: Advanced Documentation Examples

## Overview
Phase 15 aims to bridge the gap between "getting started" and producing a submission-ready academic manuscript. This research identifies the specific technical patterns to showcase in the "Advanced Examples" article.

## Key Research Findings

### 1. Complex Tables
- **gt package:** `gt` now has native Typst output support. Example: `gt(df) |> as_typst()`. This is the preferred recommendation for `typstR` users.
- **tinytable package:** `tinytable` also supports Typst and is lightweight.
- **Markdown Tables:** For simple but structured tables, standard Quarto markdown tables with attributes (e.g., `#tbl-label`) are often sufficient.

### 2. Mathematics
- **Standard Syntax:** Quarto/Typst supports standard LaTeX-style math delimited by `$$`.
- **Numbering:** Equations can be numbered and cross-referenced using `$$ ... $$ {#eq-label}`.

### 3. Cross-References
- **Syntax:** `@fig-label`, `@tbl-label`, `@eq-label`, and `@sec-label`.
- **Typst Backend:** Quarto's Typst backend handles these natively without requiring extra Typst-side boilerplate.

### 4. Advanced Metadata (typstR specific)
- **Anonymization:** `anonymized: true` in YAML hides authors and acknowledgments. Useful for double-blind review.
- **Disclaimers:** `disclaimer-page: true` plus `disclaimer-text` creates a dedicated opening or closing page.
- **Report Numbers:** `report-number` is specific to `workingpaper` and `brief` formats.

### 5. Bibliography Management
- **CSL Styles:** Users can change the citation style by adding `csl: style.csl` to the YAML.
- **Multiple Bibliographies:** Quarto supports multiple bib files via `bibliography: [file1.bib, file2.bib]`.

## Implementation Strategy
- **Article Location:** `vignettes/advanced-examples.Rmd`.
- **Wiring:** Must be added to `_pkgdown.yml` under the `articles` section to ensure it appears in the navbar.
- **Structure:**
  - Introduction
  - Tabular Data (gt/tinytable focus)
  - Mathematical Notation
  - Cross-Referencing
  - Review & Submission Features (anonymization, disclaimers)
  - Conclusion
