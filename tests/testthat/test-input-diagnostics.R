primary_diag <- function(condition) {
  condition$diagnostics[[1]]
}

test_that("resolve_input() emits DIAG-INPUT-001 when no qmd is discoverable", {

  withr::with_tempdir({
    condition <- expect_error(
      resolve_input("."),
      class = "typstR_diagnostics_error"
    )

    diagnostic <- primary_diag(condition)
    expect_identical(diagnostic$code, "DIAG-INPUT-001")
    expect_identical(diagnostic$severity, "error")
    expect_true(is.list(diagnostic$location))
    expect_true(is.character(diagnostic$location$file) && nzchar(diagnostic$location$file))
    expect_true(nzchar(diagnostic$hint))
    expect_match(conditionMessage(condition), "No \\.qmd file found", perl = TRUE)
  })
})

test_that("resolve_input() emits DIAG-INPUT-002 with deterministic details for ambiguous directories", {

  withr::with_tempdir({
    writeLines("---\ntitle: 'A'\n---", "alpha.qmd")
    writeLines("---\ntitle: 'B'\n---", "beta.qmd")

    condition <- expect_error(
      resolve_input("."),
      class = "typstR_diagnostics_error"
    )

    diagnostic <- primary_diag(condition)
    expect_identical(diagnostic$code, "DIAG-INPUT-002")
    expect_identical(diagnostic$severity, "error")
    expect_true(is.list(diagnostic$details))
    expect_named(diagnostic$details, "found")
    expect_identical(diagnostic$details$found, c("alpha.qmd", "beta.qmd"))
    expect_match(conditionMessage(condition), "Multiple \\.qmd files found", perl = TRUE)
  })
})

test_that("resolve_input() emits DIAG-INPUT-003 for missing explicit inputs", {

  withr::with_tempdir({
    missing <- "missing.qmd"

    condition <- expect_error(
      resolve_input(missing),
      class = "typstR_diagnostics_error"
    )

    diagnostic <- primary_diag(condition)
    expect_identical(diagnostic$code, "DIAG-INPUT-003")
    expect_identical(diagnostic$severity, "error")
    expect_match(diagnostic$location$file, "missing\\.qmd$", perl = TRUE)
    expect_true(nzchar(diagnostic$hint))
    expect_match(conditionMessage(condition), "does not exist", perl = TRUE)
  })
})
