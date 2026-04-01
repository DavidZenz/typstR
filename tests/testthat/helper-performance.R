.perf_skip_if_bench_missing <- function() {
  testthat::skip_if_not_installed("bench")
}

.perf_quarto_available <- function() {
  requireNamespace("quarto", quietly = TRUE) && quarto::quarto_available()
}

.perf_skip_if_no_quarto <- function() {
  testthat::skip_if_not(.perf_quarto_available())
}

.perf_repo_root <- local({
  cached <- NULL

  function() {
    if (!is.null(cached)) {
      return(cached)
    }

    candidates <- c(
      getwd(),
      file.path(getwd(), ".."),
      file.path(getwd(), "..", "..")
    )

    for (candidate in candidates) {
      normalized <- normalizePath(candidate, winslash = "/", mustWork = FALSE)
      if (file.exists(file.path(normalized, "DESCRIPTION")) &&
          dir.exists(file.path(normalized, "R")) &&
          dir.exists(file.path(normalized, "inst"))) {
        cached <<- normalized
        return(cached)
      }
    }

    stop("Could not locate repository root for performance tests.", call. = FALSE)
  }
})

.perf_resolve_source_file <- function(relative_path, must_exist = TRUE) {
  candidates <- c(
    relative_path,
    file.path("..", "..", relative_path),
    file.path(.perf_repo_root(), relative_path)
  )

  existing <- candidates[file.exists(candidates)]
  if (length(existing) == 0) {
    if (!must_exist) {
      return(NA_character_)
    }
    stop(sprintf("Could not locate %s", relative_path), call. = FALSE)
  }

  normalizePath(existing[[1]], winslash = "/", mustWork = TRUE)
}

.perf_validation_env <- local({
  env <- new.env(parent = baseenv())
  source(.perf_resolve_source_file("R/diagnostics.R"), local = env)
  source(.perf_resolve_source_file("R/validation_environment.R"), local = env)
  env
})

.perf_with_validation_bindings <- function(bindings, code) {
  env <- .perf_validation_env
  restore <- list()

  for (name in names(bindings)) {
    had_existing <- exists(name, envir = env, inherits = FALSE)
    restore[[name]] <- if (had_existing) get(name, envir = env, inherits = FALSE) else NULL
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

.perf_get_validation_fn <- function(name) {
  if (!exists(name, envir = .perf_validation_env, inherits = FALSE)) {
    stop(sprintf("Could not find %s in performance validation environment", name), call. = FALSE)
  }

  get(name, envir = .perf_validation_env, inherits = FALSE)
}

.perf_passing_checks <- function(path) {
  list(
    quarto = list(ok = TRUE, available = TRUE, version = "1.5.1"),
    typst = list(ok = TRUE, available = TRUE, version = "0.13.1", raw = "typst 0.13.1", status = 0L),
    quarto_floor = list(ok = TRUE, required = ">=1.4.11", min_version = "1.4.11", compatible = TRUE, available = TRUE),
    extension = list(
      ok = TRUE,
      present = TRUE,
      manifest = as.character(fs::path_abs(file.path(path, "_extensions", "typstR", "_extension.yml")))
    )
  )
}

.perf_extension_source <- function() {
  installed <- system.file("quarto", "extensions", "typstR", package = "typstR")
  if (nzchar(installed) && dir.exists(installed)) {
    return(installed)
  }

  .perf_resolve_source_file("inst/quarto/extensions/typstR")
}

.perf_copy_extension <- function(dest_dir) {
  ext_dest_parent <- file.path(dest_dir, "_extensions")
  dir.create(ext_dest_parent, showWarnings = FALSE, recursive = TRUE)

  fs::dir_copy(.perf_extension_source(), file.path(ext_dest_parent, "typstR"))

  invisible(file.path(ext_dest_parent, "typstR", "_extension.yml"))
}

.perf_new_validation_fixture <- function() {
  project <- tempfile("perf-validation-")
  dir.create(project)
  .perf_copy_extension(project)
  list(project = project)
}

.perf_create_env <- local({
  env <- new.env(parent = baseenv())
  repo_root <- .perf_repo_root()

  local_system_file <- function(..., package = NULL, mustWork = FALSE) {
    rel <- file.path(...)
    if (identical(package, "typstR")) {
      candidate <- file.path(repo_root, "inst", rel)
      if (dir.exists(candidate) || file.exists(candidate)) {
        return(candidate)
      }
    }

    base::system.file(..., package = package, mustWork = mustWork)
  }

  assign("system.file", local_system_file, envir = env)
  source(file.path(repo_root, "R", "create_working_paper.R"), local = env)
  source(file.path(repo_root, "R", "create_article.R"), local = env)
  source(file.path(repo_root, "R", "create_policy_brief.R"), local = env)

  env
})

.perf_get_create_fn <- function(name) {
  if (!exists(name, envir = .perf_create_env, inherits = FALSE)) {
    stop(sprintf("Could not find %s in performance create-helper environment", name), call. = FALSE)
  }

  get(name, envir = .perf_create_env, inherits = FALSE)
}

.perf_new_scaffold_fixture <- function(prefix = "perf-working-paper-") {
  list(project = tempfile(prefix))
}

.perf_scaffold_specs <- function() {
  list(
    list(label = "working paper", fn_name = "create_working_paper", project_prefix = "perf-working-paper-"),
    list(label = "article", fn_name = "create_article", project_prefix = "perf-article-"),
    list(label = "policy brief", fn_name = "create_policy_brief", project_prefix = "perf-policy-brief-")
  )
}

.perf_run_collect_environment_checks <- function() {
  fixture <- .perf_new_validation_fixture()
  collect_environment_checks <- .perf_get_validation_fn("collect_environment_checks")

  .perf_with_validation_bindings(
    list(
      probe_quarto = function() list(ok = TRUE, available = TRUE, version = "1.5.1"),
      probe_typst = function(quarto_check) {
        list(ok = TRUE, available = TRUE, version = "0.13.1", raw = "typst 0.13.1", status = 0L)
      },
      probe_quarto_floor = function(quarto_check, required) {
        list(ok = TRUE, required = required, min_version = "1.4.11", compatible = TRUE, available = TRUE)
      },
      probe_extension = function(path) {
        list(ok = TRUE, present = TRUE, manifest = file.path(path, "_extensions", "typstR", "_extension.yml"))
      },
      required_quarto_floor = function() ">=1.4.11"
    ),
    collect_environment_checks(fixture$project)
  )
}


 .perf_run_validate_render_environment <- function() {
  fixture <- .perf_new_validation_fixture()
  validate_render_environment <- .perf_get_validation_fn("validate_render_environment")

  .perf_with_validation_bindings(
    list(collect_environment_checks = function(path) .perf_passing_checks(path)),
    validate_render_environment(fixture$project)
  )
}

 .perf_run_create_working_paper <- function() {
  create_working_paper <- .perf_get_create_fn("create_working_paper")
  create_working_paper(.perf_new_scaffold_fixture()$project, title = "Benchmark project", open = FALSE)
}

 .perf_run_scenario <- function(scenario_id) {
  switch(
    scenario_id,
    "perf-collect-environment-checks" = .perf_run_collect_environment_checks(),
    "perf-validate-render-environment" = .perf_run_validate_render_environment(),
    "perf-create-working-paper-baseline" = .perf_run_create_working_paper(),
    stop(sprintf("Unknown performance scenario: %s", scenario_id), call. = FALSE)
  )
}

.perf_measure_median_ms <- function(expr, iterations = 15L) {
  expr <- substitute(expr)
  eval_env <- parent.frame()

  timings <- replicate(
    iterations,
    {
      start <- proc.time()[["elapsed"]]
      eval(expr, envir = eval_env)
      (proc.time()[["elapsed"]] - start) * 1000
    },
    simplify = TRUE
  )

  stats::median(as.numeric(timings), na.rm = TRUE)
}

.perf_benchmark <- function(expr) {
  expr <- substitute(expr)

  bench::mark(
    result = eval(expr, envir = parent.frame()),
    iterations = 60,
    min_iterations = 30,
    check = FALSE
  )
}

.perf_benchmark_smoke <- function(expr, iterations = 8, min_iterations = 4) {
  expr <- substitute(expr)

  bench::mark(
    result = eval(expr, envir = parent.frame()),
    iterations = iterations,
    min_iterations = min_iterations,
    check = FALSE
  )
}

.perf_benchmark_summary <- function(result, expression = 1L) {
  times <- as.numeric(result$time[[expression]], units = "s")

  p50 <- stats::quantile(times, probs = 0.50, names = FALSE)
  p95 <- stats::quantile(times, probs = 0.95, names = FALSE)

  list(
    p50 = as.numeric(p50),
    p95 = as.numeric(p95),
    p50_ms = as.numeric(p50) * 1000,
    p95_ms = as.numeric(p95) * 1000
  )
}
