# v1.5 First Release Reliability

Defined: 2026-10-17. Planning version **v1.5**; package version remains **0.1.0**.
Historical milestone completion does not establish current release readiness.

| ID | Acceptance criteria | Phase | Status |
|---|---|---|---|
| REL-01 | Public render helpers accept explicit `.qmd`, directory and NULL; identify manuscript/project before preflight; reject missing/ambiguous input with stable diagnostics. README flow, all scaffolders, spaces and outside-project invocation have regression coverage. | 21 | Passed (21-VERIFICATION.md) |
| VAL-02 | Shared standalone/render validation checks YAML shape, supported format/variant, metadata, configured logo/bibliography/include files, with deterministic diagnostics and documented resource semantics. Valid scaffold defaults pass. Unsupported Quarto configuration is reported explicitly. | 22 | Passed (22-VERIFICATION.md) |
| RENDER-01 | Separate pinned Quarto CI renders all three fresh scaffolds via public helpers; missing prerequisites/skipped required checks fail; branding, citations, tables, equations, PDF text and artifacts are checked. Representative pages are visually reviewed. Ordinary checks need no Quarto. | 23 | Pending |
| PERF-02 | Manual benchmark runner/workflow reuses existing workloads/baselines; records versions, timing distributions and comparisons; ordinary CI excludes noisy timing assertions; measured regressions are investigated. | 23 | Pending |
| PLAN-01 | Phases 11–16 have evidence-linked retrospective verification, distinguishing static checks, historical evidence and unverified live claims; history is preserved. NEWS uses package versions; README/articles/examples agree; deferred items have explicit acceptance criteria. | 24 | Pending |
| CRAN-05 | Tests, help/site builds, clean installed-package renders, and `R CMD check --as-cran` on a built source tarball have current recorded results; errors/warnings resolved, notes explained; submission materials and maintainer checklist identify authorization/submission/review/acceptance steps. | 25 | Pending |

No CRAN submission is authorized. Submission requires explicit maintainer authorization.

## Evidence policy

Record commands, versions, commit/tree, exit status, artifacts and limitations. Do not
convert skipped checks or historical assertions into a current passing result. External
CI and live website claims require current external evidence. Keep checks reviewable in
separate commits for rendering, validation, assurance, documentation and release handoff.
