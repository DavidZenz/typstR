# Phase 3: Typst Templates, Branding, and Additional Formats - Research

**Researched:** 2026-03-23
**Domain:** Typst modular template architecture + Quarto multi-format extension + YAML-driven branding hooks
**Confidence:** HIGH (Quarto extension mechanics verified; Typst syntax verified from official docs; pitfalls cross-referenced from official GitHub discussions)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- Build all 9 branding hooks from BRANDIN_HOOKS.md: logo, primary-font, title-font, margins, title-page-style, accent-color, report-number-block, footer, disclaimer-page
- Each hook has a clean academic default that works out of the box; users override via `typstR:` YAML namespace per document
- Branding is per-document (YAML front matter), not per-format — supports multi-institution co-authored papers
- All three formats share the same branding hooks — format differences are structural (which sections appear), not branding
- Infrastructure priority: build flexible hooks now, visual design refined later
- Article format: same layout as working paper, no report-number block, no disclaimer page by default; adds `typstR: anonymized: true` mode that strips authors, affiliations, ORCID, email, corresponding markers, and acknowledgements
- Policy-brief format: "Summary" label instead of "Abstract", no JEL codes, no appendix lettered numbering, no ORCID display
- Disclaimer page available for all three formats; configurable position (`typstR: disclaimer-position: "first"` or `"last"`, default `"last"`); customizable text via `typstR: disclaimer-text:`; enabled with `typstR: disclaimer-page: true`
- Modular template architecture: shared base modules + thin format overlays: base.typ, titleblock.typ, authors.typ, abstract.typ, bibliography.typ, appendix.typ, branding.typ, disclaimer.typ
- Three thin format files: workingpaper.typ, article.typ, brief.typ
- create_article() and create_policy_brief() produce same file structure as create_working_paper(); only template.qmd YAML front matter differs; same cli-styled success summary pattern
- Phase 2 styling fixes: fix author email backslash escaping; implement academic-style affiliation superscripts (Author¹², numbered affiliations below)

### Claude's Discretion

- Exact default values for each branding hook (font choices, margin sizes, accent color)
- Typst `#import` patterns for modular file structure
- How the _extension.yml registers multiple formats (or if one format key handles all via configuration)
- Internal Typst function signatures for module interfaces
- Exact disclaimer page styling (font size, spacing, centering)
- How anonymized mode is wired through typst-show.typ (conditional variable passing)
- Default disclaimer text content

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| TMPL-01 | Base Typst template with page layout, fonts, margins, page numbering | Typst `set page()` and `set text()` patterns verified; branding hook wiring via function parameters |
| TMPL-02 | Title page with title, subtitle, date | Standard Typst `align(center)` + `text(size:, weight:)` pattern; subtitle and date as optional parameters |
| TMPL-03 | Author and affiliation block with corresponding author marker | Affiliation superscript pattern verified from Typst forum + quarto-lapreprint; `super()` for numbered superscripts |
| TMPL-04 | Abstract block with keywords and JEL codes | `pad(x:)` block + conditional JEL rendering; label differs by format (brief uses "Summary") |
| TMPL-05 | Acknowledgements section | Post-body conditional block already in monolithic template; modularized in Phase 3 |
| TMPL-06 | Bibliography rendering via Typst | Typst native citation engine; `bibliographystyle:` for style; Quarto `bibliography:` YAML key passes file path |
| TMPL-07 | Appendix handling with separate lettered numbering | `set heading(numbering: "A.1")` + `counter(heading).update(0)` pattern verified from Typst forum |
| TMPL-08 | Figure and table caption styling with notes support | fig_note/tab_note from Phase 2 emit markdown strings; caption styling via Typst `show figure:` rule |
| TMPL-09 | Modular .typ file structure | `#import "templates/module.typ": function-name` pattern; STRUCTURE.md specifies target layout |
| TMPL-10 | Branding via YAML: logo path, primary font, title font, accent color | Logo path: underscore escaping pitfall — requires `logo_path.replace("\\", "")` workaround; `mainfont` YAML option OR custom `typstR.primary-font` parameter; color via `rgb("#HEXHEX")` |
| TMPL-11 | Branding via YAML: page margins, footer text, report number block | Margins via `set page(margin: (x:, y:))` with parameter passthrough; footer via `set page(footer:)` with content parameter |
| TMPL-12 | Branding via YAML: disclaimer page support | `pagebreak()` + conditional rendering; position controlled by `disclaimer-position` flag |
| TMPL-13 | Three format definitions in _extension.yml | Single `_extension.yml` can contribute multiple named format keys; confirmed via apaquarto pattern (apaquarto-typst, apaquarto-pdf, etc.); each key gets own template-partials list |
| SCAF-02 | create_article() generates project with article template and extension | Direct reuse of create_working_paper() pattern; copy from inst/templates/article/ |
| SCAF-03 | create_policy_brief() generates project with policy brief template and extension | Direct reuse of create_working_paper() pattern; copy from inst/templates/policy-brief/ |
</phase_requirements>

---

## Summary

Phase 3 has three largely independent workstreams that converge at integration: (1) refactor the monolithic `typst-template.typ` into modular `.typ` files with a shared `branding.typ` hook system, (2) extend `_extension.yml` to register three named format variants and wire the new branding/anonymized/disclaimer YAML fields through `typst-show.typ`, and (3) add `create_article()` and `create_policy_brief()` R functions with matching `inst/templates/` subdirectories.

The most technically nuanced area is the branding hook system. Research confirms two distinct mechanisms are available: (a) using Quarto's built-in `mainfont` YAML key to pass fonts directly, or (b) using the `typstR:` namespace to pass all branding fields through `typst-show.typ` as Typst function parameters. The `typstR:` namespace approach is cleaner because it keeps all package-specific fields in one namespace. However, a confirmed pitfall exists: Pandoc processes YAML metadata as Markdown, causing underscores in file paths (e.g., `my_logo.png`) to be escaped as `\_` before reaching Typst. This requires an explicit `.replace("\\", "")` unescaping step in `branding.typ`. The `mainfont` YAML key is processed at the Quarto level (not through the Pandoc template), so it bypasses this issue — but only for the main body font.

The multi-format extension architecture is confirmed: a single `_extension.yml` can contribute multiple named format keys under `contributes: formats:`. Real-world precedent exists in the apaquarto extension which ships `apaquarto-typst`, `apaquarto-pdf`, `apaquarto-docx`, and `apaquarto-html` from one extension. The Quarto 1.8 constraint (format key must be `typst` in `_extension.yml`) means the three format names will be `typstR-typst-workingpaper`, `typstR-typst-article`, and `typstR-typst-brief` — but research from Phase 2 already established that the current extension uses `typst` as the key, making the user-facing format `typstR-typst`. The multi-format approach requires each variant to have its own template-partials list or share them with variant-specific configuration flags.

**Primary recommendation:** Build the modular Typst file structure first (base.typ + modules), then wire branding hooks, then add format variants. This sequencing allows the working paper format to be smoke-tested at each step before new format variants are added.

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| fs | >= 1.6.0 | File operations in create_article(), create_policy_brief() | Already in Imports; established pattern from create_working_paper() |
| cli | >= 3.6.0 | Success summary output in scaffolding functions | Established in Phases 1–2; consistent error/success style |
| rlang | >= 1.1.0 | Structured errors in scaffolding guards | Established; used in create_working_paper() |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| testthat | >= 3.0.0 | Tests for create_article(), create_policy_brief() | Already in Suggests; use for scaffolding file-existence tests |
| withr | any | Temporary directories in scaffolding tests | Already in Suggests; withr::local_tempdir() for create_* tests |

No new R package dependencies are required for Phase 3. All required packages are already in DESCRIPTION.

### Typst Modules (No External Packages)
Typst `@preview` packages MUST NOT be used (network dependency, bundling complexity, CRAN norms). All Typst logic must be hand-implemented using built-in Typst functions.

**Version constraint:** All `.typ` files must be compatible with the Typst version bundled in Quarto >= 1.4.11. Syntax from Typst 0.11+ features should be verified against this floor before use.

---

## Architecture Patterns

### Recommended Project Structure (Phase 3 Target)

```
inst/quarto/extensions/typstR/
├── _extension.yml                  # Three format keys under contributes: formats:
├── typst-show.typ                  # Shared Pandoc variable bridge (extended for branding)
├── templates/
│   ├── base.typ                    # Page setup, typography defaults, branding hook application
│   ├── titleblock.typ              # Title, subtitle, date rendering
│   ├── authors.typ                 # Author block, affiliation superscripts, ORCID, email
│   ├── abstract.typ                # Abstract/Summary block, keywords, JEL
│   ├── bibliography.typ            # Bibliography section rendering
│   ├── appendix.typ                # Lettered appendix numbering reset
│   ├── branding.typ                # Branding hook functions; logo, fonts, colors, margins
│   └── disclaimer.typ              # Disclaimer page with position control
├── formats/
│   ├── workingpaper.typ            # Thin overlay: enables all sections
│   ├── article.typ                 # Thin overlay: disables report-number, adds anonymized mode
│   └── brief.typ                   # Thin overlay: "Summary" label, no JEL, no lettered appendix
└── [typst-template.typ removed or kept as compatibility shim]

inst/templates/
├── workingpaper/                   # Existing — template.qmd, _quarto.yml, references.bib
├── article/                        # NEW — template.qmd with article YAML defaults
└── policy-brief/                   # NEW — template.qmd with brief YAML defaults
```

### Pattern 1: Multi-Format _extension.yml

**What:** A single `_extension.yml` contributes multiple named format keys, each pointing to the same shared template-partials but with format-identifying configuration.

**When to use:** When three output variants share the same Typst runtime but differ in section enablement flags.

```yaml
# Source: Quarto custom formats documentation + apaquarto real-world pattern
title: typstR
author: typstR authors
version: "0.1.0"
quarto-required: ">=1.4.11"
contributes:
  formats:
    typst:
      template-partials:
        - typst-show.typ
        - templates/workingpaper.typ
      typstR-format: workingpaper
    typst-article:
      base-format: typstR/typst
      template-partials:
        - typst-show.typ
        - templates/article.typ
    typst-brief:
      base-format: typstR/typst
      template-partials:
        - typst-show.typ
        - templates/brief.typ
```

**IMPORTANT CAVEAT (LOW confidence, requires smoke test):** The exact multi-format registration syntax for Typst-specific variants in a single extension is not exhaustively documented in official Quarto docs for the Typst case. The `base-format` key works for HTML/PDF multi-format extensions. Whether it applies cleanly to Typst variants needs verification with a minimal test extension. An alternative is a single `typst` format key with a `typstR-format: "workingpaper"` configuration flag passed through to control section rendering — this is simpler and avoids the multi-key uncertainty.

**Recommended fallback:** Use a single `typst` format key (yielding `typstR-typst` user-facing format) and control working-paper vs. article vs. brief behavior via a `typstR: format-variant: "workingpaper"` YAML field. Three `create_*()` functions set appropriate defaults in their template.qmd files.

### Pattern 2: Typst Modular Import

**What:** Format overlay files import shared modules and compose the document layout.

**When to use:** In workingpaper.typ, article.typ, brief.typ — each imports from templates/ and calls the shared functions.

```typst
// Source: Typst official documentation (typst.app/docs/tutorial/making-a-template/)
#import "base.typ": apply-base-styles
#import "titleblock.typ": render-title-block
#import "authors.typ": render-author-block
#import "abstract.typ": render-abstract
#import "branding.typ": apply-branding

#let workingpaper(
  title: none,
  authors: (),
  affiliations: (),
  abstract: none,
  // ... all parameters
  body,
) = {
  apply-base-styles(
    primary-font: primary-font,
    margins: margins,
    accent-color: accent-color,
  )
  render-title-block(title: title, subtitle: subtitle, date: date, report-number: report-number)
  render-author-block(authors: authors, affiliations: affiliations, anonymized: anonymized)
  // ...
  body
}
```

### Pattern 3: Affiliation Superscripts

**What:** Build a mapping of affiliation IDs to sequential integers, render authors with superscript numbers, then list numbered affiliations below.

**When to use:** Author block rendering in authors.typ.

**Source:** quarto-lapreprint (mps9506/quarto-lapreprint) and Typst forum discussion

```typst
// Affiliation superscript pattern
// Source: verified from Typst forum + quarto-lapreprint pattern (mps9506/quarto-lapreprint)
#let render-author-block(authors: (), affiliations: (), anonymized: false) = {
  if anonymized { return }

  // Build id-to-index mapping
  let aff-index = (:)
  for (i, aff) in affiliations.enumerate() {
    aff-index.insert(aff.at("id", default: str(i)), i + 1)
  }

  align(center)[
    #authors.map(a => {
      let name = a.at("name", default: "")
      let aff-ids = a.at("affiliations", default: ())
      // Collect superscript indices
      let sups = aff-ids.map(id => str(aff-index.at(id, default: "?")))
      if sups.len() > 0 {
        [#name#super(sups.join(","))]
      } else {
        [#name]
      }
    }).join([, ])
  ]

  // Affiliation list with numbers
  v(0.3em)
  align(center)[
    #affiliations.enumerate().map(((i, aff)) => {
      [#super(str(i + 1))#aff.at("name", default: "")]
    }).join([; ])
  ]
}
```

### Pattern 4: Email Unescaping (Markdown-in-metadata Pitfall Fix)

**What:** Pandoc processes YAML metadata as Markdown, converting `@` to `\@` in email addresses and `_` to `\_` in file paths. These must be unescaped in Typst.

**Source:** Confirmed in GitHub Discussion #11364 (Quarto), Discussion #8983 (Quarto)

```typst
// In typst-show.typ, capture raw string and unescape
#let logo-raw = "$typstR.logo$"
#let logo-path = logo-raw.replace("\\", "")

// For email addresses in authors.typ:
// email comes through typst-show.typ as escaped string
// Fix by replacing "\@" with "@" in the display
let email-display = a.at("email", default: "").replace("\\@", "@")
```

### Pattern 5: Branding Hook Function

**What:** `branding.typ` exposes an `apply-branding()` function that sets page and text properties from parameters. Format overlays call it once at the top of their layout function.

**Source:** Typst official docs (`set page()`, `set text()`)

```typst
// In branding.typ
#let apply-branding(
  primary-font: "Linux Libertine",
  title-font: none,
  margins: (x: 1in, y: 1in),
  accent-color: none,
) = {
  set page(margin: margins)
  set text(font: primary-font)
  // accent-color stored for heading show rules
}
```

### Pattern 6: Appendix Lettered Numbering Reset

**What:** At the appendix section boundary, reset the heading counter and switch to lettered numbering.

**Source:** Typst forum discussion "How to change numbering in Appendix?" — verified pattern

```typst
// In appendix.typ
#let start-appendix() = {
  set heading(numbering: "A.1", supplement: [Appendix])
  counter(heading).update(0)
}
```

**Important:** This must be called via a Quarto div class or a special marker in the .qmd so Quarto knows where the appendix boundary is. `appendix_title()` R helper from Phase 2 can emit the raw Typst call wrapped in a raw block.

### Pattern 7: Disclaimer Page

**What:** A separate page with disclaimer text, inserted either before or after the body based on the `disclaimer-position` flag.

```typst
// In disclaimer.typ
#let render-disclaimer(
  text: "The views expressed are those of the authors and do not necessarily reflect those of their institutions.",
  position: "last",
  enabled: false,
) = {
  if not enabled { return }
  // Rendered at the call site in the format overlay
  pagebreak()
  align(center + horizon)[
    #text(size: 10pt, style: "italic")[#text]
  ]
}
```

Disclaimer position "first" means: call `render-disclaimer()` before `body`. Position "last" means: call it after `body`.

### Anti-Patterns to Avoid

- **Duplicating shared logic across format overlays:** If both article.typ and workingpaper.typ both contain the author block rendering code, they will inevitably diverge. All shared logic lives in the shared module files; format overlays only configure what to show/hide.
- **Using Typst `@preview` packages:** Network dependency, fails offline, cannot be bundled cleanly.
- **Hardcoding fonts in base.typ:** Use parameters with sensible defaults. Every font reference must be overrideable via the branding hook.
- **Putting branding defaults in `typst-show.typ`:** The bridge file should only pass values through. Defaults belong in the Typst function signatures.
- **Using `set page()` inside a format overlay function body after content has started:** `set` rules in Typst apply to everything that follows in the current scope. All page-level `set` rules must come before any rendered content.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Affiliation ID-to-index mapping | Custom string parsing of affiliation YAML | Typst dictionary `.at()` + `.enumerate()` on the passed-in `affiliations` array | The by-author normalization in Quarto already links `it.affiliations` to the deduplicated top-level list; map over it directly |
| Superscript rendering | Custom unicode superscript characters | Typst `super()` function | `super()` is semantic, works with font metrics, and is built-in |
| Lettered appendix numbering | Counter tracking in R or Lua | Typst `set heading(numbering: "A.1")` + `counter(heading).update(0)` | Built-in Typst counter system handles ToC entries, cross-references, and supplements correctly |
| Multi-format scaffolding logic | New create_* function bodies | Direct copy-paste of create_working_paper() pattern, swapping template directory | The pattern is already proven; no abstraction needed for three similar functions |
| Logo image insertion | Custom image-path resolver | Typst `image(logo-path)` after unescaping path | Typst's built-in image() handles paths relative to the document root |
| Bibliography | Custom reference formatter | Typst native bibliography engine via Quarto `bibliography:` YAML field | Already wired in Phase 1/2; Quarto passes .bib file path to Typst automatically |

---

## Common Pitfalls

### Pitfall 1: Pandoc Escapes Underscores and @ in YAML Metadata Passed to Typst

**What goes wrong:** Any YAML string value containing `_` (e.g., `logo: "my_logo.png"`) or `@` (e.g., email addresses) gets processed as Markdown by Pandoc, converting `_` to `\_` and `@` to `\@`. These escaped strings reach Typst, causing `image("my\_logo.png")` to fail (file not found) or `my\@example.org` to appear as-is in the PDF.

**Why it happens:** Pandoc's template engine processes all metadata values as Markdown before substituting them into `.typ` templates. This is documented in GitHub Discussion #11364 and #8983.

**How to avoid:**
- In `branding.typ`, after receiving the `logo` parameter, call `.replace("\\", "")` before passing to `image()`.
- In `authors.typ`, after receiving email, call `.replace("\\@", "@")`.
- Test with file names containing underscores — this is the only way to catch it before users report it.

**Warning signs:** Logo does not render; file-not-found Typst compile error; email addresses show backslash in PDF.

---

### Pitfall 2: Typst `set` Rules Have Lexical Scope — They Must Precede Content

**What goes wrong:** When a modular function calls `set page(margin: ...)`, that `set` rule only applies to content within the function's lexical scope. If the function applies styling but then returns content that is assembled at the call site, the `set` rule may not affect the final document.

**Why it happens:** Typst's `set` rules are scoped to their containing block. The correct pattern is to wrap all content in a single layout function that applies all `set` rules at the top, with the body as the last argument.

**How to avoid:** Use the `#show: layout-function.with(...)` pattern (already established in Phase 1). The entry-point function in each format overlay receives `body` as its last argument, applies all `set`/`show` rules, then renders `body`. Never apply `set page()` or `set text()` in module functions that are called mid-document.

**Warning signs:** Margin or font changes only affect part of the document; page setup reverts unexpectedly.

---

### Pitfall 3: Multiple typstR-show.typ Format Variants Must Each Wire All New Fields

**What goes wrong:** If Phase 3 introduces new YAML fields (`typstR: logo:`, `typstR: accent-color:`, `typstR: anonymized:`) but only the working-paper variant's `typst-show.typ` is updated, article and brief renders silently omit those fields.

**Why it happens:** Each format variant has its own `typst-show.typ` (or a shared one). If sharing a single `typst-show.typ`, all formats get all fields — which is the preferred approach. If each format has its own bridge file, every new field must be added to all of them.

**How to avoid:** Use a single shared `typst-show.typ` that passes all supported fields. The format-specific Typst function ignores fields it does not use. This is architecturally cleaner.

**Warning signs:** `typstR: logo:` works for working paper but not article. Branding changes seem to affect some formats but not others.

---

### Pitfall 4: Quarto's `by-author` Affiliation IDs May Not Match Top-Level Affiliation IDs After Normalization

**What goes wrong:** When Quarto normalizes author metadata via its Lua filter, `by-author[i].affiliations` contains affiliation objects, not just IDs. The `id` field within those objects may differ from what the user typed in the YAML if Quarto remaps them.

**Why it happens:** Quarto 1.6+ deduplicates affiliations and may reassign IDs. The top-level `affiliations` list should be used as the canonical source; `by-author[i].affiliations` should be used to look up which affiliations an author has.

**How to avoid:** In `typst-show.typ`, pass the full `affiliations` array to Typst (already done in Phase 2). In `authors.typ`, build the ID-to-index map from the `affiliations` array and use `by-author[i].affiliations[j].id` for the lookup. Test with: 2 authors, 3 affiliations, one author has 2 affiliations.

**Warning signs:** Author superscript numbers are wrong or duplicate; "?" appears as affiliation superscript.

---

### Pitfall 5: format-resources Must Be Listed for Assets Bundled with the Extension

**What goes wrong:** The logo placeholder image, or any asset file shipped inside the extension, may not be accessible at render time if it is not listed under `format-resources:` in `_extension.yml`.

**Why it happens:** Quarto copies only files explicitly listed in `format-resources:` (or all files, depending on the extension type). Assets not listed may not be present in the render working directory.

**How to avoid:** List `assets/logo-placeholder.png` and any other bundled assets under `format-resources:` in `_extension.yml`. Alternatively, ship assets only in `inst/templates/` (the user project), not inside the extension itself.

**Warning signs:** Logo placeholder renders locally but fails after `quarto add`; assets missing in user projects.

---

### Pitfall 6: Typst `@preview` Package Imports Break Offline and Bundled Workflows

**What goes wrong:** Any `.typ` file that uses `#import "@preview/some-package:0.1.0": ...` requires network access to the Typst package registry. This fails in CI, CRAN check environments, and any offline use.

**Why it happens:** The `@preview` namespace resolves to the Typst Universe registry. Quarto does not automatically bundle `@preview` dependencies.

**How to avoid:** Never import `@preview` packages in any `.typ` file shipped with typstR. All functionality must use Typst built-in functions only.

---

## Code Examples

Verified patterns from official sources and community references:

### Appendix Lettered Numbering Reset
```typst
// Source: Typst forum "How to change numbering in Appendix?" (forum.typst.app)
// Verified pattern — works in Typst bundled with Quarto >= 1.4.11
#let start-appendix() = {
  set heading(numbering: "A.1", supplement: [Appendix])
  counter(heading).update(0)
}
```

### Accent Color Applied to Headings
```typst
// Source: Typst official docs — show-set rules (typst.app/docs/reference/styling/)
// accent-color must be a Typst color value, e.g. rgb("#0A5DA6")
#let apply-heading-color(accent-color) = {
  if accent-color != none {
    show heading: set text(fill: accent-color)
  }
}
```

### Disclaimer Page
```typst
// Pattern derived from Typst page/pagebreak docs
#let render-disclaimer(text: none, enabled: false) = {
  if not enabled or text == none { return }
  pagebreak()
  set page(numbering: none)
  align(center + horizon)[
    #block(width: 80%)[
      #set text(size: 10pt, style: "italic")
      #text
    ]
  ]
}
```

### typst-show.typ Extension for Branding Fields
```typst
// Pattern: extend existing typst-show.typ with branding fields
// Source: Established Phase 2 pattern + confirmed Pandoc dot-notation
#show: workingpaper.with(
  // ... existing fields from Phase 2 ...
  $if(typstR)$
  $if(typstR.logo)$
  logo: "$typstR.logo$",
  $endif$
  $if(typstR.primary-font)$
  primary-font: "$typstR.primary-font$",
  $endif$
  $if(typstR.title-font)$
  title-font: "$typstR.title-font$",
  $endif$
  $if(typstR.accent-color)$
  accent-color: rgb("$typstR.accent-color$"),
  $endif$
  $if(typstR.footer)$
  footer: "$typstR.footer$",
  $endif$
  $if(typstR.disclaimer-page)$
  disclaimer-page: true,
  $endif$
  $if(typstR.disclaimer-position)$
  disclaimer-position: "$typstR.disclaimer-position$",
  $endif$
  $if(typstR.disclaimer-text)$
  disclaimer-text: [$typstR.disclaimer-text$],
  $endif$
  $if(typstR.anonymized)$
  anonymized: true,
  $endif$
  $endif$
)
```

**Note on `accent-color`:** The user supplies a hex string like `"#0A5DA6"`. In `typst-show.typ` it is interpolated inside `rgb("...")`. The `rgb()` Typst function accepts a hex string directly. The Pandoc `$typstR.accent-color$` interpolation will not escape hex strings since they contain no Markdown-special characters.

### create_article() Scaffolding
```r
# Source: Direct adaptation of create_working_paper() (R/create_working_paper.R)
create_article <- function(path, title = NULL, open = interactive()) {
  if (fs::dir_exists(path)) {
    cli::cli_abort(c(
      "Directory {.path {path}} already exists.",
      "i" = "Choose a different path or remove the existing directory."
    ))
  }
  fs::dir_create(path)
  template_src <- system.file("templates/article", package = "typstR", mustWork = TRUE)
  template_files <- fs::dir_ls(template_src, all = TRUE, recurse = FALSE)
  fs::file_copy(template_files, fs::path(path, fs::path_file(template_files)))
  ext_src <- system.file("quarto/extensions/typstR", package = "typstR", mustWork = TRUE)
  ext_dest <- fs::path(path, "_extensions", "typstR")
  fs::dir_create(fs::path(path, "_extensions"))
  fs::dir_copy(ext_src, ext_dest)
  if (!is.null(title)) {
    qmd_path <- fs::path(path, "template.qmd")
    lines <- readLines(qmd_path)
    lines <- sub('title: "Article Title"', paste0('title: "', title, '"'), lines, fixed = TRUE)
    writeLines(lines, qmd_path)
  }
  cli::cli_alert_success("Created article project at {.path {path}}")
  cli::cli_bullets(c(
    "*" = "{.file template.qmd}",
    "*" = "{.file _quarto.yml}",
    "*" = "{.file references.bib}",
    "*" = "{.file _extensions/typstR/}"
  ))
  invisible(path)
}
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Monolithic `typst-template.typ` (Phase 1) | Modular templates/\*.typ with shared branding.typ | Phase 3 | Enables independent branding hook overrides; reduces duplication |
| Single working-paper format key in `_extension.yml` | Three format keys or single key with format-variant flag | Phase 3 | Users can specify `typstR-typst-article` or `typstR-typst` with format variant |
| Author names displayed inline, no superscripts | Author¹² superscripts with numbered affiliation list | Phase 3 | Academic standard layout; fixes human-review complaint from Phase 2 |
| Email with backslash escape rendered in PDF | Email unescaped via `.replace("\\@", "@")` in Typst | Phase 3 | Correct email display |

**Established from earlier phases (do not regress):**
- `$for(by-author)$` / `it.name.literal` / `it.attributes.corresponding` — Quarto 1.6+ author normalization (Phase 2)
- `.at('field', default: '')` for safe Typst dictionary access (Phase 2)
- `$sep$` for list separators in Pandoc `$for()$` loops (Phase 2)
- Outer `$if(typstR)$` guard wrapping all namespace conditionals (Phase 2)
- Content blocks `[...]` for free-text fields (Phase 2)

---

## Open Questions

1. **Multi-format `_extension.yml` syntax for Typst variants**
   - What we know: Single extension CAN contribute multiple named format keys (confirmed via apaquarto); `base-format:` works for HTML/PDF variants
   - What's unclear: Whether `base-format: typstR/typst` syntax works for Typst-specific sub-variants in Quarto 1.4.11+; this is not explicitly documented for the Typst case
   - Recommendation: Prototype with a minimal two-format test extension before committing. If `base-format:` does not work, fall back to a single `typst` format key with a `typstR: format-variant:` YAML flag — this is simpler and just as capable.

2. **`typstR.margins` YAML structure**
   - What we know: Typst `set page(margin:)` accepts a dictionary `(x: 1in, y: 1in)` or scalar
   - What's unclear: How to pass a YAML nested object `typstR: margins: {x: "1in", y: "1in"}` through `typst-show.typ` into a Typst dictionary literal — Pandoc dot-notation accesses `typstR.margins.x` and `typstR.margins.y` separately
   - Recommendation: Pass `typstR.margins` as a flat string (e.g., `"1in"` for uniform margins) with separate `typstR: margin-x:` and `typstR: margin-y:` keys. Or use a single scalar `typstR: margin: "1in"` for simplicity in v0.1.

3. **`typst-show.typ` format variant detection**
   - What we know: If a single `typst` format key is used, there is no built-in way to distinguish working paper from article format in `typst-show.typ`
   - What's unclear: Whether Quarto exposes the format name as a template variable
   - Recommendation: Pass `typstR: format-variant: "workingpaper"` in the scaffolded template.qmd files. This makes the variant explicit and user-visible. The `create_article()` function scaffolds a template.qmd with `format-variant: "article"` already set.

---

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | testthat >= 3.0.0 |
| Config file | `tests/testthat.R` (Config/testthat/edition: 3 in DESCRIPTION) |
| Quick run command | `devtools::test(filter = "scaffolding")` |
| Full suite command | `devtools::test()` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| TMPL-09 | Modular .typ files importable without error | smoke (quarto render) | `quarto render tests/fixtures/minimal-workingpaper.qmd` | ❌ Wave 0 |
| TMPL-10 | Logo path branding reaches Typst without error | smoke (quarto render) | `quarto render tests/fixtures/test-branding.qmd` | ❌ Wave 0 |
| TMPL-11 | Footer / margins branding parameters wire through | smoke | same fixture | ❌ Wave 0 |
| TMPL-12 | Disclaimer page renders when enabled | smoke | `quarto render tests/fixtures/test-disclaimer.qmd` | ❌ Wave 0 |
| TMPL-13 | Three format definitions registered without Quarto error | smoke | `quarto render` with each format key | ❌ Wave 0 |
| SCAF-02 | create_article() creates correct files | unit | `devtools::test(filter = "project-creation")` | ✅ (test-project-creation.R needs article cases added) |
| SCAF-03 | create_policy_brief() creates correct files | unit | `devtools::test(filter = "project-creation")` | ✅ (test-project-creation.R needs brief cases added) |
| TMPL-03 | Affiliation superscripts render correctly | smoke | render multi-author fixture | ❌ Wave 0 |
| TMPL-07 | Appendix lettered numbering resets at appendix boundary | smoke | render fixture with appendix | ❌ Wave 0 |

**Note:** Quarto render smoke tests require `quarto::quarto_available()` guard for CRAN safety. They belong in `tests/testthat/test-render-smoke.R` wrapped with `skip_if_not(quarto::quarto_available())`.

### Sampling Rate
- **Per task commit:** `devtools::test(filter = "project-creation")` for SCAF tasks; manual Quarto render for TMPL tasks
- **Per wave merge:** `devtools::test()` (full R test suite)
- **Phase gate:** Full suite green + smoke renders pass before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `tests/testthat/test-render-smoke.R` — covers TMPL-09, TMPL-10, TMPL-11, TMPL-12, TMPL-13, TMPL-03, TMPL-07
- [ ] `tests/fixtures/minimal-workingpaper.qmd` — minimal render fixture for smoke tests
- [ ] `tests/fixtures/test-branding.qmd` — fixture with all 9 branding hooks set
- [ ] `tests/fixtures/test-disclaimer.qmd` — fixture with disclaimer-page: true
- [ ] `tests/fixtures/test-multiauthor.qmd` — 3 authors, 2 affiliations fixture for superscript test

---

## Sources

### Primary (HIGH confidence)
- Typst official docs: `typst.app/docs/reference/model/heading/` — appendix numbering patterns
- Typst official docs: `typst.app/docs/reference/styling/` — `set`/`show` rule scoping
- Typst official docs: `typst.app/docs/reference/visualize/color/` — `rgb()` function
- Typst official docs: `typst.app/docs/tutorial/making-a-template/` — modular `#import` pattern
- Quarto GitHub Discussion #11364 — underscore escaping in YAML metadata passed to Typst
- Quarto GitHub Discussion #8983 — general metadata escaping by Pandoc
- Quarto GitHub Discussion #12019 — affiliation superscript in Quarto+Typst
- mps9506/quarto-lapreprint — affiliation superscript implementation reference (GitHub)

### Secondary (MEDIUM confidence)
- Quarto official docs: `quarto.org/docs/extensions/formats.html` — multi-format `_extension.yml` structure
- Quarto official docs: `quarto.org/docs/output-formats/typst-custom.html` — template-partials mechanism
- apaquarto (wjschne/apaquarto) — confirmed working example of a single extension contributing apaquarto-typst, apaquarto-pdf, apaquarto-docx, apaquarto-html from one _extension.yml
- Typst forum: "How to change numbering in Appendix?" — lettered appendix reset pattern

### Tertiary (LOW confidence)
- Exact multi-format Typst variant registration syntax with `base-format:` — no official Typst-specific documentation found; extrapolated from HTML/PDF patterns
- `typstR.margins` as nested YAML passthrough — behavior with Pandoc dot-notation for nested dicts not verified with actual render test

## Metadata

**Confidence breakdown:**
- Standard stack (R): HIGH — no new dependencies; all packages already in DESCRIPTION
- Modular .typ architecture: HIGH — standard Typst import pattern; verified from official docs
- Branding hook wiring: HIGH — Pandoc dot-notation confirmed; underscore escaping pitfall confirmed
- Affiliation superscripts: MEDIUM-HIGH — pattern confirmed from quarto-lapreprint; Quarto ID normalization edge case needs smoke test
- Multi-format _extension.yml: MEDIUM — general pattern confirmed; Typst-specific variant syntax needs smoke test verification
- Appendix numbering: HIGH — Typst forum pattern verified; works in Typst bundled with Quarto >= 1.4.11

**Research date:** 2026-03-23
**Valid until:** 2026-04-23 (30 days; Quarto and Typst are stable in this domain)
