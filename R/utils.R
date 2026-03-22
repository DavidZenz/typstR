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

  if (fs::is_dir(input)) {
    qmd_files <- fs::dir_ls(input, glob = "*.qmd")
    if (length(qmd_files) == 0) {
      cli::cli_abort(c(
        "No .qmd file found in {.path {input}}.",
        "i" = "Specify the path to a .qmd file directly."
      ))
    }
    if (length(qmd_files) > 1) {
      cli::cli_abort(c(
        "Multiple .qmd files found in {.path {input}}.",
        "i" = "Specify which .qmd file to render.",
        "*" = "Found: {.file {fs::path_file(qmd_files)}}"
      ))
    }
    input <- qmd_files[[1]]
  }

  if (!fs::file_exists(input)) {
    cli::cli_abort("File {.path {input}} does not exist.")
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
