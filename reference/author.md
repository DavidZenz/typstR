# Create an author metadata object

Returns an S3 object of class `typstR_author` representing a manuscript
author. Fields are serializable to Quarto-compatible YAML via
[`yaml::as.yaml()`](https://yaml.r-lib.org/reference/as.yaml.html).

## Usage

``` r
author(
  name,
  affiliation = NULL,
  email = NULL,
  orcid = NULL,
  corresponding = FALSE
)
```

## Arguments

- name:

  Character scalar. Author's full name (required).

- affiliation:

  Character vector of affiliation IDs, or `NULL`.

- email:

  Character scalar email address, or `NULL`.

- orcid:

  Character scalar ORCID identifier in `XXXX-XXXX-XXXX-XXXX` format, or
  `NULL`.

- corresponding:

  Logical scalar. Whether this author is the corresponding author.
  Defaults to `FALSE`.

## Value

An S3 object with class `c("typstR_author", "list")`.

## Examples

``` r
author(
  name = "Ada Lovelace",
  affiliation = "econ",
  email = "ada@example.org",
  corresponding = TRUE
)
#> <typstR_author> Ada Lovelace 
```
