resolve_validation_source_file <- function(relative_path, must_exist = TRUE) {
  candidates <- c(
    relative_path,
    file.path("..", "..", relative_path),
    file.path(getwd(), relative_path)
  )

  existing <- candidates[file.exists(candidates)]
  if (length(existing) == 0) {
    if (!must_exist) {
      return(NA_character_)
    }

    stop(sprintf("Could not locate %s", relative_path))
  }

  normalizePath(existing[[1]], winslash = "/", mustWork = TRUE)
}

validation_test_env <- local({
  env <- new.env(parent = baseenv())
  source(resolve_validation_source_file("R/diagnostics.R"), local = env)

  validation_source <- resolve_validation_source_file(
    "R/validation_environment.R",
    must_exist = FALSE
  )
  if (!is.na(validation_source)) {
    source(validation_source, local = env)
  }

  env
})

get_validation_fn <- function(name) {
  if (!exists(name, envir = validation_test_env, inherits = FALSE)) {
    stop(sprintf("Could not find %s in validation test environment", name), call. = FALSE)
  }

  get(name, envir = validation_test_env, inherits = FALSE)
}
