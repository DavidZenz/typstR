# Performance micro-benchmarks for Phase 08 hotspot scenarios.

.perf_scenario_collect_environment_checks <- function() {
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

.perf_scenario_validate_render_environment <- function() {
  fixture <- .perf_new_validation_fixture()
  validate_render_environment <- .perf_get_validation_fn("validate_render_environment")

  .perf_with_validation_bindings(
    list(collect_environment_checks = function(path) .perf_passing_checks(path)),
    validate_render_environment(fixture$project)
  )
}

.perf_scenario_create_working_paper <- function() {
  fixture <- .perf_new_scaffold_fixture()
  create_working_paper <- .perf_get_create_fn("create_working_paper")
  create_working_paper(fixture$project, title = "Benchmark project", open = FALSE)
}

.perf_assert_low_noise <- function(result, scenario_id, max_ratio = 1.35) {
  stats <- .perf_benchmark_summary(result)
  expect_true(is.finite(stats$p50), info = paste(scenario_id, "p50 must be finite"))
  expect_true(is.finite(stats$p95), info = paste(scenario_id, "p95 must be finite"))
  expect_lte(stats$p95 / stats$p50, max_ratio, info = paste(scenario_id, "noise bound exceeded"))
}

test_that("micro: D-01 scenario perf-collect-environment-checks is deterministic", {
  .perf_skip_if_bench_missing()

  result <- bench::mark(
    perf_collect_environment_checks = .perf_scenario_collect_environment_checks(),
    iterations = 60,
    min_iterations = 30,
    check = FALSE
  )

  .perf_assert_low_noise(result, "perf-collect-environment-checks")
})

test_that("micro: D-02 scenario perf-validate-render-environment is deterministic", {
  .perf_skip_if_bench_missing()

  result <- bench::mark(
    perf_validate_render_environment = .perf_scenario_validate_render_environment(),
    iterations = 60,
    min_iterations = 30,
    check = FALSE
  )

  .perf_assert_low_noise(result, "perf-validate-render-environment")
})

test_that("micro: D-04 scenario perf-create-working-paper-baseline is deterministic", {
  .perf_skip_if_bench_missing()

  result <- bench::mark(
    perf_create_working_paper = .perf_scenario_create_working_paper(),
    iterations = 60,
    min_iterations = 30,
    check = FALSE
  )

  .perf_assert_low_noise(result, "perf-create-working-paper-baseline")
})

test_that("micro: scaffold helper matrix remains symmetric", {
  specs <- .perf_scaffold_specs()

  expect_equal(
    vapply(specs, `[[`, character(1), "fn_name"),
    c("create_working_paper", "create_article", "create_policy_brief")
  )

  expect_equal(
    vapply(specs, `[[`, character(1), "label"),
    c("working paper", "article", "policy brief")
  )
})

test_that("smoke: perf-collect-environment-checks scenario stays low-noise", {
  .perf_skip_if_bench_missing()

  result <- bench::mark(
    perf_collect_environment_checks = .perf_scenario_collect_environment_checks(),
    iterations = 8,
    min_iterations = 4,
    check = FALSE
  )

  .perf_assert_low_noise(result, "perf-collect-environment-checks")
})

test_that("smoke: perf-validate-render-environment scenario stays low-noise", {
  .perf_skip_if_bench_missing()

  result <- bench::mark(
    perf_validate_render_environment = .perf_scenario_validate_render_environment(),
    iterations = 8,
    min_iterations = 4,
    check = FALSE
  )

  .perf_assert_low_noise(result, "perf-validate-render-environment")
})

test_that("smoke: perf-create-working-paper-baseline scenario matrix still resolves", {
  specs <- .perf_scaffold_specs()
  expect_equal(length(specs), 3L)
  expect_true(all(vapply(specs, function(spec) nzchar(spec$project_prefix), logical(1))))

  .perf_skip_if_bench_missing()

  result <- bench::mark(
    perf_create_working_paper = .perf_scenario_create_working_paper(),
    iterations = 6,
    min_iterations = 3,
    check = FALSE
  )

  .perf_assert_low_noise(result, "perf-create-working-paper-baseline")
})
