---
phase: 07
slug: first-run-onboarding-reliability
status: draft
nyquist_compliant: false
wave_0_complete: false
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
| **Estimated runtime** | ~45 seconds (Quarto absent) / ~120 seconds (Quarto present) |

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
| 07-01-01 | 01 | 1 | ONB-01 | unit | `Rscript -e "testthat::test_file('tests/testthat/test-scaffolding.R')"` | ✅ | ⬜ pending |
| 07-01-02 | 01 | 1 | ONB-01 | integration (guarded) | `Rscript -e "testthat::test_file('tests/testthat/test-yaml-integration.R')"` | ✅ | ⬜ pending |
| 07-02-01 | 02 | 2 | ONB-01 | integration (guarded) | `Rscript -e "testthat::test_file('tests/testthat/test-yaml-integration.R')"` | ✅ | ⬜ pending |
| 07-02-02 | 02 | 2 | ONB-01 | regression | `Rscript -e "testthat::test_local('.')"` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] Extend `tests/testthat/test-yaml-integration.R` with helper-driven article and policy-brief scaffold -> validation assertions.
- [ ] Extend `tests/testthat/test-yaml-integration.R` with helper-driven article and policy-brief scaffold -> render success assertions.
- [ ] Add explicit assertions that inline onboarding guidance comments do not break YAML parsing/render for all formats.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Confirm first-run onboarding reliability on supported Quarto-enabled setup | ONB-01 | Local environment currently lacks Quarto CLI, so guarded integration checks skip by design | Run `test-yaml-integration.R` and full `test_local('.')` on Quarto-enabled machine/CI; confirm all ONB checks execute and pass (not skip). |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 90s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending