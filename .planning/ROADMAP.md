# Roadmap: typstR

## Overview

**Active milestone:** v1.3 — Branding and Documentation Depth

Goal: Establish a distinct visual identity for the typstR site and provide deeper technical guidance through complex examples and format comparisons.

## Milestones

- SHIPPED **v1.0 Foundation and CRAN Release** — Phases 1-4 (shipped 2026-03-23)
- SHIPPED **v1.1 Reliability and Onboarding Polish** — Phases 5-10 (shipped 2026-05-06)
- SHIPPED **v1.2 Documentation and Website Polish** — Phases 11-13 (shipped 2026-06-01)
- ACTIVE **v1.3 Branding and Documentation Depth** — Phases 14-16

## Phases

- [x] **Phase 14: Visual Branding and Identity** - Implement logo, favicon, and custom CSS accents.
- [x] **Phase 15: Advanced Documentation Examples** - Create the advanced examples article covering tables, math, and cross-refs.
- [ ] **Phase 16: Format Comparison and Milestone Audit** - Create the format comparison matrix and finalize the milestone.

## Phase Details

### Phase 14: Visual Branding and Identity
**Goal**: The pkgdown site feels branded and polished.
**Depends on**: Phase 13 (v1.2 completion)
**Requirements**: BRAND-01, BRAND-02
**Plans**: 3 plans
- [x] 14-01-PLAN.md — Asset Preparation
- [x] 14-02-PLAN.md — Site Styling
- [x] 14-03-PLAN.md — Validation
**Success Criteria**:
  1. Custom logo appears in navbar.
  2. Favicon appears in browser tab.
  3. Custom CSS accents (colors/links) are visible on the site.

### Phase 15: Advanced Documentation Examples
**Goal**: Users can see how to handle complex academic document requirements.
**Depends on**: Phase 14
**Requirements**: EXT-01
**Plans**: 2 plans
- [x] 15-01-PLAN.md — Content Drafting
- [x] 15-02-PLAN.md — Site Wiring and Validation
**Success Criteria**:
  1. "Advanced Examples" article exists and is reachable via the navbar.
  2. Examples cover complex tables (e.g., gt), multi-line equations, and bib citations.

### Phase 16: Format Comparison and Milestone Audit
**Goal**: Users can easily choose the right format for their needs.
**Depends on**: Phase 15
**Requirements**: EXT-02
**Plans**: 2 plans
- [x] 16-01-PLAN.md — Format Comparison Article
- [ ] 16-02-PLAN.md — Milestone Audit and Closure
**Success Criteria**:
  1. "Format Comparison" matrix exists and is reachable via the navbar.
  2. Matrix correctly compares all three formats (workingpaper, article, brief).
  3. Milestone v1.3 audit passes.

## Progress

**Execution Order:** 14 → 15 → 16

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
| 16. Format Comparison and Milestone Audit | v1.3 | 1/2 | In progress | 2026-06-01 |
