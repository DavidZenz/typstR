test_that("sort_diagnostics() orders by severity, location, and code", {
  new_diagnostic <- get_diagnostics_fn("new_diagnostic")
  sort_diagnostics <- get_diagnostics_fn("sort_diagnostics")

  diagnostics <- list(
    new_diagnostic(
      code = "DIAG-INPUT-003",
      severity = "warning",
      location = list(file = "b.qmd", field = "typstR.authors"),
      hint = "Fix author metadata."
    ),
    new_diagnostic(
      code = "DIAG-INPUT-002",
      severity = "error",
      location = list(file = "b.qmd", field = "typstR.title"),
      hint = "Fix title metadata."
    ),
    new_diagnostic(
      code = "DIAG-INPUT-001",
      severity = "error",
      location = list(file = "a.qmd", field = "typstR.title"),
      hint = "Fix title metadata."
    ),
    new_diagnostic(
      code = "DIAG-RUNTIME-001",
      severity = "warning",
      location = list(file = "a.qmd", field = "typstR.runtime"),
      hint = "Install Quarto."
    )
  )

  sorted <- sort_diagnostics(diagnostics)

  expect_equal(
    vapply(sorted, function(x) x$code, character(1)),
    c("DIAG-INPUT-001", "DIAG-INPUT-002", "DIAG-RUNTIME-001", "DIAG-INPUT-003")
  )
  expect_equal(
    vapply(sorted, function(x) x$severity, character(1)),
    c("error", "error", "warning", "warning")
  )
})

test_that("sort_diagnostics() produces deterministic results across repeated runs", {
  new_diagnostic <- get_diagnostics_fn("new_diagnostic")
  sort_diagnostics <- get_diagnostics_fn("sort_diagnostics")

  diagnostics <- list(
    new_diagnostic(
      code = "DIAG-INPUT-003",
      severity = "warning",
      location = list(file = "c.qmd", field = "typstR.authors"),
      hint = "Fix author metadata."
    ),
    new_diagnostic(
      code = "DIAG-INPUT-001",
      severity = "error",
      location = list(file = "a.qmd", field = "typstR.title"),
      hint = "Fix title metadata."
    ),
    new_diagnostic(
      code = "DIAG-INPUT-002",
      severity = "error",
      location = list(file = "b.qmd", field = "typstR.title"),
      hint = "Fix title metadata."
    )
  )

  first <- sort_diagnostics(diagnostics)
  second <- sort_diagnostics(diagnostics)

  expect_identical(first, second)
  expect_identical(
    vapply(first, function(x) x$code, character(1)),
    vapply(second, function(x) x$code, character(1))
  )
})

test_that("emit_diagnostics_error() emits classed condition with diagnostics payload", {
  new_diagnostic <- get_diagnostics_fn("new_diagnostic")
  emit_diagnostics_error <- get_diagnostics_fn("emit_diagnostics_error")

  diagnostics <- list(
    new_diagnostic(
      code = "DIAG-INPUT-003",
      severity = "warning",
      location = list(file = "b.qmd", field = "typstR.authors"),
      hint = "Fix author metadata."
    ),
    new_diagnostic(
      code = "DIAG-INPUT-001",
      severity = "error",
      location = list(file = "a.qmd", field = "typstR.title"),
      hint = "Fix title metadata."
    )
  )

  captured <- expect_error(
    emit_diagnostics_error(diagnostics),
    class = "typstR_diagnostics_error"
  )

  expect_s3_class(captured, "typstR_diagnostics_error")
  expect_type(captured$diagnostics, "list")
  expect_gt(length(captured$diagnostics), 1)
  expect_identical(captured$diagnostics[[1]]$severity, "error")
  expect_identical(captured$diagnostics[[2]]$severity, "warning")
})
