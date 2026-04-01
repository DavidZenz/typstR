---
phase: 05
slug: structured-diagnostics-foundation
status: draft
nyquist_compliant: false
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
| 05-01-01 | 01 | 1 | DIAG-01 | unit | `Rscript -e "testthat::test_file('tests/testthat/test-render-guards.R')"` | ✅ | ⬜ pending |
| 05-01-02 | 01 | 1 | DIAG-01 | unit | `Rscript -e "testthat::test_dir('tests/testthat')"` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Existing infrastructure covers all phase requirements.

---

## Manual-Only Verifications

All phase behaviors have automated verification.

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
