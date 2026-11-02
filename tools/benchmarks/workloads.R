# Developer-only workloads. Load the package with pkgload before sourcing.
.perf_quarto_available <- function() quarto::quarto_available()

.perf_validation_fixture <- local({
  project <- NULL
  function() {
    if (is.null(project)) {
      project <<- tempfile("benchmark-environment-")
      create_working_paper(project, open = FALSE)
    }
    project
  }
})

.perf_passing_checks <- function(path) list(
  quarto = list(ok = TRUE, available = TRUE, version = "1.5.1"),
  typst = list(ok = TRUE, available = TRUE, version = "0.13.1", raw = "typst 0.13.1"),
  quarto_floor = list(ok = TRUE, required = ">=1.4.11", compatible = TRUE, available = TRUE),
  extension = list(ok = TRUE, present = TRUE,
                   manifest = file.path(path, "_extensions", "typstR", "_extension.yml"))
)

.perf_run_scenario <- function(scenario_id) {
  if (scenario_id == "perf-create-working-paper-baseline") {
    testthat::local_mocked_bindings(scaffold_emit_success = function(...) invisible(NULL),
                                   .package = "typstR")
    return(create_working_paper(tempfile("benchmark-scaffold-"),
                                title = "Benchmark project", open = FALSE))
  }
  project <- .perf_validation_fixture()
  if (scenario_id == "perf-collect-environment-checks") {
    testthat::local_mocked_bindings(
      probe_quarto = function() .perf_passing_checks(project)$quarto,
      probe_typst = function(quarto_check) .perf_passing_checks(project)$typst,
      probe_quarto_floor = function(quarto_check, required) .perf_passing_checks(project)$quarto_floor,
      probe_extension = function(path) .perf_passing_checks(path)$extension,
      required_quarto_floor = function() ">=1.4.11", .package = "typstR")
    return(typstR:::collect_environment_checks(project))
  }
  if (scenario_id == "perf-validate-render-environment") {
    testthat::local_mocked_bindings(collect_environment_checks = .perf_passing_checks,
                                   .package = "typstR")
    return(validate_render_environment(project))
  }
  stop("Unknown benchmark scenario: ", scenario_id)
}

.perf_benchmark_summary <- function(result) {
  times <- as.numeric(result$time[[1]]) * 1000
  list(p50_ms = unname(stats::quantile(times, 0.5)),
       p95_ms = unname(stats::quantile(times, 0.95)))
}

# Retained only for explicit historical baseline derivation.
.perf_measure_median_ms <- function(expr, iterations = 15L) {
  expr <- substitute(expr)
  caller <- parent.frame()
  result <- bench::mark(eval(expr, caller), iterations = iterations, check = FALSE)
  .perf_benchmark_summary(result)$p50_ms
}
