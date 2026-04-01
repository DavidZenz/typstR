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
  scaffold_project_from_template(
    path = path,
    template_dir = "policy-brief",
    success_label = "policy brief",
    title = title
  )
}
