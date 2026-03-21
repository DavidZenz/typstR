# Feature Research

**Domain:** R scientific publishing package (Quarto + Typst PDF)
**Researched:** 2026-03-21
**Confidence:** HIGH (ecosystem well-documented; competitors directly inspected)

---

## Feature Landscape

### Table Stakes (Users Expect These)

Features users assume exist. Missing these = product feels incomplete.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Multiple author support with affiliations | Every scientific paper has multiple authors mapped to institutions; this is a formatting primitive, not a differentiator | MEDIUM | Quarto's standard author/affiliations YAML schema works; need to render correctly in Typst titleblock. apaquarto, reproducr, and quarto-preprint all implement this. |
| Abstract | Universal in papers; expected in the YAML block | LOW | Standard Quarto metadata field; maps to Typst template block. |
| Bibliography / citations | Reproducible scientific writing requires citable references | LOW | Quarto handles via `bibliography:` YAML + Typst native citation or pandoc citeproc. Already solved infrastructure. |
| Cross-references for figures and tables | Researchers number and refer to figures/tables; manual numbering is unacceptable | LOW | Quarto provides `@fig-` and `@tbl-` syntax natively for Typst. Not in scope to reimplement. |
| Table of contents | Expected on multi-section working papers and reports | LOW | Quarto `toc: true` passes through to Typst natively. |
| Keywords | Standard front-matter field for academic papers and working papers alike | LOW | Typst template renders a keywords block from YAML; typstR-specific metadata extension. |
| Section numbering | Convention for academic documents; readers cite section numbers | LOW | Quarto `number-sections: true` works for Typst. |
| Appendix | Economics and social science papers routinely have appendices | MEDIUM | Quarto has appendix support; rendering as a named section in Typst with correct numbering needs template work. |
| Figure and table captions | Standard for all scientific figures and tables | LOW | Quarto standard figure/table syntax handles this. |
| ORCID identifier per author | Increasingly required by journals; expected in modern templates | LOW | Standard Quarto YAML author field; rendered as icon or text in title block. |
| Corresponding author designation | Standard for multi-author papers | LOW | Quarto YAML `corresponding: true` per author; needs Typst titleblock rendering. |
| Acknowledgements section | Funding, thanks to reviewers — expected | LOW | Typst template block; driven by YAML field. |

---

### Differentiators (Competitive Advantage)

Features that set the product apart. Not required, but valued.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Project scaffolding (`create_working_paper()`) | Users go from zero to polished PDF in one function call — the "one-minute setup" that competitors don't provide; rticles requires manual file setup | MEDIUM | Must generate .qmd, _quarto.yml, example bib, assets, and open in editor. This is the primary adoption hook. |
| JEL classification codes | Domain-specific to economics; no existing R/Quarto/Typst template handles this as a first-class metadata field | LOW | Simple rendered block after keywords; high signal value to target audience (economists, policy analysts). |
| Report number block | Standard for institute working paper series; not present in quarto-preprint, rticles, or apaquarto | LOW | Single rendered line on title page driven by `report-number:` YAML; trivial to implement, high user value. |
| Institutional branding via YAML (no Typst editing) | Institutes need branded PDFs; current solutions require editing raw Typst — typstR makes this declarative | HIGH | Cover: logo path, accent color, fonts, margins, footer text, disclaimer page. Quarto's `_brand.yml` partially overlaps; typstR should be compatible but extend it. Key differentiator from raw Quarto templates. |
| Anonymized / review mode | Journal submission requires blinding; apaquarto has this for APA, but no Typst-native solution exists for general scientific use | MEDIUM | YAML flag strips authors, affiliations, ORCID, acknowledgements, funding from rendered output. reproducr and apaquarto both implement blinding, confirming strong user demand. |
| Funding declaration block | Required by many funders (NIH, EU, ERC); increasingly expected | LOW | YAML field `funding:` drives a rendered declaration section. Data/code availability statements are adjacent. |
| Data and code availability statements | Required by many journals and replication policies | LOW | `data_availability:` and `code_availability:` YAML fields map to a rendered section. Differentiator because no existing Typst template makes these first-class. |
| `validate_manuscript()` diagnostics | Users hit cryptic Typst/Quarto errors at render time; pre-render validation catches common issues early | MEDIUM | Checks: Quarto installed, Typst available, required files present, logo path valid, bib exists if cited, metadata well-formed. quarto-preprint and rticles have no equivalent. |
| Three named publication formats | workingpaper, article, policy-brief cover the full target user range without forcing users to adapt a generic template | HIGH | Each format has distinct title page layout, metadata fields, and optional feature set. The three formats share 80% of the Typst template layer — marginal cost is low once the base layer is built. |
| Render wrapper (`render_pub()`, `render_working_paper()`) | Lowers the cognitive overhead for users unfamiliar with Quarto CLI; provides a clean R-native entry point | LOW | Thin wrapper over `quarto::quarto_render()` with format-aware defaults. |
| Fig/table note helpers (`fig_note()`, `tab_note()`) | Economics convention is to put source/note lines under figures and tables; no standard Quarto/Typst mechanism exists | LOW | Small helper functions that emit correctly formatted Typst markup for sub-caption note lines. Researchers use these constantly. |
| Modular Typst template layer | Makes customization and maintenance tractable; users who know Typst can swap individual modules | HIGH | Separate .typ files for titleblock, authors, abstract, bibliography, floats, appendix, branding. Design constraint, not user-facing feature — but critical for longevity. |

---

### Anti-Features (Commonly Requested, Often Problematic)

Features that seem good but create problems.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Journal submission compatibility for 40+ publishers | rticles has 40+ templates; users ask for "just add Nature/PLOS/Elsevier" | Each publisher has idiosyncratic layout requirements; maintaining them is a full-time job that dilutes the core product; rticles itself struggles with template staleness | Explicitly out of scope for v0.1. If demand exists after launch, add one high-value journal template (e.g., arXiv preprint style) as v0.2 work. |
| LaTeX `.cls` / `.sty` import | Users have institutional LaTeX templates and want automatic conversion | Fundamentally different typesetting system; conversion is lossy; no reliable automated path exists | Typst templates are the replacement, not a conversion target. Document this decision clearly. |
| HTML and Word output | "Can it output to Word for co-authors?" is common | Typst output pipeline is the entire value proposition; Word requires a completely different template and workflow; splitting effort dilutes quality | Quarto's default HTML/Word output works for those formats; typstR is explicitly PDF-first. |
| Built-in table engine | Users want `gt`-style tables in Typst output | typstable, gt with Typst support, and tinytable already exist; reinventing this is wasted effort and creates conflicts | Delegate entirely to typstable/gt/tinytable. typstR handles layout conventions (captions, notes, positioning) only. |
| Real-time preview / live render | Nice developer experience feature | Requires a file watcher, browser integration, or RStudio pane — far outside the R package scope and adds binary dependencies | Quarto's built-in preview (`quarto preview`) handles this. typstR should document this workflow. |
| Universal LaTeX-to-Typst conversion | "I have 50 .tex files I want to migrate" | Structurally hard; pandoc conversion of Typst is incomplete; math macros, custom environments, and bibliography styles all break | Not in scope. Point users to pandoc's experimental Typst writer. |
| Automatic DOI resolution / CrossRef API | "Fill in the metadata from the DOI" | Adds a network dependency, API rate limits, and authentication complexity; out of mission for a document formatting package | Users manage their own bibliography .bib files. |
| CRediT contributor taxonomy | apaquarto implements all 14 CRediT roles with degree-of-involvement | Valuable for psychology and biomedical fields; excess complexity for the economics/policy target audience | Document that users can add custom author notes manually if needed. Reconsider if non-economics adoption grows. |
| Multi-language / i18n for template text | "Can the 'Abstract' label appear in German/French?" | Typst handles this via `set text(lang: ...)` but requires translating all template strings; maintenance burden | Expose a `lang:` pass-through to Typst for font shaping; leave label translation as an advanced customization for users who know Typst. |

---

## Feature Dependencies

```
Project scaffolding (create_working_paper)
    └──requires──> Format definitions (workingpaper_typst)
                       └──requires──> Typst template layer (base, titleblock, authors, abstract)
                                          └──requires──> Quarto extension (_extension.yml, format defs)

Institutional branding
    └──requires──> Typst template layer (branding module)
    └──enhances──> All three publication formats

Anonymized review mode
    └──requires──> Author/affiliation rendering in Typst titleblock
    └──conflicts──> Branding (branding output may identify institution; branding should also be suppressed in review mode)

Validation (validate_manuscript)
    └──requires──> Format definitions (to know what fields are required per format)
    └──enhances──> All render wrappers

Render wrappers (render_pub, render_working_paper)
    └──requires──> quarto R package (quarto::quarto_render)
    └──enhances──> Project scaffolding (scaffolded project uses render wrappers in README)

JEL codes / keywords
    └──requires──> typstR: YAML metadata block handling
    └──enhances──> workingpaper and article formats

Fig/table notes (fig_note, tab_note)
    └──requires──> Quarto Typst output (raw Typst block passthrough)

Data/code availability, funding
    └──requires──> typstR: YAML metadata block handling
    └──enhances──> article format (often required for journal submission)
```

### Dependency Notes

- **Project scaffolding requires format definitions:** `create_working_paper()` generates a `.qmd` pointing to `typstR-workingpaper`; the format must exist or the generated file is broken.
- **Branding requires Typst template modularization:** If the Typst layer is one monolithic file, swapping branding elements safely is fragile. The modular design is a prerequisite.
- **Anonymized mode conflicts with branding:** A review submission with a logo defeats the purpose. The `review: true` flag must suppress both author metadata and branding.
- **Validation requires knowing expected fields per format:** `validate_manuscript()` needs to know which metadata fields are required vs optional for each format — this ties validation to the format definitions.

---

## MVP Definition

### Launch With (v0.1)

Minimum viable product — what's needed to validate the concept with the economics/policy institute target audience.

- [ ] `workingpaper_typst` format — primary format for target audience; standalone value
- [ ] Title, subtitle, authors, affiliations, corresponding author, ORCID — without these, the title page is useless
- [ ] Abstract, keywords, JEL codes — economics-specific metadata; a key differentiator
- [ ] Acknowledgements, funding declaration — expected in working papers
- [ ] Report number — trivial implementation, high signal to institute users
- [ ] Bibliography — papers without references are not papers
- [ ] Appendix support — most economics working papers have one
- [ ] Figure and table captions, fig_note / tab_note — fundamental to scientific figures
- [ ] `create_working_paper()` scaffolding — the one-minute setup; adoption hook
- [ ] Institutional branding (logo, font, color, margin, footer) via YAML — primary differentiator for institute users
- [ ] `validate_manuscript()` and `check_*()` diagnostics — pre-render error catching; reduces support burden
- [ ] `render_pub()` / `render_working_paper()` wrappers — R-native entry point

### Add After Validation (v0.1.x)

Features to add once core is working and the template layer is stable.

- [ ] `article_typst` format — adds anonymized review mode; needed for journal preprint/submission use case
- [ ] `policy_brief` format — short format; shares most of the base template layer
- [ ] Data and code availability statements — increasingly required; low complexity add-on
- [ ] Anonymized / review mode — tied to `article_typst`; implement together

### Future Consideration (v0.2+)

Features to defer until product-market fit is established.

- [ ] `_brand.yml` deep integration — Quarto's brand YAML overlaps with typstR branding; deeper integration would reduce duplication but requires stability in Quarto's brand API
- [ ] arXiv preprint style — would make typstR useful for pure preprint workflow; only worth building if user demand emerges outside economics institutes
- [ ] CRediT contributor taxonomy — relevant if adoption expands to biomedical or psychology users
- [ ] Language localization of template strings — niche need; only worth implementing if non-English institute adoption occurs

---

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| workingpaper format + titleblock | HIGH | HIGH | P1 |
| Author/affiliation/ORCID rendering | HIGH | MEDIUM | P1 |
| Abstract, keywords, JEL codes | HIGH | LOW | P1 |
| create_working_paper() scaffolding | HIGH | MEDIUM | P1 |
| Bibliography | HIGH | LOW | P1 |
| Institutional branding via YAML | HIGH | HIGH | P1 |
| Report number | HIGH | LOW | P1 |
| Appendix support | HIGH | MEDIUM | P1 |
| fig_note / tab_note helpers | MEDIUM | LOW | P1 |
| validate_manuscript() diagnostics | MEDIUM | MEDIUM | P1 |
| render_pub() wrappers | MEDIUM | LOW | P1 |
| article_typst format | HIGH | MEDIUM | P2 |
| Anonymized / review mode | HIGH | MEDIUM | P2 |
| policy_brief format | MEDIUM | LOW | P2 |
| Data/code availability statements | MEDIUM | LOW | P2 |
| _brand.yml deep integration | LOW | MEDIUM | P3 |
| arXiv preprint style | LOW | MEDIUM | P3 |
| CRediT taxonomy | LOW | HIGH | P3 |

**Priority key:**
- P1: Must have for launch (v0.1)
- P2: Should have, add when possible (v0.1.x)
- P3: Nice to have, future consideration (v0.2+)

---

## Competitor Feature Analysis

| Feature | rticles | quarto-preprint | apaquarto | reproducr | typstR (planned) |
|---------|---------|----------------|-----------|-----------|-----------------|
| Output format | PDF via LaTeX | PDF via Typst | PDF/DOCX/HTML via Typst/pandoc | PDF/HTML via R Markdown | PDF via Typst |
| Project scaffolding | rmarkdown::draft() only | quarto use template | quarto use template | none | create_working_paper() R function |
| Author/affiliation | Template-specific | Yes (standard Quarto) | Yes (full CRediT) | Yes | Yes |
| ORCID | Template-specific | Yes | Yes | Yes | Yes |
| Keywords | Template-specific | Via categories field | Yes | Yes | Yes (first-class YAML) |
| JEL codes | AEA template only | No | No | No | Yes (first-class, all formats) |
| Report number | No | No | No | No | Yes |
| Anonymized review mode | No (some templates) | No | Yes (mask:) | Yes (blinding param) | Yes (article format) |
| Institutional branding | No | No | No | No | Yes (logo, fonts, colors, footer) |
| Validation / diagnostics | No | No | No | No | Yes (validate_manuscript) |
| Fig/table notes | No | No | No | No | Yes (fig_note, tab_note) |
| Funding declaration | No | No | Auto from author note | No | Yes (first-class YAML) |
| Data/code availability | No | No | No | No | Yes (v0.1.x) |
| R-native render wrapper | No | No | No | No | Yes (render_pub) |
| CRAN availability | Yes | No (Quarto ext only) | Yes | GitHub only | Target: Yes |

---

## Sources

- [rticles CRAN package documentation](https://cran.r-project.org/web/packages/rticles/rticles.pdf) — Confirmed feature set, template scope, AEA JEL template
- [rticles GitHub](https://github.com/rstudio/rticles) — Template list, community contributions
- [Quarto Typst Basics](https://quarto.org/docs/output-formats/typst.html) — Native Typst features, known limitations
- [Quarto Custom Typst Formats](https://quarto.org/docs/output-formats/typst-custom.html) — Template partials model, extension structure
- [Quarto Manuscript Authoring](https://quarto.org/docs/manuscripts/authoring/rstudio.html) — Scholarly metadata, cross-references
- [Quarto Brand YAML for Typst](https://quarto.org/docs/advanced/typst/brand-yaml.html) — Branding system, font/color integration
- [quarto-preprint GitHub](https://github.com/mvuorre/quarto-preprint) — Closest Typst competitor; confirmed feature gaps (no JEL, no report number, no branding, no diagnostics)
- [apaquarto options](https://wjschne.github.io/apaquarto/options.html) — Anonymized mode implementation, CRediT taxonomy, author note automation
- [reproducr package](https://jschultecloos.github.io/reproducr/) — Blinding mode, ORCID, separate bibliographies pattern
- [typstable CRAN](https://cloud.r-project.org/web/packages/typstable/typstable.pdf) — Confirmed scope: table styling only, not a manuscript framework
- [typr R package](https://r-packages.io/packages/typr) — Confirmed scope: Typst CLI compilation helper only

---

*Feature research for: R scientific publishing package (Quarto + Typst PDF)*
*Researched: 2026-03-21*
