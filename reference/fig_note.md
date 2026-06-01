# Emit a figure note in markdown format

Outputs a note line starting with `*Note:*` via
[`cat()`](https://rdrr.io/r/base/cat.html), suitable for use in Quarto
code chunks with `#| output: asis`. This allows figure notes to be
rendered as formatted markdown in the final document.

## Usage

``` r
fig_note(...)
```

## Arguments

- ...:

  One or more character strings to concatenate into the note text
  (concatenated with no separator).

## Value

The note text string, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
# In a Quarto code chunk with #| output: asis
fig_note("Source: World Bank, WDI database (2023).")
fig_note("Note: ", n_obs, " observations. Robust standard errors in parentheses.")
} # }
```
