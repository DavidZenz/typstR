# Pitfalls Research

**Domain:** R package bundling Quarto extensions with Typst templates for scientific publishing
**Researched:** 2026-03-21
**Confidence:** MEDIUM-HIGH (most pitfalls verified against official Quarto docs and GitHub discussions; some from community sources)

---

## Critical Pitfalls

### Pitfall 1: Extensions Must Live in the User's Project — Not in the Installed Package

**What goes wrong:**
Quarto's extension resolution is strictly per-project. When `create_working_paper()` scaffolds a new directory, it must copy the `_extensions/` tree into that directory. If the package only ships the extension in `inst/quarto/extensions/typstR/` and tells users to reference it there, render will fail with a "format not found" error. There is no global extension registry.

**Why it happens:**
Developers assume R's `system.file()` path is enough — that because the package installed successfully, Quarto can reach the extension. Quarto never searches installed R packages for extensions; it only searches relative to the document or project root.

**How to avoid:**
In every scaffolding function (`create_working_paper()`, `create_article()`, `create_policy_brief()`), copy the full `_extensions/typstR/` subtree from `system.file("quarto/extensions/typstR", package = "typstR")` into the user's new project directory under `_extensions/typstR/`. Do this unconditionally, not lazily. Verify the copy succeeded before returning.

**Warning signs:**
- Manual `quarto render` on a scaffolded project produces "Unknown format: typstR-workingpaper"
- Tests that only call R helper functions pass but render tests fail
- Package works in the development repo (where `_extensions/` exists) but not in a fresh install

**Phase to address:** Project scaffolding phase (first phase involving `create_*` functions)

---

### Pitfall 2: Quarto Locks In a Specific Bundled Typst Version — Your `.typ` Code Must Match It

**What goes wrong:**
Typst introduces breaking syntax changes between minor versions. Quarto bundles a specific Typst binary and upgrades it at most once per major Quarto release. Template code written against Typst 0.12 syntax (e.g., `context` keyword, revised `show` rule semantics) silently fails or errors when Quarto ships Typst 0.11. Users cannot override the bundled binary in standard workflows.

**Why it happens:**
Typst documentation and community examples track the latest Typst release, not Quarto's bundled version. Developers copy examples from typst.app/docs without checking the Quarto version matrix. The mismatch produces cryptic Typst compile errors far removed from the actual version problem.

**How to avoid:**
- Document the minimum Quarto version required (and thus the Typst version floor) in `DESCRIPTION` and `check_typstR()`.
- Write all `.typ` files against the Typst version bundled in the minimum supported Quarto. Check this at the start of each development session with `quarto --version` and compare against the Typst changelog.
- Avoid Typst `@preview` package imports entirely in bundled templates — they require network access or manual `typst-gather` bundling, and they tie templates to Typst package registry version pins.

**Warning signs:**
- Template works with standalone `typst compile` but not `quarto render`
- Compile errors referencing Typst syntax that appears correct in the docs
- Users on different Quarto versions report inconsistent behavior

**Phase to address:** Template authoring phase; also enforce in the validation layer (`check_typst()` should report the Typst version Quarto will use)

---

### Pitfall 3: YAML Metadata Is Not Automatically Available in Typst — You Must Wire Every Field

**What goes wrong:**
YAML front matter fields do not flow into Typst templates automatically. Fields defined in a `typstR:` block (e.g., `jel`, `acknowledgements`, `report-number`) are invisible to Typst unless `typst-show.typ` explicitly extracts and passes them as arguments to the layout function. Forgetting a field means it silently renders as nothing, with no error.

A second wrinkle: standard Quarto fields (`toc`, `fig-cap-location`) are processed by Pandoc and do not appear as template variables at all — you cannot read them back out in `typst-show.typ`. Only fields unknown to Pandoc/Quarto pass through as metadata.

**Why it happens:**
Developers expect the YAML front matter to be a shared namespace. The two-file split (`typst-template.typ` for layout, `typst-show.typ` for the metadata bridge) is not obvious, and the gotcha about standard Quarto fields being consumed before reaching Typst is documented only in community discussions.

**How to avoid:**
- Map every field the user can set through the `typstR:` block by writing an explicit argument in `typst-show.typ`. Include `none` as the default for optional fields so Typst receives a defined value even when the field is absent.
- Keep all typstR-specific fields under the `typstR:` namespace to avoid conflicts with Pandoc's own metadata processing.
- Write integration tests that render a document with every supported field and assert the rendered PDF contains the expected content (use `pdftools` or regex on extracted text).

**Warning signs:**
- A metadata field appears in the YAML but not in the rendered PDF, with no error
- `typst-show.typ` grows ad hoc without a systematic mapping of all supported fields
- Developers test individual R helpers but never do a full end-to-end render

**Phase to address:** Template authoring phase and metadata helpers phase (both must be co-developed and tested together)

---

### Pitfall 4: Vignettes That Call `quarto render` Will Fail on CRAN

**What goes wrong:**
CRAN build machines do not have Quarto installed. Any vignette that calls `quarto::quarto_render()`, `render_pub()`, or any function that shells out to Quarto will fail `R CMD check` with a "Quarto not found" or execution error, causing the package to be rejected.

**Why it happens:**
The package's core purpose is to render documents with Quarto, so it seems natural to demonstrate this in vignettes. But CRAN treats all external system binaries as unavailable during check unless they are in the SystemRequirements field and the package handles their absence gracefully.

**How to avoid:**
- List `SystemRequirements: quarto` in `DESCRIPTION`.
- Guard all rendering code in vignettes with `if (quarto::quarto_available()) { ... }` or equivalent.
- Pre-render vignettes and commit the output (`.Rmd` with pre-knitted results), or use `knitr::opts_chunk$set(eval = FALSE)` for render-calling chunks.
- Validate that `check_quarto()` returns FALSE gracefully — never stop() on a missing external binary during package load or during vignette build.

**Warning signs:**
- Vignette contains `render_pub()` or `quarto::quarto_render()` in an evaluated code chunk
- `R CMD check` passes locally (Quarto installed) but CI fails on a fresh Ubuntu runner
- `check_quarto()` calls `stop()` instead of returning a structured result

**Phase to address:** Package structure / CRAN-readiness phase; validation functions must be designed before vignettes are written

---

### Pitfall 5: Author/Affiliation Schema Complexity Causes Silent Data Loss

**What goes wrong:**
Quarto's normalized author schema is a closed schema — any unrecognized keys placed at the root of an `author:` entry are remapped under a `metadata:` sub-key rather than being passed through. If `typst-show.typ` reads `author.email` but the user's YAML puts email at the wrong nesting level, no error occurs but the field is empty in the PDF. Affiliation deduplication also requires exact string matches; two authors with the same institution but slightly different strings get separate footnote numbers.

**Why it happens:**
Author/affiliation handling is the most complex part of any scientific publication template. Quarto's schema is rich but not well-publicized. Template developers often handle the happy path (single author, simple affiliation) and discover edge cases only from user bug reports.

**How to avoid:**
- Study Quarto's normalized author schema fully before implementing the author block: `name`, `orcid`, `email`, `corresponding`, `equal-contributor`, and the `affiliations` list with `id`, `name`, `department`, `city`, `country`.
- Build test documents with: single author, multiple authors, multiple affiliations per author, corresponding author flag, ORCID, equal contributors.
- Provide R helper functions (`author()`, `affiliation()`) that generate correctly structured YAML so users are not writing raw YAML structure manually.
- Document the exact YAML schema in the vignette with copy-pasteable examples.

**Warning signs:**
- Author block renders correctly for a single author but breaks with two or more
- Affiliation numbers in the rendered PDF are wrong or duplicated
- Users report that `email` or `orcid` fields are missing from the output despite being set

**Phase to address:** Metadata helpers phase; author/affiliation edge cases must be tested before any format is declared stable

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Put all Typst layout in a single `base.typ` file | Faster initial development | Very hard to override individual blocks for branding; becomes a monolith | Never — modular files are the same effort once the pattern is established |
| Hardcode fonts in `.typ` files | Simpler template code | Users must edit Typst to change fonts; breaks the "no Typst knowledge required" promise | Never for brand-configurable elements |
| Skip the `typstR:` YAML namespace and use flat top-level fields | Fewer characters for users to type | Collides with Pandoc/Quarto reserved fields; fields silently ignored or overridden | Never — namespace from day one |
| Use `system()` or `processx::run()` directly for rendering instead of the `quarto` package | Works immediately | Bypasses Quarto's path resolution; breaks on Windows path spaces; not CRAN-safe | Never — depend on the `quarto` package |
| Skip `mustWork = TRUE` in `system.file()` calls | Avoids one argument | Silent path failures when extension files are missing; render error instead of informative message | Never for critical extension files |
| Write vignettes that render a full document | Shows the feature working | Fails CRAN check without Quarto guard; slow vignette builds | Only if fully guarded with `quarto_available()` check |

---

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| Quarto extension discovery | Reference extension from `system.file()` path in render call | Copy `_extensions/` tree into user project in every `create_*()` function |
| Typst bibliography | Use `csl:` key expecting Pandoc citeproc behavior | Typst defaults to its own citation engine; use `bibliographystyle:` for Typst styles, or set `citeproc: true` to opt into Pandoc citeproc |
| Quarto heading levels | Define `= Heading` (level 1) in Typst template for what will be `##` in Quarto | Quarto shifts headings up one level when converting to Typst — a `##` in `.qmd` becomes level 1 in Typst |
| Font availability | Reference custom fonts by name in `.typ` | Typst only discovers fonts from `--font-paths`, system fonts, and embedded fonts; custom fonts must be shipped as assets or documented as a user prerequisite |
| `quarto render` working directory | Assume `.qmd` file directory is the working directory | Quarto uses project root when a `_quarto.yml` exists; no project means the document directory; both cases must be handled in render wrappers |
| `@preview` Typst packages | Import utility packages from `@preview` namespace | Requires network access; silently fails offline; must be bundled via `typst-gather` if used at all |

---

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Calling `validate_manuscript()` inside `render_pub()` | Render calls run validation twice (once explicit, once implicit) | Keep validation and rendering separate; call validation only when the user explicitly asks | Any document with slow validation checks |
| Copying the full extension tree on every render call | Render is noticeably slow; extension directory is overwritten on every call | Copy extension only during scaffolding (`create_*` functions); do not re-copy at render time | Projects with large assets in `_extensions/` |
| Shelling out to `quarto --version` inside package-load code | Package load is slow; CRAN check flags slow `.onLoad` | Only check Quarto availability lazily (inside `check_quarto()` or `render_pub()`), never in `.onLoad` or `.onAttach` | Always — any shell call at load time is wrong |

---

## "Looks Done But Isn't" Checklist

- [ ] **Extension bundling:** `create_working_paper()` copies `_extensions/typstR/` into the project — verify with a fresh `tempdir()` that render succeeds after package install, not just from source
- [ ] **Anonymized mode:** `article_typst` with `anonymized: true` — verify author names, email, ORCID, and acknowledgements are all suppressed in the rendered PDF, not just hidden in YAML
- [ ] **Bibliography:** A document with citations actually renders with correct reference formatting — Typst and Quarto citeproc are separate systems; verify the right one is active
- [ ] **Branding YAML roundtrip:** Setting `logo:`, `primary-font:`, `accent-color:` via YAML changes the rendered PDF — verify each field actually reaches the Typst template through `typst-show.typ`
- [ ] **Multi-author layout:** Render a document with 3 authors and 2 affiliations — verify affiliation superscripts are correct and no author's email is missing
- [ ] **Report number:** `report-number: "WP 001"` appears on the title page — this field flows through a custom YAML key; easy to forget to wire it in `typst-show.typ`
- [ ] **R CMD check clean:** Run `devtools::check()` on a machine without Quarto — all checks pass; vignettes do not call render code without a `quarto_available()` guard
- [ ] **Appendix heading:** The appendix section renders with correct lettered headings (A, B, C) not numbered headings — requires Typst `show` rule reset

---

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Extension not copied to user project | LOW | Add `fs::dir_copy()` call in `create_*()` functions; existing users run `install_typstR_extension()` helper |
| Typst version incompatibility in templates | HIGH | Audit all `.typ` files against the target Typst version; may require rewriting `show` rules; add `minimum_quarto_version` check to `check_typstR()` |
| YAML field wiring missing from `typst-show.typ` | LOW | Add the missing argument; no user-facing API change required |
| CRAN rejection for Quarto dependency in vignettes | MEDIUM | Pre-render vignettes; add `quarto_available()` guards; resubmit |
| Author schema edge case reported by users | LOW | Fix `typst-show.typ` author loop; write regression test; patch release |
| Monolithic `.typ` file makes branding impossible | HIGH | Refactor into modular files; likely breaks existing user customizations; requires a deprecation cycle |

---

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Extension not copied to user project | Project scaffolding phase | `create_working_paper(tempdir())` then `quarto render` succeeds on a clean install |
| Typst version incompatibility | Template authoring phase | CI matrix tests against minimum and latest supported Quarto version |
| YAML metadata not wired to Typst | Template + metadata helpers phase | Integration test renders with all supported fields and asserts content in PDF |
| Vignettes fail CRAN check | Package structure / CRAN phase | `R CMD check` run on CI runner without Quarto installed passes cleanly |
| Author/affiliation schema edge cases | Metadata helpers phase | Test matrix: 1 author, 3 authors, shared affiliation, corresponding author, ORCID |
| Bibliography system mismatch | Template authoring phase | Render a document with citations; verify reference list format and in-text style |
| Branding fields not reaching Typst | Branding hooks phase | Render with each branding field set; compare PDF against expected output |
| Monolithic template blocks customization | Template authoring phase (upfront) | Verify each `.typ` module can be overridden independently before any format ships |

---

## Sources

- [Custom Typst Formats — Quarto Documentation](https://quarto.org/docs/output-formats/typst-custom.html) — MEDIUM confidence (official, but sparse on gotchas)
- [Typst Basics — Quarto Documentation](https://quarto.org/docs/output-formats/typst.html) — HIGH confidence
- [Managing Extensions — Quarto Documentation](https://quarto.org/docs/extensions/managing.html) — HIGH confidence (confirms per-project extension model)
- [Define the path to the _extensions folder (Discussion #8098)](https://github.com/quarto-dev/quarto-cli/discussions/8098) — HIGH confidence (maintainer confirmed no global install)
- [When will the Typst dependency be upgraded? (Discussion #11956)](https://github.com/orgs/quarto-dev/discussions/11956) — HIGH confidence (confirms Typst version lock per Quarto release)
- [Help with custom Typst format (Discussion #10690)](https://github.com/quarto-dev/quarto-cli/discussions/10690) — MEDIUM confidence (community discussion with maintainer response)
- [YAML arguments not being passed to Typst template partials (Discussion #11459)](https://github.com/quarto-dev/quarto-cli/discussions/11459) — MEDIUM confidence (confirms standard Quarto fields don't pass through to Typst)
- [Citation style in Typst inconsistent with documentation (Discussion #9761)](https://github.com/orgs/quarto-dev/discussions/9761) — MEDIUM confidence (confirms citeproc/Typst citation system split)
- [Creating Quarto Journal Article Templates — Christopher T. Kenny](https://christophertkenny.com/posts/2023-07-01-creating-quarto-journal-articles/) — MEDIUM confidence (practitioner report; author built the `typr` adjacent package)
- [How to Make High-Quality PDFs with Quarto and Typst — R for the Rest of Us](https://rfortherestofus.com/2025/11/quarto-typst-pdf) — MEDIUM confidence (practitioner experience, 2025)
- [Authors & Affiliations — Quarto Journal Documentation](https://quarto.org/docs/journals/authors.html) — HIGH confidence (official schema documentation)
- [Vignettes — R Packages (2e)](https://r-pkgs.org/vignettes.html) — HIGH confidence (official R package development guidance)
- [Relative paths for includes bundled with extensions (Issue #3531)](https://github.com/quarto-dev/quarto-cli/issues/3531) — MEDIUM confidence (confirmed path resolution inconsistency)

---

*Pitfalls research for: R package (typstR) bundling Quarto extensions with Typst templates for scientific publishing*
*Researched: 2026-03-21*
