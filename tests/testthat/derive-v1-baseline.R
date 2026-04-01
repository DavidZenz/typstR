repo_root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
map_path <- file.path(repo_root, "tests", "testthat", "perf-scenario-map.yml")
helper_path <- file.path(repo_root, "tests", "testthat", "helper-performance.R")

if (!file.exists(map_path)) {
  stop("Missing tests/testthat/perf-scenario-map.yml", call. = FALSE)
}
if (!file.exists(helper_path)) {
  stop("Missing tests/testthat/helper-performance.R", call. = FALSE)
}

source(helper_path, local = TRUE)
scenario_map <- yaml::read_yaml(map_path)$scenarios

if (!is.list(scenario_map) || length(scenario_map) == 0) {
  stop("Scenario map is empty.", call. = FALSE)
}

measure_current_baseline <- function(entry) {
  .perf_measure_median_ms(.perf_run_scenario(entry$scenario_id), iterations = 15L)
}

new_v1_env <- function(worktree) {
  env <- new.env(parent = baseenv())

  local_system_file <- function(..., package = NULL, mustWork = FALSE) {
    rel <- file.path(...)
    if (identical(package, "typstR")) {
      candidate <- file.path(worktree, "inst", rel)
      if (dir.exists(candidate) || file.exists(candidate)) {
        return(candidate)
      }
    }

    base::system.file(..., package = package, mustWork = mustWork)
  }

  assign("system.file", local_system_file, envir = env)
  source(file.path(worktree, "R", "utils.R"), local = env)
  source(file.path(worktree, "R", "render.R"), local = env)
  source(file.path(worktree, "R", "create_working_paper.R"), local = env)

  env
}

run_v1_scenario <- function(env, baseline_key) {
  switch(
    baseline_key,
    v1_quarto_available_check = {
      env$quarto_available()
    },
    v1_resolve_input_directory = {
      fixture <- tempfile("v1-resolve-")
      dir.create(fixture)
      writeLines(c("---", "title: \"Benchmark\"", "---", "", "Body"), file.path(fixture, "template.qmd"))
      env$resolve_input(fixture)
    },
    v1_create_working_paper = {
      project <- tempfile("v1-working-paper-")
      env$create_working_paper(project, title = "Benchmark project", open = FALSE)
    },
    stop(sprintf("Unsupported v1 baseline key: %s", baseline_key), call. = FALSE)
  )
}

measure_v1_baseline <- function(env, entry) {
  .perf_measure_median_ms(run_v1_scenario(env, entry$v1_baseline_key), iterations = 15L)
}

worktree <- tempfile("typstR-v1-worktree-")
add_output <- system2(
  "git",
  c("worktree", "add", "--detach", worktree, "v1.0"),
  stdout = TRUE,
  stderr = TRUE
)

if (!dir.exists(worktree)) {
  stop(
    paste(
      c("Could not create v1.0 worktree for baseline derivation.", add_output),
      collapse = "\n"
    ),
    call. = FALSE
  )
}

on.exit(system2("git", c("worktree", "remove", "--force", worktree), stdout = TRUE, stderr = TRUE), add = TRUE)

v1_env <- new_v1_env(worktree)

v1_scenarios <- list()
current_scenarios <- list()

for (entry in scenario_map) {
  current_median <- measure_current_baseline(entry)
  v1_median <- measure_v1_baseline(v1_env, entry)

  current_scenarios[[entry$current_baseline_key]] <- list(
    scenario_id = entry$scenario_id,
    median_ms = as.numeric(round(current_median, 6))
  )

  v1_scenarios[[entry$v1_baseline_key]] <- list(
    scenario_id = entry$scenario_id,
    median_ms = as.numeric(round(v1_median, 6))
  )
}

source_ref <- trimws(system2("git", c("rev-parse", "--short", "HEAD"), stdout = TRUE, stderr = FALSE)[1])
now <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")

current_payload <- list(
  source_ref = if (nzchar(source_ref)) source_ref else "unknown",
  generated_at = now,
  measurement_method = "proc.time median over 15 iterations",
  scenarios = current_scenarios
)

v1_payload <- list(
  source_tag = "v1.0",
  generated_at = now,
  measurement_method = "proc.time median over 15 iterations",
  scenarios = v1_scenarios
)

yaml::write_yaml(current_payload, file.path(repo_root, "tests", "testthat", "perf-baseline.yml"))
yaml::write_yaml(v1_payload, file.path(repo_root, "tests", "testthat", "perf-v1-baseline.yml"))

cat("Wrote tests/testthat/perf-baseline.yml and tests/testthat/perf-v1-baseline.yml\n")
