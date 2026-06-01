# Specify JEL classification codes for a manuscript

Creates a validated list of JEL codes for use in manuscript metadata.
Each code must match the pattern `[A-Z][0-9]{1,2}` (one uppercase letter
followed by 1 or 2 digits).

## Usage

``` r
jel_codes(...)
```

## Arguments

- ...:

  One or more JEL code strings (e.g., `"F10"`, `"L5"`).

## Value

An S3 object of class `c("typstR_jel", "list")`.

## Examples

``` r
jel_codes("F10", "L52")
#> <typstR_jel> [F10, L52]
```
