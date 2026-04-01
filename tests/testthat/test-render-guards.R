resolve_render_source_file <- function(relative_path) {
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

render_test_env <- local({
  env <- new.env(parent = baseenv())
  source(resolve_render_source_file("R/diagnostics.R"), local = env)
  source(resolve_render_source_file("R/utils.R"), local = env)
  source(resolve_render_source_file("R/render.R"), local = env)
  env
})

get_render_fn <- function(name) {
  get(name, envir = render_test_env, inherits = FALSE)
}

mock_quarto_unavailable <- function() {
  env <- render_test_env
  old <- get("quarto_available", envir = env)
  was_locked <- bindingIsLocked("quarto_available", env)

  if (was_locked) {
    unlockBinding("quarto_available", env)
  }

  assign("quarto_available", function() FALSE, envir = env)

  withr::defer({
    if (bindingIsLocked("quarto_available", env)) {
      unlockBinding("quarto_available", env)
    }
    assign("quarto_available", old, envir = env)
    if (was_locked) {
      lockBinding("quarto_available", env)
    }
  })
}

primary_diag <- function(condition) {
  condition$diagnostics[[1]]
}

assert_runtime_diag <- function(condition) {
  diagnostic <- primary_diag(condition)
  expect_identical(diagnostic$code, "DIAG-RUNTIME-001")
  expect_identical(diagnostic$severity, "error")
  expect_true(is.list(diagnostic$location))
  expect_true(nzchar(diagnostic$hint))
}

test_that("render_pub() emits structured diagnostics when Quarto is unavailable", {
  render_pub <- get_render_fn("render_pub")
  mock_quarto_unavailable()

  condition <- expect_error(
    render_pub("paper.qmd", open = FALSE),
    class = "typstR_diagnostics_error"
  )

  assert_runtime_diag(condition)
  expect_match(conditionMessage(condition), "Quarto is not installed or not on PATH\\.", perl = TRUE)
})

test_that("render_working_paper() emits the same no-Quarto structured diagnostic", {
  render_working_paper <- get_render_fn("render_working_paper")
  mock_quarto_unavailable()

  condition <- expect_error(
    render_working_paper("paper.qmd", open = FALSE),
    class = "typstR_diagnostics_error"
  )

  assert_runtime_diag(condition)
  expect_match(conditionMessage(condition), "Quarto is not installed or not on PATH\\.", perl = TRUE)
})
