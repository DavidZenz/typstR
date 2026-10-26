# Phase 13 Context: CI/CD Deployment and Live Site

## Goal
Automate the deployment of the typstR pkgdown site via GitHub Actions to GitHub Pages and confirm the live public URL is fully functional.

## Requirements
- SITE-01: GitHub Actions workflow for automated pkgdown deployment.
- SHIP-03: Live site publicly accessible at https://davidzenz.github.io/typstR/.

## Success Criteria
1. GitHub Actions workflow (`pkgdown.yaml`) is present and configured with `contents: write` permissions.
2. Push to `main` triggers a successful build and deploy to the `gh-pages` branch.
3. Live site loads correctly and all navigation links (Home, Get Started, Reference, Articles, Changelog) are functional.
4. All article pages render correctly on the live site.

## Constraints
- Use canonical `r-lib/actions` pkgdown workflow.
- Deploy to `gh-pages` branch.
- No Quarto/Typst required in CI runner (vignettes are .Rmd).
