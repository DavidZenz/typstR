with_validation_bindings <- function(bindings, code) {
  env <- validation_test_env
  restore <- list()

  for (name in names(bindings)) {
    has_existing <- exists(name, envir = env, inherits = FALSE)
    restore[[name]] <- if (has_existing) get(name, envir = env, inherits = FALSE) else NULL
    assign(name, bindings[[name]], envir = env)
  }

  withr::defer({
    for (name in names(bindings)) {
      previous <- restore[[name]]
      if (is.null(previous)) {
        if (exists(name, envir = env, inherits = FALSE)) {
          rm(list = name, envir = env)
        }
      } else {
        assign(name, previous, envir = env)
      }
    }
  })

  force(code)
}

passing_checks <- function(path) {
  list(
    quarto = list(
      ok = TRUE,
      available = TRUE,
      version = "1.5.1"
    ),
    typst = list(
      ok = TRUE,
      available = TRUE,
      version = "0.13.1",
      raw = "typst 0.13.1"
    ),
    quarto_floor = list(
      ok = TRUE,
      required = ">=1.4.11",
      compatible = TRUE,
      available = TRUE
    ),
    extension = list(
      ok = TRUE,
      present = TRUE,
      manifest = as.character(fs::path_abs(file.path(path, "_extensions", "typstR", "_extension.yml")))
    )
  )
}

failing_checks <- function(path) {
  list(
    quarto = list(
      ok = FALSE,
      available = FALSE,
      version = NA_character_,
      reason = "quarto CLI unavailable"
    ),
    typst = list(
      ok = FALSE,
      available = FALSE,
      version = NA_character_,
      raw = NA_character_,
      reason = "quarto typst --version failed"
    ),
    quarto_floor = list(
      ok = FALSE,
      required = ">=1.4.11",
      compatible = FALSE,
      available = FALSE
    ),
    extension = list(
      ok = FALSE,
      present = FALSE,
      manifest = as.character(fs::path_abs(file.path(path, "_extensions", "typstR", "_extension.yml")))
    )
  )
}

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
