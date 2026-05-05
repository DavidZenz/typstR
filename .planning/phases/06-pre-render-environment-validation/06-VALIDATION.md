---
phase: 06
slug: pre-render-environment-validation
status: passed
nyquist_compliant: true
wave_0_complete: true
created: 2026-04-01
---

# Phase 06 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | testthat (edition 3) |
| **Config file** | `DESCRIPTION` (`Config/testthat/edition: 3`), `tests/testthat.R` |
| **Quick run command** | `Rscript -e 'testthat::test_file("tests/testthat/test-validation-environment.R")'` |
| **Full suite command** | `Rscript -e 'testthat::test_local(".")'` |
| **Estimated runtime** | ~35 seconds |

---

## Sampling Rate

- **After every task commit:** Run `Rscript -e 'testthat::test_file("tests/testthat/test-validation-environment.R")'`
- **After every plan wave:** Run `Rscript -e 'testthat::test_file("tests/testthat/test-render-guards.R"); testthat::test_file("tests/testthat/test-input-diagnostics.R")'`
- **Before `$gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 06-01-01 | 01 | 1 | VAL-01 | unit | `Rscript -e 'testthat::test_file("tests/testthat/test-validation-environment.R")'` | ✅ | ✅ green |
| 06-01-02 | 01 | 1 | VAL-01 | unit | `Rscript -e 'testthat::test_file("tests/testthat/test-diagnostics-codebook.R")'` | ✅ | ✅ green |
| 06-02-01 | 02 | 2 | VAL-01 | unit/integration | `Rscript -e 'testthat::test_file("tests/testthat/test-render-guards.R")'` | ✅ | ✅ green |
| 06-02-02 | 02 | 2 | VAL-01 | integration (guarded) | `Rscript -e 'testthat::test_file("tests/testthat/test-yaml-integration.R")'` | ✅ | ✅ green |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Existing infrastructure covers all phase requirements.

---

## Manual-Only Verifications

All phase behaviors have automated verification (Quarto-present checks remain guard-skipped when unavailable).

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 60s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** approved. Phase 06 verification already passed, and the validation bookkeeping now matches the existing automated evidence.
