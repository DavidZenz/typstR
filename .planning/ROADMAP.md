# Roadmap: typstR

## Overview

**Active milestone:** v1.4 Hardening and CRAN Submission Readiness

**Goal:** Ensure the package meets all strict CRAN policies and is fully hardened for a public release on the Comprehensive R Archive Network.

## Milestones

- SHIPPED **v1.0 Foundation and CRAN Release** — Phases 1-4 (shipped 2026-03-23)
- SHIPPED **v1.1 Reliability and Onboarding Polish** — Phases 5-10 (shipped 2026-05-06)
- SHIPPED **v1.2 Documentation and Website Polish** — Phases 11-13 (shipped 2026-06-01)
- SHIPPED **v1.3 Branding and Documentation Depth** — Phases 14-16 (shipped 2026-06-01)
- ACTIVE **v1.4 Hardening and CRAN Submission Readiness** — Phases 17-20

## Phases

- [ ] **Phase 17: Dependency Review and Cleanup** - Review and minimize package dependencies.
- [ ] **Phase 18: Cross-Platform Test Hardening** - Ensure tests run robustly across all platforms.
- [ ] **Phase 19: R CMD Check Optimization** - Achieve 0 errors, 0 warnings, and 0 notes on all platforms.
- [ ] **Phase 20: CRAN Submission Preparation** - Prepare cran-comments.md and finalize submission artifacts.

## Phase Details

### Phase 17: Dependency Review and Cleanup
**Goal**: The package dependency footprint is minimized to reduce CRAN installation burden.
**Depends on**: Phase 16
**Requirements**: CRAN-02
**Success Criteria**:
  1. Unused or unnecessary packages are removed from Imports and Suggests in DESCRIPTION.
  2. Remaining dependencies are justified and actively utilized in the package codebase.
**Plans**: 1 plans
- [x] 17-01-PLAN.md — Dependency Alignment

### Phase 18: Cross-Platform Test Hardening
**Goal**: The test suite executes reliably on all platforms without false failures.
**Depends on**: Phase 17
**Requirements**: CRAN-04
**Success Criteria**:
  1. Tests run successfully on macOS, Windows, and Linux CI environments.
  2. Tests fail gracefully or skip appropriately when Quarto or Typst are missing on a host machine.
**Plans**: 2 plans
- [x] 18-01-PLAN.md — CI Workflow Scaffolding
- [x] 18-02-PLAN.md — Cross-Platform Execution and Hardening

### Phase 19: R CMD Check Optimization
**Goal**: The package passes all rigorous CRAN checks perfectly across operating systems.
**Depends on**: Phase 18
**Requirements**: CRAN-01
**Success Criteria**:
  1. `R CMD check --as-cran` executes with 0 errors, 0 warnings, and 0 notes locally.
  2. CI workflows confirm 0 errors, 0 warnings, 0 notes on macOS, Windows, and Linux.
**Plans**: 2 plans
- [ ] 19-01-PLAN.md — Build-Ignore Alignment
- [ ] 19-02-PLAN.md — CI Perfection Verification

### Phase 20: CRAN Submission Preparation
**Goal**: All necessary artifacts for a formal CRAN submission are complete and validated.
**Depends on**: Phase 19
**Requirements**: CRAN-03
**Success Criteria**:
  1. `cran-comments.md` is fully drafted and populated with required testing environment details.
  2. The package structure is verified to meet CRAN repository policies.
**Plans**: 2 plans

## Progress

**Execution Order:** 17 → 18 → 19 → 20

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
| 11. Documentation Content Foundation | v1.2 | 4/4 | Complete | 2026-06-01 |
| 12. Site Configuration and Local Validation | v1.2 | 3/3 | Complete | 2026-06-01 |
| 13. CI/CD Deployment and Live Site | v1.2 | 2/2 | Complete | 2026-06-01 |
| 14. Visual Branding and Identity | v1.3 | 3/3 | Complete | 2026-06-01 |
| 15. Advanced Documentation Examples | v1.3 | 2/2 | Complete | 2026-06-01 |
| 16. Format Comparison and Milestone Audit | v1.3 | 2/2 | Complete | 2026-06-01 |
| 17. Dependency Review and Cleanup | v1.4 | 1/1 | Complete | 2026-06-02 |
| 18. Cross-Platform Test Hardening | v1.4 | 2/2 | Complete | 2026-06-02 |
| 19. R CMD Check Optimization | v1.4 | 0/2 | Not started | - |
| 20. CRAN Submission Preparation | v1.4 | 0/2 | Not started | - |
