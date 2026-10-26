---
phase: 13-ci-cd-deployment-and-live-site
status: human_needed
verified: 2026-10-17
retrospective: true
requirements_completed: [SITE-01, SHIP-03]
---

# Retrospective verification: phase 13

## Scope and provenance

This report reconciles existing source and historical evidence. It was not present
at original milestone closure. The historical summaries/audits are preserved,
including their limitations; a statement in a summary is attributed evidence, not
a new observation.

Historical source: [13-02-SUMMARY.md](13-02-SUMMARY.md); milestone audit:
[original v1.2 audit](../../../v1.2-MILESTONE-AUDIT.md).

## Evidence

Deployment workflow source is present and correctly gates publishing on non-PR events. Fresh local site build passes. The historical summary reports 200 responses and gh-pages deployment on 2026-06-01, but does not retain raw HTTP responses/run IDs. Current public site reachability/deployment is NOT independently revalidated; verify the exact release deployment before publishing release docs.

Current local command: `pkgdown::check_pkgdown(); pkgdown::build_site(new_process=FALSE, install=FALSE, preview=FALSE)`.
R 4.6.1, Pandoc 3.6.4, current site source; exited 0 without warnings.
The full test suite passed with real Quarto and with Quarto deliberately unavailable;
required render assurance is recorded separately for milestone v1.5.

## Limits

Local generated HTML proves local content/build integration. It does not prove
current hosted-site reachability, deployment, visual accessibility, or CRAN status.
See [reconciliation ledger](../../../RECONCILIATION.md).
