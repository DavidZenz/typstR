# Requirements: typstR

**Defined:** 2026-06-01
**Core Value:** Users can go from `create_working_paper("my-paper")` to a polished, branded PDF in minutes — no Typst or LaTeX knowledge required.

## v1.3 Requirements

Requirements for the v1.3 branding and documentation depth milestone.

### Visual Branding

- [x] **BRAND-01**: The pkgdown site displays a custom typstR logo in the navbar and a matching favicon in the browser tab.
- [x] **BRAND-02**: The pkgdown site uses branded accent colors (aligned with typstR's aesthetic) for links, sidebar highlights, and callouts, implemented via `pkgdown/extra.css`.

### Documentation Depth

- [x] **EXT-01
**: Users can reference an "Advanced Examples" article that demonstrates complex tables (using `gt` or `tinytable`), multi-line equations, and cross-reference patterns.
- [x] **EXT-02
**: Users can consult a "Format Comparison" matrix that explicitly compares features (anonymization, report numbers, disclaimers) across the three supported publication types.

## v2 Requirements (Deferred)

Requirements that matter for long-term growth but are not yet scheduled.

- **EXT-03**: Users can switch between multiple documentation versions (release vs development).
- **BRAND-03**: Users see rendered output screenshots or other rich visual previews on landing pages.

## Out of Scope (v1.3)

| Feature | Reason |
|---------|--------|
| Multi-version docs | Too much infrastructure overhead for the current package stage |
| Embedded PDF screenshots | Adds CI complexity (Quarto in GHA) that we intentionally avoided in v1.2 |

---
*Requirements defined: 2026-06-01*
*Milestone: v1.3 Branding and Documentation Depth*
