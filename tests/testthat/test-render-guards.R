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
  source(resolve_render_source_file("R/validation_environment.R"), local = env)
  source(resolve_render_source_file("R/utils.R"), local = env)
  source(resolve_render_source_file("R/render.R"), local = env)
  env
})

get_render_fn <- function(name) {
  get(name, envir = render_test_env, inherits = FALSE)
}

mock_environment_unavailable <- function() {
  env <- render_test_env
  assign("collect_environment_checks", function(path) {
    location <- as.character(fs::path_abs(path))
    list(
      quarto = list(ok = FALSE, available = FALSE, version = NA_character_, reason = "quarto CLI unavailable"),
      typst = list(ok = FALSE, available = FALSE, version = NA_character_, raw = NA_character_, reason = "quarto typst --version failed"),
      quarto_floor = list(ok = FALSE, required = ">=1.4.11", compatible = FALSE, available = FALSE),
      extension = list(ok = TRUE, present = TRUE, manifest = file.path(location, "_extensions", "typstR", "_extension.yml"))
    )
  }, envir = env)
}

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
  render_pub <- get_render_fn("render_pub")
  mock_environment_unavailable()

  condition <- expect_error(
    render_pub("paper.qmd", open = FALSE),
    class = "typstR_diagnostics_error"
  )

  assert_env_diag(condition)
  expect_match(conditionMessage(condition), "Quarto is not installed or not on PATH\\.", perl = TRUE)
})

test_that("render_working_paper() emits the same no-Quarto structured diagnostic", {
  render_working_paper <- get_render_fn("render_working_paper")
  mock_environment_unavailable()

  condition <- expect_error(
    render_working_paper("paper.qmd", open = FALSE),
    class = "typstR_diagnostics_error"
  )

  assert_env_diag(condition)
  expect_match(conditionMessage(condition), "Quarto is not installed or not on PATH\\.", perl = TRUE)
})
