---
phase: 08
slug: measured-performance-optimization
status: human_needed
nyquist_compliant: true
wave_0_complete: true
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
| **Quick run command** | `Rscript -e 'elapsed <- system.time(testthat::test_file("tests/testthat/test-performance-gain.R"))[["elapsed"]]; if (elapsed >= 30) stop(sprintf("quick verify exceeded 30s: %.2f", elapsed))'` |
| **Full suite command** | `Rscript -e 'testthat::test_local(".", filter = "performance|render-guards|validation-environment|yaml-integration|scaffolding")'` |
| **Estimated runtime** | ~25 seconds (task smoke) / ~60 seconds (Quarto absent full suite) / ~180 seconds (Quarto present full suite) |

---

## Sampling Rate

- **After every task commit (Nyquist fast gate):** `Rscript -e 'elapsed <- system.time({ testthat::test_file("tests/testthat/test-performance-micro.R"); testthat::test_file("tests/testthat/test-performance-baseline-contract.R"); testthat::test_file("tests/testthat/test-performance-gain.R") })[["elapsed"]]; if (elapsed >= 30) stop(sprintf("task verify exceeded 30s: %.2f", elapsed))'`
- **After every plan wave:** `Rscript -e 'testthat::test_local(".", filter = "validation-environment|render-guards|yaml-integration|scaffolding|performance")'`
- **Before `$gsd-verify-work`:** `Rscript -e 'testthat::test_local(".", filter = "performance|render-guards|validation-environment|yaml-integration|scaffolding")'`
- **Max feedback latency:** 30 seconds per-task smoke gate; 180 seconds for wave/phase full suites

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 08-01-01 | 01 | 1 | PERF-01 | micro verify gate | `Rscript -e 'elapsed <- system.time(testthat::test_file("tests/testthat/test-performance-micro.R"))[["elapsed"]]; if (elapsed >= 30) stop(sprintf("verify exceeded 30s: %.2f", elapsed))'` | ✅ | ✅ green |
| 08-01-02 | 01 | 1 | PERF-01 | baseline contract verify gate | `Rscript -e 'elapsed <- system.time(testthat::test_file("tests/testthat/test-performance-baseline-contract.R"))[["elapsed"]]; if (elapsed >= 30) stop(sprintf("verify exceeded 30s: %.2f", elapsed))'` | ✅ | ✅ green |
| 08-02-01 | 02 | 2 | PERF-01 | gain verify gate (validation/render coverage) | `Rscript -e 'elapsed <- system.time(testthat::test_file("tests/testthat/test-performance-gain.R"))[["elapsed"]]; if (elapsed >= 30) stop(sprintf("verify exceeded 30s: %.2f", elapsed))'` | ✅ | ✅ green |
| 08-02-02 | 02 | 2 | PERF-01 | gain verify gate (scaffold coverage) | `Rscript -e 'elapsed <- system.time(testthat::test_file("tests/testthat/test-performance-gain.R"))[["elapsed"]]; if (elapsed >= 30) stop(sprintf("verify exceeded 30s: %.2f", elapsed))'` | ✅ | ✅ green |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Runtime execution evidence is intentionally deferred to Phase 10 on a supported Quarto-enabled and `{bench}`-enabled setup.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Validate integration timing and semantic parity on Quarto-enabled machine | PERF-01 | Current local environment lacks Quarto CLI; guarded integration timing cannot execute end-to-end locally | On Quarto-enabled machine/CI, run `test-performance-regression.R`, `test-yaml-integration.R`, and filtered `test_local()` command; confirm performance suites execute (not skip) and semantic assertions remain green. |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 30s for per-task smoke gates
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** approved. Bookkeeping evidence is complete; remaining human-needed runtime checks stay limited to Phase 10 bench-backed gain/regression runs and Quarto-enabled semantic checks.
