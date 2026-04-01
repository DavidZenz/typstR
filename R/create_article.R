#' Create an article project
#'
#' Scaffolds a new article project directory with a Quarto document,
#' bibliography, project configuration, and the typstR Quarto extension.
#' The article format is identical to the working paper layout but does not
#' include a report number block or disclaimer page by default. It supports
#' anonymized mode via `typstR: anonymized: true` in the YAML front matter.
#'
#' @param path Path to the new project directory. Must not already exist.
#' @param title Optional title to pre-fill in the template YAML.
#' @param open Whether to open the project directory. Defaults to `TRUE`
#'   in interactive sessions.
#' @return The project path, invisibly.
#' @examples
#' \dontrun{
#' create_article(
#'   "my-article",
#'   title = "Firm Dynamics in Open Economies",
#'   open = FALSE
#' )
#' }
#' @export
create_article <- function(path, title = NULL, open = interactive()) {
  scaffold_project_from_template(
    path = path,
    template_dir = "article",
    success_label = "article",
    title = title
  )
}
