#' Create a policy brief project
#'
#' Scaffolds a new policy brief project directory with a Quarto document,
#' bibliography, project configuration, and the typstR Quarto extension.
#' The policy brief format uses a shorter, audience-oriented layout with a
#' concise summary instead of a full abstract. It does not include JEL codes
#' and uses policy-oriented section headings (Key Findings, Evidence,
#' Policy Implications).
#'
#' @param path Path to the new project directory. Must not already exist.
#' @param title Optional title to pre-fill in the template YAML.
#' @param open Whether to open the project directory. Defaults to `TRUE`
#'   in interactive sessions.
#' @return The project path, invisibly.
#' @examples
#' \dontrun{
#' create_policy_brief(
#'   "my-policy-brief",
#'   title = "What Export Controls Mean for Small Open Economies",
#'   open = FALSE
#' )
#' }
#' @export
create_policy_brief <- function(path, title = NULL, open = interactive()) {
  if (fs::dir_exists(path)) {
    cli::cli_abort(c(
      "Directory {.path {path}} already exists.",
      "i" = "Choose a different path or remove the existing directory."
    ))
  }

  fs::dir_create(path)

  template_src <- system.file("templates/policy-brief", package = "typstR",
                               mustWork = TRUE)
  template_files <- fs::dir_ls(template_src, all = TRUE, recurse = FALSE)
  fs::file_copy(template_files, fs::path(path, fs::path_file(template_files)))

  ext_src <- system.file("quarto/extensions/typstR", package = "typstR",
                          mustWork = TRUE)
  ext_dest <- fs::path(path, "_extensions", "typstR")
  fs::dir_create(fs::path(path, "_extensions"))
  fs::dir_copy(ext_src, ext_dest)

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

  cli::cli_alert_success("Created policy brief project at {.path {path}}")
  cli::cli_bullets(c(
    "*" = "{.file template.qmd}",
    "*" = "{.file _quarto.yml}",
    "*" = "{.file references.bib}",
    "*" = "{.file _extensions/typstR/}"
  ))

  invisible(path)
}
