# Phase 11 Validation

**Phase:** 11-documentation-content-foundation  
**Status:** Ready for execution

## Validation Strategy

Phase 11 needs a mixed validation gate: lightweight content assertions for the onboarding surfaces, an explicit exported-help-page audit beyond `devtools::check_man()`, and build-level checks for vignette rendering and tarball hygiene.

## Requirement Coverage

| Requirement | Validation approach | Command / check |
|-------------|---------------------|-----------------|
| DOCS-01 | README first-screen smoke check plus human review of opening copy | `Rscript -e 'lines <- readLines("README.md", warn = FALSE, n = 35); stopifnot(any(grepl("install_github\\(\"DavidZenz/typstR\"\\)", lines)), any(grepl("Quarto", lines)), any(grepl("create_working_paper", lines)), any(grepl("render_working_paper", lines)))'` |
| DOCS-02 | Cross-surface command alignment plus vignette backlink assertions | `grep -RIn "create_working_paper\\|render_working_paper" README.md pkgdown/index.md vignettes/getting-started.Rmd` and `Rscript -e 'wp <- readLines("vignettes/working-papers.Rmd", warn = FALSE); cb <- readLines("vignettes/customizing-branding.Rmd", warn = FALSE); stopifnot(any(grepl("vignette\\(\"getting-started\"", wp)), any(grepl("vignette\\(\"getting-started\"", cb))))'` |
| DOCS-03 | Installed-package article build with Quarto explicitly absent from PATH while keeping pandoc available | `R CMD INSTALL . && bash -lc 'TMP=$(mktemp -d) && ln -s /opt/homebrew/bin/pandoc "$TMP/pandoc" && PATH="$TMP:/usr/bin:/bin" Rscript -e '"'"'stopifnot(Sys.which("quarto") == ""); pkgdown::build_articles(quiet = FALSE, lazy = FALSE, preview = FALSE)'"'"' ; STATUS=$? ; rm -rf "$TMP" ; exit $STATUS'` |
| DOCS-04 | Source regeneration check plus exported-help-page audit | `Rscript -e 'devtools::document(quiet = TRUE); devtools::check_man(); testthat::test_file("tests/testthat/test-documentation-reference.R", reporter = testthat::StopReporter$new())'` |
| DOCS-05 | NEWS heading check | `grep -n '^# typstR ' NEWS.md` |
| SHIP-04 | Git-ignore check plus tarball inspection | `bash -lc 'if git check-ignore man/create_working_paper.Rd >/dev/null 2>&1; then echo "man page still ignored"; exit 1; fi && R CMD build . >/dev/null && PKG=$(ls -t typstR_*.tar.gz | head -n 1) && if tar -tf "$PKG" | grep -E "(^typstR/docs/|^typstR/pkgdown/)"; then echo "pkgdown artifact leaked into tarball"; exit 1; fi'` |

## Execution Order

1. Run the README/home smoke checks after Plan 01 changes.
2. Run the RED-state exported-help-page audit from Plan 02 before any roxygen refresh.
3. Run the NEWS / ignore / tarball checks after Plan 03 changes.
4. Run the full documentation regeneration and help-page audit after Plan 04 changes.
5. Finish with a brief manual pass confirming README first-screen clarity and that `pkgdown/index.md` stays lighter than `getting-started`.

## Phase Gate

Phase 11 is complete only when:

- the canonical working-paper onboarding story is consistent across README, `pkgdown/index.md`, and `getting-started`
- both follow-on vignettes link back to `getting-started`
- `pkgdown::build_articles()` passes with `Sys.which("quarto") == ""`
- exported help pages pass both `devtools::check_man()` and the stricter audit
- `NEWS.md` exists with the required headings
- `man/*.Rd` is trackable in git and pkgdown-only artifacts stay out of the built tarball
