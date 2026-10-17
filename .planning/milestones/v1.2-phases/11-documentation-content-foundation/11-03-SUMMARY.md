---
phase: 11-documentation-content-foundation
plan: 03
subsystem: documentation
tags: [news, pkgdown, rbuildignore, gitignore, cran]
requires:
  - phase: 11-documentation-content-foundation
    provides: stable milestone framing and docs surfaces to summarize in NEWS
provides:
  - pkgdown-readable milestone changelog source
  - git tracking for committed man pages
  - tarball exclusions for pkgdown-only source and output directories
affects: [phase-11-plan-04, phase-12-site-configuration, cran-package-build]
tech-stack:
  added: []
  patterns: [separate git tracking rules from source-tarball exclusions]
key-files:
  created: [NEWS.md, .planning/phases/11-documentation-content-foundation/11-03-SUMMARY.md]
  modified: [.gitignore, .Rbuildignore, .planning/ROADMAP.md, .planning/STATE.md]
key-decisions:
  - "Use pkgdown's exact `# typstR X.Y` heading format for milestone changelog entries."
  - "Keep `pkgdown/` and `docs/` out of package builds while allowing committed Rd files into git."
patterns-established:
  - "Git ignore rules govern tracked source artifacts; `.Rbuildignore` governs what ships in the tarball."
  - "Phase 11 documentation metadata stays release-facing and avoids Phase 12/13 deployment details."
requirements-completed: [DOCS-05, SHIP-04]
duration: 2min
completed: 2026-06-01
---

# Phase 11: Plan 03 Summary

**A pkgdown-readable `NEWS.md` now summarizes v1.0-v1.2, and the repo/build ignore split allows committed Rd files without leaking `pkgdown/` or `docs/` into package tarballs.**

## Performance

- **Duration:** 2 min
- **Started:** 2026-06-01T12:30:50Z
- **Completed:** 2026-06-01T12:32:03Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments
- Added `NEWS.md` with the required v1.0, v1.1, and v1.2 headings and user-facing milestone bullets.
- Removed the `man/*.Rd` gitignore rule so regenerated reference pages can be committed.
- Added `^docs$` and `^pkgdown$` tarball exclusions and confirmed they stay out of `R CMD build` output.

## Task Commits

Each task was committed atomically:

1. **Task 1: Milestone changelog source** - `30adfa6` (docs)
2. **Task 2: Git/build ignore split** - `a8d4c70` (build)

**Plan metadata:** recorded in this summary commit.

## Files Created/Modified
- `NEWS.md` - Pkgdown-readable changelog for milestones v1.0, v1.1, and v1.2.
- `.gitignore` - Allows committed `man/*.Rd` files.
- `.Rbuildignore` - Excludes `docs/` and `pkgdown/` from package tarballs.
- `.planning/ROADMAP.md` - Marked Plan 11-03 complete and updated Phase 11 progress.
- `.planning/STATE.md` - Advanced execution to Plan 11-04.

## Decisions Made
- Summarized v1.2 in release-facing terms about docs polish and onboarding, without pulling in later deployment work.
- Verified the ignore split with both `git check-ignore` and a real source tarball inspection.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
Plan 11-04 can now regenerate source-driven Rd pages against a committed-man-pages workflow and the new red-state audit.
No blockers remain for completing Phase 11.

---
*Phase: 11-documentation-content-foundation*
*Completed: 2026-06-01*
