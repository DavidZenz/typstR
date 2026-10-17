---
phase: 23-render-and-performance-assurance
status: human_needed
verified: 2026-10-17
requirements_completed: [PERF-02]
---

# Render/performance assurance

Required PDF runner passed all six fresh installed-tarball renders with zero
skips/warnings. It fails when Quarto is absent (verified exit 1), extracts meaningful
PDF text, records toolchain and rasters all pages. Final representative pages match
visually reviewed output. The nested article exercises inherited logo and
bibliography resources from outside the project; all scaffold paths contain spaces.

Pinned required-render workflow added alongside unchanged five-target package
check matrix; documentation Pandoc is separately pinned. Hosted execution is still
pending and must be linked before RENDER-01 is marked complete.

Manual benchmark workflow and reusable workload runner are present, syntax-checked
and locally executed. Existing contracts and baselines are preserved. Ordinary
timing assertions are opt-in. PERF-02 is satisfied; no speed claims are made.
See PERFORMANCE.md for measured results and regression investigation.
