# Specify a data availability statement for a manuscript

Wraps a scalar string as a typed metadata value for use in
[`manuscript_meta()`](https://davidzenz.github.io/typstR/reference/manuscript_meta.md).

## Usage

``` r
data_availability(text)
```

## Arguments

- text:

  A single character string describing data availability.

## Value

An S3 object of class `c("typstR_data_availability", "character")`.

## Examples

``` r
data_availability("Data available at https://example.com/data")
#> [1] "Data available at https://example.com/data"
#> attr(,"class")
#> [1] "typstR_data_availability" "character"               
```
