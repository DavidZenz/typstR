# Specify a code availability statement for a manuscript

Wraps a scalar string as a typed metadata value for use in
[`manuscript_meta()`](https://davidzenz.github.io/typstR/reference/manuscript_meta.md).

## Usage

``` r
code_availability(text)
```

## Arguments

- text:

  A single character string describing code availability.

## Value

An S3 object of class `c("typstR_code_availability", "character")`.

## Examples

``` r
code_availability("Replication code at https://github.com/example/repo")
#> [1] "Replication code at https://github.com/example/repo"
#> attr(,"class")
#> [1] "typstR_code_availability" "character"               
```
