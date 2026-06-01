# Getting Started

`typstR` is built around one fast path: scaffold a working paper, edit
one Quarto project, and render a PDF when Quarto is available.

## Create a project

Start by creating a working paper directory:

``` r

library(typstR)
```

``` r

create_working_paper("my-paper")
```

This creates a small project with:

- `template.qmd` for the manuscript
- `_quarto.yml` for project settings
- `references.bib` for bibliography entries
- the bundled `typstR` extension used by the template

## Know the three files you will edit most

The working-paper starter is intentionally small, and each file has a
distinct job:

- `template.qmd` is the manuscript you edit day to day
- `_quarto.yml` stores project-level Quarto settings
- `references.bib` is where you add bibliography entries

If you only remember one thing from this vignette, remember that the
normal flow is `template.qmd` for content, `_quarto.yml` for project
settings, and `references.bib` for citations.

## Edit `template.qmd`

The working-paper template already contains the main fields most users
need: title, authors, affiliations, an abstract, bibliography wiring,
and a `typstR:` block for publication metadata.

``` yaml
typstR:
  keywords:
    - supply chains
    - trade policy
  jel:
    - F14
    - F13
  report-number: "WP 001"
  funding: |
    This research was supported by the Applied Trade Policy Programme.
```

You can also build structured metadata in R before pasting it into the
Quarto file:

``` r

lead_author <- author(
  "Elena Fischer",
  email = "elena.fischer@example.org",
  corresponding = TRUE,
  affiliation = "1"
)

home_institute <- affiliation("1", "Centre for European Industrial Analysis")

manuscript_meta(
  authors = list(lead_author),
  affiliations = list(home_institute)
)
#> <typstR_meta> 1 author(s), 1 affiliation(s)
```

## Check `_quarto.yml` and `references.bib`

The generated `_quarto.yml` keeps the project wiring minimal:

``` yaml
project:
  type: default
```

You usually do not need to change it on day one, but it is the place to
look when you later want project-wide Quarto behavior.

The starter `references.bib` includes one example entry so you can see
the expected BibTeX shape immediately. Add your own entries there and
keep `bibliography: references.bib` in the manuscript YAML.

## Add manuscript content

Keep the manuscript in `template.qmd`. The shipped starter uses a
compact working-paper structure:

- `Introduction`
- `Data and Methods`
- `Results`
- `Conclusion`
- `References`

Add citations through `references.bib` and cite them in the manuscript
with standard Quarto syntax such as `@smith2020`.

## Render the PDF

Rendering depends on Quarto, so the call below is shown but not run
during vignette checks.

``` r

render_working_paper("my-paper/template.qmd")
```

If you prefer to guard the call in your own scripts, use the same
condition that package tests use:

``` r

quarto_ready <- quarto::quarto_available()
quarto_ready
#> [1] TRUE
```

``` r

if (quarto::quarto_available()) {
  render_working_paper("my-paper/template.qmd")
}
```

## Next steps

Once the basic workflow is working, the other vignettes cover the two
main follow-up tasks instead of repeating the scaffold/render
introduction:

- [`vignette("working-papers", package = "typstR")`](https://davidzenz.github.io/typstR/articles/working-papers.md)
  for working-paper metadata
- [`vignette("customizing-branding", package = "typstR")`](https://davidzenz.github.io/typstR/articles/customizing-branding.md)
  for branding fields
