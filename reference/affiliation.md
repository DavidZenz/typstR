# Create an affiliation metadata object

Returns an S3 object of class `typstR_affiliation` representing an
institutional affiliation. Fields are serializable to Quarto-compatible
YAML via
[`yaml::as.yaml()`](https://yaml.r-lib.org/reference/as.yaml.html).

## Usage

``` r
affiliation(id, name, department = NULL, address = NULL, country = NULL)
```

## Arguments

- id:

  Character scalar. Unique identifier used to link authors to this
  affiliation (required).

- name:

  Character scalar. Institution name (required).

- department:

  Character scalar department name, or `NULL`.

- address:

  Character scalar address, or `NULL`.

- country:

  Character scalar country name, or `NULL`.

## Value

An S3 object with class `c("typstR_affiliation", "list")`.

## Examples

``` r
affiliation(
  id = "econ",
  name = "Institute for Advanced Policy Studies",
  country = "Austria"
)
#> <typstR_affiliation> [econ] Institute for Advanced Policy Studies
```
