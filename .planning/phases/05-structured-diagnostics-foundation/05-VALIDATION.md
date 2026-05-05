---
phase: 05
slug: structured-diagnostics-foundation
status: passed
nyquist_compliant: true
wave_0_complete: true
created: 2026-04-01
---

# Phase 05 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | testthat 3.x |
| **Config file** | `tests/testthat.R` + `DESCRIPTION (Config/testthat/edition: 3)` |
| **Quick run command** | `Rscript -e "testthat::test_file('tests/testthat/test-render-guards.R')"` |
| **Full suite command** | `Rscript -e "testthat::test_dir('tests/testthat')"` |
| **Estimated runtime** | ~45 seconds |

---

## Sampling Rate

- **After every task commit:** Run `Rscript -e "testthat::test_file('tests/testthat/test-render-guards.R')"`
- **After every plan wave:** Run `Rscript -e "testthat::test_dir('tests/testthat')"`
- **Before `$gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 05-01-01 | 01 | 1 | DIAG-01 | unit | `Rscript -e "testthat::test_file('tests/testthat/test-render-guards.R')"` | ✅ | ✅ green |
| 05-01-02 | 01 | 1 | DIAG-01 | unit | `Rscript -e "testthat::test_dir('tests/testthat')"` | ✅ | ✅ green |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Existing infrastructure covers all phase requirements.

---

## Manual-Only Verifications

All phase behaviors have automated verification.

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 60s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** approved. Phase 05 verification already passed, and the validation bookkeeping now matches the existing automated evidence.
