# Render defects discovered by real PDF verification

2026-10-17: R 4.6.1, Quarto 1.10.19, Typst 0.15.1.

- Fixed absent default font by using bundled Libertinus Serif.
- Fixed Pandoc-escaped hex colors; made accent heading rules apply outside local scope.
- Resolve logo image at manuscript call site and normalize inherited logo paths.
- Pass relative extension context so nested manuscripts import the actual extension.
- Reconcile Quarto's normalized author affiliation IDs/aliases; public metadata API unchanged.
- Remove empty starter References headings; Quarto emits the actual bibliography.

`tools/run-render-assurance.sh artifacts/render-attempt-5` passed all six default/
representative public-helper renders without warnings; article representative is
nested, uses root project resources, and renders from outside the project. All
scaffold paths contain spaces. PDF text confirms titles, citations, table and
formula section, footer/disclaimer; PNG review confirms corrected affiliations,
logo, blue headings, readable table/equation and no clipping/overlap on representative
pages. The latest follow-up assertion adds affiliation superscript text to the
required checks and must pass again for the final source tarball.

Targeted render/scaffolding/manuscript/YAML integration tests: exit 0, no failures.
No external CI or CRAN readiness is claimed here.
