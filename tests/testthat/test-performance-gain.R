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
  wanted <- c("perf-collect-environment-checks")
  Filter(function(entry) entry$scenario_id %in% wanted, entries)
}

.perf_gain_scaffold_entries <- function() {
  list()
}

 .perf_gain_entry_for <- function(scenario_id) {
  entry <- Filter(function(candidate) identical(candidate$scenario_id, scenario_id), .perf_gain_map())
  expect_true(length(entry) == 1L, info = paste("Missing scenario mapping:", scenario_id))
  entry[[1]]
}

.perf_measure_gain_current_ms <- function(scenario_id, iterations = 15L) {
  .perf_measure_median_ms(.perf_run_scenario(scenario_id), iterations = iterations)
}

.perf_assert_gain_target <- function(entry, iterations = 15L) {
  v1_baseline <- .perf_gain_v1_baseline()

  v1_baseline_ms <- as.numeric(v1_baseline[[entry$v1_baseline_key]]$median_ms)
  gain_target_ratio <- as.numeric(entry$gain_target_ratio)
  current_median_ms <- .perf_measure_gain_current_ms(entry$scenario_id, iterations = iterations)

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
    .perf_assert_gain_target(entry)
  }
})

test_that("smoke: validation hotspot beats mapped v1 baseline target", {
  .perf_skip_if_bench_missing()

  entry <- .perf_gain_entry_for("perf-collect-environment-checks")
  .perf_assert_gain_target(entry, iterations = 6L)
})
