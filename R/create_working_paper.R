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
  scaffold_project_from_template(
    path = path,
    template_dir = "workingpaper",
    success_label = "working paper",
    title = title
  )
}
