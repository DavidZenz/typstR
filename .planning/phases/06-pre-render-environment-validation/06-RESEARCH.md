# Phase 6: Pre-render Environment Validation - Research

**Researched:** 2026-04-01
**Domain:** R package preflight validation for Quarto/Typst render pipeline
**Confidence:** MEDIUM-HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

### Validation entrypoint and user contract
- **D-01:** Provide a user-invokable pre-render validation entrypoint that can be run before `render_pub()` and reports a clear pass/fail outcome.
- **D-02:** Validation MUST emit structured diagnostics via the Phase 5 contract (`typstR_diagnostics_error`) on failure, not prose-only aborts.
- **D-03:** Validation success SHOULD return a structured report object containing check outcomes and detected version values (for Quarto and Typst) so callers can inspect results programmatically.

### Check coverage and truthfulness
- **D-04:** Minimum checks in this phase are: Quarto availability, Typst availability and detected version, Quarto version-floor compatibility, and typstR extension presence in the target project.
- **D-05:** Checks are collect-all where feasible in one run; users should receive a complete issue set for known blockers rather than failing on the first issue.
- **D-06:** Every failing check maps to stable diagnostics codes in the existing codebook namespace rules (`DIAG-<AREA>-<NNN>`) and keeps deterministic ordering.

### Render integration behavior
- **D-07:** `render_pub()` preflight behavior should be driven by the shared validation primitives introduced in this phase (no parallel preflight logic).
- **D-08:** Existing user-facing guidance text should remain compatible where possible while payload/class assertions become the primary test contract.

### Claude's Discretion
- Exact public function naming and helper decomposition, provided one clear user entrypoint exists and aligns with existing package naming conventions.
- Exact Quarto version-floor value and comparison implementation, provided the floor is explicit, test-covered, and surfaced in diagnostics.
- Exact structure of successful validation report class/print behavior, provided pass/fail and version evidence are unambiguous.

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| VAL-01 | User can run pre-render environment validation that reports Quarto/Typst availability, version-floor compatibility, and extension presence before render begins. | Reuse Phase 5 diagnostics contract, add environment validation module, derive Quarto floor from extension manifest, probe Typst through `quarto typst --version`, and wire `render_pub()` to shared validation primitive. |
</phase_requirements>

## Summary

Phase 6 should be implemented as one shared validation pipeline that both (a) users can invoke directly and (b) `render_pub()` runs before any render attempt. The current code already has the key seams: `R/diagnostics.R` provides a stable error payload contract and deterministic ordering; `R/render.R` has a `quarto_available()` preflight seam; scaffolds consistently install `_extensions/typstR`. The plan should build on these instead of creating alternate validation paths.

The safest implementation is: collect check results in an internal environment validator, return a structured success report on pass, and emit `typstR_diagnostics_error` with stable codes on fail. Keep checks collect-all where independent (e.g., extension presence can be checked even when Quarto is missing). For version-floor truthfulness, use the extension manifest (`_extension.yml: quarto-required`) as source of truth, then evaluate installed Quarto via `quarto::quarto_available(min = ...)` and include detected Quarto + Typst versions in the report.

Environment audit in this workspace shows Quarto CLI is currently missing (`quarto` not on PATH), while the R `quarto` package is installed. This does not block planning, but it does block positive-path integration execution locally unless Quarto is installed or tests are split into no-Quarto and Quarto-present paths.

**Primary recommendation:** Implement a single internal `validate_render_environment()` engine, expose one user entrypoint, and make `render_pub()` consume that same engine before `quarto_render()`.

## Standard Stack

### Core
| Library/Tool | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Quarto CLI | `>=1.4.11` floor (from `inst/quarto/extensions/typstR/_extension.yml`) | Runtime render engine + embedded Typst | typstR render path depends on Quarto CLI; extension declares authoritative minimum compatibility floor. |
| R package `quarto` | 1.5.1 (CRAN, published 2025-09-04) | Programmatic availability/version checks and rendering entrypoint | Already imported by typstR; provides `quarto_available(min=)` and `quarto_version()` with numeric version semantics. |
| `R/diagnostics.R` contract | Phase 5 current | Structured diagnostics emission and deterministic ordering | Locked by prior phase; avoids redesigning error protocol. |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `fs` | 2.0.1 current on CRAN (published 2026-03-24); 2.0.0 installed here | Path normalization and extension file checks | Use for robust file/directory checks and absolute paths in diagnostics locations. |
| `cli` | 3.6.5 (CRAN, published 2025-04-23) | User-facing abort formatting | Keep compatible message/hint rendering via existing diagnostics emitter. |
| `testthat` | 3.3.2 (CRAN, published 2026-01-11) | Contract and guard tests | Existing test framework for payload-first assertions and no-Quarto safe execution. |
| `withr` | 3.0.2 (CRAN, published 2024-10-28) | Temp directories and reversible environment changes in tests | Use for isolated validation scenarios. |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Reading Quarto floor from extension manifest | Hardcoded floor constant in R code | Hardcoded constant drifts from `_extension.yml` and creates split-brain requirements. |
| Typst version via `quarto typst --version` | Require standalone `typst` binary | Incorrectly rejects valid Quarto-only setups; Quarto embeds Typst. |
| Shared validator consumed by `render_pub()` | Separate standalone validator plus existing render preflight | Violates D-07 and risks behavior drift/tests divergence. |

**Installation:**
```bash
# R dependencies
Rscript -e 'install.packages(c("quarto","cli","fs","testthat","withr"), repos="https://cloud.r-project.org")'

# Quarto CLI (required for positive-path render/validation)
# https://quarto.org/docs/get-started/
```

**Version verification:**
```bash
Rscript -e 'db <- tools::CRAN_package_db(); print(db[db$Package %in% c("quarto","cli","fs","testthat"), c("Package","Version","Published")])'
```

## Architecture Patterns

### Recommended Project Structure
```text
R/
├── diagnostics.R              # existing stable diagnostics contract (reuse)
├── validation_environment.R   # new shared environment validation engine
└── render.R                   # call shared validator before quarto_render()

tests/testthat/
├── test-validation-environment.R   # new phase-6 contract tests
├── test-render-guards.R            # update to assert shared path usage
└── test-yaml-integration.R         # keep Quarto-present smoke behavior
```

### Pattern 1: Single Source of Truth for Preflight
**What:** One internal validator function returns structured check results and diagnostics candidates; both user entrypoint and `render_pub()` call it.
**When to use:** Always for pre-render environment checks.
**Example:**
```r
validate_render_environment <- function(path = ".") {
  results <- list(
    quarto = probe_quarto(),
    typst = probe_typst_via_quarto(),
    extension = probe_typstr_extension(path)
  )

  diagnostics <- build_environment_diagnostics(results)
  if (length(diagnostics) > 0) {
    emit_diagnostics_error(diagnostics, message = "Environment validation failed.")
  }

  structure(list(ok = TRUE, checks = results), class = "typstR_validation_report")
}
```
Source: existing diagnostics contract pattern in `R/diagnostics.R` and `R/render.R`

### Pattern 2: Version-Floor Check via Quarto API (not string compare)
**What:** Use `quarto::quarto_available(min = floor)` for compatibility checks.
**When to use:** Quarto version-floor gate.
**Example:**
```r
floor <- numeric_version("1.4.11")
is_compatible <- requireNamespace("quarto", quietly = TRUE) &&
  quarto::quarto_available(min = floor)
```
Source: `quarto` package API (`quarto_available(min,max,error)`), official reference: https://quarto-dev.github.io/quarto-r/reference/quarto_available.html

### Pattern 3: Typst Detection Through Quarto Wrapper
**What:** Query Typst version using Quarto’s embedded Typst command.
**When to use:** Typst availability/version evidence for report output.
**Example:**
```r
quarto_bin <- quarto::quarto_path()
out <- system2(quarto_bin, c("typst", "--version"), stdout = TRUE, stderr = TRUE)
# parse version token from first line, store raw output for details if parse fails
```
Source: Quarto CLI docs (`quarto typst [...args]` passes args to embedded Typst): https://quarto.org/docs/cli/typst.html

### Anti-Patterns to Avoid
- **Parallel preflight logic:** Keeping old inline `render_pub()` checks and new validator side-by-side creates drift.
- **Hardcoded duplicated version floor:** Duplicating `1.4.11` in multiple files invites mismatch with `_extension.yml`.
- **Fail-fast on first issue:** Hides actionable blockers and violates collect-all intent.
- **Message-only assertions in tests:** Reintroduces brittle tests; payload/class must stay primary contract.

## Implementation Guidance

1. **Add `R/validation_environment.R`** with small probes:
   - `probe_quarto()` -> available bool, detected version, floor, compatible bool
   - `probe_typst_via_quarto()` -> available bool, detected version/raw output
   - `probe_extension(path)` -> check `_extensions/typstR/_extension.yml`
2. **Extend diagnostics codebook** in `R/diagnostics.R` with new stable keys (e.g., Quarto floor incompatible, Typst unavailable, extension missing).
3. **Build one aggregator** that converts probe failures to diagnostics list and emits via `emit_diagnostics_error()`.
4. **Export one user entrypoint** (name at planner discretion) returning structured report on success.
5. **Refactor `render_pub()`** to call the shared validation primitive before resolving input/render.
6. **Preserve compatibility text** while switching tests to payload-first assertions.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Quarto version range logic | Custom semver parser/comparator | `quarto::quarto_available(min=..., max=...)` | Already handles version checks against discovered Quarto binary. |
| Quarto binary discovery | Manual PATH traversal logic | `quarto::quarto_path()` / `quarto::quarto_version()` | Centralized behavior with QUARTO_PATH support and consistent failure semantics. |
| Diagnostic sorting/shape | New error object type | Existing `new_diagnostic()` + `emit_diagnostics_error()` | Contract stability already established and tested in Phase 5. |
| Extension compatibility floor source | Duplicate floor constants | Read `quarto-required` from `_extension.yml` | Keeps code aligned with extension metadata contract. |

**Key insight:** Most complexity here is contract consistency, not probing. Reusing existing primitives and authoritative metadata avoids false confidence and schema drift.

## Common Pitfalls

### Pitfall 1: Calling `quarto::quarto_version()` without guarding for missing CLI
**What goes wrong:** Function aborts and short-circuits collect-all behavior.
**Why it happens:** `quarto` R package can be installed even when Quarto CLI is missing.
**How to avoid:** Use `tryCatch()` around version detection and independently record availability/failure diagnostics.
**Warning signs:** Tests fail with “Quarto command-line tools path not found!” before diagnostics payload is assembled.

### Pitfall 2: Treating standalone `typst` binary as required
**What goes wrong:** Valid Quarto-only setups are incorrectly reported as broken.
**Why it happens:** Confusing Quarto-embedded Typst with external Typst CLI requirement.
**How to avoid:** Define Typst check as `quarto typst --version` capability check.
**Warning signs:** Validation fails on machines where `quarto render` works.

### Pitfall 3: Floor constant drift
**What goes wrong:** Validation reports compatibility mismatch with extension’s own declared `quarto-required`.
**Why it happens:** Floor duplicated in code and extension metadata.
**How to avoid:** Parse one canonical floor value from `_extension.yml`.
**Warning signs:** Changing extension manifest requires edits in multiple files.

### Pitfall 4: Divergence between standalone validation and render path
**What goes wrong:** Users get pass from validator but fail in `render_pub()` preflight (or vice versa).
**Why it happens:** Two independent implementations.
**How to avoid:** One shared validation primitive called by both entrypoints.
**Warning signs:** Duplicate logic in `R/render.R` and validation module.

## Risk List

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Quarto CLI absent in user env | Blocking false-negative/positive-path not executable | High | Emit deterministic diagnostic with install hint and absolute location context. |
| Typst version parse format changes | Misreported version evidence | Medium | Store raw command output in `details`; mark parse failure explicitly rather than inventing version. |
| Extension check rooted at wrong directory | False "missing extension" in valid projects | Medium | Resolve project root from input path and normalize with `fs::path_real()`. |
| New diagnostic codes accidentally reordered/reused | Contract break for automation/tests | Medium | Add explicit codebook immutability tests for new issue keys. |

## Code Examples

Verified patterns from official and in-repo sources:

### Quarto availability + version-floor
```r
has_quarto <- requireNamespace("quarto", quietly = TRUE) && quarto::quarto_available()
meets_floor <- requireNamespace("quarto", quietly = TRUE) && quarto::quarto_available(min = "1.4.11")
version <- tryCatch(as.character(quarto::quarto_version()), error = function(e) NA_character_)
```
Source: https://quarto-dev.github.io/quarto-r/reference/quarto_available.html and current package behavior in `R/render.R`

### Structured diagnostics emission
```r
diagnostic <- new_diagnostic(
  code = diagnostics_codebook()[["quarto_unavailable"]],
  severity = "error",
  location = list(file = as.character(fs::path_abs(path))),
  hint = "Install Quarto from https://quarto.org.",
  message = "Quarto is not installed or not on PATH."
)
emit_diagnostics_error(list(diagnostic), message = diagnostic$message, hint = diagnostic$hint)
```
Source: `R/render.R`, `R/diagnostics.R`

### Extension presence check
```r
extension_manifest <- fs::path(project_dir, "_extensions", "typstR", "_extension.yml")
present <- fs::file_exists(extension_manifest)
```
Source: scaffold conventions in `R/create_working_paper.R`, `R/create_article.R`, `R/create_policy_brief.R`

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Inline single Quarto presence check in `render_pub()` | Shared multi-check pre-render validator with structured report + diagnostics | Phase 6 target | Eliminates validator/render drift and provides actionable preflight evidence. |
| Message-first tests | Payload-first diagnostics contract assertions | Phase 5 (2026-04) | More stable tests and machine-readable failure semantics. |
| Static assumptions about setup | Explicit environment probes (Quarto/Typst/floor/extension) | Phase 6 target | Truthful readiness report before render side effects. |

**Deprecated/outdated:**
- Prose-only preflight aborts as primary contract: replaced by `typstR_diagnostics_error` payload contract.

## Open Questions

1. **Public function name and return class**
   - What we know: One clear user entrypoint is required; success should return structured report.
   - What's unclear: Canonical exported name (`validate_environment()`, `check_environment()`, etc.) and print method expectations.
   - Recommendation: Choose one exported name aligned with package naming style and add explicit return-class tests.

2. **Canonical source for Quarto floor at runtime**
   - What we know: Extension manifest declares `quarto-required: ">=1.4.11"`.
   - What's unclear: Whether to parse floor from project extension copy, package-installed extension, or both with precedence.
   - Recommendation: Use package extension manifest as baseline; if project extension exists, prefer project manifest for truth-in-project.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Quarto CLI (`quarto`) | Core validation checks + render execution | ✗ | — | None (blocking for positive-path execution) |
| Embedded Typst via `quarto typst` | Typst availability/version evidence | ✗ (because Quarto missing) | — | None until Quarto installed |
| Standalone `typst` CLI | Optional direct Typst tooling (not required by Quarto path) | ✗ | — | Use Quarto-embedded Typst once Quarto installed |
| R package `quarto` | Programmatic checks (`quarto_available`, `quarto_version`) | ✓ | 1.5.1 | — |
| testthat | Validation contract tests | ✓ | 3.3.2 | — |

**Missing dependencies with no fallback:**
- Quarto CLI on PATH (blocks end-to-end positive-path validation/render verification in this environment).

**Missing dependencies with fallback:**
- Standalone `typst` CLI (acceptable if Quarto CLI is installed, since Quarto embeds Typst).

## Validation Strategy

- Add payload-first unit tests for each required check outcome (available/unavailable, floor pass/fail, extension present/missing).
- Keep no-Quarto-safe tests executable on CI/dev machines without Quarto by asserting structured diagnostics from shared validator.
- Gate Quarto-present integration checks with explicit skip guards, mirroring existing `test-yaml-integration.R` posture.
- Add regression test asserting `render_pub()` and standalone validator produce identical diagnostic codes for same failing environment.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | testthat 3.3.2 (edition 3) |
| Config file | `tests/testthat.R` + `DESCRIPTION` (`Config/testthat/edition: 3`) |
| Quick run command | `Rscript -e 'testthat::test_file("tests/testthat/test-validation-environment.R")'` |
| Full suite command | `Rscript -e 'testthat::test_dir("tests/testthat")'` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| VAL-01 | Standalone pre-render validator returns clear pass/fail and structured evidence | unit | `Rscript -e 'testthat::test_file("tests/testthat/test-validation-environment.R")'` | ❌ Wave 0 |
| VAL-01 | Failing checks emit stable diagnostics codes via `typstR_diagnostics_error` | unit | `Rscript -e 'testthat::test_file("tests/testthat/test-validation-environment.R")'` | ❌ Wave 0 |
| VAL-01 | `render_pub()` uses shared validator path (no parallel preflight logic) | unit/integration | `Rscript -e 'testthat::test_file("tests/testthat/test-render-guards.R")'` | ✅ |
| VAL-01 | Quarto-present path reports Quarto/Typst versions and floor compatibility | integration (guarded) | `Rscript -e 'testthat::test_file("tests/testthat/test-yaml-integration.R")'` | ✅ |

### Sampling Rate
- **Per task commit:** `Rscript -e 'testthat::test_file("tests/testthat/test-validation-environment.R")'`
- **Per wave merge:** `Rscript -e 'testthat::test_file("tests/testthat/test-render-guards.R"); testthat::test_file("tests/testthat/test-input-diagnostics.R")'`
- **Phase gate:** `Rscript -e 'testthat::test_dir("tests/testthat")'`

### Wave 0 Gaps
- [ ] `tests/testthat/test-validation-environment.R` — covers VAL-01 environment checks and report contract.
- [ ] `tests/testthat/helper-validation.R` (or equivalent) — shared sourcing/helpers for validation module tests.
- [ ] Add codebook tests for new environment diagnostic keys in `tests/testthat/test-diagnostics-codebook.R`.

## Sources

### Primary (HIGH confidence)
- Repository implementation references:
  - `R/diagnostics.R` (structured diagnostics contract, codebook, ordering)
  - `R/render.R` (current Quarto preflight seam)
  - `R/create_working_paper.R`, `R/create_article.R`, `R/create_policy_brief.R` (extension placement convention)
  - `inst/quarto/extensions/typstR/_extension.yml` (`quarto-required: ">=1.4.11"`)
  - `tests/testthat/test-render-guards.R`, `tests/testthat/test-input-diagnostics.R`, `tests/testthat/test-yaml-integration.R`
- Quarto R package official reference:
  - https://quarto-dev.github.io/quarto-r/reference/quarto_available.html
  - https://quarto-dev.github.io/quarto-r/reference/quarto_version.html
- Quarto CLI official docs:
  - https://quarto.org/docs/cli/typst.html
  - https://quarto.org/docs/extensions/
- CRAN package release metadata:
  - https://cran.r-project.org/package=quarto
  - Verified via `tools::CRAN_package_db()` on 2026-04-01

### Secondary (MEDIUM confidence)
- `quarto` package runtime behavior observed in this environment via `Rscript` introspection (`quarto_available`, `quarto_version`, `quarto_path`).

### Tertiary (LOW confidence)
- Web-search aggregation snippets for ecosystem notes about embedded Typst version churn across Quarto releases (used only as non-authoritative context, not core decisions).

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - grounded in current repository dependencies, extension manifest, CRAN metadata, and official Quarto docs.
- Architecture: HIGH - directly constrained by locked decisions and existing code seams.
- Pitfalls: MEDIUM - validated against observed behavior and prior phase tests; edge conditions around Typst output parsing still need implementation-time confirmation.

**Research date:** 2026-04-01
**Valid until:** 2026-05-01 (30 days, moderate release cadence)
