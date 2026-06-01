# Create an article project

Scaffolds a new article project directory with a Quarto document,
bibliography, project configuration, and the typstR Quarto extension.
The article format is identical to the working paper layout but does not
include a report number block or disclaimer page by default. It supports
anonymized mode via `typstR: anonymized: true` in the YAML front matter.

## Usage

``` r
create_article(path, title = NULL, open = interactive())
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
create_article(
  "my-article",
  title = "Firm Dynamics in Open Economies",
  open = FALSE
)
} # }
```
