# Validate render environment prerequisites

Runs pre-render environment checks for Quarto/Typst/runtime
prerequisites and confirms the typstR extension is present in the target
project.

## Usage

``` r
validate_render_environment(path = ".")
```

## Arguments

- path:

  Project path to validate. Defaults to current directory.

## Value

A `typstR_validation_report` object when all checks pass. On failure,
aborts with class `typstR_diagnostics_error` and structured diagnostics
payload.

## Examples

``` r
if (FALSE) { # \dontrun{
validate_render_environment("my-working-paper")
} # }
```
