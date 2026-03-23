---
phase: 02-metadata-helpers-and-yaml-interface
plan: "04"
subsystem: testing
tags: [quarto, typst, pandoc, integration-tests, testthat, withr]

requires:
  - phase: 02-01
    provides: author(), affiliation(), manuscript_meta() R functions
  - phase: 02-02
    provides: keywords(), jel_codes(), report_number(), funding() R functions
  - phase: 02-03
    provides: typst-show.typ Pandoc variable wiring for typstR: namespace

provides:
  - Integration test suite validating full YAML-to-PDF pipeline (4 guarded tests)
  - Quarto 1.8 compatibility fixes for typst extension (format key, Pandoc template syntax, author structure)
  - Confirmed: typstR: namespace fields (keywords, jel, acknowledgements, report-number, funding, data-availability, code-availability) pass through Pandoc to Typst PDF without errors
  - Confirmed: standard Quarto fields (toc, number-sections) coexist with typstR: fields
  - Confirmed: hyphenated keys (report-number, data-availability, code-availability) work in Quarto 1.8

affects:
  - 03-typst-template-and-branding
  - 04-validation-and-cran

tech-stack:
  added: []
  patterns:
    - All integration tests guarded with skip_if_not(quarto::quarto_available()) for CRAN safety (TEST-04)
    - withr::with_tempdir() for isolated render test environments
    - Quarto 1.8 format key must be "typst" (not custom name) in _extension.yml; user-facing format is "{extension-name}-typst"
    - Quarto 1.8 author normalisation: Lua filter transforms raw author to by-author; use $for(by-author)$ and it.name.literal in Pandoc templates
    - Pandoc 3.6 for loop: $for()$ directive must be on its own line when followed by literal quote characters; use $sep$ for separators

key-files:
  created:
    - tests/testthat/test-yaml-integration.R
  modified:
    - inst/quarto/extensions/typstR/_extension.yml
    - inst/quarto/extensions/typstR/typst-show.typ
    - inst/quarto/extensions/typstR/typst-template.typ
    - inst/templates/workingpaper/template.qmd
    - R/render.R

key-decisions:
  - "Quarto extension format key changed from 'workingpaper' to 'typst': Quarto 1.8 strict YAML schema validation rejects unknown format keys; only 'typst' is accepted for typst-based formats. User-facing format name is now typstR-typst."
  - "typst-show.typ uses $for(by-author)$ not $for(author)$: Quarto 1.6+ normalises authors through its Lua filter into a by-author variable with name.literal, email, attributes.corresponding structure. The raw author variable retains user input but name fields are not accessible via Pandoc template syntax after filter transformation."
  - "Pandoc 3.6 template syntax: $for()$ directive followed immediately by literal double-quote causes parse error. Fix is to add a newline after $for()$ before the quoted string content. Switched to $sep$ for list separators."
  - "Typst dictionary field access via .at(): Typst dictionaries require a.at('name') not a.name for field access. Fixed in typst-template.typ for both author name and affiliation name fields."
  - "Hyphenated YAML keys (report-number, data-availability, code-availability) confirmed working in Quarto 1.8 with $if(typstR.report-number)$ syntax — no fallback needed."

patterns-established:
  - "Integration tests: skip_if_not(quarto::quarto_available()) as first line of each test_that block"
  - "Extension format naming in Quarto 1.8: contributes.formats.typst in _extension.yml -> {ext-name}-typst in user docs"
  - "Author template variables: by-author.name.literal (not author.name) after Quarto Lua filter"

requirements-completed:
  - YAML-01
  - YAML-02
  - YAML-03

duration: 25min
completed: 2026-03-23
---

# Phase 2 Plan 04: YAML Integration Tests Summary

**Integration tests for full YAML-to-PDF pipeline with 4 Quarto-guarded tests; Quarto 1.8 compatibility fixes for format key naming, Pandoc 3.6 template syntax, and author normalisation**

## Performance

- **Duration:** 11 min
- **Started:** 2026-03-23T08:53:45Z
- **Completed:** 2026-03-23T09:04:45Z
- **Tasks:** 2 of 2 complete (Task 2 human-verified and approved)
- **Files modified:** 6

## Accomplishments
- Created `tests/testthat/test-yaml-integration.R` with 4 integration tests covering: scaffold render, typstR: namespace field passthrough, standard Quarto field coexistence, and hyphenated key validation
- Discovered and fixed 4 Quarto 1.8/Pandoc 3.6 compatibility issues in the typst extension that would have prevented any render from succeeding
- Successfully rendered `/tmp/meta-test/template.pdf` from the scaffolded working paper template for human verification

## Task Commits

1. **Task 1: Create integration tests** - `6e3f432` (feat)
2. **[Rule 1] Quarto 1.8 compatibility fixes** - `e0653d3` (fix)
3. **Task 2: Human PDF verification** - Approved. PDF confirmed showing title, authors, affiliations, abstract, keywords, JEL codes, acknowledgements, report number, and funding. Two Phase 3 notes recorded (see Next Phase Readiness).

## Files Created/Modified
- `tests/testthat/test-yaml-integration.R` - 4 integration tests guarded by skip_if_not(quarto::quarto_available())
- `inst/quarto/extensions/typstR/_extension.yml` - format key changed from 'workingpaper' to 'typst'
- `inst/quarto/extensions/typstR/typst-show.typ` - Quarto 1.8 and Pandoc 3.6 fixes
- `inst/quarto/extensions/typstR/typst-template.typ` - Typst dictionary field access fix
- `inst/templates/workingpaper/template.qmd` - updated format name to typstR-typst
- `R/render.R` - updated format name to typstR-typst

## Decisions Made

- Quarto 1.8 changed format key schema validation — extension must use `typst` not a custom name (`workingpaper`)
- Quarto 1.6+ normalizes `author` metadata via Lua filter into `by-author` with `name.literal` structure
- Pandoc 3.6 requires newline after `$for()$` before literal `"` characters; `$sep$` syntax replaces manual comma concatenation

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Quarto 1.8 rejects 'workingpaper' as format key in _extension.yml**
- **Found during:** Task 1 verification (render attempt)
- **Issue:** Quarto 1.8 performs strict YAML schema validation before extension format resolution. Custom format names (e.g., `workingpaper`) are rejected with "has value default, which must instead be no possible value". Only `typst` is accepted as the format key for typst-based extensions.
- **Fix:** Changed `contributes.formats.workingpaper:` to `contributes.formats.typst:` in `_extension.yml`. Updated `template.qmd` and `render.R` from `typstR-workingpaper` to `typstR-typst`.
- **Files modified:** `_extension.yml`, `template.qmd`, `R/render.R`, integration tests
- **Verification:** Quarto render passes schema validation and proceeds to Pandoc/Typst compilation
- **Committed in:** `e0653d3`

**2. [Rule 1 - Bug] typst-show.typ #import statement causes file-not-found Typst error**
- **Found during:** Task 1 verification (render attempt after fix 1)
- **Issue:** `typst-show.typ` had `#import "typst-template.typ": working-paper` at the top. With template-partials, Quarto embeds `typst-template.typ` content inline into the output `.typ` file — there is no separate `typst-template.typ` file for Typst to import. Typst threw a file-not-found error.
- **Fix:** Removed the `#import` statement; `working-paper` is already defined in the generated `.typ` file.
- **Files modified:** `typst-show.typ`
- **Verification:** Render proceeds past Pandoc phase to Typst compilation
- **Committed in:** `e0653d3`

**3. [Rule 1 - Bug] Pandoc 3.6 template parse error: literal " immediately after $for()$**
- **Found during:** Task 1 verification (after fix 2)
- **Issue:** `keywords: ($for(typstR.keywords)"$it$",$endfor$)` causes Pandoc 3.6 to throw "unexpected \"\" expecting $" because the `"` immediately follows `$for()$` on the same line. Pandoc 3.6 requires a newline after the `$for()$` directive before literal characters.
- **Fix:** Split into two lines: `$for(typstR.keywords)$\n"$it$"$sep$, $endfor$`. Applied to both `keywords` and `jel` loops.
- **Files modified:** `typst-show.typ`
- **Verification:** Pandoc template compiles without error
- **Committed in:** `e0653d3`

**4. [Rule 1 - Bug] Quarto 1.8 author normalisation: $for(author)$ produces empty fields**
- **Found during:** Task 1 verification (after fix 3, Typst compile error)
- **Issue:** `typst-show.typ` used `$for(author)$` with `$if(it.name.literal)$...$else$$if(it.name)$...$endif$$endif$`. After Quarto's Lua filter transforms author metadata, neither condition matched. Quarto 1.6+ normalises `author` into a `by-author` variable where each item has `name.literal`, `email`, and `attributes.corresponding`.
- **Fix:** Replaced `$for(author)$` with `$for(by-author)$` and updated field access to `it.name.literal`, `it.email`, `it.attributes.corresponding`. Also fixed `typst-template.typ` to use `a.at("name", default: "")` instead of `a.name` (Typst dictionary field access requires `.at()`).
- **Files modified:** `typst-show.typ`, `typst-template.typ`
- **Verification:** Full render to PDF succeeds with correct author names in output
- **Committed in:** `e0653d3`

---

**Total deviations:** 4 auto-fixed (all Rule 1 - Bugs)
**Impact on plan:** All fixes essential for any render to succeed. Discovered Quarto 1.8 breaking changes that affected the extension core. No scope creep.

## Issues Encountered

- The `typst-show.typ` template was written for Quarto <=1.5 conventions. Quarto 1.8 (bundled with Positron) introduced breaking changes in three areas simultaneously: format key schema validation, author normalisation via Lua filters, and underlying Pandoc version (3.6). All four issues had to be resolved in sequence before a successful render could be verified.
- The "Linux Libertine" font warning in Typst is expected on machines without the system font — the font ships with Quarto's bundled Typst compiler. PDF renders correctly despite the warning.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Integration tests complete and CRAN-safe (skip gracefully without Quarto)
- Quarto 1.8 compatibility verified: full scaffold-to-PDF pipeline works
- Human approved PDF: all metadata fields (title, authors, affiliations, abstract, keywords, JEL codes, acknowledgements, report number, funding) display correctly
- Hyphenated keys confirmed working — the research flag in STATE.md blockers can be resolved
- **Phase 3 styling notes (from human review):**
  1. Author email escaping: PDF shows `<author.one\@example.org>` with a backslash before `@` — fix in Phase 3 template styling
  2. Affiliation numbering: should use academic-style superscripts (Author¹, Author¹², with numbered affiliations below) — fix in Phase 3 template styling
- Phase 3 (Typst template and branding) is unblocked and ready to begin

---
*Phase: 02-metadata-helpers-and-yaml-interface*
*Completed: 2026-03-23*
