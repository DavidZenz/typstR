# Specify a funding statement for a manuscript

Wraps a scalar string as a typed metadata value for use in
[`manuscript_meta()`](https://davidzenz.github.io/typstR/reference/manuscript_meta.md).

## Usage

``` r
funding(text)
```

## Arguments

- text:

  A single character string describing funding sources.

## Value

An S3 object of class `c("typstR_funding", "character")`.

## Examples

``` r
funding("Supported by ERC Grant 12345.")
#> [1] "Supported by ERC Grant 12345."
#> attr(,"class")
#> [1] "typstR_funding" "character"     
```
