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
- Hosted checks were pending when the October 26 local results were recorded.
  They subsequently passed for eb1d0a3; see the hosted verification update below.
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

Subsequent hosted verification for eb1d0a3 passed the required Linux
minimum/current and Windows current lanes, plus package checks and pkgdown.
See the hosted verification update below. No publication, release tag, or CRAN
submission was performed.

## Hosted verification update — checked November 1, 2026

[Required PDF renders, run 40293307359](https://github.com/DavidZenz/typstR/actions/runs/40293307359)
passed for commit `eb1d0a34a3db27d682e523b55a8f43911175daba` in all three jobs:
Ubuntu/Quarto 1.4.11, Ubuntu/Quarto 1.10.19, and Windows/Quarto 1.10.19.
The workflow pins R 4.6.1 and Typst 0.15.1. The five-target package check
(run 40293307394) and documentation build (run 40293307500) also succeeded.
These hosted results certify the preceding committed tree, not the following
November 1 fixes. Historical local measurements above remain unchanged.

## Manuscript validation and encoding fixes — November 1, 2026

This is fresh local verification of the subsequent working-tree changes. The
hosted run above is historical and does not certify these uncommitted fixes.

### Decisions and regression coverage

- Static preflight recognizes both local config filenames and follows Quarto's
  `.yml.local` before `.yaml.local` selection (verified in both supported CLI
  sources). Effective publication overrides fail closed with the override's
  file path. Empty/editor-only local files are safe to ignore. Profiles selected
  by `_environment` files are also diagnosed. This avoids relying on early
  Quarto's incomplete inspect behavior or requiring Quarto for offline checks.
- YAML handlers retain only lowercase unquoted `true` and `false` as logical
  values. Ambiguous spellings remain text and fail typed boolean validation;
  validation runs after project/directory/document/selected-format merging.
  Authors' corresponding flags, disclaimer flags and standard boolean layout
  options share this rule. Documentation shows canonical programmatic YAML.
- The existing Lua filter encodes code-context metadata as raw Typst string
  literals, preserving quotes, backslashes, line breaks and Unicode. Titles,
  subtitles, abstracts and statements retain content-context Pandoc formatting.
  All string interpolation slots were reviewed, including author identifiers,
  affiliations, font names, paths, colors, numbering patterns and footer text.
- The existing prose scanner excludes indented code and HTML comments, retains
  fenced/inline-code exclusions, and detects `-@key` with mixed citations and
  reserved cross-references. A one-off 100,000-line mixed-prose scan completed
  in 7.128 seconds; this is an observation, not a test threshold.
- Existing unit tests and the same nine render scenarios now exercise the
  reported failures. No new render family, CI lane, dependency or public API
  was added. Current Linux fixtures remain C-locale compatible; intermediate
  fixture failures are retained in the artifact directory.

### Dependency review

`local_mocked_bindings()` is present in testthat 3.1.7's archived source; the
minimum is now 3.1.7. Installing that historical release on R 4.6.1 failed in its
own C code because R removed its legacy C API. No dependency patch or test skip
was used; current testthat 3.3.2 passes, and lower-R verification of testthat
3.1.7 itself remains unperformed.

An actual quarto R 1.4 installation exposed a pre-existing incorrect lower
bound: `quarto_available()` was not exported until 1.5.0. The minimum R-interface
package is now 1.5.0. Its archived installation passed the unit suite and all nine
macOS PDF scenarios with Quarto CLI 1.10.19. The CLI floor remains **1.4.11**;
this is independent of the R-interface version. Existing cli/fs/yaml calls need
no new APIs or raised bounds.

### Final source-package evidence

Tarball: `artifacts/validation-fixes-20261101/check/typstR_0.1.0.tar.gz`.
SHA-256: `11b27e8f9f58c50bf6cf4dc0b5ae2e8c59fccaed5af81c3364f21c2a327b71f2`.

`R CMD check --as-cran` on macOS ARM64/R 4.6.1: **zero errors, zero warnings,
two notes** (new submission; existing old HTML Tidy limitation). Installed tests:
**625 passes, zero failures/warnings/skips**. Help regeneration, source vignettes,
examples, documentation consistency and PDF manual builds pass. Full log:
`artifacts/validation-fixes-20261101/check/typstR.Rcheck/00check.log`.

Every row below installs that exact tarball and completes all nine scenarios,
with zero skipped cases and no render warnings:

| Platform | R / quarto R | Quarto CLI / Typst | Evidence directory |
|---|---|---|---|
| macOS ARM64 | 4.6.1 / 1.5.0 | 1.10.19 / bundled 0.15.1 | `artifacts/validation-fixes-20261101/macos-verified/` |
| Ubuntu 26.04 ARM64, C locale | 4.5.2 / 1.5.1 | 1.10.19 / bundled 0.15.1 | `artifacts/validation-fixes-20261101/linux-current-verified/` |
| Ubuntu 26.04 ARM64, C locale | 4.5.2 / 1.5.1 | 1.4.11 / standalone 0.15.1 | `artifacts/validation-fixes-20261101/linux-minimum-verified/` |

Retained evidence includes generated Typst, manuscript/project sources, PDF text,
properties/fonts/bounding boxes, PDFs, page images and complete runner logs.
Visual review of identified academic/brief and anonymous article pages confirms
literal quoted/backslash metadata, preserved subtitle formatting, expected
appendices and anonymity, without clipping or overlap.

### Remaining limitations

The three existing Ubuntu/Windows CI lanes are unchanged. These new changes have
not been executed on hosted Windows or on a pushed review commit; the earlier
successful Windows run must not be treated as verification of this working tree.
Static preflight intentionally rejects effective local publication/profile
overrides rather than resolving arbitrary dynamic Quarto configuration. Authors
must still review identifying body text and publication statements. No commit,
push, release tag or CRAN submission was performed as part of this fix.
