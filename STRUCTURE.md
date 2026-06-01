typstR/
├─ DESCRIPTION
├─ NAMESPACE
├─ R/
│  ├─ create_working_paper.R
│  ├─ create_article.R
│  ├─ metadata_helpers.R
│  ├─ validation.R
│  ├─ render.R
│  ├─ notes_helpers.R
│  └─ utils.R
├─ inst/
│  ├─ quarto/
│  │  └─ extensions/
│  │     └─ typstR/
│  │        ├─ _extension.yml
│  │        ├─ formats/
│  │        │  ├─ workingpaper.yml
│  │        │  ├─ article.yml
│  │        │  └─ brief.yml
│  │        ├─ templates/
│  │        │  ├─ base.typ
│  │        │  ├─ titleblock.typ
│  │        │  ├─ authors.typ
│  │        │  ├─ abstract.typ
│  │        │  ├─ bibliography.typ
│  │        │  ├─ floats.typ
│  │        │  ├─ appendix.typ
│  │        │  └─ branding.typ
│  │        ├─ partials/
│  │        ├─ assets/
│  │        │  ├─ logo-placeholder.png
│  │        │  └─ example-bibliography.bib
│  │        └─ examples/
│  │           ├─ workingpaper.qmd
│  │           └─ article.qmd
│  └─ templates/
│     ├─ workingpaper/
│     │  ├─ template.qmd
│     │  ├─ _quarto.yml
│     │  ├─ references.bib
│     │  └─ logo.png
│     ├─ article/
│     └─ policy-brief/
├─ man/
├─ vignettes/
│  ├─ getting-started.Rmd
│  ├─ working-papers.Rmd
│  └─ customizing-branding.Rmd
├─ tests/
│  ├─ testthat/
│  │  ├─ test-metadata.R
│  │  ├─ test-validation.R
│  │  ├─ test-render-helpers.R
│  │  └─ test-project-creation.R
└─ README.md
