test_that("new_diagnostic() includes required fields and keeps optional fields", {
  new_diagnostic <- get_diagnostics_fn("new_diagnostic")

  diagnostic <- new_diagnostic(
    code = "DIAG-INPUT-001",
    severity = "error",
    location = list(file = "paper.qmd"),
    hint = "Provide a valid manuscript path.",
    message = "No .qmd file found.",
    details = list(found = character())
  )

  expect_named(
    diagnostic,
    c("code", "severity", "location", "hint", "message", "details")
  )
  expect_identical(diagnostic$code, "DIAG-INPUT-001")
  expect_identical(diagnostic$severity, "error")
  expect_identical(diagnostic$hint, "Provide a valid manuscript path.")
  expect_identical(diagnostic$message, "No .qmd file found.")
  expect_identical(diagnostic$details, list(found = character()))
})

test_that("new_diagnostic() only accepts error and warning severities", {
  new_diagnostic <- get_diagnostics_fn("new_diagnostic")

  warning_diag <- new_diagnostic(
    code = "DIAG-INPUT-002",
    severity = "warning",
    location = list(field = "typstR.report-number"),
    hint = "Use one report number value."
  )

  expect_identical(warning_diag$severity, "warning")

  expect_error(
    new_diagnostic(
      code = "DIAG-INPUT-003",
      severity = "info",
      location = list(file = "paper.qmd"),
      hint = "Severity must be supported."
    ),
    "severity"
  )
})

test_that("new_diagnostic() supports file-level and field-level locations", {
  new_diagnostic <- get_diagnostics_fn("new_diagnostic")

  file_level <- new_diagnostic(
    code = "DIAG-INPUT-001",
    severity = "error",
    location = list(file = "project/template.qmd"),
    hint = "Create a manuscript file."
  )

  field_level <- new_diagnostic(
    code = "DIAG-INPUT-002",
    severity = "warning",
    location = list(field = "typstR.authors"),
    hint = "Set at least one author."
  )

  expect_identical(file_level$location$file, "project/template.qmd")
  expect_true(is.na(file_level$location$field))

  expect_true(is.na(field_level$location$file))
  expect_identical(field_level$location$field, "typstR.authors")
})
