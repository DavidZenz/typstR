---
phase: 20
slug: cran-submission-preparation
status: validated
nyquist_compliant: true
wave_0_complete: true
created: 2026-06-02
validated: 2026-08-05
---

# Phase 20 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

Phase 20 validation covers the CRAN submission artifacts, release metadata, local CRAN-style checking, and the milestone-closure evidence that ties the phase to the final cross-platform CI result.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | R package checks (`devtools` / `R CMD check`), `testthat` package suite, and POSIX shell assertions |
| **Config file** | `DESCRIPTION`, `.github/workflows/R-CMD-check.yaml`, `tests/testthat.R` |
| **Quick run command** | `grep -F "This is a new submission." cran-comments.md && Rscript -e 'd <- read.dcf("DESCRIPTION"); stopifnot(d[1, "Version"] == "0.1.0")'` |
| **Full suite command** | `Rscript -e 'devtools::check(args = "--as-cran", document = FALSE, error_on = "warning")'` |
| **Estimated runtime** | ~2–5 minutes locally; CI duration varies by target |

## Sampling Rate

- **After every task commit:** Run the quick artifact/version checks.
- **After every plan wave:** Run the full `devtools::check(..., --as-cran)` command.
- **Before `/gsd:verify-work`:** Confirm the local 0/0/0 check and final CI evidence remain recorded in `20-VERIFICATION.md`.
- **Max feedback latency:** 300 seconds locally.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 20-01-01 | 01 | 1 | CRAN-03 | T-20-02 | `cran-comments.md` identifies a new submission and records 0 errors, 0 warnings, and 0 notes without sensitive local paths. | smoke | `grep -F "This is a new submission." cran-comments.md && grep -F "0 errors | 0 warnings | 0 notes" cran-comments.md` | ✅ existing artifact | ✅ green |
| 20-01-02 | 01 | 1 | CRAN-03 / SHIP-READY | T-20-01 | `DESCRIPTION` reports release version `0.1.0`, and the release candidate passes the local CRAN-style check with 0/0/0. | integration | `Rscript -e 'd <- read.dcf("DESCRIPTION"); stopifnot(d[1, "Version"] == "0.1.0")'`; `Rscript -e 'devtools::check(args = "--as-cran", document = FALSE, error_on = "warning")'` | ✅ existing package | ✅ green |
| 20-02-01 | 02 | 2 | CRAN-01 / CRAN-02 / CRAN-03 / CRAN-04 / MILESTONE-AUDIT | T-20-03 | The milestone audit records evidence for all four CRAN requirements and links the final five-target CI run. | integration | `test -f .planning/v1.4-MILESTONE-AUDIT.md && grep -q "CRAN-01" .planning/v1.4-MILESTONE-AUDIT.md && grep -q "CRAN-02" .planning/v1.4-MILESTONE-AUDIT.md && grep -q "CRAN-03" .planning/v1.4-MILESTONE-AUDIT.md && grep -q "CRAN-04" .planning/v1.4-MILESTONE-AUDIT.md` | ✅ existing audit | ✅ green |
| 20-02-02 | 02 | 2 | CRAN-01 / CRAN-02 / CRAN-03 / CRAN-04 | T-20-03 | Project tracking records v1.4 as shipped after the requirement audit and phase completion. | smoke | `grep -F "SHIPPED **v1.4" .planning/ROADMAP.md && grep -F "status: shipped" .planning/STATE.md` | ✅ existing tracking | ✅ green |

### Evidence retained from phase verification

- `20-VERIFICATION.md` records `devtools::check(args = "--as-cran", document = FALSE, error_on = "warning")` completing with 0 errors, 0 warnings, and 0 notes.
- `20-VERIFICATION.md` records the final five-target green GitHub Actions run [30987307046](https://github.com/DavidZenz/typstR/actions/runs/30987307046), covering Ubuntu devel, Ubuntu release, Ubuntu oldrel-1, macOS release, and Windows release.
- The phase verification report records all six observable truths as VERIFIED and `behavior_unverified: 0`.
- Current static checks executed during this audit passed for the submission text, 0/0/0 comment result, `DESCRIPTION` version, and four CRAN requirement references in the milestone audit.

## Wave 0 Requirements

Existing R package and shell-check infrastructure covers all phase requirements; no new fixtures or test stubs are required.

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| None | — | The cross-platform result is produced by automated GitHub Actions jobs, and the archived verification report records the authenticated final run. | No manual-only action remains for this phase. |

## Validation Sign-Off

- [x] All tasks have an `<automated>` verify block or existing Wave 0 dependencies.
- [x] Sampling continuity: no 3 consecutive tasks without automated verification.
- [x] Wave 0 covers all missing references.
- [x] No watch-mode flags.
- [x] Feedback latency is within the stated local target for quick checks.
- [x] `nyquist_compliant: true` is set in frontmatter.

**Approval:** approved 2026-08-05

## Validation Audit 2026-08-05

| Metric | Count |
|--------|-------|
| Gaps found | 1 documentation-schema gap |
| Resolved | 1 |
| Escalated | 0 |
| Manual-only items | 0 |

The existing validation artifact was reconciled to the current Nyquist schema. No implementation or test-infrastructure defect was found, and no implementation files were modified. The phase is **NYQUIST-COMPLIANT** based on the passing archived behavioral verification and the audit-time static checks above.

## Preserved Phase Gate Evidence

Phase 20 passed because:

- `0.1.0` is the package version.
- `cran-comments.md` is fully drafted and states `0 errors | 0 warnings | 0 notes` for the new submission.
- Final local `R CMD check --as-cran` is **0/0/0**.
- `.planning/v1.4-MILESTONE-AUDIT.md` shows evidence for all four CRAN requirements, backed by the final green CI run.
