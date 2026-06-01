# Create a working paper project

Scaffolds a new working paper project directory with the files used in
the standard typstR onboarding flow: `template.qmd`, `_quarto.yml`,
`references.bib`, and the bundled typstR Quarto extension.

## Usage

``` r
create_working_paper(path, title = NULL, open = interactive())
```

## Arguments

- path:

  Path to the new project directory. Must not already exist.

- title:

  Optional title to pre-fill in the template YAML.

- open:

  Whether to open the project directory. Defaults to `TRUE` in
  interactive sessions.

## Value

The project path, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
create_working_paper(
  "my-working-paper",
  title = "Trade, Policy, and Growth",
  open = FALSE
)

render_working_paper("my-working-paper/template.qmd", quiet = TRUE, open = FALSE)
} # }
```
