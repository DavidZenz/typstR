---
phase: 3
slug: typst-templates-branding-and-additional-formats
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-23
---

# Phase 3 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | testthat 3.x |
| **Config file** | tests/testthat.R (exists from Phase 1) |
| **Quick run command** | `Rscript -e "testthat::test_dir('tests/testthat')"` |
| **Full suite command** | `Rscript -e "devtools::check()"` |
| **Estimated runtime** | ~45 seconds |

---

## Sampling Rate

- **After every task commit:** Run `Rscript -e "testthat::test_dir('tests/testthat')"`
- **After every plan wave:** Run `Rscript -e "devtools::check()"`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 45 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 03-01-01 | 01 | 1 | TMPL-09, TMPL-01 | unit | `grep -r "#import" inst/quarto/extensions/typstR/` | ❌ W0 | ⬜ pending |
| 03-02-01 | 02 | 1 | TMPL-02, TMPL-03, TMPL-04, TMPL-05 | integration | `quarto render` smoke test | ❌ W0 | ⬜ pending |
| 03-03-01 | 03 | 2 | TMPL-10, TMPL-11, TMPL-12 | integration | `quarto render` with branding YAML | ❌ W0 | ⬜ pending |
| 03-04-01 | 04 | 2 | TMPL-13, SCAF-02, SCAF-03 | unit | `test_that("create_article scaffolds")` | ❌ W0 | ⬜ pending |
| 03-05-01 | 05 | 3 | TMPL-06, TMPL-07, TMPL-08 | integration | `quarto render` with appendix/bibliography | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `tests/testthat/test-scaffold-article.R` — stubs for SCAF-02
- [ ] `tests/testthat/test-scaffold-brief.R` — stubs for SCAF-03
- [ ] `tests/testthat/test-templates.R` — stubs for TMPL modular structure checks

*Existing infrastructure from Phase 1+2: testthat bootstrap, metadata tests, integration tests*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Branding hooks change rendered PDF | TMPL-10, TMPL-11 | Visual verification | Set logo/font/color in YAML, render, verify changes |
| Affiliation superscripts render correctly | TMPL-03 | Visual verification | Multi-author paper, verify ¹² superscripts |
| Anonymized mode strips author info | TMPL-13 | Visual verification | Set anonymized: true, render, verify no author/affiliation |
| Disclaimer page renders at correct position | TMPL-12 | Visual verification | Set disclaimer-page: true with position first/last |
| Appendix lettered numbering | TMPL-07 | Visual verification | Add appendix sections, verify A.1, A.2 numbering |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 45s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
