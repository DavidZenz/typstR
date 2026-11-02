# Phase 13 Research: CI/CD Deployment and Live Site

## Overview
Phase 13 handles the automation and public launch of the documentation site. It relies on standard GitHub Actions patterns for R packages.

## Key Research Findings
- **Workflow Scaffolding:** `usethis::use_pkgdown_github_pages()` is the recommended command. It creates `.github/workflows/pkgdown.yaml`.
- **Permissions:** The workflow requires `permissions: contents: write` to allow the runner to push built artifacts to the `gh-pages` branch.
- **Environment:** The CI runner does *not* need Quarto or Typst because vignettes were carefully guarded in Phase 11 to only use `knitr` and not execute render commands in CI.
- **GitHub Pages Activation:** While GHA handles the deployment to `gh-pages`, the user must ensure that the GitHub Repository Settings are configured to serve from the `gh-pages` branch (Source: "Deploy from a branch").

## Pitfalls to Avoid
- **Permission Denied:** Failing to include `contents: write` in the workflow will cause the deploy step to fail.
- **Missing gh-pages Branch:** The first run of the workflow will create the branch if it doesn't exist, but the Pages setting cannot be finalized until the branch is present.
- **Quarto/Typst in CI:** If a vignette is accidentally marked `eval=TRUE` for a Quarto-dependent chunk, the build will fail in CI. Phase 11 validation should have mitigated this.

## Technical Details
- Deploy branch: `gh-pages`.
- Deploy target: root `/` of the branch.
- URL: `https://davidzenz.github.io/typstR/`.
