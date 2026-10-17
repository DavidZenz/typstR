---
phase: 22-shared-manuscript-validation
status: passed
verified: 2026-10-17
requirements_completed: [VAL-02]
---

# Shared validation verification

`validate_manuscript()` and `render_pub()` use the same internal context validator.
The existing environment-only function remains public and compatible. No runtime
dependencies were added. Existing diagnostic assignments are retained.

Full `testthat::test_local(reporter="summary")` with CI=true on R 4.6.1 completed
with zero failures/warnings; nine noisy performance tests skipped by existing CI
guards. Quarto-enabled integration tests ran (Quarto 1.10.19, Typst 0.15.1).

Positive/negative tests cover all scaffold defaults, YAML syntax/shape, format and
variant, required title, metadata shapes, valid and missing local bibliography,
logo, CSL and include files, citations without bibliography, inherited project and
directory resources, author IDs, missing extension templates, deterministic payloads,
standalone/render equivalence and explicit unsupported dynamic configuration.

Contract and limits: ../../../VALID_STRATEGY.md and getting-started article.
PDF branding/content/visual assurance is tracked under RENDER-01.
