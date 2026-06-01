# typstR

`typstR` gives research and policy teams a working-paper-first path from Quarto
source to a polished Typst PDF. The package ships scaffold helpers, publication
metadata helpers, and bundled templates so you can stay in a normal Quarto
workflow while using a publication-ready format.

## Start here

Install the package in R:

```r
remotes::install_github("DavidZenz/typstR")
```

> You can install `typstR` immediately in R. Quarto is only required when you
> render a document.

The default onboarding path is:

```r
library(typstR)

create_working_paper("my-paper")
# edit my-paper/template.qmd
render_working_paper("my-paper/template.qmd")
```

That single working-paper flow is the canonical first run for the package.

## What to edit after scaffolding

`create_working_paper()` creates four key pieces:

- `template.qmd` for the manuscript body and YAML front matter
- `_quarto.yml` for project-level Quarto settings
- `references.bib` for citations
- `_extensions/typstR/` for the bundled format extension

If you want the full walkthrough of how those files fit together, start with
[Getting started](articles/getting-started.html).

## Where to go next

| If you need... | Start here |
|---|---|
| The full install -> scaffold -> render walkthrough | [Getting started](articles/getting-started.html) |
| More detail on title-page metadata and working-paper fields | [Working Papers](articles/working-papers.html) |
| Practical YAML knobs for logos, fonts, and color | [Customizing Branding](articles/customizing-branding.html) |
| Function-level help for scaffold and render wrappers | [Reference](reference/index.html) |

## Other format entry points

Once the working-paper path is clear, you can branch into adjacent formats:

```r
create_article("my-article")
create_policy_brief("my-brief")
```

Use `create_article()` for article-style manuscripts and
`create_policy_brief()` for shorter policy-facing outputs.
