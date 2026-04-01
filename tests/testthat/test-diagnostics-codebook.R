test_that("diagnostics codebook exposes stable Phase 05 mappings", {
  diagnostics_codebook <- get_diagnostics_fn("diagnostics_codebook")
  codebook <- diagnostics_codebook()

  expect_named(
    codebook,
    c(
      "quarto_unavailable",
      "no_qmd_found",
      "multiple_qmd_found",
      "input_not_found"
    )
  )

  expect_identical(codebook[["quarto_unavailable"]], "DIAG-RUNTIME-001")
  expect_identical(codebook[["no_qmd_found"]], "DIAG-INPUT-001")
  expect_identical(codebook[["multiple_qmd_found"]], "DIAG-INPUT-002")
  expect_identical(codebook[["input_not_found"]], "DIAG-INPUT-003")
})

test_that("diagnostics codebook entries are unique and format-valid", {
  diagnostics_codebook <- get_diagnostics_fn("diagnostics_codebook")
  codebook <- diagnostics_codebook()

  expect_true(all(grepl("^DIAG-[A-Z]+-[0-9]{3}$", unname(codebook))))
  expect_length(unique(unname(codebook)), length(codebook))
})

test_that("validate_diagnostic_codebook() rejects reassigned stable codes", {
  diagnostics_codebook <- get_diagnostics_fn("diagnostics_codebook")
  validate_diagnostic_codebook <- get_diagnostics_fn("validate_diagnostic_codebook")

  reassigned <- diagnostics_codebook()
  reassigned[["no_qmd_found"]] <- "DIAG-INPUT-099"

  expect_error(
    validate_diagnostic_codebook(reassigned),
    "must remain assigned"
  )
})
