# typstR 0.1.0

First release preparation; CRAN submission and acceptance are not yet recorded.
Planning milestones v1.0–v1.5 are internal identifiers, not package versions.

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
