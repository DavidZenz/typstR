## Test environments
* local macOS Tahoe 26.6.2 (aarch64), R 4.6.1
* Quarto 1.10.19 with bundled Typst 0.15.1 for clean-session PDF assurance
* Five-target GitHub Actions checks are required before submission; historical
  v1.4 checks are not presented as current verification of these changes.

## R CMD check results

`R CMD check --as-cran` on the built 0.1.0 source tarball:

0 errors | 0 warnings | 2 notes

* This is a new submission.
* HTML manual validation was skipped because the local system HTML Tidy is too
  old. Rd checks and PDF manual generation passed. This is an environment
  limitation; it is not evidence of completed HTML Tidy validation.

## Release evidence

The maintainer handoff and current verification ledger are in
`RELEASE_CHECKLIST.md` and `.planning/phases/25-release-handoff/` in the source
repository (excluded from the package archive). They retain commands, toolchain,
source tarball hash, test/check logs, PDF content checks and visual review.

No CRAN submission or acceptance is recorded. Explicit maintainer authorization
is required before submitting the reviewed tarball.
