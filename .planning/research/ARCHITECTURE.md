# Architecture Research

**Domain:** R package bundling Quarto extension + Typst templates (scientific publishing)
**Researched:** 2026-03-21
**Confidence:** HIGH

## Standard Architecture

### System Overview

```
┌──────────────────────────────────────────────────────────────────────┐
│                         User Project (on disk)                        │
│                                                                        │
│  paper.qmd          _quarto.yml        references.bib    logo.png     │
│  (YAML front matter  (project config)  (bibliography)   (branding)    │
│   + prose + code)                                                      │
│       │                                                                │
│       │  format: typstR-workingpaper                                   │
│       │                                                                │
│  _extensions/typstR/          ← copied here by create_working_paper() │
│  ├── _extension.yml                                                    │
│  ├── typst-show.typ                                                    │
│  ├── templates/base.typ                                                │
│  └── ...                                                               │
└──────────────────────────────────────────────────────────────────────┘
          │
          │  quarto render / render_pub()
          ▼
┌──────────────────────────────────────────────────────────────────────┐
│                          Quarto CLI (1.4+)                             │
│                                                                        │
│  1. Parse YAML front matter                                            │
│  2. Convert .qmd → Pandoc AST (markdown + code execution)             │
│  3. Locate extension via _extensions/typstR/_extension.yml            │
│  4. Apply typst-show.typ (map Pandoc metadata → Typst function args)   │
│  5. Apply typst-template.typ partials (base layout, branding, etc.)   │
│  6. Emit .typ intermediate file                                        │
└──────────────────────────────────────────────────────────────────────┘
          │
          │  (Quarto invokes bundled Typst compiler)
          ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    Typst Compiler (bundled with Quarto)                │
│                                                                        │
│  Compiles .typ → .pdf                                                  │
│  Resolves #import statements for modular .typ files                    │
│  Applies fonts, colors, layout from branding.typ                       │
└──────────────────────────────────────────────────────────────────────┘
          │
          ▼
       paper.pdf
```

### Component Responsibilities

| Component | Responsibility | Location |
|-----------|----------------|----------|
| R layer — scaffolding | `create_working_paper()` copies extension from `inst/` into user project `_extensions/` and creates starter `.qmd` | `R/create_*.R` |
| R layer — metadata helpers | Produce YAML-safe R lists that serialize into Quarto front matter | `R/metadata_helpers.R` |
| R layer — render wrappers | Thin wrappers around `quarto::quarto_render()` with pre-flight validation | `R/render.R` |
| R layer — validation | Checks Quarto/Typst availability, file presence, metadata structure | `R/validation.R` |
| Quarto extension — `_extension.yml` | Declares format names (`typstR-workingpaper`, etc.) and lists template partials | `inst/quarto/extensions/typstR/_extension.yml` |
| Quarto extension — `typst-show.typ` | Bridge: maps Pandoc/YAML metadata variables into Typst function arguments | `inst/quarto/extensions/typstR/typst-show.typ` |
| Quarto extension — format YAMLs | Per-format defaults (toc, margins, section numbering, etc.) | `inst/quarto/extensions/typstR/formats/*.yml` |
| Typst templates — `base.typ` | Root layout: page size, columns, main body show rule, imports all other partials | `inst/quarto/extensions/typstR/templates/base.typ` |
| Typst templates — `titleblock.typ` | Title, subtitle, report number, date block | `templates/titleblock.typ` |
| Typst templates — `authors.typ` | Author and affiliation rendering, corresponding author marker, ORCID | `templates/authors.typ` |
| Typst templates — `abstract.typ` | Abstract box, keywords, JEL code block | `templates/abstract.typ` |
| Typst templates — `floats.typ` | Figure and table caption styling, float note display | `templates/floats.typ` |
| Typst templates — `appendix.typ` | Appendix numbering, section reset, title rendering | `templates/appendix.typ` |
| Typst templates — `branding.typ` | Logo placement, accent colors, fonts, footer text, margins — YAML-driven | `templates/branding.typ` |
| Typst templates — `bibliography.typ` | Reference list styling | `templates/bibliography.typ` |
| Inst templates (project starters) | Starter `.qmd` + `_quarto.yml` + `references.bib` copied to user's directory | `inst/templates/workingpaper/` etc. |

## Recommended Project Structure

```
typstR/
├── DESCRIPTION
├── NAMESPACE
├── R/
│   ├── create_working_paper.R   # scaffolding: copies inst/templates + inst/extensions
│   ├── create_article.R
│   ├── create_policy_brief.R
│   ├── metadata_helpers.R       # author(), affiliation(), manuscript_meta(), etc.
│   ├── render.R                 # render_pub(), render_working_paper()
│   ├── validation.R             # check_quarto(), check_typst(), validate_manuscript()
│   ├── notes_helpers.R          # fig_note(), tab_note(), jel_codes(), keywords()
│   └── utils.R                  # internal helpers (path ops, yaml serialization)
│
├── inst/
│   ├── quarto/
│   │   └── extensions/
│   │       └── typstR/                    ← the Quarto extension bundle
│   │           ├── _extension.yml         ← declares formats + partials
│   │           ├── typst-show.typ         ← Pandoc metadata → Typst arg bridge
│   │           ├── formats/
│   │           │   ├── workingpaper.yml   ← format defaults
│   │           │   ├── article.yml
│   │           │   └── brief.yml
│   │           ├── templates/             ← modular Typst files
│   │           │   ├── base.typ           ← imports all others; root show rule
│   │           │   ├── titleblock.typ
│   │           │   ├── authors.typ
│   │           │   ├── abstract.typ
│   │           │   ├── bibliography.typ
│   │           │   ├── floats.typ
│   │           │   ├── appendix.typ
│   │           │   └── branding.typ
│   │           ├── partials/              ← Pandoc template partials if needed
│   │           └── assets/
│   │               ├── logo-placeholder.png
│   │               └── example-bibliography.bib
│   └── templates/                         ← project starter skeletons
│       ├── workingpaper/
│       │   ├── template.qmd
│       │   ├── _quarto.yml
│       │   ├── references.bib
│       │   └── logo.png
│       ├── article/
│       │   ├── template.qmd
│       │   └── _quarto.yml
│       └── policy-brief/
│           ├── template.qmd
│           └── _quarto.yml
│
├── man/                          ← roxygen2-generated docs
├── vignettes/
│   ├── getting-started.Rmd
│   ├── working-papers.Rmd
│   └── customizing-branding.Rmd
├── tests/
│   └── testthat/
│       ├── test-metadata.R
│       ├── test-validation.R
│       ├── test-render-helpers.R
│       └── test-project-creation.R
└── README.md
```

### Structure Rationale

- **`inst/quarto/extensions/typstR/`:** This is where the Quarto extension lives inside the package. The subdirectory path is conventional for R packages shipping Quarto extensions (as opposed to `inst/extdata/_extensions/` used by some older examples — both work, but the `inst/quarto/` prefix makes the purpose explicit and avoids collisions with extdata conventions).
- **`inst/templates/`:** Separate from the extension itself. These are the starter project files that `create_working_paper()` copies into the user's new directory. The extension files live separately and are also copied by the scaffolding function.
- **`templates/` inside the extension:** Modular Typst files that `base.typ` imports via Typst's `#import`. This allows each concern (titleblock, authors, branding) to be edited in isolation without touching the root template.
- **`formats/*.yml`:** Per-format YAML defaults (toc, number-sections, columns, margins) kept separate from the core extension metadata so adding a new format is additive, not a mutation.

## Architectural Patterns

### Pattern 1: Extension-Copy Scaffolding

**What:** The `create_*()` functions use `system.file()` to locate the bundled extension and `file.copy(recursive = TRUE)` to copy it into the user's project `_extensions/` directory alongside the starter `.qmd`.

**When to use:** This is the standard mechanism for shipping non-R assets (Quarto extensions, Typst files) in an R package and making them locally available in user projects. Quarto requires the extension to physically exist in `_extensions/` relative to the document.

**Trade-offs:** Users get a local copy of the extension in every project — editable for customization but not auto-updated when the package updates. This is acceptable and expected behavior; it mirrors how `rmarkdown::draft()` works.

**Example:**
```r
create_working_paper <- function(path, title = NULL, open = interactive()) {
  # 1. Create project directory
  fs::dir_create(path)

  # 2. Copy starter template files (template.qmd, _quarto.yml, etc.)
  template_dir <- system.file("templates/workingpaper", package = "typstR")
  fs::dir_copy(template_dir, path, overwrite = FALSE)

  # 3. Copy extension into _extensions/ within the new project
  ext_src <- system.file("quarto/extensions/typstR", package = "typstR")
  ext_dest <- file.path(path, "_extensions", "typstR")
  fs::dir_create(file.path(path, "_extensions"))
  fs::dir_copy(ext_src, ext_dest, overwrite = FALSE)

  # 4. Optionally set title in template.qmd, open file
  if (open) rstudioapi::openProject(path)
}
```

### Pattern 2: YAML-Driven Branding via Typst Variables

**What:** All branding options (logo path, fonts, colors, margins, footer) are declared in YAML front matter or `_quarto.yml` under the format key, passed through `typst-show.typ` as named Typst function arguments, and consumed by `branding.typ`.

**When to use:** Any option a user should configure without editing Typst directly. This keeps the design principle that users never need to open `.typ` files.

**Trade-offs:** Custom Pandoc variable passthrough has had stability issues at Quarto/Pandoc version boundaries (notably the 1.6 change where interpolated variables moved). This is a known fragility point that requires version-pinning or defensive coding in `typst-show.typ`.

**Example (YAML front matter):**
```yaml
format:
  typstR-workingpaper:
    logo: "logo.png"
typstR:
  accent-color: "#003f7f"
  title-font: "Source Serif Pro"
  footer-text: "Vienna Institute for International Economic Studies"
```

**Example (typst-show.typ maps this to Typst):**
```typst
#show: article.with(
  logo: "$logo$",
  accent-color: "$typstR.accent-color$",
  footer-text: "$typstR.footer-text$",
)
```

### Pattern 3: Modular Typst via `#import`

**What:** `base.typ` acts as the root template function. It `#import`s each sub-template file (`titleblock.typ`, `authors.typ`, etc.) and orchestrates them. Each sub-template exposes a single function (e.g., `#title-block(title, subtitle, report-number)`) that `base.typ` calls.

**When to use:** Necessary for maintainability at this scope. A single monolithic `.typ` file exceeding a few hundred lines becomes very hard to test and maintain.

**Trade-offs:** Typst's `#import` paths must be resolvable at compile time relative to the document root. When the extension lives in `_extensions/typstR/`, relative imports inside the `templates/` subdirectory work correctly (`#import "templates/titleblock.typ": title-block`). Verified pattern.

## Data Flow

### Render Flow

```
User edits paper.qmd
        │
        │  (YAML front matter: title, authors, typstR: block)
        ▼
render_pub("paper.qmd")   OR   quarto::quarto_render("paper.qmd")
        │
        │  [optional pre-flight: validate_manuscript()]
        ▼
Quarto CLI
  ├── Executes R/Python code chunks → embeds outputs
  ├── Parses YAML front matter → Pandoc metadata variables
  ├── Loads _extensions/typstR/_extension.yml → finds format typstR-workingpaper
  ├── Loads formats/workingpaper.yml → merges format defaults
  ├── Runs typst-show.typ → maps Pandoc vars to Typst show rule args
  ├── Runs templates/base.typ (via template-partials) → constructs full layout
  └── Emits paper.typ (intermediate Typst source)
        │
        ▼
Typst compiler (bundled with Quarto)
  ├── Resolves #import statements for modular template files
  ├── Applies branding.typ (logo, fonts, colors, margins)
  ├── Renders floats, bibliography, appendix sections
  └── Produces paper.pdf
```

### Key Data Flows

1. **Metadata propagation:** YAML front matter → Pandoc metadata → `typst-show.typ` template variables → Typst function arguments → rendered PDF fields. The `typstR:` YAML block carries custom fields (jel, keywords, report-number, branding). Each must be explicitly mapped in `typst-show.typ`.

2. **Scaffolding flow:** `create_working_paper(path)` → read `inst/templates/workingpaper/` via `system.file()` → copy to `path/` → read `inst/quarto/extensions/typstR/` via `system.file()` → copy to `path/_extensions/typstR/` → open project. The user's project is then self-contained and renderable.

3. **Validation flow:** `validate_manuscript(path)` → checks Quarto binary exists, Typst reachable via Quarto, required files present, `_extensions/typstR/` present, logo path valid if specified, bibliography file exists if `bibliography:` declared, metadata fields well-formed. Returns list of warnings/errors before the user attempts render.

4. **Branding override flow:** User edits YAML (not `.typ` files) → `typst-show.typ` passes values to `branding.typ` function → PDF reflects branding. If user needs deeper customization, they can edit the locally copied `.typ` files directly, but this is escape-hatch behavior.

## Build Order (Phase Implications)

The three layers have strict dependencies that dictate what must be built before what:

```
Phase 1 — Package skeleton + Typst base template
  ├── DESCRIPTION, NAMESPACE, R CMD check passing
  ├── One format: typstR-workingpaper
  ├── _extension.yml + typst-show.typ + base.typ
  └── create_working_paper() + render_pub()
        ↓ (validates that the R↔Quarto↔Typst pipeline works end to end)

Phase 2 — Metadata helpers + YAML interface
  ├── author(), affiliation(), manuscript_meta()
  ├── typstR: YAML block structure
  ├── typst-show.typ metadata passthrough wiring
  └── validate_manuscript() for metadata checks
        ↓ (requires Phase 1 render pipeline to test against)

Phase 3 — Modular Typst templates
  ├── titleblock.typ, authors.typ, abstract.typ
  ├── bibliography.typ, floats.typ, appendix.typ
  ├── branding.typ (YAML-driven)
  └── jel_codes(), keywords(), fig_note(), tab_note()
        ↓ (requires Phase 2 metadata to populate templates)

Phase 4 — Additional formats + review mode
  ├── typstR-article (anonymized/review mode)
  ├── typstR-brief
  └── format-specific format/*.yml defaults

Phase 5 — Hardening
  ├── Full test suite
  ├── Vignettes
  ├── check_typst(), check_quarto(), check_typstR()
  └── CRAN submission preparation
```

**Rationale for this order:** The render pipeline must work before metadata wiring can be tested. Modular Typst files depend on the metadata they receive, so they come after the YAML interface is stable. Additional formats are thin overlays once the base template exists.

## Anti-Patterns

### Anti-Pattern 1: Shipping Extension as Quarto Install Target Only

**What people do:** Point users to `quarto install extension typstR/typstR` from GitHub rather than bundling the extension inside the R package.

**Why it's wrong:** Breaks the R-native workflow. Users must run a shell command, extension version is decoupled from package version, and `system.file()` won't find the extension for `create_*()` functions. The R package and the Quarto extension become two separate things to keep in sync.

**Do this instead:** Bundle the extension in `inst/quarto/extensions/typstR/` and have `create_*()` copy it into each project. The extension version is always the installed package version.

### Anti-Pattern 2: Monolithic `typst-template.typ`

**What people do:** Put all layout code (title page, authors, abstract, body, floats, bibliography, appendix, branding) in one large `.typ` file.

**Why it's wrong:** A single file becomes unmanageable beyond a few hundred lines. Format variants (workingpaper vs. article) diverge and you end up with `if workingpaper { ... } else { ... }` branches everywhere. Testing individual concerns is impossible.

**Do this instead:** One `.typ` file per concern. `base.typ` imports and orchestrates. Each sub-template exposes a single well-named function. Format variants override only the partials they need to differ.

### Anti-Pattern 3: Hardcoding Branding in Typst

**What people do:** Hardcode logo path, colors, and fonts directly in `.typ` files.

**Why it's wrong:** Every institute or project using typstR has to edit Typst internals, which defeats the purpose of the package. Branding becomes a code change rather than a configuration change.

**Do this instead:** All branding values flow from YAML through `typst-show.typ` into `branding.typ` function arguments. Typst files contain no hardcoded branding constants — only variable references. Sensible defaults live in `formats/workingpaper.yml` and can be overridden per-document.

### Anti-Pattern 4: Skipping Intermediate Validation

**What people do:** Call `quarto::quarto_render()` directly and let Typst/Quarto produce opaque error messages when metadata is malformed or files are missing.

**Why it's wrong:** Typst and Quarto error messages for missing variables, bad paths, or malformed YAML are cryptic. This undermines the "easy for non-Typst users" goal.

**Do this instead:** `render_pub()` calls `validate_manuscript()` first. Validation catches common errors (missing logo, no `_extensions/typstR/`, missing bibliography) with human-readable messages before the render pipeline even starts.

### Anti-Pattern 5: Using `inst/extdata/_extensions/` Path

**What people do:** Some tutorials show `inst/extdata/_extensions/` as the path for bundled extensions.

**Why it's wrong:** It works but conflates extension files with "data" in the R package sense. `inst/quarto/extensions/typstR/` is more explicit about the purpose and avoids potential `extdata` tooling assumptions (e.g., some CRAN checks enumerate extdata for size).

**Do this instead:** Use `inst/quarto/extensions/typstR/` as the canonical path. Makes intent clear and keeps Quarto-specific assets in a named namespace.

## Integration Points

### External Services / Tools

| Tool | Integration Pattern | Notes |
|------|---------------------|-------|
| Quarto CLI | R `quarto` package wraps CLI calls; `quarto_render()` and `quarto_add_extension()` | Must be present on PATH; version checked by `check_quarto()` |
| Typst compiler | Bundled with Quarto — not a separate install for typical users | `check_typst()` verifies Quarto's bundled Typst is available; direct CLI usage is optional escape hatch |
| tinytable / gt / typstable | No direct dependency; typstR handles layout, delegates table formatting to these packages | User chooses table package; typstR's `floats.typ` handles caption and note display |
| rstudioapi | Optional: `create_*()` calls `rstudioapi::openProject()` when `interactive()` | Graceful fallback if not in RStudio |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| R layer → Quarto extension | File system: `create_*()` copies files; `render_pub()` invokes `quarto_render()` | No in-process communication; entirely file-based |
| R layer → YAML | R helpers produce named lists; serialized to YAML via `yaml::as.yaml()` or direct character output | `manuscript_meta()` and friends return R objects the user injects into front matter |
| Quarto extension → Typst templates | `template-partials:` list in `_extension.yml`; Quarto composes them | The bridge is `typst-show.typ`; template files are #imported by `base.typ` |
| Typst templates → branding | `branding.typ` function called from `base.typ` with YAML-derived arguments | No side effects; pure layout functions |
| `validate_manuscript()` → render | Validation runs first, blocks render on error, warns on non-fatal issues | `render_pub()` orchestrates this sequencing |

## Sources

- [Custom Typst Formats — Quarto official docs](https://quarto.org/docs/output-formats/typst-custom.html) — HIGH confidence
- [Including Quarto Template in R Package — Spencer Schien](https://spencerschien.info/post/r_for_nonprofits/quarto_template/) — MEDIUM confidence (practical implementation pattern)
- [Designing and Deploying Internal Quarto Templates — Meghan Hall](https://meghan.rbind.io/blog/2024-08-14-quarto-templates/) — MEDIUM confidence (2024, current pattern)
- [quarto-awesomecv-typst — Kazuya Nagimoto on GitHub](https://github.com/kazuyanagimoto/quarto-awesomecv-typst) — MEDIUM confidence (R + Quarto + Typst integration pattern in production)
- [quarto-ext/typst-templates — Quarto official templates repo](https://github.com/quarto-ext/typst-templates) — HIGH confidence
- [YAML metadata passthrough discussion — quarto-dev GitHub](https://github.com/quarto-dev/quarto-cli/discussions/11459) — MEDIUM confidence (known fragility with Pandoc variable interpolation across versions)
- [Quarto 1.6 Typst variable interpolation issue — quarto-dev/quarto-cli #10212](https://github.com/quarto-dev/quarto-cli/issues/10212) — HIGH confidence (confirmed version-specific behavior change)

---
*Architecture research for: R package + Quarto extension + Typst template (typstR scientific publishing)*
*Researched: 2026-03-21*
