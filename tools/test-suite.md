# Test suite ownership

Ordinary tests run through `testthat::test_local()` or installed-package
`R CMD check`. They never render a PDF or probe an external executable.
Quarto R calls are mocked with bindings restored after each test. Directly
sourcing package R files is no longer a supported test execution mode.

## Coverage retained during consolidation

| Previous coverage | Current owner |
|---|---|
| Constructor audit edge cases | Metadata tests: missing/blank/vector values, email/ORCID, collections and affiliation references |
| Citation versus cross-reference regressions | Manuscript tests, including capitalized references and mixed citation prose |
| Scaffold YAML and onboarding markers | One scaffold suite across all variants; one table of six title-escaping cases |
| Public scaffold opening and returns | Scaffold suite, mocked opener and per-variant invisible returns |
| Quarto inspect paths, missing outputs, restored legacy environment | Mocked render-context tests |
| Diagnostic codes, payloads, severity and ordering | Diagnostic/input/environment suites; original guarantees retained |
| Six legacy render smoke cases | Required defaults and enriched PDF cases, with content/property assertions |
| Nine optional PDF cases | Six required cases combining identified+numbered and anonymous+unnumbered across all variants |
| Live Quarto/Typst evidence | Required runner toolchain preflight and retained reports |
| Performance micro/gain/regression/baseline tests | One explicit benchmark command with baseline validation |
| Rd presence/structure tests | R CMD check; examples completeness is a review concern |
| Helper-map, function-body and redundant equality tests | Removed: they constrain test data or implementation rather than package behavior |

## Required PDF matrix

Run `bash tools/run-render-assurance.sh artifacts/render` from the repository
root after installing the source tarball in a clean-session library. Use a
fresh output directory. The runner sources only developer tooling and loads
package functions from the installed library, never from the source checkout.

| Family | Working paper | Article | Brief |
|---|---|---|---|
| Default | File input, render_working_paper | Directory input, render_pub | NULL input, render_pub |
| Identified enriched | Numbered A/B appendices | Numbered A/B appendices starting at H2 | Ordinary numeric appendices |
| Anonymous unnumbered | Identity suppressed, no numbering | Identity suppressed, no numbering | Identity suppressed, no numbering |

Defaults preserve starter manuscripts and layout; only `keep-typ: true` is
added to project configuration to preserve intermediate evidence. They verify
Letter paper, Libertinus Serif, numbered sections, and multiple keyword/JEL
values where supported. Enriched cases cover singleton arrays, abstract/TOC
order, title/depth, A4, primary-font/margin overrides, a distinct title font,
Roman page numbers, logo/accent/footer/disclaimer, project metadata inheritance,
bibliography, footnotes, equations, tables, funding and data/code statements.
Anonymous cases cover omitted arrays, disabled TOC/section/page numbers,
standard Quarto font/margin fallback and identity suppression in PDF text and
metadata. Every family checks all variants. Combining anonymization and disabled
numbering deliberately reduces interaction coverage.

Audit cases use a default working-paper filename, custom article/brief filenames,
and nested article manuscripts under a project output directory. Paths contain
spaces and are rendered from outside the project. The runner retains source,
PDFs, text, properties, fonts, bounding boxes and page images. Font size is
checked in generated Typst; glyph bounding-box height is not a font-size contract.

All nine cases are required in each CI lane: Linux Quarto 1.4.11, Linux 1.10.19,
and Windows 1.10.19. Missing prerequisites and scenarios fail; there are no skips.
This is 27 matrix renders rather than 45, with none duplicated in package tests.
Visually review representative academic and brief page images before release.

## Manual performance work

Run `Rscript --vanilla tools/benchmark.R artifacts/benchmark` from the repository
root. This validates the three-workload map and baseline values, records the
machine/toolchain, and produces raw measurements and CSV comparisons. Environment
workloads mock external probes; scaffolding copies real assets. Historical
baselines and derivation tooling live under `tools/benchmarks/`; do not reset
baselines automatically. Harness setup changed during consolidation, so historical
ratios require investigation on comparable hardware and are not speed claims.


November 1 regressions extend these same nine cases with quoted/backslash/Unicode
metadata, preserved subtitle markup, format-specific anonymization precedence,
and a conflicting local override followed by an editor-only override. The unit
suite covers both local suffixes, ambiguous YAML boolean spellings, negative
citations, indented code and HTML comments. The matrix size is unchanged.

November 5 regressions use conflicting `_metadata.yml`/`.yaml` siblings in the
anonymous cases and nested identified articles. The identified working paper
combines external and inline references, including a shared cross-reference/
citation group; the article uses inline references with explicit citeproc enabled;
the brief retains native bibliography-only output. These cases also reject
duplicate bibliography entries. First-position disclaimers in working papers
are checked page by page, including a minimal two-page anonymous document,
preserved headers/footers and the manuscript page counter. Identified articles
and briefs retain last-position disclaimers; other anonymous cases disable them.
The ordinary suite covers selected versus shadowed configuration files and the
early diagnostic for explicitly disabling citeproc with inline references.
