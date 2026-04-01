diagnostics_source_file <- function() {
  candidates <- c(
    "R/diagnostics.R",
    "../../R/diagnostics.R",
    file.path(getwd(), "R", "diagnostics.R")
  )

  existing <- candidates[file.exists(candidates)]
  if (length(existing) == 0) {
    stop("Could not locate R/diagnostics.R")
  }

  normalizePath(existing[[1]], winslash = "/", mustWork = TRUE)
}

diagnostics_env <- function() {
  env <- new.env(parent = baseenv())
  source(diagnostics_source_file(), local = env)
  env
}

get_diagnostics_fn <- function(name) {
  get(name, envir = diagnostics_env(), inherits = FALSE)
}
