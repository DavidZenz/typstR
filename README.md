# typstR

`typstR` is an R package for researchers and policy teams who want a fast path from a Quarto manuscript to a polished Typst PDF. It bundles publication-ready templates, metadata helpers, and scaffold functions so the default workflow stays simple: create a working paper project, edit one `.qmd`, and render a branded PDF without touching Typst internals.

## Installation

```r
remotes::install_github("DavidZenz/typstR")
```

## Quick start

Create a new working paper project:

```r
library(typstR)

create_working_paper("my-paper")
```

This creates a project directory with `template.qmd`, `_quarto.yml`, `references.bib`, and the bundled `typstR` Quarto extension.

Edit the manuscript in `my-paper/template.qmd`. The starter file already includes a title block, author metadata, abstract, bibliography, and the `typstR:` YAML block for fields such as keywords, JEL codes, acknowledgements, funding, and report number.

When the manuscript is ready, render it to PDF:

```r
render_working_paper("my-paper/template.qmd")
```

That working-paper path is the main onboarding flow for the package: scaffold, edit the generated Quarto file, and render a publication-ready PDF.

## Other publication formats

`typstR` also ships scaffolders for two adjacent formats:

```r
create_article("my-article")
create_policy_brief("my-brief")
```

Use `create_article()` for article-style manuscripts without a report-number block, and `create_policy_brief()` for shorter, policy-facing documents with brief-oriented sections such as Key Findings and Policy Implications.

## Metadata and publication helpers

The exported helpers are designed to keep manuscript metadata readable and reusable:

- `author()`, `affiliation()`, and `manuscript_meta()` build structured author and affiliation metadata.
- `funding()`, `data_availability()`, and `code_availability()` capture standard publication statements.
- `keywords()`, `jel_codes()`, and `report_number()` provide typed publication metadata.
- `fig_note()`, `tab_note()`, and `appendix_title()` support common manuscript annotations.
- `render_pub()` and `render_working_paper()` wrap Quarto rendering from R.
