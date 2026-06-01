# Create a policy brief project

Scaffolds a new policy brief project directory with a Quarto document,
bibliography, project configuration, and the typstR Quarto extension.
The policy brief format uses a shorter, audience-oriented layout with a
concise summary instead of a full abstract. It does not include JEL
codes and uses policy-oriented section headings (Key Findings, Evidence,
Policy Implications).

## Usage

``` r
create_policy_brief(path, title = NULL, open = interactive())
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
create_policy_brief(
  "my-policy-brief",
  title = "What Export Controls Mean for Small Open Economies",
  open = FALSE
)
} # }
```
