---
phase: 1
slug: skeleton-and-pipeline
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-22
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | testthat 3.x |
| **Config file** | tests/testthat.R (Wave 0 creates) |
| **Quick run command** | `Rscript -e "testthat::test_dir('tests/testthat')"` |
| **Full suite command** | `Rscript -e "devtools::check()"` |
| **Estimated runtime** | ~30 seconds |

---

## Sampling Rate

- **After every task commit:** Run `Rscript -e "testthat::test_dir('tests/testthat')"`
- **After every plan wave:** Run `Rscript -e "devtools::check()"`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 01-01-01 | 01 | 1 | FOUN-01 | unit | `R CMD check` | ❌ W0 | ⬜ pending |
| 01-02-01 | 02 | 1 | FOUN-02 | unit | `test_that("extension files exist")` | ❌ W0 | ⬜ pending |
| 01-03-01 | 03 | 1 | FOUN-03 | integration | `test_that("extension copies to _extensions/")` | ❌ W0 | ⬜ pending |
| 01-04-01 | 04 | 2 | FOUN-04 | integration | `test_that("render_pub produces PDF")` | ❌ W0 | ⬜ pending |
| 01-05-01 | 04 | 2 | FOUN-05 | integration | `test_that("render_working_paper produces PDF")` | ❌ W0 | ⬜ pending |
| 01-06-01 | 03 | 1 | SCAF-01 | unit | `test_that("create_working_paper creates all files")` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `tests/testthat.R` — testthat bootstrap
- [ ] `tests/testthat/test-scaffold.R` — stubs for SCAF-01, FOUN-03
- [ ] `tests/testthat/test-render.R` — stubs for FOUN-04, FOUN-05 (guarded with skip_if_not)
- [ ] `tests/testthat/test-package.R` — stubs for FOUN-01, FOUN-02

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| PDF renders correctly with Quarto | FOUN-04 | Requires Quarto installation | Run `render_pub()` on scaffolded project, verify PDF exists and is non-empty |
| Extension discovered by Quarto | FOUN-03 | Quarto runtime behavior | Scaffold project, run `quarto render`, verify it finds the extension |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
