---
phase: 12-site-configuration-and-local-validation
status: passed
verified: 2026-10-17
retrospective: true
requirements_completed: [SITE-02, SITE-03, SITE-04, SITE-05, SHIP-01, SHIP-02]
---

# Retrospective verification: phase 12

## Scope and provenance

This report reconciles existing source and historical evidence. It was not present
at original milestone closure. The historical summaries/audits are preserved,
including their limitations; a statement in a summary is attributed evidence, not
a new observation.

Historical source: [12-03-SUMMARY.md](12-03-SUMMARY.md); milestone audit:
[original v1.2 audit](../../../v1.2-MILESTONE-AUDIT.md).

## Evidence

_pkgdown.yml has grouped references, Get Started navigation, article ordering and release display mode. Fresh local site build/check passed on 2026-10-17. The historical summary contains a conflicting 2024 date; preserve it as an unreliable timestamp, not proof of completion date.

Current local command: `pkgdown::check_pkgdown(); pkgdown::build_site(new_process=FALSE, install=FALSE, preview=FALSE)`.
R 4.6.1, Pandoc 3.6.4, current site source; exited 0 without warnings.
The full test suite passed with real Quarto and with Quarto deliberately unavailable;
required render assurance is recorded separately for milestone v1.5.

## Limits

Local generated HTML proves local content/build integration. It does not prove
current hosted-site reachability, deployment, visual accessibility, or CRAN status.
See [reconciliation ledger](../../../RECONCILIATION.md).
