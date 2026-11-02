#' Resolve input file path
#'
#' If input is NULL, looks for a .qmd file in the current directory.
#' If input is a directory, looks for a .qmd file inside it.
#' If input is a file, returns it as-is.
#'
#' @param input File path, directory path, or NULL.
#' @return Resolved path to a .qmd file.
#' @noRd
resolve_input <- function(input) {
  if (is.null(input)) {
    input <- "."
  }

  if (!is.character(input) || length(input) != 1L || is.na(input) || !nzchar(input)) {
    cli::cli_abort("{.arg input} must be NULL or a single non-empty path.")
  }

  abort_input_diagnostic <- function(issue_key, message, hint, location_file, details = NULL) {
    code <- diagnostics_codebook()[[issue_key]]
    diagnostic <- new_diagnostic(
      code = code,
      severity = "error",
      location = list(file = as.character(fs::path_abs(location_file))),
      hint = hint,
      message = message,
      details = details
    )

    emit_diagnostics_error(
      diagnostics = list(diagnostic),
      message = message,
      hint = hint
    )
  }

  if (fs::is_dir(input)) {
    qmd_files <- fs::dir_ls(input, glob = "*.qmd")
    if (length(qmd_files) == 0) {
      abort_input_diagnostic(
        issue_key = "no_qmd_found",
        message = sprintf("No .qmd file found in '%s'.", input),
        hint = "Specify the path to a .qmd file directly.",
        location_file = input
      )
    }
    if (length(qmd_files) > 1) {
      abort_input_diagnostic(
        issue_key = "multiple_qmd_found",
        message = sprintf("Multiple .qmd files found in '%s'.", input),
        hint = "Specify which .qmd file to render.",
        location_file = input,
        details = list(found = sort(as.character(fs::path_file(qmd_files))))
      )
    }
    input <- qmd_files[[1]]
  }

  if (!fs::file_exists(input)) {
    abort_input_diagnostic(
      issue_key = "input_not_found",
      message = sprintf("File '%s' does not exist.", input),
      hint = "Check the file path and try again.",
      location_file = input
    )
  }

  if (!identical(tolower(fs::path_ext(input)), "qmd")) {
    abort_input_diagnostic(
      issue_key = "input_not_found",
      message = "Input must be a .qmd manuscript.",
      hint = "Specify an existing .qmd file or a directory containing one.",
      location_file = input
    )
  }

  as.character(fs::path_real(input))
}

# Resolve from the manuscript, never from the caller's working directory. The
# nearest project configuration is the boundary for extension discovery.
resolve_render_context <- function(input) {
  manuscript <- resolve_input(input)
  manuscript_dir <- dirname(manuscript)
  current <- manuscript_dir
  extension_dir <- NULL
  project_file <- NULL

  repeat {
    if (is.null(extension_dir) && file.exists(file.path(current, "_extensions", "typstR", "_extension.yml"))) {
      extension_dir <- current
    }
    configs <- file.path(current, c("_quarto.yml", "_quarto.yaml"))
    configs <- configs[file.exists(configs)]
    if (length(configs)) {
      project_file <- configs[[1]]
      break
    }
    parent <- dirname(current)
    if (identical(parent, current)) break
    current <- parent
  }

  project_dir <- if (is.null(project_file)) manuscript_dir else dirname(project_file)
  list(
    input = manuscript,
    manuscript_dir = manuscript_dir,
    project_dir = project_dir,
    project_file = project_file,
    extension_dir = if (is.null(extension_dir)) project_dir else extension_dir
  )
}

#' Open a file in the system viewer
#'
#' @param path Path to the file to open.
#' @noRd
open_file <- function(path) {
  if (fs::file_exists(path)) {
    utils::browseURL(path)
  }
}
