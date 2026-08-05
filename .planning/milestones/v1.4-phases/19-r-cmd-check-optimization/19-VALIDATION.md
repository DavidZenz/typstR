---
phase: 19
slug: r-cmd-check-optimization
status: validated
nyquist_compliant: false
wave_0_complete: true
created: 2026-06-02
---

# Phase 19 — Validation Strategy

> Validation contract for CRAN-style package checking and cross-platform CI readiness.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | R package checks via `devtools`; package tests use `testthat` |
| **Config file** | `tests/testthat.R`, `DESCRIPTION`, `.github/workflows/R-CMD-check.yaml` |
| **Quick run command** | `Rscript -e 'devtools::check(args = "--as-cran", document = FALSE, error_on = "warning", quiet = TRUE)'` |
| **Full suite command** | Same local CRAN-style check plus the five-target GitHub Actions `R-CMD-check` matrix |
| **Estimated runtime** | ~1 minute locally; CI duration is environment-dependent |

## Sampling Rate

- **After every task commit:** Run the local CRAN-style check command above.
- **After every plan wave:** Run the local check; after Wave 2, inspect the complete CI matrix.
- **Before `/gsd:verify-work`:** Confirm local 0/0/0 and the recorded CI matrix evidence.
- **Max feedback latency:** ~1 minute locally; CI is asynchronous.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 19-01-01 | 01 | 1 | CRAN-01 | T-19-01 | Build exclusions prevent project metadata from entering the package bundle. | static/build | `rg -n -F -e '^init\\.json$' -e '^\\.Rhistory$' -e '^\\.DS_Store$' .Rbuildignore` | ✅ | ✅ green |
| 19-01-02 | 01 | 1 | CRAN-01 | T-19-01 | Local `R CMD check --as-cran` completes with 0 errors, 0 warnings, and 0 notes. | integration | `Rscript -e 'check_res <- devtools::check(args = "--as-cran", document = FALSE, error_on = "warning", quiet = TRUE); quit(status = if (length(check_res$errors) == 0 && length(check_res$warnings) == 0 && length(check_res$notes) == 0) 0 else 1)'` | ✅ | ✅ green |
| 19-02-01 | 02 | 2 | CRAN-01 | T-19-02 | The committed changes trigger the R-CMD-check workflow. | CI smoke | GitHub Actions run linked below | ✅ | ⚠️ manual-only |
| 19-02-02 | 02 | 2 | CRAN-01 | T-19-02 | All configured macOS, Windows, and Ubuntu matrix targets complete with 0/0/0. | CI integration | GitHub Actions run linked below | ✅ | ⚠️ manual-only |

### Actual local result

The audit reran the Plan 19-01 check command on 2026-08-05. It completed successfully and reported:

```text
errors=0 warnings=0 notes=0
```

This is direct automated evidence for the local portion of `CRAN-01`.

## Wave 0 Requirements

Existing R/testthat and GitHub Actions infrastructure covers all phase requirements; no Wave 0 stubs or dependency installation were required.

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Workflow dispatch after the Phase 19 changes | CRAN-01 | Triggering and observing an external GitHub Actions run is outside the local test runner. | Confirm that the `R-CMD-check` workflow starts for the pushed Phase 19 changes. |
| Cross-platform 0/0/0 result | CRAN-01 | macOS, Windows, and the configured R versions are external CI environments; the archived result cannot be reproduced by the local command. | Inspect [GitHub Actions run 30987307046](https://github.com/DavidZenz/typstR/actions/runs/30987307046) and confirm Ubuntu devel/release/oldrel-1, macOS release, and Windows release each report 0 errors, 0 warnings, and 0 notes. |

The archived Phase 19 verification records that run 30987307046 completed successfully for all five configured targets. This evidence is preserved, but remains manual-only for Nyquist classification because it is an external historical CI observation.

## Supporting Verification Evidence

- Plan 19-01 recorded a local `devtools::check(args = '--as-cran', document = FALSE)` result of 0 errors, 0 warnings, and 0 notes.
- Plan 19-02 recorded the final cross-platform result in [GitHub Actions run 30987307046](https://github.com/DavidZenz/typstR/actions/runs/30987307046): Ubuntu/Linux, macOS, and Windows all passed with 0/0/0.
- The existing `19-VERIFICATION.md` remains the source of the archived phase verification and is not modified by this audit.

## Validation Sign-Off

- [x] All tasks have an automated or explicitly documented manual verification path.
- [x] Sampling continuity is defined for both plan waves.
- [x] Wave 0 infrastructure coverage is documented.
- [x] No watch-mode flags are used.
- [x] Local automated feedback latency is approximately one minute.
- [ ] `nyquist_compliant: true` — not set because cross-platform CI coverage is manual-only.

**Approval:** validated 2026-08-05; partial Nyquist compliance due to manual-only CI coverage.

## Validation Audit 2026-08-05

| Metric | Count |
|--------|-------|
| Gaps found | 4 task-level entries lacked current-schema coverage |
| Resolved | 2 automated local entries |
| Manual-only | 2 external CI entries |
| Escalated | 0 |

**Compliance classification:** `VALIDATED (PARTIAL)` — `CRAN-01` has direct green local automated evidence and preserved green five-target CI evidence, but the cross-platform portion is not locally automatable and therefore remains manual-only.
