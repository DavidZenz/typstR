#' Specify keywords for a manuscript
#'
#' Creates a validated list of keyword strings for use in manuscript metadata.
#' The returned object can be passed to `manuscript_meta()`.
#'
#' @param ... One or more character strings, each a keyword.
#' @return An S3 object of class `c("typstR_keywords", "list")`.
#' @export
#' @examples
#' keywords("trade", "policy", "gravity model")
keywords <- function(...) {
  args <- list(...)
  not_char <- !vapply(args, is.character, logical(1L))
  if (any(not_char)) {
    cli::cli_abort("{.arg ...} must be character strings.")
  }
  codes <- unlist(args)
  structure(as.list(codes), class = c("typstR_keywords", "list"))
}

#' @export
print.typstR_keywords <- function(x, ...) {
  cat("<typstR_keywords> [", length(x), " item", if (length(x) != 1L) "s" else "", "]\n", sep = "")
  invisible(x)
}

#' Specify JEL classification codes for a manuscript
#'
#' Creates a validated list of JEL codes for use in manuscript metadata.
#' Each code must match the pattern `[A-Z][0-9]{1,2}` (one uppercase letter
#' followed by 1 or 2 digits).
#'
#' @param ... One or more JEL code strings (e.g., `"F10"`, `"L5"`).
#' @return An S3 object of class `c("typstR_jel", "list")`.
#' @export
#' @examples
#' jel_codes("F10", "L52")
jel_codes <- function(...) {
  codes <- c(...)
  if (!is.character(codes)) {
    cli::cli_abort("{.arg ...} must be character strings.")
  }
  valid <- grepl("^[A-Z][0-9]{1,2}$", codes)
  if (!all(valid)) {
    invalid <- codes[!valid]
    cli::cli_abort(c(
      "Invalid JEL codes: {.val {invalid}}",
      "i" = "Expected format: one uppercase letter followed by 1-2 digits (e.g., F10, L52)."
    ))
  }
  structure(as.list(codes), class = c("typstR_jel", "list"))
}

#' @export
print.typstR_jel <- function(x, ...) {
  cat("<typstR_jel> [", paste(unlist(x), collapse = ", "), "]\n", sep = "")
  invisible(x)
}

#' Specify a report number for a manuscript
#'
#' Wraps a scalar string as a typed metadata value for use in
#' `manuscript_meta()`.
#'
#' @param text A single character string giving the report number.
#' @return An S3 object of class `c("typstR_report_number", "character")`.
#' @export
#' @examples
#' report_number("WP 001")
report_number <- function(text) {
  if (!is.character(text) || length(text) != 1L) {
    cli::cli_abort("{.arg text} must be a single character string.")
  }
  structure(text, class = c("typstR_report_number", "character"))
}

#' Specify a funding statement for a manuscript
#'
#' Wraps a scalar string as a typed metadata value for use in
#' `manuscript_meta()`.
#'
#' @param text A single character string describing funding sources.
#' @return An S3 object of class `c("typstR_funding", "character")`.
#' @export
#' @examples
#' funding("Supported by ERC Grant 12345.")
funding <- function(text) {
  if (!is.character(text) || length(text) != 1L) {
    cli::cli_abort("{.arg text} must be a single character string.")
  }
  structure(text, class = c("typstR_funding", "character"))
}

#' Specify a data availability statement for a manuscript
#'
#' Wraps a scalar string as a typed metadata value for use in
#' `manuscript_meta()`.
#'
#' @param text A single character string describing data availability.
#' @return An S3 object of class `c("typstR_data_availability", "character")`.
#' @export
#' @examples
#' data_availability("Data available at https://example.com/data")
data_availability <- function(text) {
  if (!is.character(text) || length(text) != 1L) {
    cli::cli_abort("{.arg text} must be a single character string.")
  }
  structure(text, class = c("typstR_data_availability", "character"))
}

#' Specify a code availability statement for a manuscript
#'
#' Wraps a scalar string as a typed metadata value for use in
#' `manuscript_meta()`.
#'
#' @param text A single character string describing code availability.
#' @return An S3 object of class `c("typstR_code_availability", "character")`.
#' @export
#' @examples
#' code_availability("Replication code at https://github.com/example/repo")
code_availability <- function(text) {
  if (!is.character(text) || length(text) != 1L) {
    cli::cli_abort("{.arg text} must be a single character string.")
  }
  structure(text, class = c("typstR_code_availability", "character"))
}
