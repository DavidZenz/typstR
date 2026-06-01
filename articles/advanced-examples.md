# Advanced Examples

While `typstR` is designed for a simple “scaffold and write” workflow,
it supports the full technical depth of Quarto and Typst for complex
document requirements.

This article covers advanced features like complex tables, mathematical
notation, and review-specific metadata. If you are new to the package,
start with
[`vignette("getting-started", package = "typstR")`](https://davidzenz.github.io/typstR/articles/getting-started.md)
for the basic workflow.

## Complex Tables

For standard tables, markdown syntax or
[`knitr::kable()`](https://rdrr.io/pkg/knitr/man/kable.html) work well.
For more complex layouts, `typstR` supports the `gt` package via its
Typst output.

``` r

library(gt)
library(typstR)

# Create a gt table and ensure it renders via Typst
mtcars |>
  head() |>
  gt() |>
  tab_header(
    title = "Advanced Table Example",
    subtitle = "Using gt with typstR"
  )
```

Quarto automatically detects `gt` objects and uses the appropriate
renderer when the output format is Typst.

## Mathematics

`typstR` supports standard Quarto/LaTeX math syntax. For multi-line,
numbered equations, use the following pattern in your `.qmd` file:

``` latex
$$
\begin{aligned}
y_{it} &= \alpha_i + \beta X_{it} + \varepsilon_{it} \\
\mathbb{E}[\varepsilon_{it} | X_{it}, \alpha_i] &= 0
\end{aligned}
$$ {#eq-model}
```

This will render as a numbered equation block that can be referenced
elsewhere.

## Cross-references

Quarto’s cross-referencing system works seamlessly with the `typstR`
formats. Use the `@` syntax to reference figures, tables, and equations:

- **Figures:** `See @fig-results for details.` (where the figure has
  `#fig-results`)
- **Tables:** `Results are summarized in @tbl-main.` (where the table
  has `#tbl-main`)
- **Equations:** `We estimate @eq-model using OLS.` (where the equation
  has `#eq-model`)

## Review and Publication Features

`typstR` includes specific controls for the peer-review process and
pre-publication drafts.

### Anonymization

For double-blind review, set `anonymized: true` in the YAML header (or
within the `typstR:` block depending on the specific template version).
This will hide author names and affiliations.

``` yaml
---
title: "My Anonymous Submission"
anonymized: true
---
```

### Disclaimer Pages

For working papers, you can enable a dedicated disclaimer page before
the main content:

``` yaml
typstR:
  disclaimer-page: true
```

## Bibliography Styles

By default, the templates use a standard Chicago-like style. You can
change this by providing a CSL (Citation Style Language) file in your
YAML header:

``` yaml
---
bibliography: references.bib
csl: american-economic-review.csl
---
```

You can find CSL files for almost any journal at the [Zotero Style
Repository](https://www.zotero.org/styles).

## Next Steps

For the full end-to-end onboarding flow, return to
[`vignette("getting-started", package = "typstR")`](https://davidzenz.github.io/typstR/articles/getting-started.md).
