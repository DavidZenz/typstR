# Render a working paper to PDF

Convenience wrapper that renders a document using the `typstR-typst`
working-paper format.

## Usage

``` r
render_working_paper(input = NULL, quiet = FALSE, open = interactive())
```

## Arguments

- input:

  Path to a `.qmd` file, a directory containing a `.qmd` file, or `NULL`
  to look in the current directory.

- quiet:

  If `TRUE`, suppresses Quarto output. Defaults to `FALSE`.

- open:

  If `TRUE`, opens the rendered PDF in the system viewer. Defaults to
  `TRUE` in interactive sessions.

## Value

`NULL`, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
render_working_paper("my-working-paper/template.qmd", quiet = TRUE, open = FALSE)
} # }
```
