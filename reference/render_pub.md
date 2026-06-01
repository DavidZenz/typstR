# Render a Quarto document to PDF

Renders a Quarto document using the Quarto CLI after running the shared
environment validation checks that typstR uses before rendering.

## Usage

``` r
render_pub(
  input = NULL,
  output_format = NULL,
  quiet = FALSE,
  open = interactive()
)
```

## Arguments

- input:

  Path to a `.qmd` file, a directory containing a `.qmd` file, or `NULL`
  to look in the current directory.

- output_format:

  Quarto output format name (e.g., `"typstR-typst"`). If `NULL`, uses
  the format specified in the document YAML.

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
render_pub("my-working-paper/template.qmd", quiet = TRUE, open = FALSE)
render_pub(
  "my-article/template.qmd",
  output_format = "typstR-article",
  quiet = TRUE,
  open = FALSE
)
} # }
```
