# Emit a formatted appendix section title

Outputs a markdown header with Quarto's `{.appendix}` class via
[`cat()`](https://rdrr.io/r/base/cat.html), suitable for use in Quarto
code chunks with `#| output: asis`. This marks the section as an
appendix in Quarto's cross-reference system.

## Usage

``` r
appendix_title(title, level = 1)
```

## Arguments

- title:

  A single character string giving the appendix section title.

- level:

  An integer giving the header level (number of `#` characters).
  Defaults to `1` (top-level `#` header).

## Value

The title string, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
# In a Quarto code chunk with #| output: asis
appendix_title("Data Sources")
appendix_title("Additional Tables", level = 2)
} # }
```
