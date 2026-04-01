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

  as.character(fs::path_real(input))
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
