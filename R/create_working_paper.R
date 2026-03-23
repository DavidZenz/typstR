#' Create a working paper project
#'
#' Scaffolds a new working paper project directory with a Quarto document,
#' bibliography, project configuration, and the typstR Quarto extension.
#'
#' @param path Path to the new project directory. Must not already exist.
#' @param title Optional title to pre-fill in the template YAML.
#' @param open Whether to open the project directory. Defaults to `TRUE`
#'   in interactive sessions.
#' @return The project path, invisibly.
#' @examples
#' \dontrun{
#' create_working_paper(
#'   "my-working-paper",
#'   title = "Trade, Policy, and Growth",
#'   open = FALSE
#' )
#' }
#' @export
create_working_paper <- function(path, title = NULL, open = interactive()) {
  # Guard: error if directory exists (locked decision: no overwrite, no force argument)
  if (fs::dir_exists(path)) {
    cli::cli_abort(c(
      "Directory {.path {path}} already exists.",
      "i" = "Choose a different path or remove the existing directory."
    ))
  }

  # Create project directory
  fs::dir_create(path)

  # Copy starter template files from inst/templates/workingpaper/
  template_src <- system.file("templates/workingpaper", package = "typstR",
                               mustWork = TRUE)
  template_files <- fs::dir_ls(template_src, all = TRUE, recurse = FALSE)
  fs::file_copy(template_files, fs::path(path, fs::path_file(template_files)))

  # Copy extension into _extensions/typstR/ within the new project (FOUN-03)
  ext_src <- system.file("quarto/extensions/typstR", package = "typstR",
                          mustWork = TRUE)
  ext_dest <- fs::path(path, "_extensions", "typstR")
  fs::dir_create(fs::path(path, "_extensions"))
  fs::dir_copy(ext_src, ext_dest)

  # Optionally pre-fill title in template.qmd
  if (!is.null(title)) {
    qmd_path <- fs::path(path, "template.qmd")
    lines <- readLines(qmd_path)
    lines <- sub(
      '^title: ".*"$',
      paste0('title: "', title, '"'),
      lines
    )
    writeLines(lines, qmd_path)
  }

  # cli success summary (locked decision: usethis-style checkmarks)
  cli::cli_alert_success("Created working paper project at {.path {path}}")
  cli::cli_bullets(c(
    "*" = "{.file template.qmd}",
    "*" = "{.file _quarto.yml}",
    "*" = "{.file references.bib}",
    "*" = "{.file _extensions/typstR/}"
  ))

  invisible(path)
}
