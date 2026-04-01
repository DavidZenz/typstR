# Roadmap: typstR

## Overview

typstR is now operating in milestone mode: v1.0 is shipped and archived, and v1.1 focuses on reliability and onboarding polish. v1.1 phases are sequenced to deliver a diagnostics-first validation flow, then onboarding hardening, then measured performance improvements.

## Milestones

- SHIPPED **v1.0 Foundation and CRAN Release** — Phases 1-4 (shipped 2026-03-23)
- ACTIVE **v1.1 Reliability and Onboarding Polish** — Phases 5-8 (in progress)

## Phases

- [x] **Phase 1: Skeleton and Pipeline** - Scaffold and render a working paper end-to-end.
- [x] **Phase 2: Metadata Helpers and YAML Interface** - Express publication metadata in R/YAML and carry it into output.
- [x] **Phase 3: Typst Templates, Branding, and Additional Formats** - Deliver modular templates and format variants with branding hooks.
- [x] **Phase 4: Tests, Documentation, and CRAN Hardening** - Finalize quality, docs, and release readiness.
- [x] **Phase 5: Structured Diagnostics Foundation** - Standardize user-facing diagnostics schema for validation failures.
- [x] **Phase 6: Pre-render Environment Validation** - Validate Quarto/Typst/runtime prerequisites before render starts.
- [x] **Phase 7: First-run Onboarding Reliability** - Ensure scaffolded starters validate and render successfully without manual fixes.
- [x] **Phase 8: Measured Performance Optimization** - Improve selected hotspots with benchmarked gains and unchanged semantics.

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

### v1.1 Reliability and Onboarding Polish (Active)

**Milestone Goal:** Users get truthful pre-render diagnostics, reliable first-run scaffolds, and faster hotspots without output changes.

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
## Progress

**Execution Order:** 5 → 6 → 7 → 8

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
