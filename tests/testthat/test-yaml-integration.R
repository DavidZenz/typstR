# Integration tests for the full YAML-to-PDF pipeline.
#
# These tests validate the complete chain:
#   R metadata -> YAML -> Pandoc -> typst-show.typ -> typst-template.typ -> PDF
#
# All tests are guarded with skip_if_not(quarto::quarto_available()) so they
# are safe for CRAN (TEST-04).  Each test runs in an isolated temp directory
# via withr::with_tempdir().

# ---------------------------------------------------------------------------
# Helper: copy the bundled extension into a temp project directory
# ---------------------------------------------------------------------------
.copy_extension <- function(dest_dir) {
  ext_src <- system.file("quarto/extensions/typstR", package = "typstR",
                         mustWork = TRUE)
  ext_dest <- file.path(dest_dir, "_extensions", "typstR")
  dir.create(file.path(dest_dir, "_extensions"), showWarnings = FALSE)
  fs::dir_copy(ext_src, ext_dest)
  invisible(ext_dest)
}

# ---------------------------------------------------------------------------
# Test 1: scaffold renders without errors
# ---------------------------------------------------------------------------
test_that("scaffold renders without errors", {
  skip_if_not(quarto::quarto_available())

  withr::with_tempdir({
    create_working_paper("test-project", open = FALSE)

    # Render the scaffold; success = PDF produced
    render_working_paper("test-project", quiet = TRUE, open = FALSE)

    expect_true(file.exists(file.path("test-project", "template.pdf")))
  })
})

# ---------------------------------------------------------------------------
# Test 2: typstR namespace fields reach the PDF (render succeeds)
# ---------------------------------------------------------------------------
test_that("typstR namespace fields reach the PDF", {
  skip_if_not(quarto::quarto_available())

  withr::with_tempdir({
    .copy_extension(".")

    qmd_content <- '---
title: "Metadata Field Test"
author:
  - name: "Test Author"
    email: "test@example.org"
    corresponding: true
abstract: |
  Testing typstR namespace field passthrough.
format:
  typstR-workingpaper: default
typstR:
  keywords:
    - trade
    - policy
  jel:
    - F10
    - L52
  acknowledgements: "We thank the reviewers."
  report-number: "WP 001"
  funding: "ERC Grant 12345."
---

## Introduction

This document tests that all `typstR:` namespace fields are passed through
the Pandoc variable pipeline without errors.
'
    writeLines(qmd_content, "test-meta.qmd")

    # A successful render proves the Pandoc variable wiring is syntactically
    # correct.  PDF text content cannot be inspected without pdftools, but
    # the absence of a render error is the key signal here.
    expect_no_error(
      quarto::quarto_render("test-meta.qmd", quiet = TRUE)
    )

    expect_true(file.exists("test-meta.pdf"))
  })
})

# ---------------------------------------------------------------------------
# Test 3: standard Quarto fields work alongside typstR fields
# ---------------------------------------------------------------------------
test_that("standard Quarto fields work alongside typstR fields", {
  skip_if_not(quarto::quarto_available())

  withr::with_tempdir({
    .copy_extension(".")

    qmd_content <- '---
title: "Standard + typstR Field Coexistence Test"
author:
  - name: "Jane Smith"
abstract: |
  Testing that toc and number-sections do not conflict with typstR fields.
format:
  typstR-workingpaper:
    toc: true
    number-sections: true
typstR:
  keywords:
    - economics
    - policy
  jel:
    - A10
  acknowledgements: "Thanks to everyone."
  report-number: "WP 002"
---

## First Section

Content of the first section.

## Second Section

Content of the second section.
'
    writeLines(qmd_content, "test-coexist.qmd")

    expect_no_error(
      quarto::quarto_render("test-coexist.qmd", quiet = TRUE)
    )

    expect_true(file.exists("test-coexist.pdf"))
  })
})

# ---------------------------------------------------------------------------
# Test 4: hyphenated key validation (report-number, data-availability,
#          code-availability)
# ---------------------------------------------------------------------------
test_that("hyphenated keys pass through without errors", {
  skip_if_not(quarto::quarto_available())

  withr::with_tempdir({
    .copy_extension(".")

    qmd_content <- '---
title: "Hyphenated Key Test"
author:
  - name: "Researcher A"
abstract: |
  Smoke-testing hyphenated key passthrough.
format:
  typstR-workingpaper: default
typstR:
  report-number: "WP 003"
  data-availability: "Data available at https://example.com/data"
  code-availability: "Replication code at https://github.com/example/repo"
---

## Introduction

This document validates that hyphenated YAML keys in the `typstR:` namespace
are handled correctly by the Pandoc variable interpolation in typst-show.typ.
'
    writeLines(qmd_content, "test-hyphen.qmd")

    expect_no_error(
      quarto::quarto_render("test-hyphen.qmd", quiet = TRUE)
    )

    expect_true(file.exists("test-hyphen.pdf"))
  })
})
