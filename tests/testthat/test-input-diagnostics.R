resolve_source_file <- function(relative_path) {
  candidates <- c(
    relative_path,
    file.path("..", "..", relative_path),
    file.path(getwd(), relative_path)
  )

  existing <- candidates[file.exists(candidates)]
  if (length(existing) == 0) {
    stop(sprintf("Could not locate %s", relative_path))
  }

  normalizePath(existing[[1]], winslash = "/", mustWork = TRUE)
}

input_diagnostics_env <- local({
  env <- new.env(parent = baseenv())
  source(resolve_source_file("R/diagnostics.R"), local = env)
  source(resolve_source_file("R/utils.R"), local = env)
  env
})

resolve_input_fn <- function() {
  get("resolve_input", envir = input_diagnostics_env, inherits = FALSE)
}

primary_diag <- function(condition) {
  condition$diagnostics[[1]]
}

test_that("resolve_input() emits DIAG-INPUT-001 when no qmd is discoverable", {
  resolve_input <- resolve_input_fn()

  withr::with_tempdir({
    condition <- expect_error(
      resolve_input("."),
      class = "typstR_diagnostics_error"
    )

    diagnostic <- primary_diag(condition)
    expect_identical(diagnostic$code, "DIAG-INPUT-001")
    expect_identical(diagnostic$severity, "error")
    expect_true(is.list(diagnostic$location))
    expect_match(diagnostic$location$file, "\\.", perl = TRUE)
    expect_true(nzchar(diagnostic$hint))
    expect_match(conditionMessage(condition), "No \\.qmd file found", perl = TRUE)
  })
})

test_that("resolve_input() emits DIAG-INPUT-002 with deterministic details for ambiguous directories", {
  resolve_input <- resolve_input_fn()

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
  resolve_input <- resolve_input_fn()

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
