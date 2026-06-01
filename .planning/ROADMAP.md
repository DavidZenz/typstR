# Roadmap: typstR

## Overview

**Active milestone:** v1.2 — Documentation and Website Polish (Phases 11-13)

Goal: A live, polished pkgdown site at `https://davidzenz.github.io/typstR/` that lets a researcher follow a canonical install → scaffold → render onboarding path without friction. No new R package features ship in this milestone.

## Milestones

- SHIPPED **v1.0 Foundation and CRAN Release** — Phases 1-4 (shipped 2026-03-23)
- SHIPPED **v1.1 Reliability and Onboarding Polish** — Phases 5-10 (shipped 2026-05-06)
- ACTIVE **v1.2 Documentation and Website Polish** — Phases 11-13

## Phases

- [x] **Phase 1: Skeleton and Pipeline** - Scaffold and render a working paper end-to-end.
- [x] **Phase 2: Metadata Helpers and YAML Interface** - Express publication metadata in R/YAML and carry it into output.
- [x] **Phase 3: Typst Templates, Branding, and Additional Formats** - Deliver modular templates and format variants with branding hooks.
- [x] **Phase 4: Tests, Documentation, and CRAN Hardening** - Finalize quality, docs, and release readiness.
- [x] **Phase 5: Structured Diagnostics Foundation** - Standardize user-facing diagnostics schema for validation failures.
- [x] **Phase 6: Pre-render Environment Validation** - Validate Quarto/Typst/runtime prerequisites before render starts.
- [x] **Phase 7: First-run Onboarding Reliability** - Ensure scaffolded starters validate and render successfully without manual fixes.
- [x] **Phase 8: Measured Performance Optimization** - Improve selected hotspots with benchmarked gains and unchanged semantics.
- [x] **Phase 9: Audit Traceability and Validation Artifact Closure** - Close milestone-audit evidence gaps and align verification artifacts with delivered requirements.
- [x] **Phase 10: Supported-Environment Verification Closure** - Capture Quarto-enabled and bench-enabled runtime evidence needed to close milestone verification.
- [ ] **Phase 11: Documentation Content Foundation** - Polish all source artifacts pkgdown consumes into a coherent, onboarding-first single voice.
- [ ] **Phase 12: Site Configuration and Local Validation** - Build and locally validate a fully configured pkgdown site with zero warnings.
- [ ] **Phase 13: CI/CD Deployment and Live Site** - Deploy the site via GitHub Actions and confirm the live public URL.

## Phase Details

<details>
<summary>SHIPPED v1.0 Foundation and CRAN Release (Phases 1-4) — 2026-03-23</summary>

### Phase 1: Skeleton and Pipeline
**Goal**: Users can scaffold a working paper and render a baseline PDF.
**Depends on**: Nothing (first phase)
**Requirements**: Archived in milestone v1.0
**Success Criteria** (what must be TRUE):
  1. User can create a new project scaffold with required template and extension files.
  2. User can render a scaffolded working paper to PDF through typstR wrappers.
**Plans**: 3 plans

Plans:
- [x] 01-01: Package skeleton and extension packaging
- [x] 01-02: Project scaffolding path
- [x] 01-03: Render wrapper path

### Phase 2: Metadata Helpers and YAML Interface
**Goal**: Users can define manuscript metadata through R helpers and YAML.
**Depends on**: Phase 1
**Requirements**: Archived in milestone v1.0
**Success Criteria** (what must be TRUE):
  1. User-defined metadata helpers emit valid structures for manuscript fields.
  2. Metadata declared in YAML appears correctly in rendered output.
**Plans**: 4 plans

Plans:
- [x] 02-01: Core metadata object helpers
- [x] 02-02: YAML integration path
- [x] 02-03: Template metadata rendering integration
- [x] 02-04: Metadata validation and docs

### Phase 3: Typst Templates, Branding, and Additional Formats
**Goal**: Users can produce branded outputs across working paper, article, and policy brief formats.
**Depends on**: Phase 2
**Requirements**: Archived in milestone v1.0
**Success Criteria** (what must be TRUE):
  1. User can render all three supported formats from typstR scaffolds.
  2. Branding controls in YAML change output styling without editing Typst internals.
**Plans**: 5 plans

Plans:
- [x] 03-01: Modular template architecture
- [x] 03-02: Branding hook implementation
- [x] 03-03: Additional format support
- [x] 03-04: Format-specific behavior hardening
- [x] 03-05: End-to-end format verification

### Phase 4: Tests, Documentation, and CRAN Hardening
**Goal**: typstR remains release-ready with robust checks and onboarding documentation.
**Depends on**: Phase 3
**Requirements**: Archived in milestone v1.0
**Success Criteria** (what must be TRUE):
  1. Package checks and tests pass under supported CI/CRAN constraints.
  2. Users can follow docs/vignettes to complete a scaffold-to-render flow.
**Plans**: 6 plans

Plans:
- [x] 04-01: Test coverage expansion
- [x] 04-02: Documentation and README hardening
- [x] 04-03: Vignette updates
- [x] 04-04: CRAN compliance checks
- [x] 04-05: Final QA pass
- [x] 04-06: Milestone completion packaging

</details>

<details>
<summary>SHIPPED v1.1 Reliability and Onboarding Polish (Phases 5-10) — 2026-05-06</summary>

**Milestone Goal:** Users get truthful pre-render diagnostics, reliable first-run scaffolds, and faster hotspots without output changes, with audit-complete evidence for milestone archive.

### Phase 5: Structured Diagnostics Foundation
**Goal**: Users receive structured diagnostics with stable fields for validation issues.
**Depends on**: Phase 4
**Requirements**: DIAG-01
**Success Criteria** (what must be TRUE):
  1. Validation failures surface diagnostics that always include code, severity, location, and hint fields.
  2. The same issue class produces the same diagnostic code across repeated runs.
  3. Multiple issues are reported as structured entries rather than collapsed prose.
**Plans**: 2 plans

Plans:
- [x] 05-01-PLAN.md — Define diagnostics contract, immutable codebook, and deterministic ordering helpers with dedicated contract tests.
- [x] 05-02-PLAN.md — Wire diagnostics into render/input failure paths and migrate message-only tests to class+payload assertions without breaking no-Quarto safety.

### Phase 6: Pre-render Environment Validation
**Goal**: Users can run pre-render validation that truthfully reports environment readiness before render begins.
**Depends on**: Phase 5
**Requirements**: VAL-01
**Success Criteria** (what must be TRUE):
  1. User can run pre-render validation before render and receive a clear pass/fail outcome.
  2. Validation reports Quarto and Typst availability plus detected versions.
  3. Validation flags Quarto version-floor incompatibility before any render attempt.
  4. Validation flags missing typstR extension presence before render begins.
**Plans**: 2 plans

Plans:
- [x] 06-01-PLAN.md — Define standalone environment-validation contract, stable diagnostics codes, and structured success report semantics.
- [x] 06-02-PLAN.md — Cut over render preflight to shared validator and verify parity across guard/integration tests.

### Phase 7: First-run Onboarding Reliability
**Goal**: Users can scaffold any supported format and succeed on the first validation+render run without manual template repair.
**Depends on**: Phase 6
**Requirements**: ONB-01
**Success Criteria** (what must be TRUE):
  1. User can scaffold working paper, article, and policy brief starters through typstR create helpers.
  2. Freshly scaffolded projects pass validation on a supported setup without manual template fixes.
  3. Freshly scaffolded projects render successfully on a supported setup without manual template fixes.
**Plans**: 2 plans

Plans:
- [x] 07-01-PLAN.md — Lock cross-format starter contracts and align hybrid runnable template defaults with inline onboarding guidance.
- [x] 07-02-PLAN.md — Prove helper-driven scaffold → validate → render first-run success for working paper, article, and policy brief.

### Phase 8: Measured Performance Optimization
**Goal**: Users observe measurable speed improvements in selected helper/render hotspots with no output semantics changes.
**Depends on**: Phase 7
**Requirements**: PERF-01
**Success Criteria** (what must be TRUE):
  1. Benchmarked helper/render hotspots show measurable runtime improvement versus v1.0 baseline.
  2. For equivalent inputs, optimized paths preserve output semantics and rendered behavior.
  3. Regression checks detect performance backsliding in selected benchmark scenarios.
**Plans**: 2 plans

Plans:
- [x] 08-01: TBD (created during /gsd:plan-phase 8)
- [x] 08-02-PLAN.md — Implement measured hotspot optimizations with mapped gain assertions and semantic parity checks.

### Phase 9: Audit Traceability and Validation Artifact Closure
**Goal**: Milestone audit evidence is complete and traceable across requirements, summaries, verifications, and validation artifacts.
**Depends on**: Phase 8
**Requirements**: DIAG-01, VAL-01, ONB-01, PERF-01
**Gap Closure**: Closes milestone-audit traceability and validation-artifact gaps from `v1.1-MILESTONE-AUDIT.md`.
**Success Criteria** (what must be TRUE):
  1. Phase 05-08 summaries expose requirement-completion metadata required by milestone audit.
  2. Verification and validation artifacts no longer fail the milestone audit for missing bookkeeping evidence.
  3. Re-auditing can treat previously delivered requirements as fully evidenced once runtime checks are satisfied.
**Plans**: 2 plans

Plans:
- [x] 09-01-PLAN.md — Normalize Phase 05-08 summary traceability so each requirement is audit-readable and runtime deferrals stay explicit.
- [x] 09-02-PLAN.md — Align validation, verification, requirements, roadmap, and milestone-audit artifacts to leave only Phase 10 runtime evidence open.

### Phase 10: Supported-Environment Verification Closure
**Goal**: Supported-environment runtime evidence is captured for onboarding and performance requirements that were environment-gated during local audit.
**Depends on**: Phase 9
**Requirements**: ONB-01, PERF-01
**Gap Closure**: Closes supported-environment flow gaps from `v1.1-MILESTONE-AUDIT.md`.
**Success Criteria** (what must be TRUE):
  1. Quarto-enabled onboarding validation/render matrix executes and passes for all supported formats.
  2. Bench-backed gain and no-backslide checks execute and pass on a supported setup.
  3. Human verification evidence is recorded so milestone audit can pass without environment-gated caveats.
**Plans**: 2 plans

Plans:
- [x] `10-01-PLAN.md` — Execute Quarto-enabled onboarding scaffold -> validate -> render evidence and close the remaining `ONB-01` runtime gap.
- [x] `10-02-PLAN.md` — Execute bench-enabled performance evidence, refresh the milestone audit, and close the remaining `PERF-01` runtime gap.

</details>

## Phase Details — v1.2 Documentation and Website Polish

### Phase 11: Documentation Content Foundation
**Goal**: All source artifacts that pkgdown consumes exist, are complete, and tell one coherent onboarding-first story.
**Depends on**: Phase 10
**Requirements**: DOCS-01, DOCS-02, DOCS-03, DOCS-04, DOCS-05, SHIP-04
**Success Criteria** (what must be TRUE):
  1. README communicates typstR's value, install path, and system requirements within the first screenful — no scrolling required.
  2. A new user can follow one canonical install → scaffold → render flow that appears consistently across the README, pkgdown home page, and the getting-started article.
  3. All three vignettes build successfully via `pkgdown::build_articles()` in a local shell with no Quarto in PATH — no chunk produces a "command not found" or render error.
  4. Every exported function help page has a meaningful title, description, all `@param` entries, and at least one `@examples` block; `devtools::check_man()` returns clean.
  5. A `NEWS.md` exists with entries summarizing v1.0, v1.1, and v1.2 milestones using the `# typstR X.Y` heading format pkgdown expects.
  6. All generated `man/*.Rd` files are committed to git (removed from `.gitignore`) and CRAN-sensitive pkgdown build artifacts are excluded from the package tarball via `.Rbuildignore`.
**Plans**: 4 plans
**UI hint**: yes

Plans:
- [x] 11-01-PLAN.md — Split README, pkgdown home, and the vignette corpus around one canonical working-paper onboarding story.
- [x] 11-02-PLAN.md — Add a RED-state exported-help-page audit that enumerates the real exported reference surface.
- [ ] 11-03-PLAN.md — Add NEWS.md and lock the git/build-ignore split for committed man pages and CRAN-safe pkgdown artifacts.
- [ ] 11-04-PLAN.md — Refresh source-driven reference docs and regenerate committed Rd pages behind the audit and ignore-rule gates.

### Phase 12: Site Configuration and Local Validation
**Goal**: A fully configured `_pkgdown.yml` drives a local site build that navigates cleanly through all nav entry points with zero pkgdown warnings and no dev badge visible.
**Depends on**: Phase 11
**Requirements**: SITE-02, SITE-03, SITE-04, SITE-05, SHIP-01, SHIP-02
**Success Criteria** (what must be TRUE):
  1. `pkgdown::check_pkgdown()` returns zero warnings after the final `_pkgdown.yml` edits.
  2. `pkgdown::build_site(preview = FALSE)` completes locally without errors; `docs/index.html` opens and renders correctly in a browser.
  3. The site navbar exposes exactly: Home, Get Started (wired to the getting-started article), Reference, Articles, and Changelog — with no dead links.
  4. The Reference index displays five named function groups (Scaffolding, Metadata helpers, Publication helpers, Rendering, Validation and diagnostics); every exported function appears in exactly one group; no "unmatched" warning is emitted.
  5. All three vignettes appear in the Articles section in onboarding-first order; no "unlisted article" warning is emitted.
  6. The site renders without the pkgdown development-mode badge (suppressed via `development: mode: release` in `_pkgdown.yml`).
**Plans**: TBD
**UI hint**: yes

### Phase 13: CI/CD Deployment and Live Site
**Goal**: The pkgdown site is publicly reachable at `https://davidzenz.github.io/typstR/` and re-deploys automatically on every push to `main`.
**Depends on**: Phase 12
**Requirements**: SITE-01, SHIP-03
**Success Criteria** (what must be TRUE):
  1. A GitHub Actions run triggered by a push to `main` completes without errors and deploys to the `gh-pages` branch.
  2. `https://davidzenz.github.io/typstR/` loads a valid home page with the correct package content.
  3. All top-level nav links (Home, Get Started, Reference, Articles, Changelog) resolve to the correct pages on the live site.
  4. All three article pages load and display correctly on the live site.
**Plans**: TBD

## Progress

**Execution Order:** 11 → 12 → 13

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| 1. Skeleton and Pipeline | v1.0 | 3/3 | Complete | 2026-03-23 |
| 2. Metadata Helpers and YAML Interface | v1.0 | 4/4 | Complete | 2026-03-23 |
| 3. Typst Templates, Branding, and Additional Formats | v1.0 | 5/5 | Complete | 2026-03-23 |
| 4. Tests, Documentation, and CRAN Hardening | v1.0 | 6/6 | Complete | 2026-03-23 |
| 5. Structured Diagnostics Foundation | v1.1 | 2/2 | Complete | 2026-04-01 |
| 6. Pre-render Environment Validation | v1.1 | 2/2 | Complete | 2026-04-01 |
| 7. First-run Onboarding Reliability | v1.1 | 2/2 | Complete | 2026-04-01 |
| 8. Measured Performance Optimization | v1.1 | 2/2 | Complete | 2026-04-01 |
| 9. Audit Traceability and Validation Artifact Closure | v1.1 | 2/2 | Complete | 2026-05-05 |
| 10. Supported-Environment Verification Closure | v1.1 | 2/2 | Complete | 2026-05-06 |
| 11. Documentation Content Foundation | v1.2 | 0/4 | Not started | - |
| 12. Site Configuration and Local Validation | v1.2 | 0/? | Not started | - |
| 13. CI/CD Deployment and Live Site | v1.2 | 0/? | Not started | - |
