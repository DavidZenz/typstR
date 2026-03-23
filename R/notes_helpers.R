#' Emit a figure note in markdown format
#'
#' Outputs a note line starting with `*Note:*` via [cat()], suitable for use
#' in Quarto code chunks with `#| output: asis`. This allows figure notes to
#' be rendered as formatted markdown in the final document.
#'
#' @param ... One or more character strings to concatenate into the note text
#'   (concatenated with no separator).
#' @return The note text string, invisibly.
#' @export
#' @examples
#' \dontrun{
#' # In a Quarto code chunk with #| output: asis
#' fig_note("Source: World Bank, WDI database (2023).")
#' fig_note("Note: ", n_obs, " observations. Robust standard errors in parentheses.")
#' }
fig_note <- function(...) {
  text <- paste(..., sep = "")
  cat("*Note:* ", text, "\n", sep = "")
  invisible(text)
}

#' Emit a table note in markdown format
#'
#' Outputs a note line starting with `*Note:*` via [cat()], suitable for use
#' in Quarto code chunks with `#| output: asis`. This allows table notes to
#' be rendered as formatted markdown in the final document.
#'
#' `tab_note()` is a separate function from [fig_note()] to allow divergent
#' styling in future package versions.
#'
#' @param ... One or more character strings to concatenate into the note text
#'   (concatenated with no separator).
#' @return The note text string, invisibly.
#' @export
#' @examples
#' \dontrun{
#' # In a Quarto code chunk with #| output: asis
#' tab_note("Source: IMF World Economic Outlook (April 2023).")
#' tab_note("*p* < 0.05, ** *p* < 0.01, *** *p* < 0.001.")
#' }
tab_note <- function(...) {
  text <- paste(..., sep = "")
  cat("*Note:* ", text, "\n", sep = "")
  invisible(text)
}

#' Emit a formatted appendix section title
#'
#' Outputs a markdown header with Quarto's `{.appendix}` class via [cat()],
#' suitable for use in Quarto code chunks with `#| output: asis`. This marks
#' the section as an appendix in Quarto's cross-reference system.
#'
#' @param title A single character string giving the appendix section title.
#' @param level An integer giving the header level (number of `#` characters).
#'   Defaults to `1` (top-level `#` header).
#' @return The title string, invisibly.
#' @export
#' @examples
#' \dontrun{
#' # In a Quarto code chunk with #| output: asis
#' appendix_title("Data Sources")
#' appendix_title("Additional Tables", level = 2)
#' }
appendix_title <- function(title, level = 1) {
  if (!is.character(title) || length(title) != 1L) {
    cli::cli_abort("{.arg title} must be a single character string.")
  }
  header <- paste0(strrep("#", level), " Appendix: ", title, " {.appendix}")
  cat(header, "\n", sep = "")
  invisible(title)
}
