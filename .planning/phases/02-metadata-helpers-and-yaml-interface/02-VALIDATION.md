---
phase: 2
slug: metadata-helpers-and-yaml-interface
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-23
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | testthat 3.x |
| **Config file** | tests/testthat.R (exists from Phase 1) |
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
| 02-01-01 | 01 | 1 | META-01 | unit | `test_that("author returns S3 object")` | ❌ W0 | ⬜ pending |
| 02-01-02 | 01 | 1 | META-02 | unit | `test_that("affiliation returns S3 object")` | ❌ W0 | ⬜ pending |
| 02-02-01 | 02 | 1 | META-03 | unit | `test_that("manuscript_meta combines and validates")` | ❌ W0 | ⬜ pending |
| 02-02-02 | 02 | 1 | META-04,05,06 | unit | `test_that("simple helpers validate and return")` | ❌ W0 | ⬜ pending |
| 02-03-01 | 03 | 2 | META-07 | unit | `test_that("fig_note returns markdown")` | ❌ W0 | ⬜ pending |
| 02-03-02 | 03 | 2 | META-08,09,10 | unit | `test_that("appendix_title, funding, availability")` | ❌ W0 | ⬜ pending |
| 02-04-01 | 04 | 2 | YAML-01,02,03 | integration | `test_that("YAML wiring passes through Pandoc")` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `tests/testthat/test-metadata.R` — stubs for META-01 through META-06
- [ ] `tests/testthat/test-notes.R` — stubs for META-07, META-08, META-09, META-10
- [ ] `tests/testthat/test-yaml-wiring.R` — stubs for YAML-01, YAML-02, YAML-03 (guarded with skip_if_not)

*Existing infrastructure from Phase 1: tests/testthat.R bootstrap*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| typstR: fields render in PDF | YAML-02 | Requires Quarto + Typst | Scaffold project, add metadata, render, verify all fields appear |
| fig_note renders below figure | META-07 | Requires Quarto render | Add fig_note() in chunk, render, verify italic note text appears |
| Hyphenated keys pass through Pandoc | YAML-02 | Environment-dependent | Test `$typstR.report-number$` in typst-show.typ with quarto render |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
