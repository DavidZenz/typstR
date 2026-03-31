# Technology Stack — typstR v1.1 (Reliability + Onboarding Polish)

**Project:** typstR  
**Milestone:** v1.1 (Reliability and Onboarding Polish)  
**Researched:** 2026-03-31  
**Scope:** pre-render validation, structured diagnostics, scaffold onboarding defaults, measurable helper/render performance  
**Overall confidence:** HIGH (core stack and architecture fit), MEDIUM (point-in-time package version snapshots)

---

## v1.1 Stack Decisions (Opinionated)

1. **Keep runtime dependencies minimal; do not introduce a new validation framework.**
2. **Promote `yaml` to `Imports`** for runtime manuscript/front-matter checks (currently in `Suggests`).
3. **Use `cli` condition metadata for structured diagnostics** (error class + fields + remediation hints), not a new diagnostics package.
4. **Add `bench` as dev/test-only (`Suggests`)** for measurable performance work; never required at runtime.
5. **Keep Quarto-dependent tests explicitly skippable** (already done) so CI/CRAN can run without Quarto.

---

## Recommended Stack for v1.1

### Runtime (user-facing)

| Technology | Version Constraint | Purpose in v1.1 | Integration Notes |
|---|---:|---|---|
| R | `>= 4.1.0` | Baseline runtime | Matches `quarto` package requirement; no change needed. |
| cli | `>= 3.6.0` | Human-readable + structured diagnostics | Keep using `cli::cli_abort()`/`cli_warn()`; attach machine-parseable fields (e.g., `class`, `field`, `hint`, `example`) in condition metadata. |
| fs | `>= 1.6.0` | Fast, cross-platform path/file checks | Continue using for file existence and scaffold checks in pre-render validation. |
| quarto (R pkg) | `>= 1.4` | Render backend + Quarto availability checks | Keep as render entry point (`quarto::quarto_render()`); do **not** shell out directly. |
| yaml | **`>= 2.3.10`** | Runtime parsing of YAML front matter during validation | **Move from `Suggests` to `Imports`** for deterministic pre-render metadata checks and onboarding diagnostics. |

### Dev/Test-only (NOT runtime)

| Tool | Version Constraint | Why in v1.1 | Usage Boundary |
|---|---:|---|---|
| testthat | `>= 3.0.0` | Validation and diagnostics behavior tests | Keep unit tests Quarto-free where possible; integration tests only when rendering is required. |
| withr | current | Isolated temp projects and env control | Keep for scaffold and validation isolation. |
| bench | `>= 1.1.4` | Quantify helper/render overhead before/after changes | Add to `Suggests`; run in perf scripts/tests guarded by opt-in env vars, not on CRAN. |

---

## Version/Compatibility Constraints to Enforce

### 1) Quarto package version vs Quarto CLI version
`DESCRIPTION` currently constrains the **R package** (`quarto >= 1.4`), while extension manifest constrains the **CLI** (`inst/quarto/extensions/typstR/_extension.yml` has `quarto-required: ">=1.4.11"`).

**v1.1 guidance:**
- Keep R package dependency (`quarto >= 1.4`) for API stability.
- Add/maintain explicit runtime CLI version check in validation preflight and diagnostics.
- Error message should clearly separate:
  - "R package installed"
  - "Quarto CLI missing/too old"

### 2) CRAN/CI behavior when Quarto is absent
Quarto is a system requirement; not all CI agents (or CRAN environments) have it.

**v1.1 guidance:**
- Keep current test pattern: `requireNamespace("quarto", quietly = TRUE) && quarto::quarto_available()`.
- Validation logic that does not require rendering must stay runnable without Quarto.
- Render integration tests remain conditionally skipped (not silently passing).

---

## Integration Guidance with Current typstR Architecture

| Layer | Keep | Add/Change for v1.1 |
|---|---|---|
| **R package layer** (`R/`) | Existing render/scaffold architecture | Add a dedicated validation+diagnostic core that returns structured condition metadata and remediation hints. |
| **Quarto extension layer** (`inst/quarto/extensions/typstR/`) | Existing extension packaging model | No new extension framework; only compatibility checks + clearer failure messaging tied to `quarto-required`. |
| **Template/scaffold layer** (`inst/templates/`) | Existing starter templates and copy flow | Improve starter defaults/content only; do not introduce new output format families. |

**Practical integration rules:**
- Run pre-render validation before `quarto::quarto_render()`.
- Emit one canonical diagnostic schema (same fields for setup errors and manuscript errors).
- Keep diagnostics in R layer; Typst templates remain presentation-focused.

---

## What NOT to Add (Scope Creep Guardrails)

| Do NOT add | Why not for v1.1 | Do instead |
|---|---|---|
| New runtime validation frameworks (`checkmate`, `assertthat`, `validate`, etc.) | Duplicates existing domain-specific checks; adds dependency surface without solving remediation quality | Implement typstR-specific checks + structured condition metadata using existing stack (`cli` + base types + `yaml`). |
| Direct process orchestration (`processx`/`callr`) for render path | Splits render behavior and increases platform risk | Keep single render path via `quarto::quarto_render()`. |
| Hard dependency on standalone Typst CLI | Conflicts with current Quarto-first packaging and onboarding simplicity | Continue relying on Quarto-managed Typst toolchain. |
| New output formats / journal-specific engines | Explicitly out of scope for v1.1 | Focus only on reliability/onboarding for existing formats. |
| Runtime profiling/caching frameworks (`profvis`, `memoise`) as defaults | Premature complexity without measured bottleneck evidence | Benchmark first (`bench`), optimize hot paths directly, keep semantics unchanged. |

---

## Suggested DESCRIPTION delta for v1.1

```yaml
Imports:
  cli (>= 3.6.0)
  fs (>= 1.6.0)
  quarto (>= 1.4)
  yaml (>= 2.3.10)   # move from Suggests to Imports

Suggests:
  testthat (>= 3.0.0)
  withr
  bench (>= 1.1.4)   # new, dev/perf only
```

---

## Confidence by Area

| Area | Confidence | Why |
|---|---|---|
| Runtime dependency decisions | HIGH | Directly aligned with current codebase and v1.1 scope. |
| Quarto/CRAN compatibility guidance | HIGH | Matches current test patterns and CRAN policy constraints on external software. |
| Performance tooling choice (`bench`) | MEDIUM-HIGH | Strong ecosystem fit; benchmark thresholds still project-specific. |
| Version snapshots | MEDIUM | Package versions evolve; constraints should use minima + periodic refresh. |

---

## Sources

- Quarto custom format extensions and Typst format docs:  
  https://quarto.org/docs/extensions/formats.html  
  https://quarto.org/docs/output-formats/typst-custom.html
- typstR extension manifest (`quarto-required`):  
  `inst/quarto/extensions/typstR/_extension.yml` (repository)
- CRAN `quarto` package metadata (R version/system requirement/dependencies):  
  https://cran.r-project.org/web/packages/quarto/index.html
- CRAN `yaml` package metadata:  
  https://cran.r-project.org/web/packages/yaml/index.html
- CRAN `bench` package metadata:  
  https://cran.r-project.org/web/packages/bench/index.html
- `cli` conditions API (`cli_abort`):  
  https://cli.r-lib.org/reference/cli_abort.html
- `testthat` skip helpers:  
  https://testthat.r-lib.org/reference/skip.html
- CRAN repository policy and Writing R Extensions (external software/testing constraints):  
  https://cran.r-project.org/web/packages/policies.html  
  https://stat.ethz.ch/R-manual/R-devel/doc/manual/R-exts.html
