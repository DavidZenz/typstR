# Project Milestones: typstR

## v1.5 First Release Reliability (Completed: 2026-10-17)

**Package:** 0.1.0, unsubmitted. Planning milestone completion is not a CRAN release.
**Scope:** 5 phases, 6 requirements, 5 retrospective execution records.

- Reliable public scaffold-to-PDF input/project context and shared manuscript validation.
- Real PDF assurance discovered/fixed branding, affiliation and nested-resource defects.
- Six clean installed-tarball renders, meaningful text and representative visual review.
- All five hosted package targets, required PDF assurance and site build passed.
- Manual benchmarks recorded; historical discrepancy investigated without speed claims.
- Historical phase evidence preserved/reconciled and deferred backlog restored.
- Verifiable source-tarball/check evidence and maintainer checklist prepared.

**Evidence:** [audit](v1.5-MILESTONE-AUDIT.md), [handoff](phases/25-release-handoff/25-VERIFICATION.md).
**Check:** 0 errors, 0 warnings, 2 explained local notes; 484 test passes.
**Tarball SHA-256:** `9d7cf19b24c7fb4a9a3919e01b57be6b3b811760125b9b02796e425c7c0a2cb0`.
**Next release action:** final maintainer review, then explicit authorization before CRAN submission.

---

## v1.4 Hardening and CRAN Submission Readiness (Shipped: 2026-08-05)

**Phases completed:** 4 phases, 7 plans, 0 tasks

**Key accomplishments:**

- Audited the dependency footprint and moved the runtime `yaml` dependency into `Imports`.
- Hardened the test suite for CI environments without Quarto or Typst.
- Stabilized CI timing assertions and deterministic diagnostic ordering on Windows.
- Verified clean local and five-target GitHub Actions `R CMD check` results.
- Prepared CRAN submission metadata for package version 0.1.0.

**Stats:**

- 4 phases, 7 plans
- Local `devtools::check(args = "--as-cran")`: 0 errors, 0 warnings, 0 notes
- Final R-CMD-check matrix: Ubuntu devel/release/oldrel-1, macOS release, Windows release - all passed
- CI evidence: https://github.com/DavidZenz/typstR/actions/runs/30987878100

---

## v1.0 Foundation and CRAN Release (Shipped: 2026-03-23)

**Delivered:** CRAN-ready typstR package with working-paper, article, and policy-brief outputs backed by modular Typst templates and YAML-driven branding.

**Phases completed:** 1-4 (18 plans total)

**Key accomplishments:**

- End-to-end scaffold + render pipeline for Quarto + Typst documents
- Metadata helper layer and YAML interface for manuscript fields
- Modular Typst template system with institutional branding hooks
- Test, documentation, and package hardening for release readiness

**Stats:**

- 111 files changed (including planning artifacts)
- ~14,700 lines touched (including planning artifacts)
- 4 phases, 18 plans

**Git range:** Not recorded in archived artifact

**What's next:** v1.1 Reliability and Onboarding Polish

---
