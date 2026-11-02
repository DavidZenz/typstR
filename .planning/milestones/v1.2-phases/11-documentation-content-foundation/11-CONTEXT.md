# Phase 11: Documentation Content Foundation - Context

**Gathered:** 2026-06-01
**Status:** Ready for planning

<domain>
## Phase Boundary

Polish the documentation content layer for v1.2 so a new user can go from install to scaffold to render without ambiguity. This phase covers README messaging, vignette positioning and content, help-page/reference improvements, `NEWS.md`, and docs-source hygiene such as tracking generated `man/*.Rd` and keeping pkgdown build artifacts out of the package tarball. It does **not** cover `_pkgdown.yml`, site navigation wiring, or GitHub Pages deployment; those belong to Phases 12 and 13.

</domain>

<decisions>
## Implementation Decisions

### Canonical onboarding split
- **D-01:** README should prove value quickly and show install; the pkgdown home page should act as the polished overview and navigation hub; `vignettes/getting-started.Rmd` should own the full walkthrough.
- **D-02:** The canonical onboarding example should use the **working paper** scaffold only. Article and policy brief paths should appear as follow-on options rather than equal first-run branches.
- **D-03:** `getting-started` should explicitly name and explain the roles of `template.qmd`, `_quarto.yml`, and `references.bib`; README and home-page content should keep that step lighter.

### First-screen README message
- **D-04:** The first screenful of README must contain the package value proposition, the install command, an explicit Quarto/system-requirement note, and a very short scaffold -> render preview.
- **D-05:** The Quarto note should be direct: users can install `typstR` in R immediately, but Quarto is required when they render.
- **D-06:** README opening copy should be adoption-focused and outcome-oriented, not written like a technical reference page.

### Vignette roles and order
- **D-07:** Articles should have an intentional journey: `getting-started` first, `working-papers` second, `customizing-branding` third.
- **D-08:** `working-papers` should deepen the metadata/title-page story rather than reintroduce the package from scratch.
- **D-09:** `customizing-branding` should be a practical guide to the YAML/front-matter knobs users are most likely to change first.
- **D-10:** The later two articles should link back to `getting-started` for the base scaffold/render flow instead of duplicating the full intro.

### Reference and example style
- **D-11:** Help-page examples should stay short and runnable; they should reinforce the main workflow without becoming mini-vignettes.
- **D-12:** Example refresh should prefer real scaffold/edit/render actions and only use helper-only examples when that is the clearest fit.
- **D-13:** Phase 11 should prioritize the highest-traffic user-facing functions first; lower-level helpers can remain lighter if they already meet the minimum quality bar.

### the agent's Discretion
- Exact README wording, section titles, and line-level ordering inside the chosen first-screen structure
- The precise boundary between what lives in README versus pkgdown home-page prose, as long as the split above is preserved
- Which lower-level helper pages receive expanded examples after the scaffold/render entrypoints are brought up to standard
- Final `NEWS.md` phrasing for v1.0, v1.1, and v1.2 entries

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Milestone contract
- `.planning/ROADMAP.md` — Phase 11 goal, dependency on Phase 10, and success criteria for README, vignette, help-page, `NEWS.md`, and docs-hygiene work
- `.planning/REQUIREMENTS.md` — `DOCS-01` through `DOCS-05` and `SHIP-04`, which define the documentation and source-tracking requirements this phase must satisfy
- `.planning/PROJECT.md` — v1.2 milestone framing and the onboarding-first objective for the documentation polish milestone
- `.planning/STATE.md` — current milestone state and phase ordering context

### Existing documentation surfaces
- `README.md` — current repository landing page and the main surface that must communicate value/install/prerequisites immediately
- `vignettes/getting-started.Rmd` — canonical walkthrough surface for the install -> scaffold -> render flow
- `vignettes/working-papers.Rmd` — existing article that should specialize in working-paper metadata/title-page depth
- `vignettes/customizing-branding.Rmd` — existing article that should specialize in practical YAML/front-matter branding customization

### Package metadata and reference sources
- `DESCRIPTION` — current package metadata and `SystemRequirements`, which shape prerequisite messaging and later site metadata
- `.gitignore` — current ignore rules; Phase 11 must stop ignoring generated `man/*.Rd`
- `.Rbuildignore` — package tarball exclusions; Phase 11 must ensure pkgdown artifacts stay out of the built package
- `R/typstR-package.R` — package-level narrative that should stay aligned with the onboarding story
- `R/create_working_paper.R` — primary scaffold entrypoint and a high-priority help page for example refresh
- `R/create_article.R` — adjacent scaffold entrypoint that should be positioned as a follow-on path, not the default onboarding path
- `R/create_policy_brief.R` — adjacent scaffold entrypoint that should be positioned as a follow-on path, not the default onboarding path
- `R/render.R` — primary render entrypoint and a high-priority help page for example refresh

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `README.md`: already contains install and quick-start material that can be reorganized into the new onboarding split instead of rewritten from scratch
- `vignettes/getting-started.Rmd`, `vignettes/working-papers.Rmd`, `vignettes/customizing-branding.Rmd`: existing article corpus to refine, reorder, and de-duplicate rather than replace
- `R/create_working_paper.R`, `R/create_article.R`, `R/create_policy_brief.R`, `R/render.R`: current exported scaffold/render entrypoints with roxygen blocks and examples that can be upgraded directly
- `R/typstR-package.R`: concise package-level value statement that already matches the scaffold -> edit -> render mental model

### Established Patterns
- Public functions use roxygen2 comments with `@param`, `@return`, `@examples`, and `@export`; improving help quality should follow that source-driven pattern rather than editing generated Rd files directly
- Current examples are wrapped in `\dontrun{}` where rendering or file-system side effects occur; Phase 11 should preserve safe example conventions while making examples more meaningful
- The package narrative is YAML-driven and Quarto-backed; docs should continue to explain the workflow in those terms rather than exposing Typst internals
- Repo hygiene is controlled through `.gitignore` and `.Rbuildignore`; documentation-source tracking changes must respect that split

### Integration Points
- README, vignette content, package-level docs, and help-page examples all need to tell the same install -> scaffold -> render story so later pkgdown pages inherit a consistent narrative
- `DESCRIPTION` and the render-validation code shape how prerequisites are described; docs should stay consistent with the actual requirement that Quarto is needed at render time
- Changes to roxygen comments in `R/*.R` will flow into `man/*.Rd`, so reference refresh and the man-page tracking decision are linked work

</code_context>

<specifics>
## Specific Ideas

- Use **working paper** as the single canonical first-run example
- Make the edit step concrete in `getting-started` by naming `template.qmd`, `_quarto.yml`, and `references.bib`
- Keep README/home content lighter and more persuasive, while `getting-started` carries the detailed walkthrough
- Treat `working-papers` and `customizing-branding` as follow-on guides that link back to the canonical introduction instead of repeating it

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 11-documentation-content-foundation*
*Context gathered: 2026-06-01*
