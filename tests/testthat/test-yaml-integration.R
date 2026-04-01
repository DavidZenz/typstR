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
.quarto_available <- function() {
  requireNamespace("quarto", quietly = TRUE) && quarto::quarto_available()
}

.skip_if_no_quarto <- function() {
  skip_if_not(.quarto_available())
}

.onboarding_scaffold_specs <- function() {
  list(
    list(
      label = "working paper",
      fn_name = "create_working_paper",
      project = "working-paper-project"
    ),
    list(
      label = "article",
      fn_name = "create_article",
      project = "article-project"
    ),
    list(
      label = "policy brief",
      fn_name = "create_policy_brief",
      project = "policy-brief-project"
    )
  )
}


test_that("onboarding helper matrix covers all scaffold formats", {
  specs <- .onboarding_scaffold_specs()

  expect_equal(
    vapply(specs, `[[`, character(1), "fn_name"),
    c("create_working_paper", "create_article", "create_policy_brief")
  )
})


.copy_extension <- function(dest_dir) {
  ext_src <- system.file("quarto/extensions/typstR", package = "typstR")
  if (!nzchar(ext_src)) {
    ext_src <- file.path("inst", "quarto", "extensions", "typstR")
  }
  ext_dest <- file.path(dest_dir, "_extensions", "typstR")
  dir.create(file.path(dest_dir, "_extensions"), showWarnings = FALSE)
  fs::dir_copy(ext_src, ext_dest)
  invisible(ext_dest)
}

test_that("pre-render validation succeeds across helper-generated onboarding formats", {
  .skip_if_no_quarto()

  withr::with_tempdir({
    for (spec in .onboarding_scaffold_specs()) {
      helper <- get(spec$fn_name, inherits = TRUE)
      helper(spec$project, open = FALSE)

      report <- validate_render_environment(spec$project)

      expect_s3_class(report, "typstR_validation_report", info = spec$label)
      expect_true(isTRUE(report$ok), info = spec$label)
    }
  })
})

# ---------------------------------------------------------------------------
# Existing render smoke coverage
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# Test 1: scaffold renders without errors
# ---------------------------------------------------------------------------
test_that("scaffold renders without errors", {
  .skip_if_no_quarto()

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
  .skip_if_no_quarto()

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
  typstR-typst: default
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
  .skip_if_no_quarto()

  withr::with_tempdir({
    .copy_extension(".")

    qmd_content <- '---
title: "Standard + typstR Field Coexistence Test"
author:
  - name: "Jane Smith"
abstract: |
  Testing that toc and number-sections do not conflict with typstR fields.
format:
  typstR-typst:
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
  .skip_if_no_quarto()

  withr::with_tempdir({
    .copy_extension(".")

    qmd_content <- '---
title: "Hyphenated Key Test"
author:
  - name: "Researcher A"
abstract: |
  Smoke-testing hyphenated key passthrough.
format:
  typstR-typst: default
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

test_that("article template smoke-renders without errors", {
  .skip_if_no_quarto()

  withr::with_tempdir({
    .copy_extension(".")
    fs::dir_copy(file.path("inst", "templates", "article"), "article-template")

    old <- setwd("article-template")
    on.exit(setwd(old), add = TRUE)

    expect_no_error(
      quarto::quarto_render("template.qmd", quiet = TRUE)
    )

    qmd <- readLines("template.qmd")
    expect_true(any(grepl("format-variant: article", qmd, fixed = TRUE)))
    expect_true(file.exists("template.pdf"))
  })
})

test_that("policy brief template smoke-renders without errors", {
  .skip_if_no_quarto()

  withr::with_tempdir({
    .copy_extension(".")
    fs::dir_copy(file.path("inst", "templates", "policy-brief"), "brief-template")

    old <- setwd("brief-template")
    on.exit(setwd(old), add = TRUE)

    expect_no_error(
      quarto::quarto_render("template.qmd", quiet = TRUE)
    )

    qmd <- readLines("template.qmd")
    expect_true(any(grepl("format-variant: brief", qmd, fixed = TRUE)))
    expect_true(file.exists("template.pdf"))
  })
})
