# Manual, reproducible benchmark report; ordinary package checks do not run this.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[[1]] else "artifacts/benchmark"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
stopifnot(requireNamespace("bench", quietly = TRUE))
pkgload::load_all(quiet = TRUE)
source("tests/testthat/helper-performance.R")
map <- yaml::read_yaml("tests/testthat/perf-scenario-map.yml")$scenarios
current <- yaml::read_yaml("tests/testthat/perf-baseline.yml")
v1 <- yaml::read_yaml("tests/testthat/perf-v1-baseline.yml")
writeLines(c(capture.output(sessionInfo()), paste("Recorded:", format(Sys.time(), tz = "UTC")),
             paste("Commit:", system2("git", c("rev-parse", "HEAD"), stdout = TRUE)),
             paste("CPU:", Sys.info()[["machine"]]),
             paste("Quarto:", if (.perf_quarto_available()) quarto::quarto_version() else "unavailable"),
             paste("Historical baseline source:", current$source_ref),
             "Historical baselines may use different hardware/toolchains. Ratios are investigation signals, not speed claims.",
             "Environment workloads mock external probes; scaffold workload copies real template/extension files."),
           file.path(out, "toolchain.txt"))
rows <- lapply(map, function(entry) {
  result <- bench::mark(.perf_run_scenario(entry$scenario_id), iterations = 60L, check = FALSE)
  timing <- .perf_benchmark_summary(result)
  old <- current$scenarios[[entry$current_baseline_key]]$median_ms
  reference <- v1$scenarios[[entry$v1_baseline_key]]$median_ms
  saveRDS(result, file.path(out, paste0(entry$scenario_id, ".rds")))
  data.frame(scenario = entry$scenario_id, iterations = 60L,
             p50_ms = timing$p50_ms, p95_ms = timing$p95_ms,
             current_baseline_ms = old, v1_baseline_ms = reference,
             baseline_ratio = timing$p50_ms / old,
             slowdown_limit = 1 + entry$slowdown_tolerance,
             requires_investigation = timing$p50_ms > old * (1 + entry$slowdown_tolerance))
})
report <- do.call(rbind, rows)
write.csv(report, file.path(out, "comparisons.csv"), row.names = FALSE)
print(report)
if (any(report$requires_investigation)) {
  message("Baseline tolerance exceeded: inspect workload/toolchain and repeat on comparable hardware. Do not reset baselines automatically.")
}
