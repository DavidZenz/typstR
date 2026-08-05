---
phase: 18
slug: cross-platform-test-hardening
status: validated
nyquist_compliant: false
wave_0_complete: true
created: 2026-08-05
---

# Phase 18 — Validation Strategy

> Per-phase validation contract for cross-platform R CMD check coverage and graceful behavior when Quarto/Typst are unavailable.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | GitHub Actions with `r-lib/actions/check-r-package@v2`; package tests use `testthat` |
| **Config file** | `.github/workflows/R-CMD-check.yaml`; `tests/testthat.R` |
| **Quick run command** | `test -f .github/workflows/R-CMD-check.yaml && ! grep -q "setup-quarto" .github/workflows/R-CMD-check.yaml` |
| **Full suite command** | GitHub Actions workflow `R-CMD-check` (five matrix targets); local CRAN-style check recorded in `18-VERIFICATION.md` |
| **Estimated runtime** | External CI; not bounded in the archived evidence |

The quick static check was rerun during this audit and passed. The archived verification also records a local CI-mode suite with 352 passes and 9 expected skips, plus a local CRAN-style check with 0 errors, 0 warnings, and 0 notes.

## Sampling Rate

- **After Plan 18-01:** Run the workflow-file existence/Quarto-omission check.
- **After Plan 18-02:** Inspect the GitHub Actions matrix and confirm every configured OS/R target is green.
- **Before phase acceptance:** Confirm Quarto-dependent tests use availability guards and review the final matrix run.
- **Max feedback latency:** Not applicable to the external GitHub Actions gate.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 18-01-01 | 01 | 1 | CRAN-04 | T-18-01 | R-CMD-check workflow exists and does not install/configure Quarto. | smoke | `test -f .github/workflows/R-CMD-check.yaml && ! grep -q "setup-quarto" .github/workflows/R-CMD-check.yaml` | ✅ | ✅ green |
| 18-02-01 | 02 | 2 | CRAN-04 | T-18-02 | Tests pass or skip gracefully without Quarto/Typst across macOS, Windows, and Ubuntu. | integration / CI acceptance | GitHub Actions run [30987307046](https://github.com/DavidZenz/typstR/actions/runs/30987307046) | ✅ | ✅ green (external evidence) |

## Wave 0 Requirements

Existing package `testthat` infrastructure and the phase-01 workflow check cover the phase requirements; no Wave 0 test stubs or dependency installation were required.

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Cross-platform GitHub Actions acceptance gate is green for Ubuntu devel, Ubuntu release, Ubuntu oldrel-1, macOS release, and Windows release. | CRAN-04 | The result depends on hosted runners and an external GitHub Actions execution; it cannot be reproduced by a local deterministic command. | Open [run 30987307046](https://github.com/DavidZenz/typstR/actions/runs/30987307046), confirm all five matrix jobs completed successfully, and inspect the logs for graceful Quarto/Typst handling. |

`CRAN-HYGIENE` is retained only as a legacy label from the prior validation document; it is not a Phase 18 requirement in the phase context, plans, or milestone requirements. Its relevant CI evidence is represented by the `CRAN-04` row above.

## Preserved Verification Evidence

- `.github/workflows/R-CMD-check.yaml` defines macOS, Windows, Ubuntu release, Ubuntu devel, and Ubuntu oldrel-1 jobs and omits `setup-quarto`.
- Quarto-dependent test paths use availability guards; the archived local CI-mode suite completed with 352 passes and 9 expected skips.
- The archived local CRAN-style check completed with 0 errors, 0 warnings, and 0 notes.
- GitHub Actions [run 30987307046](https://github.com/DavidZenz/typstR/actions/runs/30987307046) completed successfully for all five configured targets.
- Earlier platform-sensitive issues were resolved by guarding CI timing assertions and normalizing diagnostic path separators, as documented in `18-VERIFICATION.md`.

## Validation Sign-Off

- [x] All phase tasks are mapped to verification evidence.
- [x] Plan 18-01 has an automated verification command that was rerun successfully.
- [x] Plan 18-02 has documented external CI evidence and is explicitly marked manual-only for Nyquist purposes.
- [x] No watch-mode flags are used.
- [ ] `nyquist_compliant: true` — not set because the decisive cross-platform acceptance gate is external/manual.

**Approval:** validated 2026-08-05

## Validation Audit 2026-08-05

| Metric | Count |
|--------|-------|
| Requirements audited | 1 |
| Tasks audited | 2 |
| Gaps found | 2 |
| Resolved with automated evidence | 1 |
| Resolved with archived external evidence | 1 |
| Manual-only behaviors | 1 |
| Escalated blockers | 0 |

**Compliance classification:** VALIDATED (PARTIAL Nyquist compliance): 1 task has rerunnable local automated evidence; 1 task relies on the archived external GitHub Actions gate. The requirement is satisfied by the recorded evidence, but strict `nyquist_compliant` remains `false`.
