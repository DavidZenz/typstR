.perf_baseline_read_yaml <- function(path) {
  expect_true(file.exists(path), info = paste("Missing performance artifact:", path))
  yaml::read_yaml(path)
}

.perf_baseline_map <- function() {
  .perf_baseline_read_yaml("tests/testthat/perf-scenario-map.yml")
}

.perf_v1_baseline <- function() {
  .perf_baseline_read_yaml("tests/testthat/perf-v1-baseline.yml")
}

.perf_current_baseline <- function() {
  .perf_baseline_read_yaml("tests/testthat/perf-baseline.yml")
}

test_that("smoke: performance scenario map declares required contract fields", {
  map <- .perf_baseline_map()
  scenarios <- map$scenarios

  expect_true(is.list(scenarios))
  expect_true(length(scenarios) >= 3)

  required_fields <- c(
    "scenario_id",
    "v1_baseline_key",
    "current_baseline_key",
    "slowdown_tolerance",
    "gain_target_ratio"
  )

  for (entry in scenarios) {
    expect_true(all(required_fields %in% names(entry)), info = entry$scenario_id)
  }
})

test_that("smoke: scenario map keys resolve in both baseline artifacts", {
  map <- .perf_baseline_map()
  v1 <- .perf_v1_baseline()
  current <- .perf_current_baseline()

  for (entry in map$scenarios) {
    expect_true(entry$v1_baseline_key %in% names(v1$scenarios), info = entry$scenario_id)
    expect_true(entry$current_baseline_key %in% names(current$scenarios), info = entry$scenario_id)
  }
})

test_that("contract: v1 baseline records source tag and numeric medians", {
  map <- .perf_baseline_map()
  v1 <- .perf_v1_baseline()

  expect_identical(v1$source_tag, "v1.0")

  for (entry in map$scenarios) {
    baseline_row <- v1$scenarios[[entry$v1_baseline_key]]
    expect_true(is.numeric(baseline_row$median_ms), info = entry$scenario_id)
    expect_true(is.finite(baseline_row$median_ms), info = entry$scenario_id)
  }
})

test_that("contract: current baseline map defines numeric policy fields", {
  map <- .perf_baseline_map()
  current <- .perf_current_baseline()

  for (entry in map$scenarios) {
    baseline_row <- current$scenarios[[entry$current_baseline_key]]

    expect_true(is.numeric(baseline_row$median_ms), info = entry$scenario_id)
    expect_true(is.finite(baseline_row$median_ms), info = entry$scenario_id)
    expect_true(is.numeric(entry$slowdown_tolerance), info = entry$scenario_id)
    expect_true(is.numeric(entry$gain_target_ratio), info = entry$scenario_id)
    expect_gt(entry$slowdown_tolerance, 0, info = entry$scenario_id)
    expect_gt(entry$gain_target_ratio, 0, info = entry$scenario_id)
  }
})
