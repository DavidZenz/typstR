---
phase: 06
slug: pre-render-environment-validation
status: draft
nyquist_compliant: false
wave_0_complete: false
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
| 06-01-01 | 01 | 1 | VAL-01 | unit | `Rscript -e 'testthat::test_file("tests/testthat/test-validation-environment.R")'` | ❌ W0 | ⬜ pending |
| 06-01-02 | 01 | 1 | VAL-01 | unit | `Rscript -e 'testthat::test_file("tests/testthat/test-diagnostics-codebook.R")'` | ✅ | ⬜ pending |
| 06-02-01 | 02 | 2 | VAL-01 | unit/integration | `Rscript -e 'testthat::test_file("tests/testthat/test-render-guards.R")'` | ✅ | ⬜ pending |
| 06-02-02 | 02 | 2 | VAL-01 | integration (guarded) | `Rscript -e 'testthat::test_file("tests/testthat/test-yaml-integration.R")'` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `tests/testthat/test-validation-environment.R` — contract tests for standalone environment validation (`VAL-01`)
- [ ] `tests/testthat/helper-validation.R` — shared sourcing/mocks for environment validation tests

---

## Manual-Only Verifications

All phase behaviors have automated verification (Quarto-present checks remain guard-skipped when unavailable).

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending