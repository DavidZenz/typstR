#' Render a Quarto document to PDF
#'
#' Renders a Quarto document using the Quarto CLI after running shared
#' pre-render environment validation checks.
#'
#' @param input Path to a `.qmd` file, a directory containing a `.qmd` file,
#'   or `NULL` to look in the current directory.
#' @param output_format Quarto output format name (e.g., `"typstR-typst"`).
#'   If `NULL`, uses the format specified in the document YAML.
#' @param quiet If `TRUE`, suppresses Quarto output. Defaults to `FALSE`.
#' @param open If `TRUE`, opens the rendered PDF in the system viewer.
#'   Defaults to `TRUE` in interactive sessions.
#' @return `NULL`, invisibly.
#' @examples
#' \dontrun{
#' render_pub("my-working-paper/template.qmd", quiet = TRUE, open = FALSE)
#' render_pub(
#'   "my-article/template.qmd",
#'   output_format = "typstR-article",
#'   quiet = TRUE,
#'   open = FALSE
#' )
#' }
#' @export
render_pub <- function(input = NULL, output_format = NULL, quiet = FALSE,
                       open = interactive()) {
  # Pre-flight: shared environment validation (locked decision)
  validate_render_environment(if (is.null(input)) "." else input)

  # Input auto-detection (locked decision)
  resolved_input <- resolve_input(input)

  # Render via quarto R package (never shell out directly)
  quarto::quarto_render(
    input = resolved_input,
    output_format = output_format,
    quiet = quiet
  )

  # Open PDF in system viewer (locked decision: open = interactive())
  if (open) {
    pdf_path <- fs::path_ext_set(resolved_input, "pdf")
    open_file(pdf_path)
  }

  invisible(NULL)
}

#' Render a working paper to PDF
#'
#' Convenience wrapper that renders a document using the `typstR-workingpaper`
#' format.
#'
#' @inheritParams render_pub
#' @return `NULL`, invisibly.
#' @examples
#' \dontrun{
#' render_working_paper("my-working-paper/template.qmd", quiet = TRUE, open = FALSE)
#' }
#' @export
render_working_paper <- function(input = NULL, quiet = FALSE,
                                 open = interactive()) {
  render_pub(
    input = input,
    output_format = "typstR-typst",
    quiet = quiet,
    open = open
  )
}

