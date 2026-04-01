test_that("diagnostics codebook exposes stable Phase 05 and Phase 06 mappings", {
  diagnostics_codebook <- get_diagnostics_fn("diagnostics_codebook")
  codebook <- diagnostics_codebook()

  expect_named(
    codebook,
    c(
      "quarto_unavailable",
      "no_qmd_found",
      "multiple_qmd_found",
      "input_not_found",
      "env_quarto_unavailable",
      "env_typst_unavailable",
      "env_quarto_floor_incompatible",
      "env_extension_missing"
    )
  )

  expect_identical(codebook[["quarto_unavailable"]], "DIAG-RUNTIME-001")
  expect_identical(codebook[["no_qmd_found"]], "DIAG-INPUT-001")
  expect_identical(codebook[["multiple_qmd_found"]], "DIAG-INPUT-002")
  expect_identical(codebook[["input_not_found"]], "DIAG-INPUT-003")

  # D-06: stable environment namespace mappings
  expect_identical(codebook[["env_quarto_unavailable"]], "DIAG-ENV-001")
  expect_identical(codebook[["env_typst_unavailable"]], "DIAG-ENV-002")
  expect_identical(codebook[["env_quarto_floor_incompatible"]], "DIAG-ENV-003")
  expect_identical(codebook[["env_extension_missing"]], "DIAG-ENV-004")
})

test_that("diagnostics codebook entries are unique and format-valid", {
  diagnostics_codebook <- get_diagnostics_fn("diagnostics_codebook")
  codebook <- diagnostics_codebook()

  expect_true(all(grepl("^DIAG-[A-Z]+-[0-9]{3}$", unname(codebook))))
  expect_length(unique(unname(codebook)), length(codebook))
})

test_that("validate_diagnostic_codebook() rejects reassigned stable environment codes", {
  diagnostics_codebook <- get_diagnostics_fn("diagnostics_codebook")
  validate_diagnostic_codebook <- get_diagnostics_fn("validate_diagnostic_codebook")

  reassigned <- diagnostics_codebook()
  reassigned[["env_typst_unavailable"]] <- "DIAG-ENV-999"

  expect_error(
    validate_diagnostic_codebook(reassigned),
    "must remain assigned"
  )
})

test_that("sort_diagnostics() keeps deterministic ordering for environment payloads", {
  diagnostics_codebook <- get_diagnostics_fn("diagnostics_codebook")
  new_diagnostic <- get_diagnostics_fn("new_diagnostic")
  sort_diagnostics <- get_diagnostics_fn("sort_diagnostics")

  diagnostics <- list(
    new_diagnostic(
      code = diagnostics_codebook()[["env_quarto_floor_incompatible"]],
      severity = "error",
      location = list(file = "project", field = "environment"),
      hint = "Upgrade Quarto."
    ),
    new_diagnostic(
      code = diagnostics_codebook()[["env_quarto_unavailable"]],
      severity = "error",
      location = list(file = "project", field = "environment"),
      hint = "Install Quarto."
    ),
    new_diagnostic(
      code = diagnostics_codebook()[["env_extension_missing"]],
      severity = "warning",
      location = list(file = "project", field = "environment"),
      hint = "Copy extension files."
    ),
    new_diagnostic(
      code = diagnostics_codebook()[["env_typst_unavailable"]],
      severity = "error",
      location = list(file = "project", field = "environment"),
      hint = "Install Quarto with embedded Typst."
    )
  )

  sorted <- sort_diagnostics(diagnostics)
  expect_identical(
    vapply(sorted, function(x) x$code, character(1)),
    c("DIAG-ENV-001", "DIAG-ENV-002", "DIAG-ENV-003", "DIAG-ENV-004")
  )
})