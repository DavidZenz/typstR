# Architecture Patterns

**Domain:** typstR v1.1 (Reliability and Onboarding Polish, brownfield)
**Researched:** 2026-03-31

## Recommended Architecture

v1.1 should add a **reliability orchestration layer in the R package** without changing typstR’s core output model (Quarto extension + Typst templates). The design goal is fail-fast behavior with actionable remediation, while preserving existing public workflows (`create_*()`, `render_pub()`, `render_working_paper()`).

### System Shape for v1.1

```text
Caller
  ├─ create_working_paper()/create_article()/create_policy_brief()
  │    └─ scaffold_project() [new internal helper]
  │         ├─ copy inst/templates/<variant>
  │         ├─ copy inst/quarto/extensions/typstR
  │         ├─ apply starter defaults (title + guidance)
  │         └─ run quick readiness checks (diagnostic warnings only)
  │
  └─ render_pub()/render_working_paper()
       ├─ resolve_input()
       ├─ validate_manuscript() [new exported API]
       │    └─ emits structured diagnostics (error/warn/info + fixes)
       ├─ quarto::quarto_render()
       └─ post-render verification (expected output + open behavior)
```

### Component Boundaries

| Component | Responsibility | Communicates With |
|-----------|---------------|-------------------|
| `R/diagnostics.R` (new) | Canonical diagnostic model (`code`, `severity`, `message`, `hint`, `context`) and formatting helpers | `R/validation.R`, `R/render.R`, `R/create_*.R` |
| `R/validation.R` (new) | Pre-render checks for runtime, project structure, YAML fields, metadata consistency, file references | `R/utils.R` (path/yaml helpers), `R/diagnostics.R`, `R/render.R` |
| `R/render.R` (existing, modified) | Orchestration: resolve input, run validation gate, invoke Quarto, surface failures truthfully | `R/validation.R`, `quarto` package, `R/utils.R` |
| `R/create_*.R` (existing, modified) | User entry points for scaffolding; delegate shared logic to one helper to prevent drift | `R/scaffold.R` (new internal) or `R/utils.R`, `inst/templates/`, `_extensions/` |
| `inst/templates/*` (existing, modified) | Starter content optimized for first successful render and clear user edits | `create_*()` |
| `inst/quarto/extensions/typstR/typst-show.typ` + `formats/*.typ` (existing) | Rendering contract target for validation rules (field names and accepted variants) | Quarto + Typst runtime |

## Data Flow

### Flow 1: Validation (new primary reliability path)

1. `validate_manuscript(input)` resolves a concrete `.qmd` path.
2. Build one `manuscript_context` object (single pass):
   - project root
   - `_extensions/typstR` presence
   - parsed YAML front matter
   - discovered referenced files (`bibliography`, `logo`, etc.)
   - selected variant (`typstR.format-variant`)
3. Run check modules against the shared context (no repeated parsing/walking).
4. Return `typstR_diagnostics` object:
   - machine-readable for tests/automation
   - human-readable via CLI bullets
5. Rendering gate consumes diagnostics:
   - errors: abort with remediation
   - warnings: continue (unless strict mode)

### Flow 2: Render control flow (existing path, hardened)

```text
render_pub()
  -> quarto availability/version checks
  -> resolve_input()
  -> validate_manuscript()
  -> if diagnostics$error_count > 0: abort with actionable report
  -> quarto::quarto_render()
  -> verify expected artifact exists
  -> open file (if requested and available)
```

### Flow 3: Scaffolding control flow (onboarding hardening)

```text
create_*()
  -> scaffold_project(variant, path, title, open)
  -> copy starter template + extension
  -> apply title replacement with success check
  -> print next-step commands (edit + render)
  -> optional post-scaffold readiness check (warning-only diagnostics)
```

## Integration Points for v1.1 Scope

### 1) Expanded Pre-render Validation Coverage

**Where it should live:** `R/validation.R` with small single-purpose checks.

**Checks to implement first (highest value):**
- runtime checks: Quarto present, minimum supported version (from `_extension.yml` contract)
- project structure checks: `.qmd` exists, `_extensions/typstR` exists
- file reference checks: `bibliography`, `typstR.logo`, other file-path metadata
- metadata consistency checks:
  - `author` present/non-empty
  - affiliation references resolve
  - `typstR.format-variant` in allowed set (`workingpaper`, `article`, `brief`)
  - field type checks for `keywords`, `jel`, booleans, margins
- render-intent checks:
  - warn when `render_working_paper()` is used with non-working-paper variant

### 2) Structured Diagnostics + Remediation

**Where it should live:** `R/diagnostics.R` plus thin adapters in `validation` and `render`.

**Recommended diagnostic shape:**

| Field | Purpose |
|------|---------|
| `code` | Stable identifier (e.g., `missing_extension`, `invalid_format_variant`) |
| `severity` | `error` / `warning` / `info` |
| `message` | What failed |
| `hint` | Exact remediation step |
| `file` / `field` | Precise location |
| `evidence` | Observed value/state |

This avoids brittle string matching in tests and prevents “plausible but vague” errors.

### 3) Scaffold Defaults / Starter Content Improvements

**Where it should live:** `inst/templates/*` content + shared scaffold helper used by all `create_*()` functions.

**Integration guidance:**
- extract repeated scaffolding logic into one internal helper (single source of truth)
- keep format-specific starter text in template files only
- enforce post-copy invariants centrally (expected files present, title replacement actually applied)
- add explicit “first render success” hints in scaffold output

### 4) Targeted Performance Improvements (Only Where Measured)

**Where it should live:**
- validation context builder (`R/validation.R`) — parse once, reuse
- render orchestration (`R/render.R`) — avoid duplicate checks/path scans
- scaffold helper — reduce repeated file-system calls and duplicated logic

**Measurement requirement:** add benchmark coverage (micro for hot helpers, integration timing for render+validate path) before and after changes.

## Build Order (Dependency-aware Decomposition)

1. **Diagnostics foundation (must be first)**
   - add diagnostic schema and constructors
   - add printer/formatter
   - no behavior change yet

2. **Validation engine over shared context**
   - implement `validate_manuscript()` and check modules
   - export `check_quarto()`, `check_typst()`, `check_typstR()` only after internal contract is stable

3. **Render integration gate**
   - wire validation into `render_pub()`
   - ensure render errors preserve root cause and remediation
   - add post-render artifact verification

4. **Scaffolding consolidation + onboarding updates**
   - extract shared scaffold logic
   - update starter templates/content for first-run success
   - ensure `open` behavior is truthful and tested

5. **Performance pass + regression guardrails**
   - benchmark modified paths
   - keep only optimizations with measurable gains

## Patterns to Follow

### Pattern 1: Single Context, Multiple Checks
**What:** Build one validated context object and run all checks from it.
**When:** Any `validate_manuscript()` execution.
**Why:** Prevent repeated YAML parsing and path walking.

### Pattern 2: Diagnostics as Data, Not Strings
**What:** Return structured diagnostic records and format for CLI at boundary.
**When:** Validation and render failures.
**Why:** Stable tests, better automation, clearer user remediation.

### Pattern 3: Shared Scaffolding Core
**What:** `create_*()` remain public wrappers; one internal scaffold implementation does the real work.
**When:** Any onboarding/starter change touching multiple formats.
**Why:** Prevent format drift and triple maintenance.

### Pattern 4: Additive API Evolution
**What:** Keep existing function signatures stable; add optional behavior via new args/defaults only if needed.
**When:** Integrating validation into render/scaffold.
**Why:** Brownfield safety for existing callers.

## Anti-Patterns to Avoid

### Anti-Pattern 1: Validation by `cli_abort()` Side Effects Alone
**Why bad:** Impossible to aggregate or test robustly.
**Instead:** Collect diagnostics, then decide whether to abort.

### Anti-Pattern 2: Re-reading Files Per Check
**Why bad:** Wasted IO and slower render path.
**Instead:** Shared context object with parsed metadata and resolved paths.

### Anti-Pattern 3: Silent Fallbacks on Invalid Metadata
**Why bad:** Users think settings applied when they were ignored.
**Instead:** Explicit warnings/errors for unknown variants/invalid fields.

### Anti-Pattern 4: Unmeasured “Performance” Refactors
**Why bad:** Risky churn without user-visible benefit.
**Instead:** Baseline -> change -> benchmark -> keep/drop.

## Silent-Failure Hotspots and Mitigations

| Hotspot (current) | What can silently fail | Mitigation in v1.1 | Target location |
|---|---|---|---|
| `create_*()` `open` argument | Argument is accepted but not acted on | Implement or remove behavior; add tests asserting effect | `R/create_*.R` + tests |
| Title prefill regex substitution | No title replacement if template line shape changes | Verify replacement count; emit diagnostic when zero | shared scaffold helper |
| `format-variant` handling | Invalid value can degrade to unintended layout | Validate against allowed enum; block render on invalid value | `R/validation.R` |
| `render_pub()` output-open path assumption | PDF may not exist at inferred path | Post-render existence check + warning with actual expected path | `R/render.R` |
| `logo` path escaping in Typst bridge | Path normalization may break certain user paths | Validate path early and warn on suspicious escaping/backslashes | `R/validation.R` + `typst-show.typ` contract checks |
| Unknown `typstR:` keys | User expects effect; key is ignored | Warn on unknown keys with close-match suggestions | `R/validation.R` |

## Scalability Considerations

| Concern | At single manuscript use | At CI/batch renders | At institute/team scale |
|---------|--------------------------|---------------------|-------------------------|
| Validation overhead | negligible | can accumulate if checks duplicate IO | enforce single-context architecture |
| Diagnostics signal/noise | interactive-friendly | needs machine-readable codes | stable codebook + severity filtering |
| Scaffold consistency | manual review catches drift | drift appears as flaky tests | shared scaffold core + snapshot tests |
| Quarto/Typst drift | one user can self-fix | CI failures block release | version checks + clear upgrade guidance |

## Roadmap Implications for v1.1

Recommended milestone decomposition:
1. **Reliability substrate:** diagnostics + validation context model
2. **Coverage expansion:** metadata/file/runtime checks and check_* exports
3. **Render hardening:** preflight gating + truthful failure propagation
4. **Onboarding polish:** shared scaffolder + starter template improvements
5. **Performance validation:** benchmark-driven optimizations only

This order minimizes risk: first build shared truth objects (diagnostics/context), then attach behavior at public entry points.

## Sources

### Codebase evidence (HIGH confidence)
- `.planning/PROJECT.md`
- `R/render.R`
- `R/utils.R`
- `R/create_working_paper.R`, `R/create_article.R`, `R/create_policy_brief.R`
- `inst/templates/workingpaper/template.qmd`
- `inst/templates/article/template.qmd`
- `inst/templates/policy-brief/template.qmd`
- `inst/quarto/extensions/typstR/_extension.yml`
- `inst/quarto/extensions/typstR/typst-show.typ`
- `inst/quarto/extensions/typstR/formats/*.typ`
- `tests/testthat/test-render-guards.R`
- `tests/testthat/test-scaffolding.R`
- `tests/testthat/test-yaml-integration.R`

### External references (MEDIUM/HIGH confidence)
- Quarto custom Typst formats: https://quarto.org/docs/output-formats/typst-custom.html
- Quarto format extensions: https://quarto.org/docs/extensions/formats.html
- quarto R `quarto_available()`: https://quarto-dev.github.io/quarto-r/reference/quarto_available.html
- quarto R `quarto_version()`: https://quarto-dev.github.io/quarto-r/reference/quarto_version.html
- rlang conditions and `abort()`: https://rlang.r-lib.org/reference/abort.html
- rlang chained conditions: https://rlang.r-lib.org/reference/topic-condition-chains.html
- testthat snapshot/condition testing: https://testthat.r-lib.org/
