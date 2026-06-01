# Specify keywords for a manuscript

Creates a validated list of keyword strings for use in manuscript
metadata. The returned object can be passed to
[`manuscript_meta()`](https://davidzenz.github.io/typstR/reference/manuscript_meta.md).

## Usage

``` r
keywords(...)
```

## Arguments

- ...:

  One or more character strings, each a keyword.

## Value

An S3 object of class `c("typstR_keywords", "list")`.

## Examples

``` r
keywords("trade", "policy", "gravity model")
#> <typstR_keywords> [3 items]
```
