# Emit a table note in markdown format

Outputs a note line starting with `*Note:*` via
[`cat()`](https://rdrr.io/r/base/cat.html), suitable for use in Quarto
code chunks with `#| output: asis`. This allows table notes to be
rendered as formatted markdown in the final document.

## Usage

``` r
tab_note(...)
```

## Arguments

- ...:

  One or more character strings to concatenate into the note text
  (concatenated with no separator).

## Value

The note text string, invisibly.

## Details

`tab_note()` is a separate function from
[`fig_note()`](https://davidzenz.github.io/typstR/reference/fig_note.md)
to allow divergent styling in future package versions.

## Examples

``` r
if (FALSE) { # \dontrun{
# In a Quarto code chunk with #| output: asis
tab_note("Source: IMF World Economic Outlook (April 2023).")
tab_note("*p* < 0.05, ** *p* < 0.01, *** *p* < 0.001.")
} # }
```
