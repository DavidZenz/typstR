# Requirements: typstR

**Defined:** 2026-06-01
**Core Value:** Users can go from `create_working_paper("my-paper")` to a polished, branded PDF in minutes — no Typst or LaTeX knowledge required.

## v1.4 Requirements

Requirements for the v1.4 Hardening and CRAN Submission Readiness milestone.

### CRAN Hardening

- [ ] **CRAN-01**: R CMD check --as-cran passes with 0 errors, 0 warnings, 0 notes on local, macOS, Windows, and Linux CI.
- [ ] **CRAN-02**: Dependency footprint is minimized (Review Imports/Suggests).
- [ ] **CRAN-03**: `cran-comments.md` is prepared for submission.
- [ ] **CRAN-04**: Test coverage is sufficient for CRAN and runs robustly across platforms without Quarto/Typst failures.

## v2 Requirements (Deferred)

Requirements that matter for long-term growth but are not yet scheduled.

- **EXT-03**: Users can switch between multiple documentation versions (release vs development).
- **BRAND-03**: Users see rendered output screenshots or other rich visual previews on landing pages.

## Out of Scope (v1.4)

| Feature | Reason |
|---------|--------|
| Multi-version docs | Too much infrastructure overhead for the current package stage |
| Embedded PDF screenshots | Adds CI complexity (Quarto in GHA) that we intentionally avoided in v1.2 |

---
*Requirements defined: 2026-06-01*
*Milestone: v1.4 Hardening and CRAN Submission Readiness*

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| CRAN-02 | Phase 17 | Pending |
| CRAN-04 | Phase 18 | Pending |
| CRAN-01 | Phase 19 | Pending |
| CRAN-03 | Phase 20 | Pending |
