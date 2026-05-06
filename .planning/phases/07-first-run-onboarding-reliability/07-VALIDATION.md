---
phase: 07
slug: first-run-onboarding-reliability
status: passed
nyquist_compliant: true
wave_0_complete: true
created: 2026-04-01
---

# Phase 07 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | testthat (edition 3) |
| **Config file** | `tests/testthat.R`, `DESCRIPTION` (`Config/testthat/edition: 3`) |
| **Quick run command** | `Rscript -e "testthat::test_file('tests/testthat/test-scaffolding.R'); testthat::test_file('tests/testthat/test-yaml-integration.R')"` |
| **Full suite command** | `Rscript -e "testthat::test_local('.')"` |
| **Estimated runtime** | ~120 seconds on supported Quarto-enabled setup |

---

## Sampling Rate

- **After every task commit:** `Rscript -e "testthat::test_file('tests/testthat/test-scaffolding.R')"`
- **After every plan wave:** `Rscript -e "testthat::test_file('tests/testthat/test-yaml-integration.R')"`
- **Before `$gsd-verify-work`:** `Rscript -e "testthat::test_local('.')"`
- **Max feedback latency:** 90 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 07-01-01 | 01 | 1 | ONB-01 | unit | `Rscript -e "testthat::test_file('tests/testthat/test-scaffolding.R')"` | ✅ | ✅ green |
| 07-01-02 | 01 | 1 | ONB-01 | integration | `Rscript -e "testthat::test_file('tests/testthat/test-yaml-integration.R')"` | ✅ | ✅ green |
| 07-02-01 | 02 | 2 | ONB-01 | integration | `Rscript -e "testthat::test_file('tests/testthat/test-yaml-integration.R')"` | ✅ | ✅ green |
| 07-02-02 | 02 | 2 | ONB-01 | regression | `Rscript -e "testthat::test_local('.')"` | ✅ | ✅ green |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Existing infrastructure covers all phase requirements.

---

## Manual-Only Verifications

None. Supported-environment onboarding validation and render execution were captured during Phase 10 closure.

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 90s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** approved. Supported-environment onboarding validation and render evidence are now recorded, so Phase 07 no longer carries a runtime-verification deferral.
