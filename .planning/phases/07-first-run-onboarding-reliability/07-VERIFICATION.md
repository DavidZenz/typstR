---
phase: 07-first-run-onboarding-reliability
verified: 2026-04-01T17:39:52Z
status: human_needed
score: 4/6 must-haves verified
human_verification:
  - test: "Run helper-driven validation matrix on a Quarto-enabled setup"
    expected: "`test-yaml-integration.R` executes onboarding validation assertions (no skip at lines 77-89) and returns pass for working paper, article, and policy brief."
    why_human: "Local environment lacks Quarto CLI; guarded tests skip by design, so supported-setup validation success cannot be observed here."
  - test: "Run helper-driven render matrix on a Quarto-enabled setup"
    expected: "`test-yaml-integration.R` executes render assertions (no skip at lines 99-123), each scaffold helper renders via package wrappers, and PDF artifacts exist for all three formats."
    why_human: "Render-success truth for supported setup requires Quarto runtime that is unavailable in this verifier environment."
---

# Phase 7: First-run Onboarding Reliability Verification Report

**Phase Goal:** Users can scaffold any supported format and succeed on the first validation+render run without manual template repair.
**Verified:** 2026-04-01T17:39:52Z
**Status:** human_needed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Each `create_*` helper scaffolds a starter with shared baseline and format-only deltas. | ✓ VERIFIED | `tests/testthat/test-scaffolding.R` defines cross-format spec matrix and delta assertions (`.scaffold_specs`, lines 65-90; `format-variant`/`jel`/`report-number` checks, lines 146-161). `Rscript -e 'testthat::test_file("tests/testthat/test-scaffolding.R")'` → PASS 60. |
| 2 | Starter front matter includes realistic first-run typstR defaults per format without manual repair. | ✓ VERIFIED | Template defaults present in shipped starters: article `format-variant: article` + `jel` (`inst/templates/article/template.qmd` lines 29, 34), policy brief `format-variant: brief` + `report-number` (`inst/templates/policy-brief/template.qmd` lines 23, 28), working paper `jel` + `report-number` (`inst/templates/workingpaper/template.qmd` lines 33, 36). |
| 3 | Inline onboarding guidance exists near editable fields and keeps starter structure valid. | ✓ VERIFIED | Guidance markers present in all templates (`# Edit first`, `# Replace abstract`, narrative replacement comment) and locked by tests (`.guidance_markers`, lines 108-113; assertion loop lines 173-176). YAML front matter parses for all three templates: `Rscript -e '...yaml::read_yaml(...)'` → `parsed 3 templates`. |
| 4 | On supported setup, helper-generated working paper/article/policy brief pass `validate_render_environment()` before render. | ? UNCERTAIN | Contract is implemented (`test-yaml-integration.R` lines 76-87) and linked to validator (`validate_render_environment` call line 84), but local run is guarded-skip (`.quarto_available() is not TRUE`). |
| 5 | On supported setup, helper-generated starters render to PDF via wrappers without manual edits. | ? UNCERTAIN | Contract is implemented (`test-yaml-integration.R` lines 98-123, wrapper dispatch via `render_fn_name`), but local run is guarded-skip (`.quarto_available() is not TRUE`). |
| 6 | Quarto-absent environments stay deterministic/safe via explicit guard skips while keeping matrix contracts present. | ✓ VERIFIED | `.skip_if_no_quarto()` guard used in all runtime-dependent tests (lines 77, 99, 127, 176, 224). Local run shows matrix tests still execute while runtime tests skip deterministically: `test_file("test-yaml-integration.R")` → PASS 2, SKIP 5. |

**Score:** 4/6 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `tests/testthat/test-scaffolding.R` | Contract tests for shared scaffold baseline + allowed deltas + guidance | ✓ VERIFIED | Exists/substantive (`gsd-tools verify artifacts`: passed). Executed directly with PASS 60. |
| `inst/templates/workingpaper/template.qmd` | Runnable working-paper starter with defaults + inline guidance | ✓ VERIFIED | Exists/substantive (`gsd-tools verify artifacts`: passed). Linked from helper copy path (`R/create_working_paper.R` line 33). |
| `inst/templates/article/template.qmd` | Runnable article starter with shared baseline + article deltas | ✓ VERIFIED | Exists/substantive (`gsd-tools verify artifacts`: passed). Linked from helper copy path (`R/create_article.R` line 33). |
| `inst/templates/policy-brief/template.qmd` | Runnable policy-brief starter with shared baseline + brief deltas | ✓ VERIFIED | Exists/substantive (`gsd-tools verify artifacts`: passed). Linked from helper copy path (`R/create_policy_brief.R` line 34). |
| `tests/testthat/test-yaml-integration.R` | Helper-driven scaffold→validate→render matrix contract | ✓ VERIFIED | Exists/substantive (`gsd-tools verify artifacts`: passed). Executed with guard behavior: PASS 2, SKIP 5; matrix-shape tests run even without Quarto. |

### Key Link Verification

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| `R/create_working_paper.R` | `inst/templates/workingpaper/template.qmd` | Template copy into scaffolded project | ✓ WIRED | `gsd-tools verify key-links` (07-01) verified pattern; `template_src <- system.file("templates/workingpaper", ...)`. |
| `R/create_article.R` | `inst/templates/article/template.qmd` | Template copy into scaffolded project | ✓ WIRED | `gsd-tools verify key-links` (07-01) verified pattern; `template_src <- system.file("templates/article", ...)`. |
| `R/create_policy_brief.R` | `inst/templates/policy-brief/template.qmd` | Template copy into scaffolded project | ✓ WIRED | `gsd-tools verify key-links` (07-01) verified pattern; `template_src <- system.file("templates/policy-brief", ...)`. |
| `tests/testthat/test-yaml-integration.R` | `R/validation_environment.R` | Helper-driven validation assertions | ✓ WIRED | `validate_render_environment(spec$project)` at line 84; key-link check verified. |
| `tests/testthat/test-yaml-integration.R` | `R/render.R` | Wrapper-driven render assertions | ✓ WIRED | Matrix maps to `render_working_paper`/`render_pub` (`render_fn_name`, lines 26/32/38) and dispatches with `do.call(render_fn, ...)` line 114. |
| `tests/testthat/test-yaml-integration.R` | `R/create_working_paper.R` + `R/create_article.R` + `R/create_policy_brief.R` | Helper scaffolding before validation/render | ✓ WIRED | Matrix function names include all three helpers and call `helper(spec$project, open = FALSE)` (lines 81-83, 103-104). |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
| --- | --- | --- | --- | --- |
| `tests/testthat/test-scaffolding.R` | `spec` / `output$qmd` | `.scaffold_specs()` → helper scaffold call → `readLines(template.qmd)` | Yes; reads generated scaffold files, then asserts baseline/delta markers | ✓ FLOWING |
| `tests/testthat/test-yaml-integration.R` | `spec` / `report` / rendered PDF | `.onboarding_scaffold_specs()` → helper scaffold → `validate_render_environment()` + wrapper render call | Yes when Quarto present; currently guard-skipped locally | ✓ FLOWING (guarded runtime) |
| `inst/templates/*/template.qmd` | N/A | Static starter payload copied by `create_*` helpers | N/A (source artifacts) | ℹ️ N/A |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| --- | --- | --- | --- |
| Scaffold contract matrix executes and passes | `Rscript -e 'testthat::test_file("tests/testthat/test-scaffolding.R")'` | `[ FAIL 0 | WARN 0 | SKIP 0 | PASS 60 ]` | ✓ PASS |
| Integration matrix shape remains active while Quarto paths are guarded | `Rscript -e 'testthat::test_file("tests/testthat/test-yaml-integration.R")'` | `[ FAIL 0 | WARN 0 | SKIP 5 | PASS 2 ]` with skip reason `.quarto_available() is not TRUE` | ✓ PASS |
| Regression gate including onboarding/validation/render guard suites | `Rscript -e 'testthat::test_local(".", filter = "diagnostics-contract|diagnostics-codebook|diagnostics-ordering|input-diagnostics|validation-environment|render-guards|metadata-helpers|pub-helpers|notes-helpers|scaffolding|yaml-integration")'` | `[ FAIL 0 | WARN 0 | SKIP 6 | PASS 259 ]` | ✓ PASS |
| Inline-guidance comments do not break YAML front matter parsing | `Rscript -e '...yaml::read_yaml(...) for all templates...'` | `parsed 3 templates` | ✓ PASS |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| ONB-01 | `07-01-PLAN.md`, `07-02-PLAN.md` | User can scaffold each supported format and get a validation+render-successful starter project on a supported setup without manual template fixes. | ? NEEDS HUMAN | Scaffold and matrix contracts are present and passing in no-Quarto mode (`PASS 60`, `PASS 2/SKIP 5`, `PASS 259/SKIP 6`), but supported-setup validation/render assertions are currently skip-gated locally. |

**Orphaned requirements:** None detected (Phase 7 maps to ONB-01 only, and both phase plans declare ONB-01).

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| --- | --- | --- | --- | --- |
| — | — | No TODO/FIXME/placeholders, empty implementations, or hardcoded-empty stub patterns found in phase-modified files. | ℹ️ Info | No blocker/warning anti-patterns detected. |

### Human Verification Required

### 1. Quarto-enabled validation matrix execution

**Test:** Run `Rscript -e 'testthat::test_file("tests/testthat/test-yaml-integration.R")'` on a machine with Quarto CLI available.
**Expected:** Test `pre-render validation succeeds across helper-generated onboarding formats` executes (not skip) and passes for working paper, article, and policy brief.
**Why human:** Current verifier environment has no Quarto CLI; this path is intentionally guarded.

### 2. Quarto-enabled render matrix execution

**Test:** Run `Rscript -e 'testthat::test_file("tests/testthat/test-yaml-integration.R")'` on Quarto-enabled setup and inspect render tests.
**Expected:** Test `helper-generated onboarding scaffolds render across all supported formats` executes (not skip), render wrappers succeed, and each scaffold contains `template.pdf`.
**Why human:** Render-success behavior is runtime-dependent on Quarto/Typst availability.

### Gaps Summary

No code-level gaps or broken wiring were found in Phase 07 artifacts. The remaining verification boundary is environment availability: supported-setup (Quarto-enabled) execution is required to conclusively mark ONB-01 as fully satisfied in runtime terms.

---

_Verified: 2026-04-01T17:39:52Z_
_Verifier: Claude (gsd-verifier)_
