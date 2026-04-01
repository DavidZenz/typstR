.perf_gain_path <- function(filename) {
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

.perf_gain_map <- function() {
  yaml::read_yaml(.perf_gain_path("perf-scenario-map.yml"))$scenarios
}

.perf_gain_v1_baseline <- function() {
  yaml::read_yaml(.perf_gain_path("perf-v1-baseline.yml"))$scenarios
}

.perf_gain_validation_render_entries <- function() {
  entries <- .perf_gain_map()
  wanted <- c("perf-collect-environment-checks", "perf-validate-render-environment")
  Filter(function(entry) entry$scenario_id %in% wanted, entries)
}

.perf_assert_gain_target <- function(entry, benchmark_fun) {
  v1_baseline <- .perf_gain_v1_baseline()

  result <- benchmark_fun(.perf_run_scenario(entry$scenario_id))
  stats <- .perf_benchmark_summary(result)

  v1_baseline_ms <- as.numeric(v1_baseline[[entry$v1_baseline_key]]$median_ms)
  gain_target_ratio <- as.numeric(entry$gain_target_ratio)
  current_median_ms <- stats$p50_ms

  expect_true(
    current_median_ms <= v1_baseline_ms * gain_target_ratio,
    info = sprintf(
      "%s median %.3fms exceeded gain target %.3fms",
      entry$scenario_id,
      current_median_ms,
      v1_baseline_ms * gain_target_ratio
    )
  )
}

test_that("gain: validation/render hotspots beat mapped v1 baseline targets", {
  .perf_skip_if_bench_missing()

  for (entry in .perf_gain_validation_render_entries()) {
    .perf_assert_gain_target(entry, .perf_benchmark)
  }
})

test_that("smoke: validation hotspot beats mapped v1 baseline target", {
  .perf_skip_if_bench_missing()

  entry <- Filter(function(candidate) candidate$scenario_id == "perf-collect-environment-checks", .perf_gain_validation_render_entries())[[1]]
  .perf_assert_gain_target(entry, function(expr) .perf_benchmark_smoke(expr, iterations = 6, min_iterations = 3))
})

test_that("smoke: render hotspot beats mapped v1 baseline target", {
  .perf_skip_if_bench_missing()

  entry <- Filter(function(candidate) candidate$scenario_id == "perf-validate-render-environment", .perf_gain_validation_render_entries())[[1]]
  .perf_assert_gain_target(entry, function(expr) .perf_benchmark_smoke(expr, iterations = 6, min_iterations = 3))
})
