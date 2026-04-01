# Phase 7: First-run Onboarding Reliability - Research

**Researched:** 2026-04-01
**Domain:** R package scaffolding reliability for Quarto+Typst first-run onboarding
**Confidence:** MEDIUM

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
### Starter template depth and defaults
- **D-01:** Starter `.qmd` files should use a **hybrid runnable** approach: compact, realistic content that validates/renders cleanly on first run, with light guidance comments.
- **D-02:** Starter YAML should include **representative defaults** for `typstR` fields that are commonly needed on first run, limited to fields relevant for each format (for example JEL/report-number where appropriate).
- **D-03:** Keep a **shared baseline starter structure** across working paper/article/policy brief, then apply format-specific deltas only where required by format behavior.
- **D-04:** First-run guidance should live **inside `template.qmd`** as short inline comments/notes near editable fields (not CLI-only guidance).

### Claude's Discretion
- Exact phrasing/placement of inline guidance comments, as long as they remain concise and do not break render output.
- Exact representative metadata values used as defaults, as long as they are realistic and format-appropriate.
- Whether to extract shared scaffold logic helper(s) across `create_*` functions during implementation, provided behavior remains equivalent and tested.
- Exact test fixture organization for first-run validation/render checks under Quarto-available vs no-Quarto guard paths.

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| ONB-01 | User can scaffold each supported format and get a validation+render-successful starter project on a supported setup without manual template fixes. | Add cross-format scaffold→validate→render contract tests (working paper/article/policy brief), keep templates runnable with inline guidance comments, and preserve shared scaffolding behavior to avoid format drift. |
</phase_requirements>

## Summary

Phase 7 should be treated as a contract-hardening phase, not a feature-expansion phase. The core architecture already exists: three `create_*` scaffolders, shared pre-render validator (`validate_render_environment()`), and render wrappers (`render_pub()` / `render_working_paper()`). The gap is reliability proof across *all supported formats* in the exact first-run path users take: scaffold from helper, then validate, then render.

Current repository state confirms scaffolding tests are strong for file creation and basic markers, but validation+render integration is asymmetric: working-paper full-path coverage exists, while article/policy-brief are currently template smoke tests and not yet helper-driven first-run contracts. That leaves ONB-01 partially evidenced rather than fully enforced.

The implementation should focus on two outcomes: (1) make all three starter templates consistently runnable with concise inline edit guidance and realistic format-specific metadata defaults; (2) add guarded integration tests that assert scaffolded project validation and render success for each format on supported setups.

**Primary recommendation:** Implement a shared onboarding test matrix (`create_*` -> `validate_render_environment()` -> render -> PDF exists) for all three formats, then tune templates/comments to satisfy that matrix without introducing format-specific drift.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| quarto (R package) | 1.5.1 | Programmatic render + Quarto availability checks | Canonical integration path already used in `render_pub()`; avoids shelling out and keeps behavior testable. |
| Quarto CLI | >=1.4.11 required by extension manifest | Executes Typst rendering and `quarto typst --version` checks | Required runtime for supported setup; enforced by `_extension.yml` `quarto-required`. |
| fs | 2.0.1 (CRAN latest), 2.0.0 installed | Directory/file operations for scaffold copy flow | Cross-platform file handling for R package scaffolding (`dir_copy`, `file_copy`, `path`). |
| cli | 3.6.5 | User-facing scaffold errors and success bullets | Existing package convention for actionable, structured console messages. |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| testthat | 3.3.2 | Unit/integration contract tests | All scaffold and render reliability assertions. |
| withr | 3.0.2 | Tempdir and scoped test state | Isolated project scaffolds without residue. |
| yaml | 2.3.12 (CRAN latest), 2.3.10 installed | Reading extension manifest for Quarto floor | Keep floor source-of-truth in `_extension.yml`. |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `fs::dir_copy()` / `fs::file_copy()` | base `file.copy(..., recursive = TRUE)` | Base approach is less explicit in path semantics and easier to misuse across platforms. |
| `quarto::quarto_render()` | `system2("quarto", ...)` | Shelling out duplicates logic and weakens testability/error semantics already standardized in package. |
| Explicit assertion tests | Snapshot-only tests | Snapshots are brittle for file-system workflows and hide intent of ONB-01 contract behaviors. |

**Installation:**
```r
install.packages(c("cli", "fs", "quarto", "testthat", "withr", "yaml"))
```

**Version verification (observed 2026-04-01):**
- Verified from CRAN metadata via `tools::CRAN_package_db()`:
  - cli 3.6.5 (2025-04-23)
  - fs 2.0.1 (2026-03-24)
  - quarto 1.5.1 (2025-09-04)
  - testthat 3.3.2 (2026-01-11)
  - withr 3.0.2 (2024-10-28)
  - yaml 2.3.12 (2025-12-10)
- Verified in repo: extension manifest requires `quarto-required: ">=1.4.11"` (`inst/quarto/extensions/typstR/_extension.yml`).

## Architecture Patterns

### Recommended Project Structure
```text
R/
├── create_working_paper.R      # working paper scaffold entrypoint
├── create_article.R            # article scaffold entrypoint
├── create_policy_brief.R       # brief scaffold entrypoint
├── validation_environment.R    # shared pre-render validation contract
└── render.R                    # render wrappers using shared validator

inst/templates/
├── workingpaper/template.qmd   # baseline + working-paper deltas
├── article/template.qmd        # baseline + article deltas
└── policy-brief/template.qmd   # baseline + brief deltas

tests/testthat/
├── test-scaffolding.R          # file-level scaffold contracts
└── test-yaml-integration.R     # guarded scaffold/validate/render contracts
```

### Pattern 1: Shared scaffold pipeline with format deltas
**What:** Keep the same control flow in each `create_*` helper (guard existing path, copy template payload, copy extension, optional title patch, success bullets), with only format-specific source paths and markers changed.
**When to use:** Anytime starter behavior changes for one format.
**Example:**
```r
# Source: local codebase R/create_working_paper.R, R/create_article.R, R/create_policy_brief.R
if (fs::dir_exists(path)) cli::cli_abort(...)
fs::dir_create(path)
fs::file_copy(template_files, fs::path(path, fs::path_file(template_files)))
fs::dir_copy(ext_src, fs::path(path, "_extensions", "typstR"))
```

### Pattern 2: Validation-first render contract
**What:** Always run `validate_render_environment()` before `quarto::quarto_render()`.
**When to use:** Every onboarding success test and render path.
**Example:**
```r
# Source: local codebase R/render.R
preflight_path <- if (is.null(input)) "." else input
validate_render_environment(preflight_path)
quarto::quarto_render(input = input, output_format = output_format, quiet = quiet)
```

### Pattern 3: Guarded integration tests for optional Quarto runtime
**What:** Skip integration tests when Quarto is unavailable; keep non-Quarto tests always runnable.
**When to use:** Render/validation end-to-end tests in CRAN-safe package workflows.
**Example:**
```r
# Source: https://testthat.r-lib.org/reference/skip.html and local tests/testthat/test-yaml-integration.R
.skip_if_no_quarto <- function() {
  skip_if_not(requireNamespace("quarto", quietly = TRUE) && quarto::quarto_available())
}
```

### Anti-Patterns to Avoid
- **Template-only smoke coverage for ONB-01:** Rendering raw template directories is useful but does not prove helper-generated projects are first-run reliable.
- **Per-format scaffolder drift:** Editing one `create_*` function without synchronized updates to the others breaks D-03 (shared baseline with deltas).
- **Inline guidance that mutates YAML validity:** Comments are good; malformed indentation or key placement causes front matter parse failures before render.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Render execution | custom `system2("quarto", ...)` wrapper tree | `quarto::quarto_render()` | Existing package path is already integrated and tested; custom wrappers duplicate failure modes. |
| Preflight gating | ad-hoc per-test Quarto checks | `validate_render_environment()` + existing `.skip_if_no_quarto()` helper | Keeps one truth path for environment readiness and deterministic diagnostics. |
| Cross-platform file copy semantics | handcrafted recursive copy logic | `fs::file_copy()` / `fs::dir_copy()` | Avoids OS edge cases and path bugs in starter scaffolding. |
| Quarto floor source | duplicated hard-coded minimums in multiple files | `_extension.yml` `quarto-required` as source of truth | Prevents floor drift and contradictory checks. |

**Key insight:** ONB-01 is primarily an integration-contract problem; reliability comes from converging on existing canonical primitives, not inventing new onboarding subsystems.

## Common Pitfalls

### Pitfall 1: False confidence from skipped integration tests
**What goes wrong:** Local runs pass because Quarto-dependent tests are skipped, but no supported-setup proof is produced.
**Why it happens:** Quarto CLI is missing locally (`quarto_available=FALSE`) and tests are correctly guarded.
**How to avoid:** Treat skipped integration tests as a validation gap and require a Quarto-enabled run (CI or dedicated environment) before phase sign-off.
**Warning signs:** Test output shows many SKIP lines and zero render assertions executed.

### Pitfall 2: Guidance comments that break YAML front matter
**What goes wrong:** Inline onboarding notes accidentally break YAML syntax, causing validation/render failure.
**Why it happens:** Mis-indented comments or invalid placement near nested mappings/sequences.
**How to avoid:** Keep comments short, place them at stable boundaries, and render-check each format after edits.
**Warning signs:** Quarto YAML parse errors before Typst processing starts.

### Pitfall 3: Contract mismatch between create helpers and template tests
**What goes wrong:** Template files render in isolation but helper-generated projects fail due copy/path/extension assumptions.
**Why it happens:** Tests exercise `inst/templates/*` directly instead of end-user `create_*` flow.
**How to avoid:** Assert ONB-01 through helper-driven integration tests for each format.
**Warning signs:** `create_*` tests pass while real scaffold+render path for non-workingpaper formats is unverified.

## Code Examples

Verified patterns from official and local sources:

### Quarto extension minimum version declaration
```yaml
# Source: https://quarto.org/docs/extensions/distributing.html
quarto-required: ">=1.2.0"
```

### Quarto render wrapper contract
```r
# Source: https://quarto-dev.github.io/quarto-r/reference/quarto_render.html
quarto::quarto_render(input = "template.qmd", quiet = TRUE)
```

### Guarded integration test pattern
```r
# Source: https://testthat.r-lib.org/reference/skip.html
.skip_if_no_quarto <- function() {
  skip_if_not(requireNamespace("quarto", quietly = TRUE) && quarto::quarto_available())
}

test_that("scaffold renders", {
  .skip_if_no_quarto()
  # scaffold + render assertions
})
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Render path had separate preflight checks and potential drift risk | Shared `validate_render_environment()` used by standalone and `render_pub()` | Phase 6 (verified 2026-04-01) | ONB-01 can rely on one authoritative readiness contract. |
| Onboarding confidence relied heavily on scaffold file assertions + partial smoke rendering | Requirement expects full first-run scaffold->validate->render success for all formats | v1.1 Phase 7 target | Forces end-to-end reliability proof instead of file-presence proxy checks. |

**Deprecated/outdated:**
- Treating working-paper-only end-to-end checks as sufficient onboarding evidence for all formats.

## Open Questions

1. **Should first-run render assertions for article/brief use `render_pub(..., output_format=...)` or `quarto::quarto_render("template.qmd")` directly in tests?**
   - What we know: Current render wrappers are canonical user path; existing article/brief smoke tests call `quarto::quarto_render()` directly.
   - What's unclear: Whether ONB-01 should enforce wrapper parity for all formats or only format validity.
   - Recommendation: Prefer wrapper path where possible to maximize user-path fidelity; keep direct `quarto_render()` only as supplemental template smoke.

2. **Should shared scaffold helper extraction happen in Phase 7 or deferred?**
   - What we know: `create_*` functions are near-identical and drift-prone.
   - What's unclear: Whether refactor risk outweighs immediate onboarding reliability goals.
   - Recommendation: If duplicated edits exceed two synchronized touch points, extract one internal helper in the same phase; otherwise keep scope tight but document follow-up.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| R runtime | Package code + tests | ✓ | 4.5.3 | — |
| R package `quarto` | `render_pub()` and Quarto detection | ✓ | 1.5.1 | — |
| Quarto CLI | Actual validation/render proof on supported setup | ✗ | — | Run guarded tests locally; execute integration matrix in CI or dedicated Quarto-enabled environment |
| Typst CLI (standalone) | Optional direct CLI use | ✗ | — | Use Quarto-bundled Typst on supported setup |
| testthat | Validation architecture execution | ✓ | 3.3.2 | — |

**Missing dependencies with no fallback:**
- None for coding/testing guard paths.

**Missing dependencies with fallback:**
- Quarto CLI and direct Typst CLI are missing locally; integration tests skip safely, but ONB-01 final evidence must come from a supported environment run.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | testthat 3.3.2 (edition 3) |
| Config file | `tests/testthat.R` + `DESCRIPTION` (`Config/testthat/edition: 3`) |
| Quick run command | `Rscript -e "testthat::test_file('tests/testthat/test-scaffolding.R'); testthat::test_file('tests/testthat/test-yaml-integration.R')"` |
| Full suite command | `Rscript -e "testthat::test_dir('tests/testthat')"` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| ONB-01 | `create_working_paper()`, `create_article()`, `create_policy_brief()` scaffold expected starter files and format markers | unit | `Rscript -e "testthat::test_file('tests/testthat/test-scaffolding.R')"` | ✅ |
| ONB-01 | Scaffolded projects pass `validate_render_environment()` for all three formats on supported setup | integration (guarded) | `Rscript -e "testthat::test_file('tests/testthat/test-yaml-integration.R')"` | ❌ Wave 0 (partial coverage; only working paper currently helper-driven) |
| ONB-01 | Scaffolded projects render successfully without manual fixes for all three formats | integration (guarded) | `Rscript -e "testthat::test_file('tests/testthat/test-yaml-integration.R')"` | ❌ Wave 0 (article/brief are template smoke, not create-helper flow) |

### Sampling Rate
- **Per task commit:** `Rscript -e "testthat::test_file('tests/testthat/test-scaffolding.R')"`
- **Per wave merge:** `Rscript -e "testthat::test_file('tests/testthat/test-yaml-integration.R')"`
- **Phase gate:** `Rscript -e "testthat::test_dir('tests/testthat')"` on Quarto-enabled environment before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] Extend `tests/testthat/test-yaml-integration.R` with helper-driven article and policy-brief `create_*` -> `validate_render_environment()` assertions.
- [ ] Extend `tests/testthat/test-yaml-integration.R` with helper-driven article and policy-brief render-success assertions (PDF exists) without manual edits.
- [ ] Add explicit assertion that inline onboarding comments do not break YAML parsing/render for each format after template updates.

## Sources

### Primary (HIGH confidence)
- Quarto extension metadata docs — `_extension.yml` fields and `quarto-required`: https://quarto.org/docs/extensions/distributing.html
- Quarto Typst docs — Typst rendering behavior and bundled Typst model: https://quarto.org/docs/output-formats/typst.html
- Quarto R package reference (`quarto_render`): https://quarto-dev.github.io/quarto-r/reference/quarto_render.html
- testthat skip reference: https://testthat.r-lib.org/reference/skip.html
- testthat skipping guidance: https://testthat.r-lib.org/articles/skipping.html
- fs copy semantics: https://fs.r-lib.org/reference/copy.html
- Local code evidence: `R/create_working_paper.R`, `R/create_article.R`, `R/create_policy_brief.R`, `R/render.R`, `R/validation_environment.R`, `tests/testthat/test-scaffolding.R`, `tests/testthat/test-yaml-integration.R`, `inst/templates/*/template.qmd`

### Secondary (MEDIUM confidence)
- Quarto front matter authoring guide (YAML structure and nested mappings): https://quarto.org/docs/authoring/front-matter.html
- CRAN mirror metadata queried via `tools::CRAN_package_db()` in local R runtime (version/date verification)

### Tertiary (LOW confidence)
- None used for core recommendations.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - versions verified from CRAN metadata and repository manifest constraints.
- Architecture: HIGH - directly derived from current implementation and existing Phase 6 validated contracts.
- Pitfalls: MEDIUM - strongly evidenced by current local environment (missing Quarto) and known YAML/test skip failure modes, but final ONB render behavior needs Quarto-enabled confirmation.

**Research date:** 2026-04-01
**Valid until:** 2026-05-01
