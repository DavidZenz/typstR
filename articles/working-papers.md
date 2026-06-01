# Working Papers

This vignette focuses on the metadata surface of the working paper
format. The goal is to keep the Quarto file readable while still
capturing the fields that usually appear on an academic title page.

For the base install -\> scaffold -\> render workflow, start with
[`vignette("getting-started", package = "typstR")`](https://davidzenz.github.io/typstR/articles/getting-started.md).
This article assumes you already have a working paper scaffold and want
to refine the metadata layer.

## Start with authors and affiliations

Use [`author()`](https://davidzenz.github.io/typstR/reference/author.md)
and
[`affiliation()`](https://davidzenz.github.io/typstR/reference/affiliation.md)
to build structured metadata:

``` r

authors <- list(
  author(
    "Elena Fischer",
    email = "elena.fischer@example.org",
    corresponding = TRUE,
    affiliation = "1"
  ),
  author(
    "Martin Kovac",
    affiliation = c("1", "2")
  )
)

affiliations <- list(
  affiliation("1", "Centre for European Industrial Analysis"),
  affiliation("2", "University of Bratislava")
)

manuscript_meta(authors = authors, affiliations = affiliations)
#> <typstR_meta> 2 author(s), 2 affiliation(s)
```

## Add abstract and publication metadata

The working-paper template expects the abstract in ordinary Quarto front
matter and the publication-specific fields inside `typstR:`.

``` yaml
abstract: |
  This working paper studies how manufacturing firms adjust supplier networks
  after trade policy shocks.
typstR:
  keywords:
    - supply chains
    - trade policy
    - firm adjustment
  jel:
    - F14
    - F13
  report-number: "WP 001"
```

That is the main working-paper difference from the article format: JEL
codes and a report number usually belong on the title page.

## Reuse helper functions for standard statements

The package includes small helpers for common end-matter blocks:

``` r

funding("This research was supported by the Applied Trade Policy Programme.")
#> [1] "This research was supported by the Applied Trade Policy Programme."
#> attr(,"class")
#> [1] "typstR_funding" "character"
data_availability("Replication files will be released after publication.")
#> [1] "Replication files will be released after publication."
#> attr(,"class")
#> [1] "typstR_data_availability" "character"
code_availability("Code is available from the corresponding author on request.")
#> [1] "Code is available from the corresponding author on request."
#> attr(,"class")
#> [1] "typstR_code_availability" "character"
```

These helpers are useful when you want a consistent structure across
multiple papers in the same series.

## Keep the bibliography workflow simple

The scaffolder already includes `references.bib`, so the usual workflow
is:

1.  add BibTeX entries to `references.bib`
2.  keep `bibliography: references.bib` in the Quarto YAML
3.  cite sources in the body with keys such as `@smith2020`
4.  leave `## References` at the end of the document

## Use the starter template as the default shape

[`create_working_paper()`](https://davidzenz.github.io/typstR/reference/create_working_paper.md)
gives you a compact manuscript skeleton with:

- academic title block metadata
- bibliography wiring
- acknowledgements, funding, and report number support
- room for working-paper branding without editing Typst files directly

For the full scaffold-to-render flow, return to
[`vignette("getting-started", package = "typstR")`](https://davidzenz.github.io/typstR/articles/getting-started.md).
