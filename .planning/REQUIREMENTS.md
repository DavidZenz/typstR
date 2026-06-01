# Requirements: typstR

**Defined:** 2026-06-01
**Core Value:** Users can go from `create_working_paper("my-paper")` to a polished, branded PDF in minutes — no Typst or LaTeX knowledge required.

## v1.2 Requirements

Requirements for the v1.2 documentation and website polish milestone. Each will map to a roadmap phase.

### Documentation Foundation

- [ ] **DOCS-01**: New users can understand typstR's value, installation path, and system requirements from the README homepage without leaving the first screenful.
- [ ] **DOCS-02**: New users can follow one canonical install -> scaffold -> render onboarding flow that is presented consistently across the README, pkgdown home page, and getting-started article.
- [ ] **DOCS-03**: Users can rely on all existing vignettes to build successfully in pkgdown without requiring Quarto or Typst on the docs build runner.
- [ ] **DOCS-04**: Users can browse public function documentation with meaningful titles, descriptions, parameter docs, and runnable examples for every exported help page included in the site.
- [ ] **DOCS-05**: Users can view a changelog page that summarizes shipped milestones through v1.2.

### Site Experience

- [ ] **SITE-01**: Users can access a publishable pkgdown website at the project's public docs URL.
- [ ] **SITE-02**: Users can navigate the site through clear top-level entry points for Home, Get Started, Reference, Articles, and Changelog.
- [ ] **SITE-03**: Users can browse the reference index through named groups that match the package's main jobs instead of a flat alphabetical list.
- [ ] **SITE-04**: Users can find all three existing vignettes from the site navigation in onboarding-first order.
- [ ] **SITE-05**: Users see a release-style public docs site without a visible pkgdown development badge while the package remains on its current development version.

### Delivery and Publishing

- [ ] **SHIP-01**: Maintainers can generate the site from the existing repository structure without manual copying of reference pages, articles, or assets.
- [x] **SHIP-02
**: Maintainers can validate the pkgdown configuration locally with zero pkgdown warnings before enabling deployment.
- [ ] **SHIP-03**: Maintainers can publish the site automatically from GitHub Actions and GitHub Pages on pushes to `main`.
- [ ] **SHIP-04**: Maintainers can keep the site build CRAN-safe by excluding pkgdown-only artifacts from the package tarball while preserving all required source docs in git.

## v2 Requirements

Deferred follow-up work that may matter later but is not part of the v1.2 roadmap.

### Visual Branding

- **BRAND-01**: Users see a custom site logo, favicon, and branded accent styling.
- **BRAND-02**: Users see rendered output screenshots or other rich visual previews on landing pages.

### Extended Docs Surface

- **EXT-01**: Users can browse newly written articles beyond the three existing vignettes.
- **EXT-02**: Users can compare output formats through a dedicated format-comparison guide.
- **EXT-03**: Users can switch between multiple documentation versions (release vs development).

## Out of Scope

Explicit exclusions for v1.2 to prevent scope creep.

| Feature | Reason |
|---------|--------|
| New publication features or R package capabilities | v1.2 is a documentation/discoverability milestone, not a product-feature milestone |
| New vignettes beyond the existing three | Polishing and publishing the current docs surface is the shortest path to a live site |
| Custom hosting outside GitHub Pages | pkgdown + GitHub Pages is the simplest, canonical setup for this repo |
| Custom search services or external doc indexing | Built-in pkgdown search is sufficient for this package size |
| Logo, favicon, or custom CSS branding work | Valuable polish, but not required to launch a useful public docs site |
| Quarto `.qmd` vignette migration | Existing `.Rmd` vignettes already fit pkgdown and avoid extra CI dependencies |
| Embedded rendered PDF screenshots or image-heavy showcase pages | Adds CI and content-maintenance complexity without blocking first-use onboarding |

## Traceability

Which phases cover which requirements.

| Requirement | Phase | Status |
|-------------|-------|--------|
| DOCS-01 | Phase 11 | Pending |
| DOCS-02 | Phase 11 | Pending |
| DOCS-03 | Phase 11 | Pending |
| DOCS-04 | Phase 11 | Pending |
| DOCS-05 | Phase 11 | Pending |
| SITE-01 | Phase 13 | Pending |
| SITE-02 | Phase 12 | Pending |
| SITE-03 | Phase 12 | Pending |
| SITE-04 | Phase 12 | Pending |
| SITE-05 | Phase 12 | Pending |
| SHIP-01 | Phase 12 | Pending |
| SHIP-02 | Phase 12 | Pending |
| SHIP-03 | Phase 13 | Pending |
| SHIP-04 | Phase 11 | Pending |

**Coverage:**
- v1.2 requirements: 14 total
- Mapped to phases: 14
- Unmapped: 0 ✓

---
*Requirements defined: 2026-06-01*
*Last updated: 2026-06-01 after roadmap creation (v1.2 phases 11-13)*
