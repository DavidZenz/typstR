# Validate a typstR manuscript

Checks manuscript and project YAML, publication metadata, supported
output formats, and configured local resources. The same checks run
before rendering.

## Usage

``` r
validate_manuscript(
  path = ".",
  output_format = NULL,
  check_environment = FALSE
)
```

## Arguments

- path:

  A `.qmd` file, directory containing one `.qmd`, or `NULL` for the
  current directory. Defaults to `"."`.

- output_format:

  Optional format override. The bundled format is `"typstR-typst"`;
  select article or brief with `typstR: format-variant`.

- check_environment:

  Also check Quarto, Typst and the bundled extension. Defaults to
  `FALSE`, allowing manuscript checks without Quarto installed.

## Value

A `typstR_validation_report`, including resolved context and metadata.
Invalid input raises `typstR_diagnostics_error` with ordered
diagnostics.

## Details

Project YAML, directory `_metadata.yml` and document YAML are merged in
that order. Relative resource paths are based on the configuration file
that declares them. Profiles, local configuration, executable YAML,
metadata-files, and generated resources are not supported by this static
preflight. Empty or editor-only local configuration is allowed. Boolean
fields require unquoted `true` or `false`. See the getting-started
article for the validation contract and limitations.

## Examples

``` r
if (FALSE) { # \dontrun{
validate_manuscript("my-paper/template.qmd")
validate_manuscript("my-paper", check_environment = TRUE)
} # }
```
