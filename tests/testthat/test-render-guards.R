primary_diag <- function(condition) {
  condition$diagnostics[[1]]
}

assert_env_diag <- function(condition) {
  diagnostic <- primary_diag(condition)
  expect_identical(diagnostic$code, "DIAG-ENV-001")
  expect_identical(diagnostic$severity, "error")
  expect_true(is.list(diagnostic$location))
  expect_true(nzchar(diagnostic$hint))
}

test_that("render_pub() emits structured diagnostics when Quarto is unavailable", {
  testthat::local_mocked_bindings(collect_environment_checks = failing_checks, .package = "typstR")
  path <- withr::local_tempfile(fileext = ".qmd")
  writeLines("---\ntitle: Test\nformat: typstR-typst\n---", path)

  condition <- expect_error(
    render_pub(path, open = FALSE),
    class = "typstR_diagnostics_error"
  )

  assert_env_diag(condition)
  expect_match(conditionMessage(condition), "Quarto is not installed or not on PATH\\.", perl = TRUE)
})

test_that("render_working_paper() emits the same no-Quarto structured diagnostic", {
  testthat::local_mocked_bindings(collect_environment_checks = failing_checks, .package = "typstR")
  path <- withr::local_tempfile(fileext = ".qmd")
  writeLines("---\ntitle: Test\nformat: typstR-typst\n---", path)

  condition <- expect_error(
    render_working_paper(path, open = FALSE),
    class = "typstR_diagnostics_error"
  )

  assert_env_diag(condition)
  expect_match(conditionMessage(condition), "Quarto is not installed or not on PATH\\.", perl = TRUE)
})
