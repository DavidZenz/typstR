# typstR 0.1.0

First release preparation; CRAN submission and acceptance are not yet recorded.
Planning milestones v1.0–v1.5 are internal identifiers, not package versions.

## Audit corrections

- Fix singleton keyword/JEL rendering, pass through Quarto page, font, numbering,
  and TOC controls, and apply title-font with explicit branding precedence.
- Consolidate publication variants and implement lettered academic appendices
  with a bundled filter while preserving import paths and public R returns.
- Validate constructor metadata consistently, distinguish cross-references from
  citations, and reject misplaced anonymization settings.
- Preserve literal scaffold titles, implement scaffold opening, and resolve
  actual Quarto output paths before opening rendered PDFs.
- Add PDF content/property assertions and required Linux minimum/current and
  Windows render lanes. Early Quarto 1.4 uses standalone Typst on PATH.

## Test suite simplification

- Keep ordinary tests independent of Quarto and Poppler; consolidate scaffold,
  validation, and render-path regressions using package loading and scoped mocks.
- Reduce required PDF assurance from fifteen to nine scenarios per toolchain,
  retaining all three variants and the Linux minimum/current and Windows lanes.
- Move benchmarks and baseline validation to the explicit developer command;
  rely on R CMD check for documentation structure instead of custom Rd tests.

## First release reliability (planning milestone v1.5)

- Resolve manuscript and project context before preflight so documented file
  paths, directory input, spaces and outside-project rendering work reliably.
- Add shared `validate_manuscript()` checks for static YAML, supported formats,
  publication metadata and local resources, with stable ordered diagnostics.
- Require dedicated Quarto-enabled PDF assurance and preserve render artifacts;
  keep ordinary package checks usable without Quarto.
- Separate performance measurement from ordinary test runs and retain historical
  benchmark contracts without making unmeasured speed claims.

## Branding and release hardening (planning milestones v1.3–v1.4)

- Add a documentation logo, favicon, branded styling, advanced examples and a
  comparison of the three publication variants.
- Harden checks for environments without Quarto, stabilize Windows diagnostics,
  minimize runtime dependencies and prepare submission metadata.

## Documentation (planning milestone v1.2)

- Polished the documentation surface around one onboarding-first story spanning
  the README, pkgdown home page, and articles.
- Added a stricter exported-reference audit so incomplete help pages are caught
  before regenerated Rd files ship.
- Started the pkgdown/news/build-ignore foundation needed for the documentation
  and website polish milestone.

## Reliability and onboarding (planning milestone v1.1)

- Added structured diagnostics with stable codes, ordering, and payload fields
  for validation and render failures.
- Introduced pre-render environment validation with explicit Quarto, Typst,
  version-floor, and extension checks.
- Locked first-run scaffold reliability across working paper, article, and
  policy brief formats, then added measured performance regression coverage.
- Closed the milestone with supported-environment evidence and audit-complete
  validation artifacts.

## Foundation (planning milestone v1.0)

- Shipped the initial typstR package with working paper, article, and policy
  brief scaffolds plus Typst-backed Quarto output formats.
- Added manuscript metadata helpers, publication helpers, and YAML-driven
  template integration for research documents.
- Hardened the package with tests, starter documentation, and CRAN-ready
  packaging conventions.
