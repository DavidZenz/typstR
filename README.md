# typstR

`typstR` helps researchers and policy teams go from a Quarto manuscript to a polished Typst PDF without learning Typst internals. It ships a working-paper-first scaffold, publication metadata helpers, and render wrappers so the default path stays simple: scaffold a project, edit one `.qmd`, and render when you are ready.

## Install typstR

```r
remotes::install_github("DavidZenz/typstR")
```

> `typstR` installs like any other R package. You only need Quarto when you
> render a document.

## First run: scaffold -> edit -> render

Start with the working paper scaffold:

```r
library(typstR)

create_working_paper("my-paper")
# edit my-paper/template.qmd
render_working_paper("my-paper/template.qmd")
```

That working-paper path is the main onboarding flow for the package. It gives
you one concrete manuscript shape to learn first, then lets you branch into
other formats later.

## What gets scaffolded

`create_working_paper("my-paper")` creates a compact project with:

- `template.qmd` for the manuscript you actually edit
- `_quarto.yml` for project-level Quarto settings
- `references.bib` for citations
- `_extensions/typstR/` for the bundled format extension

The starter manuscript already includes a title block, author metadata,
abstract, bibliography wiring, and the `typstR:` YAML block for fields such as
keywords, JEL codes, acknowledgements, funding, and report number.

For the full walkthrough of what to edit in `template.qmd`, `_quarto.yml`, and
`references.bib`, start with
`vignette("getting-started", package = "typstR")`.

## Other publication formats

After the working-paper flow is familiar, `typstR` also ships scaffolders for
two adjacent formats:

```r
create_article("my-article")
create_policy_brief("my-brief")
```

Use `create_article()` for article-style manuscripts without a report-number block, and `create_policy_brief()` for shorter, policy-facing documents with brief-oriented sections such as Key Findings and Policy Implications.

## Metadata and publication helpers

The exported helpers keep manuscript metadata readable and reusable:

- `author()`, `affiliation()`, and `manuscript_meta()` build structured author and affiliation metadata.
- `funding()`, `data_availability()`, and `code_availability()` capture standard publication statements.
- `keywords()`, `jel_codes()`, and `report_number()` provide typed publication metadata.
- `fig_note()`, `tab_note()`, and `appendix_title()` support common manuscript annotations.
- `render_pub()` and `render_working_paper()` wrap Quarto rendering from R.

For the documentation hub version of this workflow, use `pkgdown/index.md`.
