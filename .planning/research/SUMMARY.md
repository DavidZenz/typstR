# Project Research Summary

**Project:** typstR
**Domain:** R package bundling Quarto extensions + Typst templates for scientific publishing
**Researched:** 2026-03-21
**Confidence:** HIGH

## Executive Summary

typstR is an R package that ships a Quarto extension and modular Typst templates to produce publication-quality PDFs for economics and policy research institutes. The core pattern — bundle the Quarto extension inside `inst/quarto/extensions/typstR/`, copy it into the user's project `_extensions/` directory at scaffold time, and pass all configuration through YAML front matter via `typst-show.typ` — is well-established, verified against production implementations, and directly supported by Quarto's extension architecture. The R layer is thin: scaffolding, metadata helpers, render wrappers, and pre-flight validation. The heavy lifting is done by Quarto and the Typst compiler bundled with it; typstR must not require users to install either separately beyond Quarto itself.

The recommended approach is to build in five sequential phases that respect a strict dependency order: the render pipeline must work end-to-end before metadata wiring can be tested; metadata wiring must be stable before the modular Typst template layer is meaningful; and additional formats (article, policy-brief) are thin overlays once the base layer exists. The primary differentiators versus competitors (rticles, quarto-preprint, apaquarto) are JEL codes as a first-class field, institutional YAML-driven branding, a project scaffolding function in R, and pre-render validation diagnostics — none of which exist in any current Typst-based solution. These are low-to-medium complexity additions once the base template layer is solid.

The critical risk is the multi-layer translation chain: YAML front matter → Pandoc metadata → `typst-show.typ` bridge → Typst function arguments → rendered PDF. Every field added to the user-facing YAML interface requires an explicit wiring step in `typst-show.typ`; omissions cause silent data loss with no error. Secondary risks are Quarto's per-project extension resolution (extensions must be physically copied into each project, not referenced from the installed package), Typst version lock (templates must target Quarto's bundled Typst version, not the latest standalone), and CRAN compliance (any call to `quarto render` must be guarded against environments where Quarto is absent).

## Key Findings

### Recommended Stack

The R runtime layer uses four production-stable CRAN packages: `cli` (3.6.x) for user-facing messages, `rlang` (1.1.x) for classed error conditions, `fs` (1.6.x) for cross-platform file operations, `yaml` (2.3.x) for metadata serialization, and the `quarto` R package (1.5.1) as the official Posit-maintained interface to the Quarto CLI. Minimum R version is 4.1.0, minimum Quarto CLI is 1.4.11 (first version supporting custom Typst format extensions). Typst is bundled with Quarto — users must not be required to install it separately. The development toolchain is the standard r-lib stack: roxygen2 7.3.x, testthat 3.x, withr, usethis, pkgdown.

**Core technologies:**
- R >= 4.1.0: package runtime — minimum required by quarto R package 1.5.1
- Quarto CLI >= 1.4.11: document rendering and Typst output — minimum for custom Typst format extensions; declare in `_extension.yml` as `quarto-required: ">=1.4.11"`
- Typst (Quarto-bundled): PDF typesetting — never require a separate Typst install; Quarto's bundled binary is the only target
- quarto R package 1.5.1: CLI wrapper — `quarto_render()`, `quarto_available()`, `project_path()`, path utilities
- cli + rlang + fs + yaml: R layer infrastructure — the r-lib standard set for CRAN-quality packages

### Expected Features

The workingpaper format is the primary MVP target: it must render title page (title, subtitle, report number, date), author and affiliation blocks with ORCID and corresponding-author markers, abstract, keywords, JEL codes, acknowledgements, funding declaration, bibliography, appendix, and figure/table captions with note helpers — all driven by YAML, requiring no Typst knowledge from the user. The one-function-call project scaffolding (`create_working_paper()`) and pre-render validation (`validate_manuscript()`) are the adoption hooks that no competitor provides.

**Must have (table stakes):**
- Multi-author + affiliation rendering — scientific papers require this; Quarto's normalized author schema handles the data; Typst template must render it correctly
- Abstract, keywords, bibliography, cross-references, section numbering, TOC — Quarto handles most of these natively; template must not interfere
- Figure and table captions, appendix support — standard; needs template work for correct appendix lettering
- ORCID, corresponding author designation, acknowledgements — low complexity, high user expectation

**Should have (competitive differentiators):**
- `create_working_paper()` scaffolding — the "one-minute setup"; primary adoption hook; zero direct competitors in R+Typst space
- JEL classification codes as first-class YAML field — domain-specific; no existing Quarto/Typst solution handles this
- Report number block — trivial implementation; uniquely meaningful to institute working paper series users
- Institutional branding via YAML (logo, font, color, footer) — highest-value differentiator; no competitors offer this without Typst editing
- `validate_manuscript()` diagnostics — pre-render error catching; reduces support burden; no competitor has this
- Anonymized / review mode — required for journal submission workflow; implemented in `article_typst` format
- `fig_note()` / `tab_note()` helpers — economics convention; no standard Quarto/Typst mechanism exists
- `render_pub()` wrapper — thin R-native entry point; low complexity, rounds out the R-first UX

**Defer (v2+):**
- `_brand.yml` deep integration — Quarto's brand API is new and evolving; wait for stability
- arXiv preprint style — only if adoption extends beyond economics institutes
- CRediT contributor taxonomy — relevant for biomedical/psychology; not the target audience
- Language localization of template strings — niche need; expose `lang:` passthrough only

### Architecture Approach

The architecture is a three-layer pipeline: R package layer (scaffolding, helpers, render wrappers, validation) → Quarto extension layer (`_extension.yml`, `typst-show.typ`, format YAMLs) → Typst template layer (modular `.typ` files per concern). All three layers communicate through the file system and YAML — there is no in-process communication between R and Typst. The constraint this imposes is that the extension must be physically present in `_extensions/typstR/` relative to the user's document at render time; `create_*()` functions must copy it there from `system.file()`. Branding and all user-configurable options flow entirely through YAML front matter → `typst-show.typ` → Typst function arguments; no user should ever need to open a `.typ` file.

**Major components:**
1. R scaffolding layer (`R/create_*.R`) — copies `inst/templates/` + `inst/quarto/extensions/typstR/` into new user project; creates self-contained, renderable project in one call
2. R metadata and helper layer (`R/metadata_helpers.R`, `R/notes_helpers.R`) — `author()`, `affiliation()`, `manuscript_meta()`, `fig_note()`, `tab_note()`, `jel_codes()` — produce correctly structured R objects that serialize to valid Quarto YAML
3. R render + validation layer (`R/render.R`, `R/validation.R`) — `render_pub()` calls `validate_manuscript()` first; validation catches missing files, missing extension, invalid logo path, missing bibliography before Quarto/Typst sees the document
4. Quarto extension (`inst/quarto/extensions/typstR/`) — `_extension.yml` declares formats; `typst-show.typ` wires YAML fields to Typst function arguments; per-format YAMLs set defaults
5. Modular Typst templates (`inst/quarto/extensions/typstR/templates/`) — `base.typ` imports and orchestrates: `titleblock.typ`, `authors.typ`, `abstract.typ`, `bibliography.typ`, `floats.typ`, `appendix.typ`, `branding.typ`
6. Project starter skeletons (`inst/templates/`) — copied by scaffolding functions; starter `.qmd`, `_quarto.yml`, `references.bib`, `logo.png` per format

### Critical Pitfalls

1. **Extension not copied into user project** — Quarto has no global extension registry; `create_*()` must unconditionally copy the full `_extensions/typstR/` tree from `system.file()` into every new project. This is the single most common failure point and produces a cryptic "Unknown format" error far from the root cause.

2. **YAML metadata silently not wired to Typst** — Every field in the `typstR:` YAML block must be explicitly mapped in `typst-show.typ` with a `none` default for optional fields. Missing entries produce no error — the field is simply absent from the rendered PDF. Standard Quarto fields (`toc`, `fig-cap-location`) are consumed by Pandoc and never reach `typst-show.typ`; keep all custom fields under the `typstR:` namespace.

3. **Typst version mismatch with Quarto's bundled binary** — Typst introduces breaking syntax changes between minor versions; Quarto locks to a specific Typst version per release. All `.typ` code must target the Typst version bundled in the minimum supported Quarto (currently 1.4.11+). Do not use `@preview` Typst package imports — they require network access.

4. **Vignettes that call `quarto render` will fail CRAN check** — CRAN machines have no Quarto installed. All render calls in vignettes must be wrapped with `if (quarto::quarto_available()) { ... }`, or vignettes must be pre-rendered and committed. `check_quarto()` must return FALSE gracefully, never `stop()` on a missing binary.

5. **Author/affiliation schema complexity causes silent data loss** — Quarto's normalized author schema remaps unrecognized keys under a `metadata:` sub-key rather than passing them through. Provide R helper functions (`author()`, `affiliation()`) to generate valid structure; test with 1 author, 3 authors, shared affiliation, corresponding author flag, ORCID, and equal contributors before declaring stable.

## Implications for Roadmap

Based on the dependency structure identified across all four research files, a five-phase build order is recommended. The key constraint is that each layer depends on the one below it being stable before it can be meaningfully tested.

### Phase 1: Package Skeleton and Render Pipeline

**Rationale:** Nothing else can be tested until an end-to-end render works. The Quarto → Typst → PDF pipeline is the foundational constraint. Building this first also validates the extension bundling approach and catches the most critical pitfall (extension discovery) immediately.

**Delivers:** An installable R package that scaffolds a working paper project, copies the extension, and produces a basic PDF. The skeleton `workingpaper_typst` format with minimal Typst template (title, body, bibliography) is enough to prove the pipeline.

**Addresses:** FEATURES.md P1 — `render_pub()`, `create_working_paper()`, one working format with bibliography

**Avoids:** Pitfall 1 (extension not copied) — must be correct from the start; Pitfall 2 (Typst version) — set `quarto-required` in `_extension.yml` from day one

**Research flag:** Standard pattern. The extension-copy scaffolding pattern is well-documented with multiple reference implementations. Skip `research-phase`.

### Phase 2: Metadata Helpers and YAML Interface

**Rationale:** The YAML → Typst wiring is the trickiest integration point in the stack and must be built systematically, not ad hoc. Building the `typstR:` YAML namespace, `author()` / `affiliation()` helpers, and `typst-show.typ` mappings as a cohesive unit prevents the silent data loss pitfall.

**Delivers:** All user-facing metadata helpers (`author()`, `affiliation()`, `manuscript_meta()`, `jel_codes()`, `keywords()`); complete `typst-show.typ` with explicit wiring for every supported field; R list serialization via `yaml::as.yaml()`.

**Addresses:** FEATURES.md P1 — authors, affiliations, ORCID, corresponding author, JEL codes, keywords, report number, acknowledgements, funding declaration

**Avoids:** Pitfall 3 (YAML not wired to Typst) — systematic mapping with `none` defaults; Pitfall 5 (author schema edge cases) — `author()` / `affiliation()` helpers enforce correct structure

**Research flag:** Needs attention. The `typst-show.typ` Pandoc variable interpolation behavior changed at Quarto 1.6 and has known fragility across versions. Validate the exact passthrough behavior for the `typstR:` namespace block against the minimum supported Quarto version before finalizing the metadata API. Use `/gsd:research-phase` if the quarto-dev discussion threads are unclear.

### Phase 3: Modular Typst Template Layer and Branding

**Rationale:** The Typst template modules require stable metadata input from Phase 2 to be implemented correctly. The modular structure (`base.typ` importing named sub-templates) must be established in this phase — refactoring a monolith later is the highest-cost recovery scenario identified in PITFALLS.md.

**Delivers:** Complete set of modular `.typ` files: `titleblock.typ`, `authors.typ`, `abstract.typ`, `bibliography.typ`, `floats.typ`, `appendix.typ`, `branding.typ`; `fig_note()` and `tab_note()` helpers; full branding YAML roundtrip (logo, accent color, font, footer text, margins).

**Addresses:** FEATURES.md P1 — institutional branding, appendix, figure/table captions and notes, complete title page layout

**Avoids:** Anti-pattern of monolithic Typst file (never acceptable per PITFALLS.md); hardcoded fonts or colors (all configurable via YAML); branding that requires editing `.typ` files

**Research flag:** Standard pattern for modular Typst with `#import`. Quarto's `template-partials:` mechanism is documented. The branding YAML integration has one known fragility point (Pandoc variable interpolation) already addressed in Phase 2. Skip `research-phase` for the Typst module structure itself.

### Phase 4: Additional Formats and Review Mode

**Rationale:** The `article_typst` and `policy_brief` formats share 80% of the base template layer built in Phase 3. They are thin overlays (format-specific `formats/*.yml`, modest `titleblock.typ` variants) once the base exists. Anonymized review mode is implemented here because it logically belongs to `article_typst` and the conflict with branding (branding must also suppress when `anonymized: true`) requires access to the full branding layer from Phase 3.

**Delivers:** `typstR-article` format with anonymized/review mode; `typstR-brief` format; `data_availability` and `code_availability` YAML fields; format-specific scaffolding functions (`create_article()`, `create_policy_brief()`).

**Addresses:** FEATURES.md P2 — article format, review mode, policy brief, data/code availability statements

**Avoids:** The `anonymized: true` + branding conflict — review mode must suppress both author metadata and institutional logo

**Research flag:** Standard pattern. Format variants are additive overlays. Anonymized mode follows the apaquarto pattern (confirmed HIGH confidence). Skip `research-phase`.

### Phase 5: Hardening, Validation, and CRAN Preparation

**Rationale:** Validation (`validate_manuscript()`, `check_quarto()`, `check_typst()`, `check_typstR()`) is most useful after all formats are stable and all metadata fields are defined — the validator needs to know what is required per format. CRAN compliance (vignette guards, `SystemRequirements`, no shell calls at load time) is a correctness concern but blocking on it early slows feature development.

**Delivers:** Full `validate_manuscript()` implementation with per-format required-field knowledge; all `check_*()` functions returning structured results (not `stop()`); CRAN-compliant vignettes with `quarto_available()` guards; full test suite with `withr::local_tempdir()` isolation; `R CMD check` clean on machines without Quarto; pkgdown documentation site.

**Addresses:** FEATURES.md P1 — `validate_manuscript()` diagnostics; PITFALLS.md Pitfall 4 — CRAN check failure from unguarded render calls

**Avoids:** Performance traps (no `quarto --version` at load time; extension copied only during scaffold, not render); CRAN rejection for unguarded vignettes

**Research flag:** Standard pattern. CRAN compliance for system-dependency packages is well-documented. testthat 3 + withr patterns are established. Skip `research-phase`.

### Phase Ordering Rationale

- **Pipeline before metadata:** You cannot test YAML wiring without a working render pipeline. Phase 1 must precede Phase 2.
- **Metadata before templates:** The Typst template modules are parameterized functions; they need the metadata they will receive to be defined before their interfaces can be finalized. Phase 2 must precede Phase 3.
- **Base template before format variants:** Phases 4's format overlays are 20% of the work because Phase 3 provides 80%. This order minimizes rework.
- **Hardening last:** Validation is most useful after the full feature surface is known. CRAN compliance concerns are real but do not block feature development if guarded correctly from day one.
- **Pitfall 1 is addressed in Phase 1, not Phase 5:** Extension copying is a correctness requirement for the scaffold function, not a hardening concern. Getting it wrong in Phase 1 means every subsequent integration test is broken.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 2 (Metadata/YAML interface):** The `typst-show.typ` Pandoc variable interpolation for nested YAML blocks (the `typstR:` namespace) has known version-specific behavior changes (Quarto 1.6 issue #10212). Validate exact behavior before finalizing the metadata API contract. Inspect the quarto-dev/quarto-cli discussion #11459 and issue #10212 directly.

Phases with standard patterns (skip research-phase):
- **Phase 1 (Pipeline skeleton):** Extension-copy scaffolding is the established pattern; multiple production implementations exist.
- **Phase 3 (Modular Typst):** `#import`-based modular templates are documented and verified in `quarto-ext/typst-templates`.
- **Phase 4 (Additional formats):** Format variants as additive YAML overlays are well-documented.
- **Phase 5 (Hardening/CRAN):** CRAN compliance for system-dependency packages follows established r-lib patterns.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All versions confirmed from CRAN and official Quarto docs; no speculation |
| Features | HIGH | Competitor landscape directly inspected; gap analysis confirmed against quarto-preprint, rticles, apaquarto, reproducr |
| Architecture | HIGH | Three-layer pattern verified against quarto-ext/typst-templates, quarto-awesomecv-typst, and official Quarto extension docs |
| Pitfalls | MEDIUM-HIGH | Critical pitfalls verified against official docs and maintainer-confirmed GitHub discussions; some community sources |

**Overall confidence:** HIGH

### Gaps to Address

- **Pandoc variable interpolation for nested YAML blocks:** The `typstR:` namespace passthrough in `typst-show.typ` is the only area with documented fragility across Quarto versions. Before finalizing the metadata API, validate that nested YAML keys (`typstR.accent-color`, `typstR.jel`) survive the Pandoc metadata pipeline for Quarto 1.4.11 through 1.9. If behavior differs, the API design may need to flatten the namespace.

- **Typst version for minimum supported Quarto:** The research notes Quarto 1.9 bundles Typst ~0.12–0.13, and a Typst 0.14.2 upgrade is in progress. The exact Typst version bundled in Quarto 1.4.11 (minimum) is not pinned in the research. Template code must be validated against that floor version, not the current Quarto stable. Confirm from the Quarto changelog before writing any Typst syntax that appeared after 0.11.

- **rstudioapi as optional dependency:** `create_working_paper()` calls `rstudioapi::openProject()` in interactive sessions. The `rstudioapi` package is not listed in DESCRIPTION Imports. The correct pattern is `if (requireNamespace("rstudioapi", quietly = TRUE) && interactive())`. Confirm this is the approach before Phase 1 ships.

## Sources

### Primary (HIGH confidence)
- [Quarto Custom Typst Formats](https://quarto.org/docs/output-formats/typst-custom.html) — extension file structure, format definitions, `typst-show.typ` pattern
- [Quarto 1.9 Release Notes](https://quarto.org/docs/download/release.html) — current stable version, bundled Typst version
- [quarto R package 1.5.1 on CRAN](https://cran.r-project.org/web/packages/quarto/index.html) — version, R minimum, `quarto_render()`, `quarto_available()`
- [quarto R package 1.5.0 blog post](https://quarto.org/docs/blog/posts/2025-07-28-r-package-release-1.5/) — new functions: `write_yaml_metadata_block()`, `project_path()`
- [Quarto Managing Extensions](https://quarto.org/docs/extensions/managing.html) — confirmed per-project extension model, no global registry
- [quarto-dev/quarto-cli discussion #8098](https://github.com/quarto-dev/quarto-cli/discussions/8098) — maintainer confirmed no global extension install
- [quarto-ext/typst-templates](https://github.com/quarto-ext/typst-templates) — official reference implementations
- [Authors & Affiliations — Quarto Journals](https://quarto.org/docs/journals/authors.html) — official author schema

### Secondary (MEDIUM confidence)
- [quarto-preprint GitHub](https://github.com/mvuorre/quarto-preprint) — competitor feature gap analysis; confirms no JEL, no branding, no diagnostics
- [apaquarto options](https://wjschne.github.io/apaquarto/options.html) — anonymized mode pattern, CRediT implementation reference
- [quarto-awesomecv-typst](https://github.com/kazuyanagimoto/quarto-awesomecv-typst) — production R + Quarto + Typst integration pattern
- [quarto-dev/quarto-cli issue #10212](https://github.com/quarto-dev/quarto-cli/issues/10212) — confirmed Quarto 1.6 Typst variable interpolation behavior change
- [quarto-dev/quarto-cli discussion #11459](https://github.com/quarto-dev/quarto-cli/discussions/11459) — standard Quarto fields not passed through to Typst templates
- [quarto-dev/discussions #13637](https://github.com/orgs/quarto-dev/discussions/13637) — Typst 0.14.2 upgrade in progress (timing uncertain)
- [Spencer Schien — Including Quarto Template in R Package](https://spencerschien.info/post/r_for_nonprofits/quarto_template/) — practical bundling pattern
- [Meghan Hall — Designing Internal Quarto Templates](https://meghan.rbind.io/blog/2024-08-14-quarto-templates/) — 2024 current pattern

### Tertiary (LOW confidence / needs validation during implementation)
- [reproducr package](https://jschultecloos.github.io/reproducr/) — blinding mode reference; GitHub-only, not CRAN
- [typr R package](https://r-packages.io/packages/typr) — confirmed scope: Typst CLI wrapper only, not a competitor

---
*Research completed: 2026-03-21*
*Ready for roadmap: yes*
