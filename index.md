# typstR

`typstR` gives research and policy teams a working-paper-first path from
Quarto source to a polished Typst PDF. The package ships scaffold
helpers, publication metadata helpers, and bundled templates so you can
stay in a normal Quarto workflow while using a publication-ready format.

## Start here

Install the package in R:

``` r

remotes::install_github("DavidZenz/typstR")
```

> You can install `typstR` immediately in R. Quarto is only required
> when you render a document.

The default onboarding path is:

``` r

library(typstR)

create_working_paper("my-paper")
# edit my-paper/template.qmd
render_working_paper("my-paper/template.qmd")
```

That single working-paper flow is the canonical first run for the
package.

## What to edit after scaffolding

[`create_working_paper()`](https://davidzenz.github.io/typstR/reference/create_working_paper.md)
creates four key pieces:

- `template.qmd` for the manuscript body and YAML front matter
- `_quarto.yml` for project-level Quarto settings
- `references.bib` for citations
- `_extensions/typstR/` for the bundled format extension

If you want the full walkthrough of how those files fit together, start
with [Getting
started](https://davidzenz.github.io/typstR/articles/getting-started.md).

## Where to go next

| If you need… | Start here |
|----|----|
| The full install -\> scaffold -\> render walkthrough | [Getting started](https://davidzenz.github.io/typstR/articles/getting-started.md) |
| More detail on title-page metadata and working-paper fields | [Working Papers](https://davidzenz.github.io/typstR/articles/working-papers.md) |
| Practical YAML knobs for logos, fonts, and color | [Customizing Branding](https://davidzenz.github.io/typstR/articles/customizing-branding.md) |
| Function-level help for scaffold and render wrappers | [Reference](https://davidzenz.github.io/typstR/reference/index.md) |

## Other format entry points

Once the working-paper path is clear, you can branch into adjacent
formats:

``` r

create_article("my-article")
create_policy_brief("my-brief")
```

Use
[`create_article()`](https://davidzenz.github.io/typstR/reference/create_article.md)
for article-style manuscripts and
[`create_policy_brief()`](https://davidzenz.github.io/typstR/reference/create_policy_brief.md)
for shorter policy-facing outputs.
