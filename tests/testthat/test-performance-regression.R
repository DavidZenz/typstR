.perf_regression_path <- function(filename) {
  candidates <- c(
    file.path("tests", "testthat", filename),
    filename,
    file.path("..", filename),
    file.path("..", "..", "tests", "testthat", filename),
    file.path(getwd(), "tests", "testthat", filename)
  )

  existing <- candidates[file.exists(candidates)]
  expect_true(length(existing) > 0, info = paste("Missing performance artifact:", filename))

  normalizePath(existing[[1]], winslash = "/", mustWork = TRUE)
}

.perf_regression_map <- function() {
  yaml::read_yaml(.perf_regression_path("perf-scenario-map.yml"))$scenarios
}

.perf_regression_current_baseline <- function() {
  yaml::read_yaml(.perf_regression_path("perf-baseline.yml"))$scenarios
}

test_that("regression: hotspot scenarios do not backslide beyond calibrated tolerance", {
  .perf_skip_if_bench_missing()

  scenario_map <- Filter(
    function(entry) !grepl("^perf-create-", entry$scenario_id),
    .perf_regression_map()
  )
  current_baseline <- .perf_regression_current_baseline()

  for (entry in scenario_map) {
    baseline_median_ms <- as.numeric(current_baseline[[entry$current_baseline_key]]$median_ms)
    allowed_median_ms <- baseline_median_ms * (1 + as.numeric(entry$slowdown_tolerance))
    current_median_ms <- .perf_measure_median_ms(.perf_run_scenario(entry$scenario_id), iterations = 15L)

    expect_true(
      current_median_ms <= allowed_median_ms,
      info = sprintf(
        "%s median %.3fms exceeded allowed %.3fms",
        entry$scenario_id,
        current_median_ms,
        allowed_median_ms
      )
    )
  }
})
