# Maintainer handoff: typstR 0.1.0

Planning milestone v1.5 is independent of package version 0.1.0.
Historical v1.4 check results are retained, but do not establish current readiness.

## Final review

- [ ] Review the release commit range, API changes, validation limits and NEWS.
- [ ] Confirm DESCRIPTION version, maintainer email, license and URLs.
- [ ] Require the existing five-target R CMD check matrix and Required PDF renders
  workflow to pass for the exact release commit. Record the run links.
- [ ] Review the six PDF artifacts and representative page images; verify author
  affiliations, citations, branding, tables, equations and pagination.
- [ ] Read the manual benchmark report; investigate flagged comparisons without
  silently replacing historical baselines.
- [ ] Build help, vignettes and pkgdown; check installation and README instructions.

## Reproduce source-package checks

Use a clean R session with development packages installed. Quarto 1.10.19 and its
bundled Typst 0.15.1 are the recorded render toolchain; R 4.6.1 is the pinned render
CI version. The normal check matrix still covers release/devel/oldrel on three OSes.
Documentation/check CI pins Pandoc 3.6.4 because current pkgdown/rmarkdown use
flags deprecated by newer Pandoc. For local documentation builds, set
`RSTUDIO_PANDOC` to the directory containing that version and prepend it to `PATH`; Quarto renders continue
to use Quarto's own bundled Pandoc.

```sh
Rscript --vanilla -e 'roxygen2::roxygenise(); testthat::test_local()'
R CMD build .
R CMD check --as-cran typstR_0.1.0.tar.gz
mkdir -p /tmp/typstR-release-library
R CMD INSTALL --library=/tmp/typstR-release-library typstR_0.1.0.tar.gz
R_LIBS_USER=/tmp/typstR-release-library bash tools/run-render-assurance.sh artifacts/release-render
Rscript --vanilla tools/benchmark.R artifacts/benchmark
```

Keep the tarball hash, complete check log, test results, toolchain report and PDFs.
Use a new artifact directory for every render run: the runner refuses stale projects.
Record all notes (including expected new-submission notes) and limitations in
`cran-comments.md`; do not claim zero notes without actual evidence.

## Submission — explicit authorization required

- [ ] Maintainer explicitly authorizes submission of the reviewed tarball/hash.
- [ ] Submit that tarball to CRAN and complete the maintainer email confirmation.
- [ ] Record submission date, confirmation and reviewer correspondence locally.
- [ ] Address reviewer requests in separate commits; repeat affected checks and
  refresh the exact tarball/hash before resubmission.

## Acceptance and release documentation

- [ ] Verify acceptance and public CRAN package listing; record the URL/date.
- [ ] Create a package-version release/tag (0.1.0) distinct from planning tags v1.*.
- [ ] Update NEWS release date, install instructions, badges and release notes.
- [ ] Confirm published documentation shows the accepted package version.
- [ ] Close the milestone with current evidence and keep EXT-03/BRAND-03 in backlog.

No submission, email, tag publication or acceptance is implied by this checklist.
