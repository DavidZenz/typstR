---
phase: 22-shared-manuscript-validation
status: passed
verified: "2026-10-17T20:12:40.722376+00:00"
requirements_completed: [VAL-02]
verification_method: inline source-test-artifact audit
covered_files: [".planning/phases/22-shared-manuscript-validation/22-01-PLAN.md", ".planning/phases/22-shared-manuscript-validation/22-01-SUMMARY.md", "NAMESPACE", "R/diagnostics.R", "R/render.R", "R/utils.R", "R/validation_environment.R", "R/validation_manuscript.R", "VALID_STRATEGY.md", "man/validate_manuscript.Rd", "tests/testthat/test-diagnostics-codebook.R", "tests/testthat/test-diagnostics-ordering.R", "tests/testthat/test-manuscript-validation.R", "tests/testthat/test-validation-environment.R"]
covered_digest: v2:sha256:ee78542200e90f24b773d97a96d4b40c57c76a0623a8e1907c5567c5e6461d22
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
