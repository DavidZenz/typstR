# Roadmap: typstR

## Overview

**Active milestone:** None. v1.5 First Release Reliability completed 2026-10-17; maintainer release review pending.
Package version: 0.1.0. Milestone numbers are internal planning identifiers.

**Next release action:** Review draft PR #1, the source tarball/hash and evidence; explicitly authorize CRAN submission after final maintainer review.

## v1.5 First Release Reliability

| Phase | Scope | Requirements | Status |
|---|---|---|---|
| 21 | Resolve manuscript/project context and repair onboarding | REL-01 | Complete |
| 22 | Shared manuscript validation and resource semantics | VAL-02 | Complete |
| 23 | Required real renders and separate performance assurance | RENDER-01, PERF-02 | Complete |
| 24 | Reconcile historical evidence, documentation and backlog | PLAN-01 | Complete |
| 25 | Current source-package verification and CRAN handoff | CRAN-05 | Complete |

Acceptance criteria: [REQUIREMENTS.md](REQUIREMENTS.md).
Each phase must record verification evidence before being marked complete.


## v1.5 Phase Details

- [x] **Phase 21: Resolve manuscript and project context** — verified; see phase report.
- [x] **Phase 22: Shared manuscript validation** — verified; see phase report.
- [x] **Phase 23: Required PDF and separate benchmark assurance** — verified; see phase report.
- [x] **Phase 24: Reconcile planning and user documentation** — verified; see phase report.
- [x] **Phase 25: Verifiable first-release handoff** — all five hosted targets and required PDF/site jobs passed.

### Phase 21: Resolve manuscript and project context

**Goal:** Resolve file/directory/NULL input before preflight; retain clear missing/ambiguous input diagnostics and test all scaffolders, spaces and outside-project invocation.
**Depends on:** Nothing (first phase)
**Requirements:** REL-01
**Plans:** 1 plan

- [x] 21-01-PLAN.md — implementation recorded; consult verification for external gates.

### Phase 22: Shared manuscript validation

**Goal:** Share standalone/render validation; check static YAML, supported format/variant, metadata and local resources; document supported inheritance and unsupported dynamic configuration.
**Depends on:** Phase 21
**Requirements:** VAL-02
**Plans:** 1 plan

- [x] 22-01-PLAN.md — implementation recorded; consult verification for external gates.

### Phase 23: Required PDF and separate benchmark assurance

**Goal:** Require six installed-package public-helper PDFs with meaningful text and visual review, pinned tools and retained artifacts. Separate measured benchmarks from normal tests; preserve baselines and investigate discrepancies.
**Depends on:** Phase 22
**Requirements:** RENDER-01, PERF-02
**Plans:** 1 plan

- [x] 23-01-PLAN.md — implementation recorded; consult verification for external gates.

### Phase 24: Reconcile planning and user documentation

**Goal:** Preserve historical records, add qualified retrospective verification, restore deferred backlog, distinguish planning and package versions, align user docs and verify the local site build.
**Depends on:** Phase 23
**Requirements:** PLAN-01
**Plans:** 1 plan

- [x] 24-01-PLAN.md — implementation recorded; consult verification for external gates.

### Phase 25: Verifiable first-release handoff

**Goal:** Build/check the source tarball, install and render in a clean session, explain check notes and prepare the maintainer checklist. Verify hosted checks; do not submit without explicit maintainer authorization.
**Depends on:** Phase 24
**Requirements:** CRAN-05
**Plans:** 1 plan

- [x] 25-01-PLAN.md — implementation recorded; consult verification for external gates.

## Milestones

- COMPLETE **v1.5 First Release Reliability** - Phases 21–25 (2026-10-17); package 0.1.0 unsubmitted.
- SHIPPED **v1.0 Foundation and CRAN Release** - Phases 1-4 (2026-03-23)
- SHIPPED **v1.1 Reliability and Onboarding Polish** - Phases 5-10 (2026-05-06)
- SHIPPED **v1.2 Documentation and Website Polish** - Phases 11-13 (2026-06-01)
- SHIPPED **v1.3 Branding and Documentation Depth** - Phases 14-16 (2026-06-01)
- SHIPPED **v1.4 Hardening and CRAN Submission Readiness** - Phases 17-20 (2026-08-05) - [archive](milestones/v1.4-ROADMAP.md)

## Completed Phase Details

<details>
<summary>v1.4 Hardening and CRAN Submission Readiness (Phases 17-20)</summary>

- [x] Phase 17: Dependency Review and Cleanup (1/1 plan)
- [x] Phase 18: Cross-Platform Test Hardening (2/2 plans)
- [x] Phase 19: R CMD Check Optimization (2/2 plans)
- [x] Phase 20: CRAN Submission Preparation (2/2 plans)

Full phase plans, summaries, validation, and verification are archived under `milestones/v1.4-phases/`.

</details>

## Progress

| Milestone | Phases | Plans | Status | Completed |
|-----------|--------|-------|--------|-----------|
| v1.0 | 1-4 | 18/18 | Complete | 2026-03-23 |
| v1.1 | 5-10 | 12/12 | Complete | 2026-05-06 |
| v1.2 | 11-13 | 9/9 | Complete | 2026-06-01 |
| v1.3 | 14-16 | 7/7 | Complete | 2026-06-01 |
| v1.4 | 17-20 | 7/7 | Complete | 2026-08-05 |
| v1.5 | 21-25 | 5/5 retrospective records | Handoff ready | 2026-10-17 |

## Backlog

See [BACKLOG.md](BACKLOG.md): BRAND-03 rendered previews (P2), EXT-03 versioned docs (P3).
