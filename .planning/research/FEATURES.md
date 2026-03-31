# Feature Landscape

**Domain:** typstR v1.1 (Reliability + Onboarding Polish, brownfield)
**Researched:** 2026-03-31
**Confidence:** MEDIUM-HIGH (strong internal codebase evidence + official docs for Quarto/cli/testthat tooling)

## Milestone Scope Boundary (v1.1)

This milestone should improve **failure quality and first-run success** of the existing three-format package.

**In scope:**
- Pre-render validation coverage expansion (setup + manuscript + metadata consistency)
- Structured diagnostics with concrete remediation hints
- Starter/scaffold defaults that render successfully on first run
- Targeted, measured performance improvements in helper/render paths

**Out of scope for this milestone:**
- Net-new major publication formats or journal template expansion
- Changes that alter output semantics of existing formats
- Broad architecture rewrites (keep brownfield integration with current R package + Quarto extension + Typst templates)

---

## Table Stakes

Features users should reasonably expect in a reliability/onboarding polish release.

| ID | Category | Feature | Why Expected | Complexity | Dependency Notes | User-Observable Acceptance |
|---|---|---|---|---|---|---|
| TS-VAL-01 | Validation | **Pre-render environment checks** (`quarto`, typst backend availability, required extension presence) | Current `render_*()` path fails late; users expect immediate setup diagnosis | MEDIUM | Depends on stable environment probe layer reused by render wrappers | Running `render_working_paper()` in a broken environment fails fast with actionable message before render starts |
| TS-VAL-02 | Validation | **Document structure checks** (`.qmd` detect, single-target resolution, `_extensions/typstR` sanity) | Current helpers already resolve input paths; users expect deterministic failure when project shape is wrong | LOW-MEDIUM | Extends `resolve_input()` path logic and scaffold assumptions | Wrong project structure returns explicit error with file/path references |
| TS-VAL-03 | Validation | **Metadata consistency checks from YAML** (required fields per variant, affiliation ref integrity, key/type checks) | Many users edit YAML directly and bypass helper constructors | HIGH | Depends on format-variant rule catalog and Typst bridge keys in `typst-show.typ` | Invalid YAML metadata yields targeted diagnostics (field + expected shape + fix) |
| TS-DIAG-01 | Diagnostics UX | **Structured diagnostics model** (severity, code, message, hint, location) | Ad-hoc strings are hard to test and hard to triage | MEDIUM | Foundation for all validator checks; should be reused by check/render entry points | Validation returns machine-testable issue set and human-readable summary |
| TS-DIAG-02 | Diagnostics UX | **Concrete remediation hints** (exact key names, file paths, command suggestions) | v1.1 goal explicitly calls for actionable guidance | MEDIUM | Requires per-check hint templates and key dictionary | Error output includes “what to change” (not just “what failed”) |
| TS-ONB-01 | Onboarding/Scaffold | **First-render-safe scaffolds** (starter content + references + metadata pass validation out of the box) | New users should succeed without reading internals | LOW-MEDIUM | Depends on validator integration in CI against shipped templates | Fresh `create_*()` project renders cleanly on supported setup |
| TS-ONB-02 | Onboarding/Scaffold | **Starter content tuned for common edits** (clear placeholders, fewer near-miss YAML keys) | Current onboarding is good but still vulnerable to YAML typo friction | LOW | Template edits only; should preserve current format semantics | Users can replace title/authors/content without breaking metadata wiring |
| TS-PERF-01 | Performance | **Measured optimization budget for render/helper hot paths** | Performance work must be evidence-driven, not speculative | MEDIUM | Requires benchmark harness and baseline snapshots before code changes | Benchmarks show measurable improvement on selected hot paths with no output behavior change |
| TS-PERF-02 | Performance | **No redundant expensive operations in wrappers** (avoid repeated filesystem scans/copies/checks within one render call) | Brownfield package should remove avoidable overhead before adding complexity | LOW-MEDIUM | Depends on call-path audit of `render.R`, scaffolding copy logic, and extension checks | Render call performs only necessary checks once; benchmark confirms reduced overhead |

---

## Differentiators

Features that can make v1.1 feel substantially better than “just more checks.”

| ID | Category | Feature | Value Proposition | Complexity | Notes |
|---|---|---|---|---|---|
| DF-DIAG-01 | Diagnostics UX | **Near-miss key detection** (e.g., `accent_color` → `accent-color`, `report_number` → `report-number`) | Prevents common YAML typo loops; high perceived polish | MEDIUM | Especially relevant given branding/docs examples and hyphenated key usage |
| DF-DIAG-02 | Diagnostics UX | **Grouped report output** (Errors vs Warnings vs Info, stable ordering) | Faster triage for users and maintainers; simpler snapshot testing | LOW-MEDIUM | Works well with `cli` bullets + testthat snapshot expectations |
| DF-ONB-01 | Onboarding | **Validation-first onboarding command pattern** (`validate` before render in docs/starter comments) | Teaches safe workflow and reduces “mystery render failure” support burden | LOW | Documentation + starter guidance + optional render preflight hook |
| DF-PERF-01 | Performance | **Regression-safe perf gates** (bench snapshots in CI for selected paths) | Protects gains from later regressions; confidence for future refactors | MEDIUM-HIGH | Needs stable benchmark scenarios and tolerance thresholds |

---

## Candidate Requirement Set for v1.1 Roadmap

Prioritized, category-balanced requirements that are directly testable.

| Priority | Req ID | Requirement | Category | Complexity | Depends On |
|---|---|---|---|---|---|
| P1 | RQ-VAL-ENV | Implement `check_quarto()/check_typst()/check_typstR()` style environment probes with actionable results | Validation | MEDIUM | TS-VAL-01, TS-DIAG-01 |
| P1 | RQ-VAL-META | Add YAML-driven metadata and consistency validation for all current variants (workingpaper/article/brief) | Validation | HIGH | TS-VAL-03, TS-DIAG-01 |
| P1 | RQ-DIAG-HINT | Introduce structured diagnostics schema with remediation hints and stable issue codes | Diagnostics UX | MEDIUM | TS-DIAG-01 |
| P1 | RQ-ONB-FIRST | Ensure every scaffolded starter renders and validates successfully in CI on supported setup | Onboarding | MEDIUM | TS-ONB-01, RQ-VAL-META |
| P2 | RQ-DIAG-NM | Add near-miss key suggestions for frequent YAML mistakes | Diagnostics UX | MEDIUM | DF-DIAG-01 |
| P2 | RQ-ONB-TPL | Tighten template defaults/placeholders to reduce first-edit failure probability | Onboarding | LOW | TS-ONB-02 |
| P2 | RQ-PERF-HOT | Profile helper/render paths and optimize top measurable hotspots without changing output semantics | Performance | MEDIUM | TS-PERF-01 |
| P3 | RQ-PERF-GATE | Add lightweight performance regression checks for selected stable benchmarks | Performance | MEDIUM-HIGH | DF-PERF-01, RQ-PERF-HOT |

---

## Anti-Features (Explicitly Avoid in v1.1)

| Anti-Feature | Why Avoid | What To Do Instead |
|---|---|---|
| Adding major new output formats or large journal-template catalog | Violates milestone goal; dilutes reliability/onboarding investment | Keep format surface fixed; improve validation and DX on existing formats |
| Silent auto-mutation of user manuscripts/YAML during validation | High trust risk; can hide errors and create hard-to-debug drift | Report exact issue + suggested fix; keep user edits explicit |
| Live preview daemon/watcher subsystem | High complexity, not required for reliability milestone | Continue leveraging Quarto’s existing preview/render tooling |
| Performance changes without benchmark baseline and acceptance threshold | Creates churn with no proof of user benefit | Require before/after measurement on defined scenarios |
| Dependency-heavy “auto-install everything” behavior in render path | Fragile in CRAN/user environments; can fail unpredictably | Detect and report missing dependencies with clear remediation commands |

---

## Feature Dependencies

```text
Structured diagnostics schema (RQ-DIAG-HINT)
  -> enables environment checks (RQ-VAL-ENV)
  -> enables metadata consistency checks (RQ-VAL-META)
  -> enables near-miss hints (RQ-DIAG-NM)

Metadata rule catalog by format variant (RQ-VAL-META)
  -> required for scaffold first-run guarantees (RQ-ONB-FIRST)
  -> required for template hardening work (RQ-ONB-TPL)

Benchmark harness + hotspot profiling (RQ-PERF-HOT)
  -> prerequisite for perf regression gates (RQ-PERF-GATE)
```

### Dependency Notes

- **Do diagnostics before adding many checks.** Without stable issue shape/codes, tests become string-fragile and roadmap phases will churn.
- **Do metadata validation before onboarding hardening.** You can’t claim first-run success unless the validator encodes expected metadata truth for each variant.
- **Do profiling before optimization.** Existing code already avoids some heavy work in render paths; optimize only confirmed hotspots.

---

## MVP Recommendation (v1.1)

Prioritize these for milestone completion:
1. **RQ-DIAG-HINT** (diagnostic contract)
2. **RQ-VAL-ENV** + **RQ-VAL-META** (fast-fail coverage)
3. **RQ-ONB-FIRST** (starter render/validate green path)
4. **RQ-PERF-HOT** (measurable hotspot improvements only)

Defer to late milestone / next milestone:
- **RQ-PERF-GATE** (if benchmark stability for CI is not yet reliable)

---

## Sources

### Internal codebase evidence (HIGH confidence)
- `.planning/PROJECT.md` (v1.1 goal and scope constraints)
- `R/render.R`, `R/utils.R`, `R/create_*.R` (current render/scaffold behavior)
- `inst/templates/*/template.qmd` (starter defaults and likely first-run friction points)
- `inst/quarto/extensions/typstR/typst-show.typ` (authoritative metadata key surface)
- `tests/testthat/test-render-guards.R`, `test-scaffolding.R`, `test-yaml-integration.R` (current behavioral guarantees)

### Official docs (MEDIUM-HIGH confidence)
- Quarto command reference (`quarto check`): https://quarto.org/docs/reference/commands/check.html
- Quarto Typst custom formats / template partials: https://quarto.org/docs/output-formats/typst-custom.html
- Quarto extensions overview: https://quarto.org/docs/extensions/
- Quarto R render API (`quarto::quarto_render`): https://quarto-dev.github.io/quarto-r/reference/quarto_render.html
- cli diagnostics primitives: https://cli.r-lib.org/reference/cli_abort.html and https://cli.r-lib.org/reference/cli_bullets.html
- rlang condition signaling: https://rlang.r-lib.org/reference/abort.html
- testthat snapshot testing (diagnostic output stabilization): https://testthat.r-lib.org/reference/expect_snapshot.html
- bench microbenchmarking: https://bench.r-lib.org/reference/mark.html
- profvis profiling: https://profvis.r-lib.org/
