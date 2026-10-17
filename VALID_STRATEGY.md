# Manuscript validation contract (package 0.1.0)

`validate_manuscript(path, output_format = NULL, check_environment = FALSE)` and
render preflight use `validate_manuscript_context()`. Rendering enables environment
checks. `validate_render_environment()` retains its environment-only API.

## Inputs and metadata

Explicit `.qmd` paths resolve independently of the caller's working directory.
Directory/NULL input selects exactly one immediate `.qmd`; missing and ambiguous
inputs retain DIAG-INPUT-001/002/003. The nearest `_quarto.yml`/`.yaml` establishes
the project boundary. Extensions are discovered between manuscript and that root.

Project, ancestor directory `_metadata.yml`/`.yaml`, then front matter are merged.
Mappings merge recursively; sequences merge; document format names select outputs
while matching format options inherit. Resource paths in each YAML source resolve
relative to that source directory (project settings relative to project root).
Resource validation does not use the caller's working directory.

## Required and optional fields

All three variants require a non-empty text title and `format: typstR-typst` (or
the equivalent mapping). `typstR.format-variant` defaults to `workingpaper` and
also accepts `article` or `brief`. Article/brief are variants of the same bundled
format, not separate Quarto format names.

Authors, affiliations, abstract, keywords, JEL codes, report number, statements
and branding remain optional for every variant, including anonymized articles.
When present, author names, IDs, emails, ORCIDs, booleans, lists, colors and margin
lengths are checked for supported shapes. Affiliation IDs must be unique;
references to a declared ID table must resolve.

Configured bibliography, CSL, logo and header/body include files must exist and
be files. Citations need a bibliography or inline references. Bibliography contents
and citation-key resolution are delegated to Quarto/citeproc; successful creation
alone does not prove meaningful PDF content. Required render assurance checks PDF
text, warnings and representative layout separately.

## Diagnostics and limitations

Existing codes retain their assignments. DIAG-MANUSCRIPT-001 covers YAML syntax
or mapping errors; 002 format/variant; 003 metadata shape; 004 missing resources;
005 unsupported configuration. Diagnostics retain severity/location/hint and are
sorted using the shared deterministic ordering contract.

This preflight supports static local YAML. Profiles (including QUARTO_PROFILE),
`.local` project overrides, `metadata-files`, executable `!expr` YAML and remote
resources are rejected explicitly. Generated resources must exist before calling
the helper. It does not parse code-generated citations, arbitrary filters,
shortcodes, publisher styles, font availability or the full Quarto schema. Inline
include `{text: ...}` is supported. Use Quarto directly with manual verification
for unsupported configurations. Do not interpret a static pass as visual approval.

Reference semantics: [Quarto project metadata](https://quarto.org/docs/projects/quarto-projects.html).
