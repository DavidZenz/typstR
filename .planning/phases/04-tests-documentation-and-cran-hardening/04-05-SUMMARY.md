---
phase: 04-tests-documentation-and-cran-hardening
plan: 05
subsystem: build
tags: [roxygen, rd, build, cran, packaging]
requires:
  - phase: 04-03
    provides: vignette sources and vignette build metadata
  - phase: 04-04
    provides: complete source-level roxygen coverage
provides:
  - Verified roxygen/NAMESPACE/man alignment
  - Fresh source tarball for final CRAN hardening
  - Build ignore rules for local RStudio project noise
affects: [build, generated-docs, packaging, cran-hardening]
tech-stack:
  added: []
  patterns: [source-loader roxygen regen, temp-lib Rd verification, uncommitted tarball artifact]
key-files:
  modified:
    - .Rbuildignore
key-decisions:
  - "The tarball is treated as a build artifact, not a committed source file."
  - "Rd structural verification is performed against a temporary installed package because tools::checkRdContents() expects an installed package path."
  - "Roxygen regeneration uses roxygen2::load_source in this environment to avoid treating missing runtime imports as a source-doc blocker."
patterns-established:
  - "Generated-doc/build verification can be a clean no-op on tracked files when source docs are already aligned; only metadata fixes should be committed."
requirements-completed: [DOCS-05]
duration: 3 min
completed: 2026-03-23
---

# Phase 04 Plan 05: Generated Docs and Build Alignment Summary

**Verified generated-document alignment, built a fresh source tarball, and tightened package build ignores**

## Performance

- **Duration:** 3 min
- **Started:** 2026-03-23T14:43:29Z
- **Completed:** 2026-03-23T14:46:57Z
- **Tasks:** 2
- **Files modified:** 1

## Accomplishments

- Regenerated package documentation with `roxygen2::roxygenise(load_code = roxygen2::load_source)` and confirmed the tracked `NAMESPACE` and `man/` outputs were already in sync.
- Built a fresh `typstR_0.0.0.9000.tar.gz` source package successfully.
- Installed the tarball into a temporary library and ran `tools::checkRdContents("typstR", lib.loc = "/tmp/typstR-lib")` successfully.
- Added `.Rbuildignore` rules for `.Rproj` and `.Rproj.user` so local project files stay out of package builds.

## Task Commits

Each task was committed atomically:

1. **Task 1-2: Regenerate docs, verify Rd structure, and harden build inputs** - `07d0d62` (build)

## Files Created/Modified

- `.Rbuildignore` - ignores local RStudio project files during package build

## Decisions Made

- Kept the source tarball as an uncommitted build artifact rather than adding release-like binaries to git.
- Used a temp-library installation for `checkRdContents()` because the function validates installed packages, not raw `man/` directories.
- Left `NAMESPACE` and `man/` untouched in git because regeneration produced no tracked diff, which keeps this commit small and reviewable.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Switched Rd verification to an installed-package check**
- **Found during:** Task 1 and Task 2 (generated-doc verification chain)
- **Issue:** The plan's original `tools::checkRdContents("man")` form is not valid because `checkRdContents()` expects an installed package, not a raw `man/` path.
- **Fix:** Built the tarball, installed it to `/tmp/typstR-lib`, and ran `tools::checkRdContents("typstR", lib.loc = "/tmp/typstR-lib")`.
- **Files modified:** none
- **Verification:** Temporary install and Rd structural check completed successfully.
- **Committed in:** `07d0d62` (the tracked packaging tweak for this plan)

---

**Total deviations:** 1 auto-fixed (1 missing critical)
**Impact on plan:** The verification path is now correct for base R tooling and gives a stronger proof point for the final CRAN hardening step.

## Issues Encountered

- Plain `roxygen2::roxygenise()` initially hit environment-specific dependency loading friction, so regeneration was rerun with `load_code = roxygen2::load_source`.
- Roxygen emitted unresolved self-link warnings for `[author()]`, `[affiliation()]`, and `[fig_note()]` under the source-loader path, but regeneration completed successfully and the installed-package Rd check passed.

## User Setup Required

None.

## Next Phase Readiness

- A fresh source tarball exists for the final `R CMD check --as-cran` plan.
- Build metadata and ignore rules are aligned, so the last plan can focus on CRAN-like verification instead of regeneration noise.

## Self-Check: PASSED

- Found `.planning/phases/04-tests-documentation-and-cran-hardening/04-05-SUMMARY.md`
- Found task commit `07d0d62`
- Confirmed `typstR_0.0.0.9000.tar.gz` exists locally

---
*Phase: 04-tests-documentation-and-cran-hardening*
*Completed: 2026-03-23*
