# Create a manuscript metadata object

Combines authors, affiliations, and optional metadata fields into a
single serializable object. Performs cross-validation: every affiliation
ID referenced by an author must have a matching
[`affiliation()`](https://davidzenz.github.io/typstR/reference/affiliation.md)
object.

## Usage

``` r
manuscript_meta(
  authors,
  affiliations = list(),
  keywords = NULL,
  jel = NULL,
  acknowledgements = NULL,
  report_number = NULL,
  funding = NULL,
  data_availability = NULL,
  code_availability = NULL
)
```

## Arguments

- authors:

  A list of `typstR_author` objects created by
  [`author()`](https://davidzenz.github.io/typstR/reference/author.md).

- affiliations:

  A list of `typstR_affiliation` objects created by
  [`affiliation()`](https://davidzenz.github.io/typstR/reference/affiliation.md).
  Defaults to an empty list.

- keywords:

  Character vector of keywords, or `NULL`.

- jel:

  Character vector of JEL classification codes, or `NULL`.

- acknowledgements:

  Character scalar acknowledgement text, or `NULL`.

- report_number:

  Character scalar report number, or `NULL`.

- funding:

  Character scalar funding statement, or `NULL`.

- data_availability:

  Character scalar data availability statement, or `NULL`.

- code_availability:

  Character scalar code availability statement, or `NULL`.

## Value

An S3 object with class `c("typstR_meta", "list")`.

## Examples

``` r
authors <- list(
  author(
    name = "Ada Lovelace",
    affiliation = "econ",
    corresponding = TRUE
  )
)

affiliations <- list(
  affiliation(
    id = "econ",
    name = "Institute for Advanced Policy Studies",
    country = "Austria"
  )
)

manuscript_meta(
  authors = authors,
  affiliations = affiliations,
  keywords = keywords("trade", "policy"),
  jel = jel_codes("F10"),
  report_number = report_number("WP 001")
)
#> <typstR_meta> 1 author(s), 1 affiliation(s)
```
