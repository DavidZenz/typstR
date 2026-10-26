# Audit correction verification — 2026-10-26

Package version remains 0.1.0. Public R signatures, S3 classes, invisible returns,
and the Quarto 1.4.11 floor are unchanged. This is new evidence after the audit;
historical milestone passes are not rewritten.

## Implemented

- Singleton metadata arrays; safe Typst title content; standard page/font/TOC
  controls; explicit typstR branding precedence; title fonts; page numbering
  with and without custom footers, including unnumbered disclaimer pages.
- Shared metadata validation, constructor collection/reference checks, reserved
  cross-reference prefix handling, and misplaced anonymization diagnostics.
- Byte-preserving YAML title replacement, scaffold opening, canonical output
  resolution, missing-output errors, and restored legacy compiler environment.
- One publication implementation, compatibility imports for all three variants,
  and a bundled appendix filter preserving headings and anchors.
- Fifteen-case installed-package assurance with PDF text, metadata, dimensions,
  embedded fonts, text bounding boxes, numbering, and retained page images.

## Verified tarball

`artifacts/audit-20261026/check-verified/typstR_0.1.0.tar.gz`

SHA-256: `68840ce5ed4fd6ef8619bb99a2b84e167f842b196bf41d0e739177ac646adcf6`

`R CMD check --as-cran` on macOS/R 4.6.1: **0 errors, 0 warnings, 2 notes**.
The test run records **639 passing expectations**, zero failures/warnings, and
nine explicitly opt-in timing tests skipped. No required PDF scenario skipped.

The two check notes are:

1. New CRAN submission.
2. System HTML Tidy is too old for HTML-manual validation. The PDF manual,
   documentation consistency checks, vignettes, and examples passed.

Full check log: `artifacts/audit-20261026/check-verified/typstR.Rcheck/00check.log`.

## Installed-tarball renders

All rows install the exact tarball above. Each run completes all fifteen cases.

| Platform | R | Quarto | Typst provider | Evidence directory |
|---|---|---|---|---|
| macOS ARM64 | 4.6.1 | 1.10.19 | Bundled 0.15.1 | `artifacts/audit-20261026/macos-tarball-current/` |
| macOS ARM64 | 4.6.1 | 1.4.11 | Standalone 0.15.1 | `artifacts/audit-20261026/macos-tarball-minimum/` |
| Ubuntu 26.04 ARM64, C locale | 4.5.2 | 1.10.19 | Bundled 0.15.1 | `artifacts/audit-20261026/linux-new-tarball/` |
| Ubuntu 26.04 ARM64, C locale | 4.5.2 | 1.4.11 | Standalone 0.15.1 | `artifacts/audit-20261026/linux-old-tarball/` |

Each directory retains `RESULTS.txt`, toolchain details, PDFs, project sources,
and page images. Audit cases also retain extracted text, font reports, PDF
properties, bounding boxes, and generated Typst. macOS runner logs are the
corresponding `.log` files alongside those directories. The final Linux run log
is `artifacts/audit-20261026/linux-tarball.log`.

Early Quarto uses a standalone compiler and has an inspect bug for ancestor
extensions. Compatibility handling is isolated to that path. The compiler root
environment is restored on success or error. Older Pandoc string citations and
consumed numbering/TOC-depth variables have small compatibility adapters.

Visual review covered academic and policy-brief representative pages, the
identified academic appendix/TOC page, an anonymous brief, and a disclaimer
page. No clipping, overlap, missing glyphs, or unresolved references were found.
The three direct Typst compatibility imports were also compiled and their
variant behavior checked; see `artifacts/audit-20261026/wrapper-imports.txt`.

## Documentation and remaining release gates

- Roxygen help regenerated; source-package vignettes and both manuals built.
- Full pkgdown build and final README homepage refresh passed. Local Pandoc
  3.12.1 emits upstream deprecated math-flag messages; the documentation workflow
  retains its existing Pandoc 3.6.4 pin.
- README, guides, NEWS, and the release checklist describe corrected behavior
  and how to replace a backed-up extension copy without changing manuscripts.
- Required CI now includes Linux Quarto 1.4.11 and 1.10.19, plus Windows Quarto
  1.10.19, with installed-tarball renders and distinct retained artifacts.
- **Pending:** hosted Windows execution and hosted release-commit checks. Local
  Linux evidence does not certify Windows, and no hosted run is claimed here.
- No branch publication, CRAN submission, release tag, or acceptance occurred.

Earlier failed diagnostic runs remain under the same artifact root for audit
history; the named verified tarball and final directories above supersede them.

## Test suite consolidation — subsequent verification

The earlier fifteen-case results above remain historical evidence. The current
required suite contains nine cases per toolchain, with details and coverage
ownership recorded in `tools/test-suite.md`. Ordinary tests no longer render
PDFs, probe external executables, validate historical baselines, or parse Rd
files. Benchmarks remain an explicit developer command.

On the same macOS ARM64/R 4.6.1 machine, `testthat::test_local()` decreased from
35.677 seconds before cleanup to 5.024 seconds after cleanup (about 86%). With
Quarto and Poppler removed from PATH, the revised suite passed in 4.788 seconds.
The ordinary test tree decreased from 3,187 to 1,395 R lines (about 56%). These
are local observations, not timing thresholds. Installed-package tests report
466 passing expectations with zero failures, warnings, or skips.

The final `R CMD check --as-cran` passed with zero errors, zero warnings, and two
notes: new submission and the existing old HTML Tidy limitation. Vignettes,
examples, documentation consistency, and the PDF manual passed. Full log:
`artifacts/test-cleanup/check/typstR.Rcheck/00check.log`. The initial sandboxed
attempt failed at network dependency checks; a subsequent attempt omitted the
installed TeX directory from PATH. Both environment issues were corrected for
the final check without changing package sources.

Final source tarball: `artifacts/test-cleanup/check/typstR_0.1.0.tar.gz`.
SHA-256: `0140dd5e1a3361e80fe43432836d15a772a28f80c90ae56283f68289878df028`.

All nine scenarios completed without skips against that installed tarball in:

| Platform/toolchain | Evidence directory |
|---|---|
| macOS ARM64, R 4.6.1, Quarto 1.10.19 | `artifacts/test-cleanup/final-tarball-macos/` |
| Linux ARM64, R 4.5.2, Quarto 1.10.19 | `artifacts/test-cleanup/final-tarball-linux-current/` |
| Linux ARM64, R 4.5.2, Quarto 1.4.11 + standalone Typst 0.15.1 | `artifacts/test-cleanup/final-tarball-linux-minimum/` |

The nine-case runner also passed on macOS with Quarto 1.4.11 before the final
rebuild, using the preceding installed tarball; see
`artifacts/test-cleanup/macos-minimum-final-pass/`. Visual review covered the
first two pages of enriched working-paper and brief outputs: title/branding,
TOC, appendices, footnotes, tables, references, and publication statements.
No clipping or overlap was observed.

The manual benchmark command completed all three workloads; reports are under
`artifacts/test-cleanup/benchmark/`. Collection and scaffolding exceeded the
historical tolerance. The collection workload now includes namespace-scoped
mock setup in place of direct environment assignments; scaffolding also reflects
the preceding audit's additional validation. Hardware/session and harness
comparability are not established, so these ratios are investigation signals,
not established package slowdowns. Historical baselines were not changed.

Hosted Windows execution and release-commit CI remain pending. The existing
required Linux minimum/current and Windows current lanes are retained. No
publication, release tag, or CRAN submission was performed.
