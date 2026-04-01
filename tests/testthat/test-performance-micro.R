# Performance micro-benchmarks for Phase 08 hotspot scenarios.

.perf_assert_low_noise <- function(result, scenario_id, max_ratio = 1.35) {
  stats <- .perf_benchmark_summary(result)
  expect_true(is.finite(stats$p50), info = paste(scenario_id, "p50 must be finite"))
  expect_true(is.finite(stats$p95), info = paste(scenario_id, "p95 must be finite"))
  expect_lte(stats$p95 / stats$p50, max_ratio, info = paste(scenario_id, "noise bound exceeded"))
}

.perf_assert_scaffold_outputs <- function(project_path, label) {
  expect_true(file.exists(file.path(project_path, "template.qmd")), info = label)
  expect_true(file.exists(file.path(project_path, "_quarto.yml")), info = label)
  expect_true(file.exists(file.path(project_path, "references.bib")), info = label)
  expect_true(file.exists(file.path(project_path, "_extensions", "typstR", "_extension.yml")), info = label)
}

test_that("micro: D-01 scenario perf-collect-environment-checks is deterministic", {
  .perf_skip_if_bench_missing()

  result <- bench::mark(
    perf_collect_environment_checks = .perf_run_collect_environment_checks(),
    iterations = 60,
    min_iterations = 30,
    check = FALSE
  )

  .perf_assert_low_noise(result, "perf-collect-environment-checks")
})

test_that("micro: D-02 scenario perf-validate-render-environment is deterministic", {
  .perf_skip_if_bench_missing()

  result <- bench::mark(
    perf_validate_render_environment = .perf_run_validate_render_environment(),
    iterations = 60,
    min_iterations = 30,
    check = FALSE
  )

  .perf_assert_low_noise(result, "perf-validate-render-environment")
})

test_that("micro: D-04 scenario perf-create-working-paper-baseline is deterministic", {
  .perf_skip_if_bench_missing()

  result <- bench::mark(
    perf_create_working_paper = .perf_run_create_working_paper(),
    iterations = 60,
    min_iterations = 30,
    check = FALSE
  )

  .perf_assert_low_noise(result, "perf-create-working-paper-baseline")
})

test_that("micro: scaffold helper matrix executes symmetric helper calls", {
  specs <- .perf_scaffold_specs()

  expect_equal(
    vapply(specs, `[[`, character(1), "fn_name"),
    c("create_working_paper", "create_article", "create_policy_brief")
  )

  for (spec in specs) {
    helper <- .perf_get_create_fn(spec$fn_name)
    fixture <- .perf_new_scaffold_fixture(spec$project_prefix)
    helper(fixture$project, title = paste("Symmetry", spec$label), open = FALSE)
    .perf_assert_scaffold_outputs(fixture$project, spec$label)
  }
})

test_that("smoke: perf-collect-environment-checks scenario stays low-noise", {
  .perf_skip_if_bench_missing()

  result <- bench::mark(
    perf_collect_environment_checks = .perf_run_collect_environment_checks(),
    iterations = 8,
    min_iterations = 4,
    check = FALSE
  )

  .perf_assert_low_noise(result, "perf-collect-environment-checks")
})

test_that("smoke: perf-validate-render-environment scenario stays low-noise", {
  .perf_skip_if_bench_missing()

  result <- bench::mark(
    perf_validate_render_environment = .perf_run_validate_render_environment(),
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

  # Smoke matrix symmetry for article/policy-brief helper call paths.
  for (spec in specs[-1]) {
    helper <- .perf_get_create_fn(spec$fn_name)
    fixture <- .perf_new_scaffold_fixture(spec$project_prefix)
    helper(fixture$project, title = paste("Smoke", spec$label), open = FALSE)
    .perf_assert_scaffold_outputs(fixture$project, spec$label)
  }

  .perf_skip_if_bench_missing()

  result <- bench::mark(
    perf_create_working_paper = .perf_run_create_working_paper(),
    iterations = 6,
    min_iterations = 3,
    check = FALSE
  )

  .perf_assert_low_noise(result, "perf-create-working-paper-baseline")
})
