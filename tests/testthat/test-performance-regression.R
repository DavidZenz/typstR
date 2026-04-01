.perf_regression_map <- function() {
  yaml::read_yaml("tests/testthat/perf-scenario-map.yml")$scenarios
}

.perf_regression_current_baseline <- function() {
  yaml::read_yaml("tests/testthat/perf-baseline.yml")$scenarios
}

test_that("regression: hotspot scenarios do not backslide beyond calibrated tolerance", {
  .perf_skip_if_bench_missing()

  scenario_map <- .perf_regression_map()
  current_baseline <- .perf_regression_current_baseline()

  for (entry in scenario_map) {
    result <- .perf_benchmark(.perf_run_scenario(entry$scenario_id))
    stats <- .perf_benchmark_summary(result)

    baseline_median_ms <- as.numeric(current_baseline[[entry$current_baseline_key]]$median_ms)
    allowed_median_ms <- baseline_median_ms * (1 + as.numeric(entry$slowdown_tolerance))

    expect_lte(
      stats$p50_ms,
      allowed_median_ms,
      info = sprintf(
        "%s median %.3fms exceeded allowed %.3fms",
        entry$scenario_id,
        stats$p50_ms,
        allowed_median_ms
      )
    )
  }
})
