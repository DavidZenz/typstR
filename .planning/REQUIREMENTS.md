# Requirements: typstR

**Defined:** 2026-03-31
**Core Value:** Users can go from `create_working_paper("my-paper")` to a polished, branded PDF in minutes — no Typst or LaTeX knowledge required.

## v1.1 Requirements

Requirements for milestone v1.1 **Reliability and Onboarding Polish**.

### Validation

- [x] **VAL-01**: User can run pre-render environment validation that reports Quarto/Typst availability, version-floor compatibility, and extension presence before render begins.

### Diagnostics

- [x] **DIAG-01**: User receives structured diagnostics for validation issues with stable code, severity, location, and hint fields.

### Onboarding

- [ ] **ONB-01**: User can scaffold each supported format and get a validation+render-successful starter project on a supported setup without manual template fixes.

### Performance

- [ ] **PERF-01**: User sees measurable improvement in selected helper/render hotspots with no output semantics changes.

## Future Requirements

Acknowledged but deferred beyond v1.1 scope.

### Validation

- **VAL-02**: User can detect malformed project structure and ambiguous input resolution before render.
- **VAL-03**: User can detect YAML metadata consistency issues across workingpaper/article/brief variants before render.

### Diagnostics

- **DIAG-02**: User gets explicit remediation playbooks per validation failure class.
- **DIAG-03**: User gets near-miss YAML key suggestions for common typo/alias mistakes.
- **DIAG-04**: User gets grouped and stable-ordered diagnostics output for faster triage.

### Onboarding

- **ONB-02**: User gets starter defaults/placeholders tuned to reduce first-edit failure probability.
- **ONB-03**: User is guided through a validation-first onboarding flow in starters and docs.

### Performance

- **PERF-02**: User avoids redundant expensive operations in wrapper/check paths within a single render flow.
- **PERF-03**: User benefits from lightweight performance regression checks for stable benchmark scenarios.

## Out of Scope

Explicitly excluded from v1.1 to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Major new output formats or large journal template expansion | Milestone is reliability/onboarding polish for existing formats, not feature-surface expansion. |
| HTML/Word output expansion | Conflicts with current Typst-first product focus for this milestone. |
| Silent auto-mutation of user YAML/manuscripts | Violates trust and obscures root causes; diagnostics must report, not rewrite. |
| Live preview/watcher subsystem | High complexity and not required for v1.1 reliability goals. |

## Traceability

Mapped during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| DIAG-01 | Phase 5 | Complete |
| VAL-01 | Phase 6 | Complete |
| ONB-01 | Phase 7 | Pending |
| PERF-01 | Phase 8 | Pending |

**Coverage:**
- v1.1 requirements: 4 total
- Mapped to phases: 4
- Unmapped: 0 ✓

---
*Requirements defined: 2026-03-31*
*Last updated: 2026-03-31 after v1.1 roadmap mapping*
