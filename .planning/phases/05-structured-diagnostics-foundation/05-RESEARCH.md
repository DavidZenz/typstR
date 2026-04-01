# Phase 05: Structured Diagnostics Foundation - Research

**Researched:** 2026-04-01  
**Domain:** R condition contracts for stable, structured validation diagnostics  
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

### Diagnostics schema contract
- **D-01:** Every diagnostic entry MUST include `code`, `severity`, `location`, and `hint`.
- **D-02:** Every diagnostic entry SHOULD also include a human-facing `message` and MAY include structured `details` for debugging context.
- **D-03:** `location` SHOULD support both file-level and field-level pointers (e.g., file path + YAML key path) so downstream checks can be precise.

### Severity semantics
- **D-04:** Use exactly two severity levels in v1.1 foundation: `error` and `warning`.
- **D-05:** Severity meaning is contract-level: `error` = blocking issue, `warning` = non-blocking issue that still needs user visibility.

### Diagnostic code system
- **D-06:** Codes follow a stable namespace format: `DIAG-<AREA>-<NNN>` (example: `DIAG-INPUT-001`).
- **D-07:** Once assigned, a code is never repurposed for a different issue class.
- **D-08:** New issue classes get new codes; historical codes remain valid for compatibility with tests/docs.

### Aggregation and ordering
- **D-09:** Validation diagnostics are collect-all per run (no fail-fast for first issue).
- **D-10:** Output ordering is deterministic: errors first, then warnings; within each severity sort by location, then code.
- **D-11:** Repeated runs over unchanged inputs MUST emit identical code sets and ordering.

### Claude's Discretion
- Exact wording templates for `message` and `hint`, as long as semantics stay stable.
- Internal representation details for `location`/`details` beyond the required external contract.
- Whether diagnostics formatting helpers live in one file or split into small internal helpers.

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| DIAG-01 | User receives structured diagnostics for validation issues with stable code, severity, location, and hint fields. | Contract-first `R/diagnostics.R` design, stable codebook table, deterministic sort helper, and condition-class testing strategy tied to `render_pub()` + `resolve_input()` current validation choke points. |
</phase_requirements>

## Summary

Current implementation is prose-first: validation-related failures are raised immediately via `cli::cli_abort(...)` in `R/render.R::render_pub()` (Quarto availability) and `R/utils.R::resolve_input()` (input resolution). This satisfies user-facing messaging but does not satisfy DIAG-01 because there is no stable machine-readable schema, no codebook, and no deterministic multi-issue aggregation object. Existing tests confirm this: they mostly assert regex text (`expect_error(..., "...")`) and therefore are brittle under wording changes.

For Phase 05, the right boundary is to introduce an internal diagnostics contract layer (new `R/diagnostics.R`) and route existing validation failures through it before aborting. Do not add Phase 06 validation breadth yet; only convert current validation issue classes into structured entries with stable code/severity/location/hint and deterministic ordering rules. This keeps scope tight while establishing the substrate Phase 06+ can consume.

Observed environment supports this plan: R/testthat are available locally, Quarto CLI is missing, and current test suite already handles this via skip/mocking patterns. That means diagnostics foundation work can be fully implemented and verified under CRAN-safe constraints without requiring live Quarto rendering.

**Primary recommendation:** Introduce a canonical diagnostic object + codebook + deterministic sorter in `R/diagnostics.R`, then adapt `render_pub()` and `resolve_input()` to emit classed conditions carrying structured diagnostics while preserving current human-readable messaging.

## Standard Stack

### Core
| Library | Version (verified) | Purpose | Why Standard |
|---------|---------------------|---------|--------------|
| cli | 3.6.5 (Published 2025-04-23) | User-facing error/warning formatting and condition signaling | Already used package-wide (`cli_abort`); supports structured condition payload passthrough via `...`. |
| rlang | 1.1.7 (Published 2026-01-09) | Condition semantics underpinning classed errors | `cli_abort()` builds on `rlang::abort()` conventions for classed conditions and metadata. |
| fs | 2.0.1 (Published 2026-03-24) | Stable file/path evidence in `location` fields | Already canonical for path resolution and existence checks in this codebase. |
| testthat | 3.3.2 (Published 2026-01-11) | Contract tests for code stability and ordering determinism | Supports class-based condition assertions to replace brittle regex-only checks. |

### Supporting
| Library | Version (verified) | Purpose | When to Use |
|---------|---------------------|---------|-------------|
| quarto (R pkg) | 1.5.1 (Published 2025-09-04) | Existing Quarto availability/render APIs | Keep existing preflight behavior and no-shelling policy intact; diagnostics wraps outcomes. |
| withr | 3.0.2 (Published 2024-10-28) | Test isolation and temporary state | For deterministic ordering and repeated-run tests in isolated contexts. |
| yaml | 2.3.12 (Published 2025-12-10) | Future location key-path support (Phase 06+) | Mentioned for forward compatibility; not required to expand validation scope in Phase 05. |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `cli` + classed conditions | Custom S3 list + manual printers only | Reinvents condition signaling; loses integration with existing `cli_abort` style and testthat condition tooling. |
| Stable codebook table | On-the-fly string concatenation in each call site | High risk of code drift/repurposing; violates D-07/D-08. |
| Class-based tests (`expect_error(..., class=...)`) | Regex-only message assertions | Regex tests are brittle and already the primary migration risk in this repo. |

**Installation:**
```bash
Rscript -e 'install.packages(c("cli","fs","rlang","testthat","withr","quarto","yaml"))'
```

**Version verification (executed):**
```bash
Rscript -e 'db <- tools::CRAN_package_db(); pkgs <- c("cli","fs","quarto","yaml","testthat","withr","bench","rlang"); print(db[match(pkgs, db$Package), c("Package","Version","Published")], row.names = FALSE)'
```

## Architecture Patterns

### Recommended Project Structure
```text
R/
├── diagnostics.R      # NEW: diagnostic schema, codebook, ordering, formatting/abort helpers
├── utils.R            # Adapt resolve_input() to return/collect diagnostic entries before abort
├── render.R           # Adapt quarto preflight to emit structured diagnostics condition
└── (no new public API required in Phase 05)

tests/testthat/
├── test-render-guards.R              # migrate from message-only to class+payload assertions
├── test-diagnostics-contract.R        # NEW: schema/code/order determinism tests
└── test-diagnostics-ordering.R        # NEW: deterministic sort and repeated-run invariance
```

### Pattern 1: Canonical Diagnostic Entry Constructor
**What:** One constructor enforces required fields (`code`, `severity`, `location`, `hint`) and optional fields (`message`, `details`).
**When to use:** Every validation issue emission path.
**Example:**
```r
# Source: https://cli.r-lib.org/reference/cli_abort.html
new_diagnostic <- function(code, severity, location, hint, message = NULL, details = NULL) {
  stopifnot(severity %in% c("error", "warning"))
  list(
    code = code,
    severity = severity,
    location = location,
    hint = hint,
    message = if (is.null(message)) "" else message,
    details = details
  )
}
```

### Pattern 2: Immutable Codebook Registry
**What:** Central table mapping issue classes to `DIAG-<AREA>-<NNN>` codes.
**When to use:** At diagnostic construction boundaries only.
**Example:**
```r
# Source: project decision D-06/D-07/D-08 in 05-CONTEXT.md
DIAGNOSTIC_CODEBOOK <- list(
  quarto_unavailable = "DIAG-RUNTIME-001",
  no_qmd_found = "DIAG-INPUT-001",
  multiple_qmd_found = "DIAG-INPUT-002",
  input_not_found = "DIAG-INPUT-003"
)
```

### Pattern 3: Deterministic Ordering Helper
**What:** Sort diagnostics by severity rank, then normalized location, then code, then insertion index.
**When to use:** Immediately before emitting aggregated diagnostics.
**Example:**
```r
sort_diagnostics <- function(diags) {
  sev_rank <- c(error = 1L, warning = 2L)
  idx <- seq_along(diags)
  ord <- order(
    sev_rank[vapply(diags, `[[`, character(1), "severity")],
    vapply(diags, function(d) d$location$file %||% "~", character(1)),
    vapply(diags, function(d) d$location$field %||% "~", character(1)),
    vapply(diags, `[[`, character(1), "code"),
    idx
  )
  diags[ord]
}
```

### Pattern 4: Condition Boundary Adapter
**What:** Keep `cli_abort` UX, but attach `diagnostics` payload and a stable class.
**When to use:** `render_pub()` and `resolve_input()` abort points.
**Example:**
```r
# Source: https://testthat.r-lib.org/reference/expect_error.html
cli::cli_abort(
  c("Validation failed.", "i" = "Run diagnostics for details."),
  class = c("typstR_diagnostics_error", "typstR_error"),
  diagnostics = sorted_diags
)
```

### Anti-Patterns to Avoid
- **Per-call-site code generation:** Building codes inline in each function leads to drift and repurposing.
- **String-only contract:** If fields only exist in prose, DIAG-01 cannot be verified robustly.
- **Fail-fast before aggregation:** Violates D-09 and makes ordering determinism untestable.
- **Adding new validation checks in Phase 05:** Scope creep into Phase 06+; defer breadth expansion.

## Diagnostics Contract (Concrete for Planner)

### Required external shape
Each diagnostic entry MUST expose:

```r
list(
  code = "DIAG-AREA-001",            # character(1), immutable mapping
  severity = "error" | "warning",   # exactly two levels in v1.1 Phase 05
  location = list(
    file = "path/to/file.qmd" | NA_character_,
    field = "typstR.report-number" | NA_character_,
    line = NA_integer_,
    column = NA_integer_
  ),
  hint = "Actionable remediation step",
  message = "Human-readable summary", # SHOULD
  details = NULL | list(...)           # MAY
)
```

### Initial code assignments (Phase-05 scope only)
- `DIAG-RUNTIME-001`: Quarto unavailable in `render_pub()` preflight.
- `DIAG-INPUT-001`: No `.qmd` found in resolved directory input.
- `DIAG-INPUT-002`: Multiple `.qmd` files found and ambiguous input.
- `DIAG-INPUT-003`: Resolved input file path does not exist.

### Ordering contract
1. `error` before `warning`.
2. Within severity: sort by `location$file`, then `location$field`, then `code`.
3. Tie-break on insertion index to guarantee reproducibility.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Structured error transport | Custom ad-hoc error list printing pipeline | `cli::cli_abort(..., class=..., diagnostics=...)` | Preserves current UX while adding machine-readable payload. |
| Code consistency | Distributed string constants across files | Single codebook object in `R/diagnostics.R` | Guarantees D-07/D-08 stability and review visibility. |
| Message-regex-only verification | Fragile regex matching for all behavior | Class + payload assertions in testthat | Prevents false failures when wording changes. |
| Quarto presence checks in tests | Hard dependency on local Quarto CLI | Existing mock + skip patterns | Keeps CRAN-safe behavior and no-Quarto CI compatibility. |

**Key insight:** This phase is a contract phase, not a check-coverage phase. Invest in stable representation and deterministic behavior now; new checks come later.

## Common Pitfalls

### Pitfall 1: Migrating to structured diagnostics but leaving tests prose-coupled
**What goes wrong:** Tests keep asserting only message text; code stability gains are unrealized.  
**Why it happens:** Quick migration updates runtime code but not assertions.  
**How to avoid:** Require at least one assertion each for condition class, diagnostic code, severity, and location fields.  
**Warning signs:** CI failures on harmless wording changes.

### Pitfall 2: Introducing ordering logic without deterministic tie-breaks
**What goes wrong:** Equal-key diagnostics reorder across runs/platforms.  
**Why it happens:** Sort keys are incomplete or rely on incidental list order.  
**How to avoid:** Explicit tie-break index + repeated-run determinism test.  
**Warning signs:** Flaky snapshots or occasional order diffs without code changes.

### Pitfall 3: Breaking Quarto-missing behavior while refactoring abort paths
**What goes wrong:** No-Quarto environments hard-fail in tests where they should skip/mock.  
**Why it happens:** Diagnostics integration assumes CLI availability.  
**How to avoid:** Keep existing `quarto_available()` mock path and Quarto-guarded integration tests unchanged.  
**Warning signs:** `test-yaml-integration.R` failures instead of skips when Quarto CLI is absent.

## Code Examples

Verified patterns from official sources and current codebase:

### Classed condition assertions (testthat)
```r
# Source: https://testthat.r-lib.org/reference/expect_error.html
expect_error(
  render_pub("paper.qmd", open = FALSE),
  class = "typstR_diagnostics_error"
)
```

### Snapshot-friendly condition capture
```r
# Source: https://testthat.r-lib.org/reference/expect_snapshot.html
expect_snapshot(
  error = TRUE,
  {
    emit_diagnostics_error(sample_diags)
  }
)
```

### Existing integration chokepoint to adapt
```r
# Source: R/render.R (current repository)
if (!quarto_available()) {
  cli::cli_abort(c(
    "Quarto is not installed or not on PATH.",
    "i" = "Install Quarto from {.url https://quarto.org}."
  ))
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Message-regex assertions for validation failures | Class + metadata-based condition assertions | testthat 3e best practice (current) | More stable tests, less churn from copy edits. |
| Immediate prose abort at each failure point | Aggregate structured diagnostics, then emit | Reliability milestones (v1.1 planning) | Enables deterministic ordering and machine checks. |
| Ad-hoc issue identifiers in text | Immutable code namespace (`DIAG-AREA-NNN`) | Required by DIAG-01 contract | Repeatable triage, stable docs/tests references. |

**Deprecated/outdated for this phase:**
- Treating diagnostic message prose as the primary test contract.
- Adding new validation checks before contract and ordering are locked.

## Open Questions

1. **Condition surface design in Phase 05**
   - What we know: Structured payload must exist; current API behavior aborts on failures.
   - What's unclear: Whether to expose a non-throwing `collect_diagnostics()` helper now or keep internal only.
   - Recommendation: Keep internal-only in Phase 05; expose API later if required by Phase 06 planner.

2. **Location granularity baseline**
   - What we know: Must support file-level and field-level pointers.
   - What's unclear: Whether line/column should be mandatory now without full YAML parser integration.
   - Recommendation: Keep `line`/`column` optional (`NA`) in Phase 05, enforce `file`/`field` support immediately.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| R runtime | Package/test execution | ✓ | 4.5.3 | — |
| Rscript | Test commands | ✓ | 4.5.3 | — |
| testthat package | Contract tests | ✓ | 3.3.2 | — |
| withr package | Isolated tests | ✓ | 3.0.2 | — |
| quarto R package | Existing preflight wrapper behavior | ✓ | 1.5.1 | — |
| Quarto CLI binary (`quarto`) | Render integration tests only | ✗ | — | Keep Phase-05 tests Quarto-free; integration tests remain skipped/mocked when unavailable |

**Missing dependencies with no fallback:**
- None for Phase 05 scope.

**Missing dependencies with fallback:**
- Quarto CLI binary (fallback: skip guarded integration tests and test diagnostics via mock/no-CLI paths).

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | testthat 3.3.2 (edition 3) |
| Config file | `DESCRIPTION` (`Config/testthat/edition: 3`), `tests/testthat.R` |
| Quick run command | `Rscript -e 'testthat::test_local(".", filter = "diagnostics|render-guards")'` |
| Full suite command | `Rscript -e 'testthat::test_local(".")'` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| DIAG-01 | Every validation issue includes stable `code`, `severity`, `location`, `hint` | unit | `Rscript -e 'testthat::test_local(".", filter = "diagnostics-contract")'` | ❌ Wave 0 |
| DIAG-01 | Same issue class keeps same code across repeated runs | unit | `Rscript -e 'testthat::test_local(".", filter = "diagnostics-codes")'` | ❌ Wave 0 |
| DIAG-01 | Multiple issues emitted as structured entries in deterministic order | unit/integration-lite | `Rscript -e 'testthat::test_local(".", filter = "diagnostics-ordering")'` | ❌ Wave 0 |
| DIAG-01 | Quarto-missing path still emits structured diagnostic contract | unit | `Rscript -e 'testthat::test_local(".", filter = "render-guards")'` | ✅ |

### Sampling Rate
- **Per task commit:** `Rscript -e 'testthat::test_local(".", filter = "diagnostics|render-guards")'`
- **Per wave merge:** `Rscript -e 'testthat::test_local(".")'`
- **Phase gate:** Full suite green (with Quarto tests allowed to skip when CLI absent) before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `tests/testthat/test-diagnostics-contract.R` — schema conformance for required fields (DIAG-01)
- [ ] `tests/testthat/test-diagnostics-codebook.R` — immutable mapping + repeat-run code stability (DIAG-01)
- [ ] `tests/testthat/test-diagnostics-ordering.R` — deterministic multi-issue ordering (DIAG-01)
- [ ] Migrate `tests/testthat/test-render-guards.R` from regex-only to class/payload assertions while keeping existing user-facing message checks as secondary assertions

## Sources

### Primary (HIGH confidence)
- Repository context files:
  - `.planning/phases/05-structured-diagnostics-foundation/05-CONTEXT.md`
  - `.planning/REQUIREMENTS.md`
  - `.planning/STATE.md`
  - `R/render.R`
  - `R/utils.R`
  - `tests/testthat/test-render-guards.R`
  - `tests/testthat/test-yaml-integration.R`
  - `DESCRIPTION`
  - `inst/quarto/extensions/typstR/_extension.yml`
- Official docs:
  - cli `cli_abort()`: https://cli.r-lib.org/reference/cli_abort.html
  - rlang `abort()`: https://rlang.r-lib.org/reference/abort.html
  - testthat `expect_error()`: https://testthat.r-lib.org/reference/expect_error.html
  - testthat `expect_snapshot()`: https://testthat.r-lib.org/reference/expect_snapshot.html
  - testthat `test_local()`: https://testthat.r-lib.org/reference/test_local.html
  - quarto-r `quarto_available()`: https://quarto-dev.github.io/quarto-r/reference/quarto_available.html
  - quarto-r `quarto_render()`: https://quarto-dev.github.io/quarto-r/reference/quarto_render.html
  - CRAN policy (external software/testing constraints): https://cran.r-project.org/web/packages/policies.html

### Secondary (MEDIUM confidence)
- `tools::CRAN_package_db()` output captured on 2026-04-01 for package version + publication-date verification.
- Prior project research synthesis:
  - `.planning/research/SUMMARY.md`
  - `.planning/research/ARCHITECTURE.md`
  - `.planning/research/PITFALLS.md`
  - `.planning/research/STACK.md`

### Tertiary (LOW confidence)
- None required for core recommendations.

## Metadata

**Confidence breakdown:**
- Standard stack: **HIGH** — directly verified from DESCRIPTION, CRAN package DB, and existing imports/test setup.
- Architecture: **HIGH** — grounded in current call sites (`render_pub`, `resolve_input`) and locked phase decisions.
- Pitfalls: **HIGH** — directly evidenced by existing regex-heavy tests and no-Quarto environment behavior.

**Research date:** 2026-04-01  
**Valid until:** 2026-05-01 (30 days; stable R stack and phase-scoped contract decisions)
