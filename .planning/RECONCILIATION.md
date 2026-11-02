# Planning reconciliation — 2026-10-17

- Planning milestone v1.5 is active; package version remains 0.1.0.
- Archived v1.0–v1.4 records are historical completion claims, not package release numbers or proof of CRAN acceptance.
- Added retrospective verification reports to phases 11–16, citing their summaries and distinguishing current static/local evidence from historical claims.
- Preserved all existing phase files byte-for-byte; moved phases 11–13 from phases/ into milestones/v1.2-phases/, and 14–16 into milestones/v1.3-phases/. Only new VERIFICATION reports were added. Old absolute paths in historical records identify their original locations.
- Phase 13 retains human_needed for current live deployment/reachability. Historical summary lacks retained raw responses/run IDs. A current successful local build does not close this external verification boundary.
- Phase 12 summary has a conflicting 2024 timestamp; original retained and discrepancy disclosed.
- Original PROJECT checklist overstated unshipped check_* APIs. Current text identifies validate_render_environment and the newly implemented validate_manuscript API.
- NEWS headings now use package version 0.1.0; internal milestone names remain in subsections.
- BRAND-03 previews (P2) and EXT-03 versioned docs (P3) are restored to BACKLOG.md with acceptance criteria.
- Older plan-count totals disagree across historical STATE/ROADMAP/MILESTONES files; do not use them as current progress evidence. v1.5 tracks requirement-level gates explicitly.

Fresh local site check/build passed with R 4.6.1 and Pandoc 3.6.4; complete logs are
retained in artifacts/release/. No new live deployment or CRAN submission is claimed.
