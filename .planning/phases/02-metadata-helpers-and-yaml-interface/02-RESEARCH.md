# Phase 2: Metadata Helpers and YAML Interface - Research

**Researched:** 2026-03-23
**Domain:** R S3 metadata helpers + Pandoc/Typst YAML variable passthrough
**Confidence:** HIGH (R yaml mechanics verified locally; Pandoc template syntax HIGH from official docs; Quarto 1.6 typst-show change MEDIUM from GitHub issue search)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- All metadata helpers return structured R lists that serialize to valid YAML via `yaml::as.yaml()`
- Each helper returns an S3-classed object (`typstR_author`, `typstR_affiliation`, `typstR_meta`, etc.) for type checking and custom print methods
- `manuscript_meta()` returns a combined R list — pure function, no side effects, no file writing
- Simple helpers (keywords, jel_codes, funding, etc.) use light validation: `keywords` checks inputs are character, `jel_codes` validates `[A-Z][0-9]{1,2}` pattern, `funding`/`data_availability`/`code_availability` wrap text
- ID-based reference model following Quarto's native schema: `author(affiliation = "1")` links by ID, affiliations are separate objects
- `author()` supports: name, affiliation (character vector of IDs), email, orcid, corresponding (logical)
- `affiliation()` supports full fields: id, name, department, address, country (all optional except id and name)
- ORCID format validation: checks `XXXX-XXXX-XXXX-XXXX` pattern, no registry lookup
- `manuscript_meta()` cross-validates: every affiliation ID referenced by an author must have a matching `affiliation()` object; errors with clear message if dangling reference found
- `fig_note()` and `tab_note()` are R functions called in code chunks with `#| output: asis`
- Return markdown strings via `cat()` — `"*Note:* {text}"` format
- No Lua filter needed; relies on Pandoc's markdown-to-Typst pipeline
- `fig_note()` and `tab_note()` are separate functions (not unified), allowing divergent styling in Phase 3
- `appendix_title()` follows the same pattern: R function, `output: asis`, emits markdown header with appendix formatting
- `typst-show.typ` Pandoc variable interpolation syntax for nested YAML fields — Claude's Discretion
- Full modular Typst template refactor deferred to Phase 3; Phase 2 extends the existing monolithic `typst-template.typ`

### Claude's Discretion

- Exact S3 class names and print method formatting
- `typst-show.typ` Pandoc variable interpolation syntax for nested YAML fields
- How much of the Typst template to extend for Phase 2 rendering vs Phase 3 styling
- Internal helper function organization across R files
- Error message wording for validation failures
- Whether to add an `as.yaml()` S3 method or rely on `yaml::as.yaml()` with `unclass()`

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| META-01 | `author()` creates structured author metadata for YAML | Quarto normalized author schema; `yaml::as.yaml()` output verified; S3 class approach confirmed |
| META-02 | `affiliation()` creates structured affiliation metadata for YAML | Quarto affiliation schema with id/name/department/address/country; ID-based linking pattern |
| META-03 | `manuscript_meta()` combines all metadata into valid YAML block | `yaml::as.yaml()` on nested lists; cross-validation of affiliation IDs; Boolean YAML 1.1 handling |
| META-04 | `keywords()` helper for keyword metadata | Simple character vector wrapper; validates character type; serializes as YAML list |
| META-05 | `jel_codes()` helper for JEL classification codes | Regex `[A-Z][0-9]{1,2}` validated; serializes as YAML list under `typstR:` namespace |
| META-06 | `report_number()` helper for institute report numbering | Scalar string wrapper; wired through `typst-show.typ` under `typstR:` namespace |
| META-07 | `fig_note()` and `tab_note()` for figure/table notes | `output: asis` + `cat()` pattern confirmed; markdown `*Note:*` prefix; no Lua filter needed |
| META-08 | `appendix_title()` helper for appendix sections | Same `output: asis` pattern; emits markdown header |
| META-09 | `funding()` helper for funding statements | Text-wrapping scalar; wired under `typstR:` namespace |
| META-10 | `data_availability()` and `code_availability()` helpers | Text-wrapping scalars; wired under `typstR:` namespace |
| YAML-01 | `typstR:` namespace in YAML front matter for package-specific fields | Pandoc dot-notation access confirmed; `$typstR.keywords$` syntax works; namespace avoids Quarto reserved field conflicts |
| YAML-02 | `typst-show.typ` correctly wires all YAML fields to Typst template variables | Pandoc `$if()$` conditionals and `$for()$` loops; nested access via `$typstR.field$`; `none` defaults for optional fields |
| YAML-03 | Standard Quarto YAML fields (toc, fig-cap-location, etc.) work alongside `typstR:` fields | Standard fields consumed by Pandoc/Quarto before Typst; must not be placed under `typstR:` namespace |
</phase_requirements>

---

## Summary

Phase 2 has two distinct workstreams that must be co-developed: (1) R S3 metadata helper functions that produce correctly-structured YAML-serializable R lists, and (2) wiring the `typstR:` YAML namespace through `typst-show.typ` into the monolithic `typst-template.typ`.

The R side is mechanically straightforward. Verified locally: `yaml::as.yaml()` on plain R lists correctly produces Quarto-compatible YAML for authors, affiliations, and the `typstR:` block. The S3 class pattern (`structure(list(...), class = c("typstR_author", "list"))`) works cleanly — `unclass()` before `yaml::as.yaml()` is not necessary because the yaml package already traverses the list structure, but using it is safer for nested S3 objects. A critical serialization subtlety: `yaml::as.yaml()` renders `TRUE` as `yes` (YAML 1.1 boolean), which Quarto's YAML parser accepts correctly — no special handler is needed.

The Typst/YAML side carries the most risk. The `typstR:` namespace approach is sound: Pandoc's template engine accesses nested YAML fields via dot notation (`$typstR.keywords$`, `$for(typstR.jel)$`). A **critical behavior change at Quarto 1.6** (issue #10212) moved one Pandoc interpolated variable from `typst-template.typ` into `typst-show.typ` — this is a cosmetic architectural change affecting the default template, not a change to how custom namespace fields (`typstR:`) pass through. However, the research flag from STATE.md must be validated with an actual render test before the plan is locked, because indirect confirmation only.

**Primary recommendation:** Build all R metadata helpers first (they are independently testable with `testthat`), then tackle `typst-show.typ` wiring as a second wave with integration render tests. Never test YAML wiring without a full render.

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| yaml | 2.3.10 (CRAN current) | R list → YAML string serialization | Only CRAN-stable YAML package for R; already in `Imports` from Phase 1 |
| cli | >= 3.6.0 | Validation error messages | Established in Phase 1; consistent error style |
| rlang | >= 1.1.0 | `abort()` for structured errors | Established in Phase 1 |
| testthat | >= 3.0.0 | Unit tests for all helpers | Already in `Suggests`; edition 3 configuration present |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| withr | any | Temporary directory fixtures in tests | Already in `Suggests`; use for render integration tests |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `yaml::as.yaml()` | Manual string building | yaml package handles YAML 1.1 escaping, quoting, and indentation correctly; string building is error-prone for nested structures |
| S3 list objects | R6 classes | S3 on plain lists is zero-dependency, trivially serialized with yaml package, and idiomatic R; R6 adds complexity with no benefit here |
| `plume` R package | Custom helpers | plume exists (CRAN) and handles author/affiliation YAML for Quarto; typstR needs tighter integration with `typstR:` namespace fields and custom validation — wrapping plume would create an unnecessary dependency |

**Installation:** No new packages needed for Phase 2. All dependencies (`yaml`, `cli`, `rlang`, `testthat`, `withr`) are already in DESCRIPTION.

---

## Architecture Patterns

### Recommended R File Layout

```
R/
├── metadata_helpers.R    # author(), affiliation(), manuscript_meta()
├── notes_helpers.R       # fig_note(), tab_note(), appendix_title()
├── pub_helpers.R         # keywords(), jel_codes(), funding(), data_availability(),
│                         #   code_availability(), report_number()
└── utils.R               # existing; may add yaml_as_yaml_block() internal helper
```

### Recommended Typst File Changes

```
inst/quarto/extensions/typstR/
├── typst-show.typ          # EXTEND: add typstR: namespace field wiring
└── typst-template.typ      # EXTEND: add new parameters to working-paper function
                            #   (keywords, jel, acknowledgements, report-number,
                            #    funding, data-availability, code-availability)
```

### Pattern 1: S3 Metadata Helper (author / affiliation)

**What:** Constructor functions return S3-classed lists. Validation runs at construction time. YAML serialization is via `yaml::as.yaml()` without special methods.

**When to use:** All structured metadata helpers where type checking or print formatting matters.

```r
# Source: verified locally 2026-03-23 with yaml 2.3.10
author <- function(name, affiliation = NULL, email = NULL,
                   orcid = NULL, corresponding = FALSE) {
  if (!is.null(orcid)) {
    if (!grepl("^[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9X]$", orcid)) {
      cli::cli_abort(c(
        "Invalid ORCID format: {.val {orcid}}",
        "i" = "Expected format: XXXX-XXXX-XXXX-XXXX"
      ))
    }
  }
  structure(
    list(
      name        = name,
      affiliation = affiliation,
      email       = email,
      orcid       = orcid,
      corresponding = corresponding
    ),
    class = c("typstR_author", "list")
  )
}

print.typstR_author <- function(x, ...) {
  cli::cli_text("<typstR_author> {x$name}")
  invisible(x)
}
```

**YAML output (verified):**
```yaml
name: Jane Doe
affiliation: '1'
email: jane@example.org
orcid: 0000-0001-2345-6789
corresponding: yes
```

### Pattern 2: manuscript_meta() Composition and Cross-Validation

**What:** Takes authors (list of `typstR_author`), affiliations (list of `typstR_affiliation`), and other metadata; cross-validates affiliation IDs; returns a structured list that serializes to full Quarto YAML front matter.

**Cross-validation logic (verified approach):**

```r
# Source: design verified 2026-03-23
manuscript_meta <- function(authors, affiliations = list(),
                            keywords = NULL, jel = NULL,
                            acknowledgements = NULL,
                            report_number = NULL,
                            funding = NULL,
                            data_availability = NULL,
                            code_availability = NULL) {
  # Cross-validate affiliation IDs
  ref_ids   <- unique(unlist(lapply(authors, `[[`, "affiliation")))
  defn_ids  <- vapply(affiliations, `[[`, character(1), "id")
  dangling  <- setdiff(ref_ids, defn_ids)
  if (length(dangling) > 0) {
    cli::cli_abort(c(
      "Author references undefined affiliation IDs: {.val {dangling}}",
      "i" = "Every affiliation ID used in author() must have a matching affiliation() object."
    ))
  }

  typstR_block <- Filter(Negate(is.null), list(
    keywords          = if (!is.null(keywords)) unclass(keywords) else NULL,
    jel               = if (!is.null(jel)) unclass(jel) else NULL,
    acknowledgements  = acknowledgements,
    `report-number`   = if (!is.null(report_number)) unclass(report_number) else NULL,
    funding           = if (!is.null(funding)) unclass(funding) else NULL,
    `data-availability`  = if (!is.null(data_availability)) unclass(data_availability) else NULL,
    `code-availability`  = if (!is.null(code_availability)) unclass(code_availability) else NULL
  ))

  result <- list(
    author       = lapply(authors, unclass),
    affiliations = lapply(affiliations, unclass)
  )
  if (length(typstR_block) > 0) result[["typstR"]] <- typstR_block

  structure(result, class = c("typstR_meta", "list"))
}
```

### Pattern 3: Scalar Text Wrappers (funding, data_availability, etc.)

**What:** Thin wrappers that attach an S3 class to a text string for type safety and print methods.

```r
# Source: design 2026-03-23
funding <- function(text) {
  if (!is.character(text) || length(text) != 1L) {
    cli::cli_abort("{.arg text} must be a single character string.")
  }
  structure(text, class = c("typstR_funding", "character"))
}
```

### Pattern 4: fig_note / tab_note (output: asis)

**What:** Called in code chunks with `#| output: asis`. Emits markdown text directly into the document stream. Pandoc converts `*Note:*` markdown italics to Typst naturally.

```r
# Source: verified locally 2026-03-23 — output: asis + cat() pattern
fig_note <- function(...) {
  text <- paste(..., sep = "")
  cat("*Note:* ", text, "\n", sep = "")
}
```

**Usage in .qmd:**
````markdown
```{r}
#| output: asis
fig_note("Source: World Bank (2023).")
```
````

### Pattern 5: typst-show.typ Pandoc Variable Wiring

**What:** Extends `typst-show.typ` with explicit `$if()$`/`$for()$` blocks for every `typstR:` namespace field. Pandoc's template engine accesses nested YAML with dot notation.

**Confirmed Pandoc template syntax (from Pandoc documentation):**
- `$variable$` — scalar substitution
- `$if(variable)$` / `$endif$` — conditional
- `$for(variable)$` / `$endfor$` — loop over array; `$it$` refers to current item
- `$variable.subfield$` — nested access via dot notation
- `$if(typstR)$` tests whether the `typstR:` block exists at all

**Current typst-show.typ (Phase 1 baseline):**
```typst
#import "typst-template.typ": working-paper

#show: working-paper.with(
  $if(title)$
  title: "$title$",
  $endif$
  $if(author)$
  authors: (
    $for(author)$
    (name: "$it.name.literal$"),
    $endfor$
  ),
  $endif$
  $if(abstract)$
  abstract: [$abstract$],
  $endif$
)
```

**Phase 2 extended typst-show.typ pattern:**
```typst
#import "typst-template.typ": working-paper

#show: working-paper.with(
  $if(title)$
  title: "$title$",
  $endif$
  $if(author)$
  authors: (
    $for(author)$
    (
      name: "$it.name.literal$",
      $if(it.email)$email: "$it.email$",$endif$
      $if(it.orcid)$orcid: "$it.orcid$",$endif$
      $if(it.corresponding)$corresponding: true,$endif$
    ),
    $endfor$
  ),
  $endif$
  $if(affiliations)$
  affiliations: (
    $for(affiliations)$
    (
      id: "$it.id$",
      name: "$it.name$",
      $if(it.department)$department: "$it.department$",$endif$
    ),
    $endfor$
  ),
  $endif$
  $if(abstract)$
  abstract: [$abstract$],
  $endif$
  $if(typstR)$
  $if(typstR.keywords)$
  keywords: ($for(typstR.keywords)"$it$",$endfor$),
  $endif$
  $if(typstR.jel)$
  jel: ($for(typstR.jel)"$it$",$endfor$),
  $endif$
  $if(typstR.acknowledgements)$
  acknowledgements: [$typstR.acknowledgements$],
  $endif$
  $if(typstR.report-number)$
  report-number: "$typstR.report-number$",
  $endif$
  $if(typstR.funding)$
  funding: [$typstR.funding$],
  $endif$
  $if(typstR.data-availability)$
  data-availability: [$typstR.data-availability$],
  $endif$
  $if(typstR.code-availability)$
  code-availability: [$typstR.code-availability$],
  $endif$
  $endif$
)
```

**CONFIDENCE NOTE:** The nested `$typstR.keywords$` dot-notation is Pandoc's documented template syntax (Pandoc MANUAL §Templates). It should work for custom namespace YAML blocks. However, the exact dot-notation behavior for nested YAML blocks in `typst-show.typ` has NOT been tested in this project. The Quarto 1.6 issue #10212 changed WHERE one variable lives (cosmetic), not whether the `typstR:` block passes through. **First implementation task must include a smoke-test render with all fields populated before writing the full template extension.**

### Pattern 6: Extended typst-template.typ Function Signature

Phase 2 extends the `working-paper` function in the monolithic template to accept new parameters:

```typst
#let working-paper(
  title: none,
  authors: (),
  affiliations: (),   // NEW
  abstract: none,
  keywords: (),       // NEW
  jel: (),            // NEW
  acknowledgements: none,  // NEW
  report-number: none,     // NEW
  funding: none,           // NEW
  data-availability: none, // NEW
  code-availability: none, // NEW
  body,
) = { ... }
```

All new parameters default to `none` or `()` so existing documents that omit them continue to render without change.

### Anti-Patterns to Avoid

- **Placing standard Quarto fields under `typstR:`:** Fields like `toc`, `number-sections`, and `fig-cap-location` are consumed by Quarto/Pandoc before reaching Typst. They must stay at the document or format level — never under `typstR:`.
- **Testing helpers without end-to-end render:** YAML serialization from R can look correct but still fail at the Pandoc template interpolation stage. Unit tests for R helpers are necessary but not sufficient; integration render tests are required.
- **`yaml::as.yaml()` on S3 objects without `unclass()`:** The yaml package can trip on custom attributes. Safer to `unclass()` before serialization or strip the S3 class during `manuscript_meta()` assembly.
- **Hardcoding field rendering in `typst-template.typ` without `none` defaults:** Any new parameter must default to `none` (scalar) or `()` (array); otherwise existing Phase 1 renders break.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| YAML serialization | Custom string builder | `yaml::as.yaml()` | Handles escaping, quoting, indentation, YAML 1.1 booleans; proven on all test cases |
| ORCID regex | Custom parser | `grepl("^[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9X]$", orcid)` | Single regex covers all valid ORCIDs including trailing X checksum character |
| JEL code validation | Database lookup | `grepl("^[A-Z][0-9]{1,2}$", codes)` | Pattern-only validation is sufficient; full JEL list changes; pattern catches common typos |
| Author YAML schema | Custom schema | Quarto's native `author`/`affiliations` keys with `id` reference model | Quarto already normalizes these for Typst output; fighting the schema creates bugs |
| fig_note Typst formatting | Custom Lua filter or raw Typst | `cat("*Note:* ", text)` in `output: asis` chunk | Pandoc handles markdown-to-Typst conversion; no filter needed for plain italic text |
| Error messages | `stop()` / `warning()` | `cli::cli_abort()` / `cli::cli_warn()` | Already established pattern in Phase 1; consistent formatting |

**Key insight:** The metadata helper layer is purely data transformation (R lists → YAML strings). Every "clever" solution here creates maintenance burden and edge-case bugs. The boring path — plain R lists, `yaml::as.yaml()`, Quarto's native schema — is the right path.

---

## Common Pitfalls

### Pitfall 1: Quarto Normalized Author Schema — Unrecognized Keys Rerouted
**What goes wrong:** Any key placed directly in an `author:` entry that Quarto does not recognize is moved under an `author.metadata` sub-key. If `typst-show.typ` reads `author.email` but email was placed at the wrong nesting level, the PDF silently omits it.

**Why it happens:** Quarto's author normalization is a closed schema. Developers assume flat keys work; the normalization step is invisible.

**How to avoid:** Use only Quarto's documented `author` schema keys: `name`, `orcid`, `email`, `corresponding`, `equal-contributor`, `affiliations` (list with `id`, `name`, `department`, `city`, `country`). Any additional typstR-specific author metadata (e.g., footnotes) should go in the `typstR:` block, not in `author:`.

**Warning signs:** Author block renders for one author but email or ORCID is missing from PDF; adding a second author breaks layout.

### Pitfall 2: Standard Quarto Fields Do Not Pass Through to Typst
**What goes wrong:** Fields like `toc: true`, `number-sections: true`, and `fig-cap-location: bottom` are consumed by Pandoc/Quarto and never appear as template variables in `typst-show.typ`. Attempting to read them back in `typst-show.typ` produces nothing (no error, silent failure).

**Why it happens:** These fields set Quarto/Pandoc writer options, not Pandoc metadata variables. The distinction is invisible in YAML.

**How to avoid:** Standard Quarto fields go at the document level or under `format: typstR-workingpaper:`. Only package-specific fields go under `typstR:`. This is already the design decision in CONTEXT.md.

**Warning signs:** A `toc: true` in the `typstR:` block has no effect; a `toc: true` at the document level works correctly.

### Pitfall 3: Boolean YAML Serialization ("yes" vs "true")
**What goes wrong:** `yaml::as.yaml(list(corresponding = TRUE))` produces `corresponding: yes`, not `corresponding: true`. Some users manually editing the YAML might be surprised.

**Why it's not actually a problem:** YAML 1.1 (which Quarto uses) treats `yes`, `true`, `on` as boolean true equivalents. Verified locally: `yaml::yaml.load("corresponding: yes")` returns `TRUE`. No special handler needed.

**Note:** This is a non-pitfall worth documenting because it looks alarming but is fine.

### Pitfall 4: Pandoc Interprets String Metadata as Markdown
**What goes wrong:** Any YAML string value (including `acknowledgements:`, `funding:`) is interpreted by Pandoc as Markdown and parsed. Special characters like `_`, `*`, `&` may be transformed.

**Why it happens:** Pandoc applies its Markdown parser to all metadata strings before template substitution.

**How to avoid:** In `typst-show.typ`, use `[$typstR.acknowledgements$]` (Typst content block) rather than `"$typstR.acknowledgements$"` (Typst string). Typst content blocks accept arbitrary markup; Typst strings require escaping. Always use content blocks `[...]` for free-text metadata fields.

**Warning signs:** Acknowledgements text with italics or special characters renders strangely or errors in Typst.

### Pitfall 5: Quarto 1.6 Issue #10212 — Pandoc Variable in typst-template.typ
**What goes wrong:** At Quarto 1.6, one Pandoc interpolated variable was introduced into `typst-template.typ` (the default Quarto template, not a custom one). This is an architectural cosmetic change — the variable should have been in `typst-show.typ` for LSP compatibility.

**Impact for typstR:** This change is in Quarto's DEFAULT template, not custom extension templates. The typstR `typst-show.typ` and `typst-template.typ` are entirely custom. The `$typstR.field$` dot-notation access for a custom namespace YAML block is governed by Pandoc's template engine, which has not changed its nested access semantics.

**How to avoid:** Validate with an actual render test on the minimum supported Quarto version (>= 1.4.11, package requires `quarto >= 1.4`). Do not assume the dot-notation works — verify it in the first implementation wave.

**Warning signs:** Fields present in YAML don't appear in rendered PDF; no error is thrown.

### Pitfall 6: typstR: Block Fields with Hyphenated Names
**What goes wrong:** `report-number` contains a hyphen. In Pandoc templates, `$typstR.report-number$` may or may not parse correctly — hyphens in variable names can be ambiguous in some template engines.

**Why it matters:** Pandoc's template engine documentation is clear that variable names follow identifier rules. A hyphenated key might be treated as `typstR.report` minus `number`.

**How to avoid:** Test `$typstR.report-number$` explicitly. If Pandoc rejects hyphenated keys, the fallback is to map to an underscore key (`$typstR.report_number$`) in `typst-show.typ` while keeping user-facing YAML key as `report-number` (via Lua filter that renames keys pre-template). Alternatively, accept `reportnumber` as the internal key name. This must be validated before the plan is locked.

**Warning signs:** `report-number` field renders as empty in PDF despite being present in YAML.

---

## Code Examples

Verified patterns from official sources and local testing:

### Author YAML Serialization (verified locally)
```r
# Source: verified locally 2026-03-23 with yaml 2.3.10
library(yaml)
authors <- list(
  list(name = "Jane Doe", affiliation = "1",
       email = "jane@example.org", orcid = "0000-0001-2345-6789",
       corresponding = TRUE),
  list(name = "John Smith", affiliation = c("1", "2"))
)
affiliations <- list(
  list(id = "1", name = "Vienna Institute for International Economic Studies"),
  list(id = "2", name = "University of Somewhere")
)
cat(as.yaml(list(author = authors, affiliations = affiliations)))
# Output:
# author:
# - name: Jane Doe
#   affiliation: '1'
#   email: jane@example.org
#   orcid: 0000-0001-2345-6789
#   corresponding: yes
# - name: John Smith
#   affiliation:
#   - '1'
#   - '2'
# affiliations:
# - id: '1'
#   name: Vienna Institute for International Economic Studies
# - id: '2'
#   name: University of Somewhere
```

### typstR: Namespace Block Serialization (verified locally)
```r
# Source: verified locally 2026-03-23
library(yaml)
typstR_block <- list(
  keywords = c("trade", "industrial policy", "CEE"),
  jel = c("F10", "F13", "L52"),
  acknowledgements = "We thank the reviewers.",
  "report-number" = "WP 001",
  funding = "European Research Council"
)
cat(as.yaml(list(typstR = typstR_block)))
# Output:
# typstR:
#   keywords:
#   - trade
#   - industrial policy
#   - CEE
#   jel:
#   - F10
#   - F13
#   - L52
#   acknowledgements: We thank the reviewers.
#   report-number: WP 001
#   funding: European Research Council
```

### JEL Code Validation (verified locally)
```r
# Source: verified locally 2026-03-23
jel_codes <- function(...) {
  codes <- c(...)
  if (!is.character(codes)) cli::cli_abort("{.arg ...} must be character strings.")
  invalid <- codes[!grepl("^[A-Z][0-9]{1,2}$", codes)]
  if (length(invalid) > 0) {
    cli::cli_abort(c(
      "Invalid JEL codes: {.val {invalid}}",
      "i" = "Expected format: one uppercase letter followed by 1-2 digits (e.g., F10, L52)."
    ))
  }
  structure(as.list(codes), class = c("typstR_jel", "list"))
}
```

### fig_note in output:asis Chunk (verified locally)
```r
# Source: verified locally 2026-03-23 — cat() output matches expected markdown
fig_note <- function(...) {
  text <- paste(..., sep = "")
  cat("*Note:* ", text, "\n", sep = "")
}
# In .qmd:
# ```{r}
# #| output: asis
# fig_note("Source: World Bank (2023). Values are in constant 2015 USD.")
# ```
# Renders as italic "Note:" prefix followed by plain text.
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Flat top-level custom YAML keys (collide with Pandoc) | Custom namespace `typstR:` block | Design decision — from day 1 | Prevents silent field override by Pandoc metadata handling |
| Inline author strings `author: "Jane Doe"` | Structured `author:` list with schema fields | Quarto 1.4+ | Enables ORCID, corresponding author, multi-affiliation |
| Custom author schema keys → Pandoc `author.metadata` | Only Quarto-recognized `author` keys | Quarto 1.x always | Unrecognized keys silently rerouted |
| `typst-template.typ` containing Pandoc interpolated variables | Variables moved to `typst-show.typ` | Quarto 1.6 (issue #10212) | Only cosmetic for built-in template; no impact on custom extensions |

**Deprecated/outdated:**
- Flat `keywords:` at the document root: conflicts with potential Pandoc/Quarto field, should always be under `typstR:`
- Raw Lua filters for fig/table notes: unnecessary when `output: asis` + `cat()` produces correct markdown

---

## Open Questions

1. **Hyphenated keys in Pandoc template dot-notation (`$typstR.report-number$`)**
   - What we know: Pandoc variable names follow identifier rules; hyphens are common in YAML keys but ambiguous in template variable paths
   - What's unclear: Whether `$typstR.report-number$` parses as one key or triggers a subtraction operation in the template engine
   - Recommendation: First implementation wave must test `report-number` passthrough explicitly. Fallback: use `report_number` as the internal Pandoc key and map in `typst-show.typ`

2. **Quarto 1.6 nested YAML block passthrough — exact confirmed behavior**
   - What we know: Issue #10212 describes a cosmetic variable placement change in the DEFAULT template; the `typstR:` namespace dot-notation access is Pandoc standard template syntax
   - What's unclear: Whether any Quarto 1.6 change accidentally broke custom namespace passthrough in custom extensions (not the default template)
   - Recommendation: Validate with a minimal render test against the installed Quarto version before building the full `typst-show.typ` extension

3. **`author.name.literal` vs `author.name` in typst-show.typ**
   - What we know: Phase 1's `typst-show.typ` uses `$it.name.literal$` for author name — Quarto normalizes `author.name` to `author.name.literal` as part of its author schema normalization
   - What's unclear: Whether this normalization happens for authors coming from `manuscript_meta()` output (where the R object produces `name: "Jane Doe"` directly, not `name: {literal: "Jane Doe"}`)
   - Recommendation: Test both paths — direct YAML and `manuscript_meta()` output — to verify correct name rendering. May need `$if(it.name.literal)$$it.name.literal$$else$$it.name$$endif$` defensive fallback

---

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | testthat 3.0.0 (edition 3) |
| Config file | `tests/testthat.R` (exists) |
| Quick run command | `devtools::test(filter = "metadata")` |
| Full suite command | `devtools::test()` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| META-01 | `author()` creates correct S3 list with right fields | unit | `devtools::test(filter = "metadata")` | ❌ Wave 0 |
| META-01 | `author()` validates ORCID format, errors on invalid | unit | `devtools::test(filter = "metadata")` | ❌ Wave 0 |
| META-01 | `author()` serializes to correct YAML via `yaml::as.yaml()` | unit | `devtools::test(filter = "metadata")` | ❌ Wave 0 |
| META-02 | `affiliation()` creates correct S3 list | unit | `devtools::test(filter = "metadata")` | ❌ Wave 0 |
| META-03 | `manuscript_meta()` cross-validates affiliation IDs, errors on dangling | unit | `devtools::test(filter = "metadata")` | ❌ Wave 0 |
| META-03 | `manuscript_meta()` combined output serializes to valid Quarto YAML | unit | `devtools::test(filter = "metadata")` | ❌ Wave 0 |
| META-04 | `keywords()` validates character input | unit | `devtools::test(filter = "pub_helpers")` | ❌ Wave 0 |
| META-05 | `jel_codes()` validates `[A-Z][0-9]{1,2}` pattern, errors on invalid | unit | `devtools::test(filter = "pub_helpers")` | ❌ Wave 0 |
| META-06 | `report_number()` wraps text, returns `typstR_report_number` class | unit | `devtools::test(filter = "pub_helpers")` | ❌ Wave 0 |
| META-07 | `fig_note()` emits `*Note:* text\n` via `cat()` | unit | `devtools::test(filter = "notes_helpers")` | ❌ Wave 0 |
| META-08 | `appendix_title()` emits markdown header string | unit | `devtools::test(filter = "notes_helpers")` | ❌ Wave 0 |
| META-09 | `funding()` wraps text | unit | `devtools::test(filter = "pub_helpers")` | ❌ Wave 0 |
| META-10 | `data_availability()` and `code_availability()` wrap text | unit | `devtools::test(filter = "pub_helpers")` | ❌ Wave 0 |
| YAML-01 | `typstR:` block with keywords/jel/acknowledgements survives Pandoc and appears in rendered PDF | integration (skip_if not quarto) | `devtools::test(filter = "integration")` | ❌ Wave 0 |
| YAML-02 | All `typstR:` namespace fields wired through `typst-show.typ` appear in PDF | integration (skip_if not quarto) | `devtools::test(filter = "integration")` | ❌ Wave 0 |
| YAML-03 | Standard Quarto fields (`toc`, `number-sections`) work alongside `typstR:` fields | integration (skip_if not quarto) | `devtools::test(filter = "integration")` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `devtools::test(filter = "metadata|pub_helpers|notes_helpers")`
- **Per wave merge:** `devtools::test()` (full suite, includes integration tests with `skip_if_not(quarto::quarto_available())`)
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `tests/testthat/test-metadata-helpers.R` — covers META-01 through META-03
- [ ] `tests/testthat/test-pub-helpers.R` — covers META-04 through META-10
- [ ] `tests/testthat/test-notes-helpers.R` — covers META-07, META-08
- [ ] `tests/testthat/test-yaml-integration.R` — covers YAML-01 through YAML-03 (guarded with `skip_if_not(quarto::quarto_available())`)

No framework install needed — testthat is already in `Suggests` with edition 3 configured.

---

## Sources

### Primary (HIGH confidence)
- Local R verification (2026-03-23) — `yaml::as.yaml()` serialization tests for all metadata patterns
- [Pandoc User's Guide — Templates](https://pandoc.org/MANUAL.html) — Pandoc template syntax: `$variable$`, `$if()$`, `$for()$`, dot notation for nested fields
- [Authors & Affiliations — Quarto Documentation](https://quarto.org/docs/journals/authors.html) — Quarto normalized author schema; id-based affiliation reference model
- Existing Phase 1 code (`typst-show.typ`, `typst-template.typ`) — established patterns in the project

### Secondary (MEDIUM confidence)
- [Typst: 1.6 introduces Pandoc interpolated variable to typst-template.typ — Issue #10212](https://github.com/quarto-dev/quarto-cli/issues/10212) — Confirmed change is cosmetic placement in default template; does not affect custom namespace passthrough
- [YAML arguments not being passed to Typst template partials — Discussion #11459](https://github.com/quarto-dev/quarto-cli/discussions/11459) — Confirms standard Quarto fields (toc etc.) do not pass through to Typst; custom fields under custom namespace do
- [plume R package — CRAN](https://cran.r-project.org/web/packages/plume/plume.pdf) — Existing author/affiliation YAML helper pattern; confirmed typstR should not depend on it but is compatible
- [Custom Typst Formats — Quarto Documentation](https://quarto.org/docs/output-formats/typst-custom.html) — typst-show.typ / typst-template.typ split; template-partials mechanism
- [yaml package — CRAN](https://cran.r-project.org/package=yaml) — Methods to Convert R Data to YAML and Back

### Tertiary (LOW confidence — needs validation with render test)
- Pandoc dot-notation for hyphenated nested keys (`$typstR.report-number$`) — inferred from Pandoc template docs, not tested in Quarto context; must be validated

---

## Metadata

**Confidence breakdown:**
- R metadata helper design: HIGH — locally verified yaml serialization; S3 pattern established in prior R package work
- Pandoc template syntax for `typstR:` namespace: MEDIUM — documented Pandoc feature; not yet tested in this project's exact Quarto version
- Quarto 1.6 impact on custom extension templates: MEDIUM — issue #10212 is cosmetic for default template; custom extension impact inferred not tested
- Hyphenated key in Pandoc template dot-notation: LOW — must be validated in Wave 0 render test

**Research date:** 2026-03-23
**Valid until:** 2026-04-23 (stable domain) — Pandoc template syntax is stable; Quarto release cadence is ~monthly but breaking changes to template variable syntax are rare
