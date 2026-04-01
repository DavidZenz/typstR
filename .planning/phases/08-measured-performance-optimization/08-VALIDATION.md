---
phase: 08
slug: measured-performance-optimization
status: draft
nyquist_compliant: true
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
| **Quick run command** | `Rscript -e 'elapsed <- system.time(testthat::test_file("tests/testthat/test-performance-gain.R", filter = "^smoke:"))[["elapsed"]]; if (elapsed >= 30) stop(sprintf("smoke verify exceeded 30s: %.2f", elapsed))'` |
| **Full suite command** | `Rscript -e 'testthat::test_local(".", filter = "performance|render-guards|validation-environment|yaml-integration|scaffolding")'` |
| **Estimated runtime** | ~25 seconds (task smoke) / ~60 seconds (Quarto absent full suite) / ~180 seconds (Quarto present full suite) |

---

## Sampling Rate

- **After every task commit (Nyquist fast gate):** `Rscript -e 'elapsed <- system.time({ testthat::test_file("tests/testthat/test-performance-micro.R", filter = "^smoke:"); testthat::test_file("tests/testthat/test-performance-baseline-contract.R", filter = "^smoke:"); testthat::test_file("tests/testthat/test-performance-gain.R", filter = "^smoke:") })[["elapsed"]]; if (elapsed >= 30) stop(sprintf("task smoke gate exceeded 30s: %.2f", elapsed))'`
- **After every plan wave:** `Rscript -e 'testthat::test_local(".", filter = "validation-environment|render-guards|yaml-integration|scaffolding|performance")'`
- **Before `$gsd-verify-work`:** `Rscript -e 'testthat::test_local(".", filter = "performance|render-guards|validation-environment|yaml-integration|scaffolding")'`
- **Max feedback latency:** 30 seconds per-task smoke gate; 180 seconds for wave/phase full suites

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 08-01-01 | 01 | 1 | PERF-01 | micro smoke gate | `Rscript -e 'elapsed <- system.time(testthat::test_file("tests/testthat/test-performance-micro.R", filter = "^smoke:"))[["elapsed"]]; if (elapsed >= 30) stop(sprintf("smoke verify exceeded 30s: %.2f", elapsed))'` | ❌ planned | ⬜ pending |
| 08-01-02 | 01 | 1 | PERF-01 | baseline contract smoke gate | `Rscript -e 'elapsed <- system.time(testthat::test_file("tests/testthat/test-performance-baseline-contract.R", filter = "^smoke:"))[["elapsed"]]; if (elapsed >= 30) stop(sprintf("smoke verify exceeded 30s: %.2f", elapsed))'` | ❌ planned | ⬜ pending |
| 08-02-01 | 02 | 2 | PERF-01 | gain smoke gate (validation/render) | `Rscript -e 'elapsed <- system.time(testthat::test_file("tests/testthat/test-performance-gain.R", filter = "^smoke: (validation|render)"))[["elapsed"]]; if (elapsed >= 30) stop(sprintf("smoke verify exceeded 30s: %.2f", elapsed))'` | ❌ planned | ⬜ pending |
| 08-02-02 | 02 | 2 | PERF-01 | gain smoke gate (scaffold) | `Rscript -e 'elapsed <- system.time(testthat::test_file("tests/testthat/test-performance-gain.R", filter = "^smoke: scaffold"))[["elapsed"]]; if (elapsed >= 30) stop(sprintf("smoke verify exceeded 30s: %.2f", elapsed))'` | ❌ planned | ⬜ pending |

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
- [ ] Feedback latency < 30s for per-task smoke gates
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
