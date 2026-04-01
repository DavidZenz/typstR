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

new_render_validation_env <- function() {
  env <- new.env(parent = baseenv())
  source(resolve_validation_source_file("R/diagnostics.R"), local = env)
  source(resolve_validation_source_file("R/validation_environment.R"), local = env)
  source(resolve_validation_source_file("R/utils.R"), local = env)
  source(resolve_validation_source_file("R/render.R"), local = env)
  env
}

copy_extension_into <- function(dest_dir) {
  ext_src <- system.file("quarto", "extensions", "typstR", package = "typstR")
  if (!nzchar(ext_src)) {
    ext_src <- resolve_validation_source_file("inst/quarto/extensions/typstR")
  }

  dir.create(file.path(dest_dir, "_extensions"), showWarnings = FALSE)
  fs::dir_copy(ext_src, file.path(dest_dir, "_extensions", "typstR"))
  invisible(file.path(dest_dir, "_extensions", "typstR", "_extension.yml"))
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

test_that("render_pub() and standalone validation emit equivalent diagnostics", {
  env <- new_render_validation_env()
  path <- tempfile("validation-render-equivalence-")
  dir.create(path)

  assign("collect_environment_checks", function(path) failing_checks(path), envir = env)

  standalone_condition <- expect_error(
    get("validate_render_environment", envir = env)(path),
    class = "typstR_diagnostics_error"
  )
  render_condition <- expect_error(
    get("render_pub", envir = env)(path, open = FALSE),
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

test_that("validate_render_environment() captures real Quarto/Typst evidence when available", {
  skip_if_not(requireNamespace("quarto", quietly = TRUE) && quarto::quarto_available())

  validate_render_environment <- get_validation_fn("validate_render_environment")

  withr::with_tempdir({
    copy_extension_into(".")

    report <- validate_render_environment(".")

    expect_s3_class(report, "typstR_validation_report")
    expect_true(isTRUE(report$checks$quarto$available))
    expect_true(nzchar(report$checks$quarto$version))
    expect_true(isTRUE(report$checks$typst$available))
    expect_true(!is.na(report$checks$quarto_floor$required))
    expect_true(isTRUE(report$checks$extension$present))
  })
})
