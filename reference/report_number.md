# Specify a report number for a manuscript

Wraps a scalar string as a typed metadata value for use in
[`manuscript_meta()`](https://davidzenz.github.io/typstR/reference/manuscript_meta.md).

## Usage

``` r
report_number(text)
```

## Arguments

- text:

  A single character string giving the report number.

## Value

An S3 object of class `c("typstR_report_number", "character")`.

## Examples

``` r
report_number("WP 001")
#> [1] "WP 001"
#> attr(,"class")
#> [1] "typstR_report_number" "character"           
```
