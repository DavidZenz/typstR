test_that("validate_render_environment() returns a structured pass report", {
  validate_render_environment <- get_validation_fn("validate_render_environment")
  path <- tempfile("validation-pass-")
  dir.create(path)

  report <- with_validation_bindings(
    list(collect_environment_checks = function(path) passing_checks(path)),
    validate_render_environment(path)
  )

  expect_s3_class(report, "typstR_validation_report")
  expect_true(report$ok)
  expect_named(report$checks, c("quarto", "typst", "quarto_floor", "extension"))
})

test_that("validate_render_environment() emits aggregate environment diagnostics", {
  validate_render_environment <- get_validation_fn("validate_render_environment")
  path <- tempfile("validation-fail-")
  dir.create(path)

  condition <- with_validation_bindings(
    list(collect_environment_checks = function(path) failing_checks(path)),
    expect_error(validate_render_environment(path), class = "typstR_diagnostics_error")
  )

  expect_identical(
    vapply(condition$diagnostics, function(entry) entry$code, character(1)),
    c("DIAG-ENV-001", "DIAG-ENV-002", "DIAG-ENV-003", "DIAG-ENV-004")
  )
})

test_that("render_pub() and standalone validation emit equivalent diagnostics", {
  path <- tempfile("validation-render-equivalence-")
  dir.create(path)
  writeLines("---\ntitle: Test\nformat: typstR-typst\n---", file.path(path, "paper.qmd"))

  testthat::local_mocked_bindings(collect_environment_checks = failing_checks, .package = "typstR")

  standalone_condition <- expect_error(
    validate_render_environment(path),
    class = "typstR_diagnostics_error"
  )
  render_condition <- expect_error(
    render_pub(path, open = FALSE),
    class = "typstR_diagnostics_error"
  )

  standalone_codes <- vapply(standalone_condition$diagnostics, function(entry) entry$code, character(1))
  render_codes <- vapply(render_condition$diagnostics, function(entry) entry$code, character(1))

  expect_identical(render_codes, standalone_codes)
})

test_that("validation report includes explicit Quarto and Typst evidence", {
  validate_render_environment <- get_validation_fn("validate_render_environment")
  path <- tempfile("validation-evidence-")
  dir.create(path)

  report <- with_validation_bindings(
    list(collect_environment_checks = function(path) passing_checks(path)),
    validate_render_environment(path)
  )

  expect_identical(report$checks$quarto$available, TRUE)
  expect_identical(report$checks$quarto$version, "1.5.1")
  expect_identical(report$checks$typst$available, TRUE)
  expect_identical(report$checks$typst$version, "0.13.1")
  expect_identical(report$checks$quarto_floor$required, ">=1.4.11")
  expect_identical(report$checks$extension$present, TRUE)
})

test_that("collect_environment_checks() evaluates extension presence when Quarto is missing", {
  collect_environment_checks <- get_validation_fn("collect_environment_checks")
  path <- tempfile("validation-collect-")
  dir.create(path)

  extension_probe_called <- FALSE

  checks <- with_validation_bindings(
    list(
      probe_quarto = function() {
        list(ok = FALSE, available = FALSE, version = NA_character_)
      },
      probe_typst = function(quarto_check) {
        list(ok = FALSE, available = FALSE, version = NA_character_, raw = NA_character_)
      },
      probe_quarto_floor = function(quarto_check, required) {
        list(ok = FALSE, required = required, compatible = FALSE, available = FALSE)
      },
      probe_extension = function(path) {
        extension_probe_called <<- TRUE
        list(ok = FALSE, present = FALSE, manifest = file.path(path, "_extensions", "typstR", "_extension.yml"))
      },
      required_quarto_floor = function() ">=1.4.11"
    ),
    collect_environment_checks(path)
  )

  expect_true(extension_probe_called)
  expect_false(checks$extension$ok)
})
