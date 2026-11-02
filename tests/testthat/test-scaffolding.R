.scaffold_specs <- function() {
  list(
    list(
      label = "working paper",
      fn_name = "create_working_paper",
      project = "wp-project",
      format_variant = NULL,
      expects_jel = TRUE,
      expects_report_number = TRUE
    ),
    list(
      label = "article",
      fn_name = "create_article",
      project = "article-project",
      format_variant = "article",
      expects_jel = TRUE,
      expects_report_number = FALSE
    ),
    list(
      label = "policy brief",
      fn_name = "create_policy_brief",
      project = "brief-project",
      format_variant = "brief",
      expects_jel = FALSE,
      expects_report_number = TRUE
    )
  )
}

.shared_baseline_markers <- function() {
  c(
    "author:",
    "affiliations:",
    "abstract: |",
    "bibliography: references.bib",
    "format:",
    "typstR:",
    "keywords:",
    "funding: |",
    "<!-- Quarto adds the bibliography automatically when citations are present. -->"
  )
}

.guidance_markers <- function() {
  c(
    "# Edit first: update title, authors, and affiliations.",
    "# Replace abstract with your project summary before sharing.",
    "<!-- Replace this starter narrative with your project-specific text. -->"
  )
}

.scaffold_project <- function(spec, title) {
  result <- withVisible(get(spec$fn_name)(spec$project, title = title, open = FALSE))
  expect_false(result$visible)
  expect_identical(result$value, spec$project)
  expect_identical(validate_manuscript(spec$project)$metadata$title, title)
  list(project = spec$project,
       qmd = readLines(file.path(spec$project, "template.qmd"), warn = FALSE))
}

test_that("create_* helpers scaffold shared baseline and only allowed format deltas", {
  withr::with_tempdir({
    for (spec in .scaffold_specs()) {
      output <- .scaffold_project(spec, title = paste("Starter", spec$label))

      expect_true(file.exists(file.path(output$project, "template.qmd")), info = spec$label)
      expect_true(file.exists(file.path(output$project, "_quarto.yml")), info = spec$label)
      expect_true(file.exists(file.path(output$project, "references.bib")), info = spec$label)
      expect_true(dir.exists(file.path(output$project, "_extensions", "typstR")), info = spec$label)

      for (marker in c(.shared_baseline_markers(), .guidance_markers())) {
        expect_true(any(grepl(marker, output$qmd, fixed = TRUE)),
          info = paste(spec$label, "missing baseline marker", marker)
        )
      }

      if (is.null(spec$format_variant)) {
        expect_false(any(grepl("format-variant:", output$qmd, fixed = TRUE)),
          info = paste(spec$label, "should not declare format-variant")
        )
      } else {
        expect_true(any(grepl(paste0("format-variant: ", spec$format_variant), output$qmd, fixed = TRUE)),
          info = paste(spec$label, "missing format-variant")
        )
      }

      expect_equal(any(grepl("jel:", output$qmd, fixed = TRUE)), spec$expects_jel,
        info = paste(spec$label, "JEL expectation mismatch")
      )
      expect_equal(any(grepl("report-number:", output$qmd, fixed = TRUE)), spec$expects_report_number,
        info = paste(spec$label, "report-number expectation mismatch")
      )
    }
  })
})

test_that("scaffold titles roundtrip through YAML without damaging comments", {
  root <- withr::local_tempdir()
  for (title in c('The "policy" effect: a test', 'A \\ path', '\u00dcber Handel', 'First\nSecond', '029', 'no')) {
    path <- tempfile(tmpdir = root)
    create_article(path, title = title, open = FALSE)
    expect_identical(validate_manuscript(path)$metadata$title, title)
    expect_true(any(grepl("# Edit first:", readLines(file.path(path, "template.qmd")), fixed = TRUE)))
  }
  path <- tempfile(tmpdir = root)
  expect_error(create_article(path, title = NA_character_, open = FALSE), "title")
  expect_false(dir.exists(path))
})

test_that("scaffold open opens only after successful creation", {
  opened <- character()
  testthat::local_mocked_bindings(open_file = function(path) {
    expect_true(file.exists(file.path(path, "template.qmd")))
    opened <<- c(opened, path)
  }, .package = "typstR")
  root <- withr::local_tempdir()
  for (create in list(create_article, create_working_paper, create_policy_brief)) {
    create(tempfile(tmpdir = root), open = TRUE)
    create(tempfile(tmpdir = root), open = FALSE)
  }
  expect_length(opened, 3L)
})
