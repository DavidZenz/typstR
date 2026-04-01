---
phase: 08
slug: measured-performance-optimization
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-04-01
---

# Phase 08 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | testthat (edition 3) |
| **Config file** | `tests/testthat.R`, `DESCRIPTION` (`Config/testthat/edition: 3`) |
| **Quick run command** | `Rscript -e 'testthat::test_file("tests/testthat/test-performance-micro.R")'` |
| **Full suite command** | `Rscript -e 'testthat::test_local(".", filter = "performance|render-guards|validation-environment|yaml-integration|scaffolding")'` |
| **Estimated runtime** | ~60 seconds (Quarto absent) / ~180 seconds (Quarto present) |

---

## Sampling Rate

- **After every task commit:** `Rscript -e 'testthat::test_file("tests/testthat/test-validation-environment.R"); testthat::test_file("tests/testthat/test-render-guards.R")'`
- **After every plan wave:** `Rscript -e 'testthat::test_local(".", filter = "validation-environment|render-guards|yaml-integration|scaffolding|performance")'`
- **Before `$gsd-verify-work`:** `Rscript -e 'testthat::test_local(".", filter = "performance|render-guards|validation-environment|yaml-integration|scaffolding")'`
- **Max feedback latency:** 180 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 08-01-01 | 01 | 1 | PERF-01 | benchmark (micro) | `Rscript -e 'testthat::test_file("tests/testthat/test-performance-micro.R")'` | ❌ W0 | ⬜ pending |
| 08-01-02 | 01 | 1 | PERF-01 | semantic regression | `Rscript -e 'testthat::test_file("tests/testthat/test-validation-environment.R"); testthat::test_file("tests/testthat/test-render-guards.R")'` | ✅ | ⬜ pending |
| 08-02-01 | 02 | 2 | PERF-01 | benchmark regression | `Rscript -e 'testthat::test_file("tests/testthat/test-performance-regression.R")'` | ❌ W0 | ⬜ pending |
| 08-02-02 | 02 | 2 | PERF-01 | guarded integration | `Rscript -e 'testthat::test_file("tests/testthat/test-yaml-integration.R")'` | ✅ (guarded) | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `tests/testthat/helper-performance.R` — shared deterministic fixture/timing helpers.
- [ ] `tests/testthat/test-performance-micro.R` — hotspot micro-bench scenarios for preflight/render helper paths.
- [ ] `tests/testthat/test-performance-regression.R` — calibrated slowdown guardrails with documented tolerances.
- [ ] Install benchmark framework dependency: `Rscript -e 'install.packages("bench")'`.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Validate integration timing and semantic parity on Quarto-enabled machine | PERF-01 | Current local environment lacks Quarto CLI; guarded integration timing cannot execute end-to-end locally | On Quarto-enabled machine/CI, run `test-performance-regression.R`, `test-yaml-integration.R`, and filtered `test_local()` command; confirm performance suites execute (not skip) and semantic assertions remain green. |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 180s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending