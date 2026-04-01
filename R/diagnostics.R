#' Diagnostics contract primitives
#'
#' Internal helpers for constructing, validating, and retrieving structured
#' diagnostics used by pre-render validation paths.
#'
#' @noRd

DIAGNOSTIC_SEVERITIES <- c("error", "warning")
DIAGNOSTIC_CODE_PATTERN <- "^DIAG-[A-Z]+-[0-9]{3}$"

DIAGNOSTIC_CODEBOOK <- c(
  quarto_unavailable = "DIAG-RUNTIME-001",
  no_qmd_found = "DIAG-INPUT-001",
  multiple_qmd_found = "DIAG-INPUT-002",
  input_not_found = "DIAG-INPUT-003"
)

DIAGNOSTIC_CODEBOOK_REFERENCE <- DIAGNOSTIC_CODEBOOK

normalize_optional_character <- function(value, name) {
  if (is.null(value) || (length(value) == 1 && is.na(value))) {
    return(NA_character_)
  }

  if (!is.character(value) || length(value) != 1 || !nzchar(value)) {
    cli::cli_abort("{.arg {name}} must be a single non-empty character value or NA.")
  }

  value
}

normalize_optional_integer <- function(value, name) {
  if (is.null(value) || (length(value) == 1 && is.na(value))) {
    return(NA_integer_)
  }

  if (length(value) != 1 || !is.numeric(value) || is.na(value) || value < 1) {
    cli::cli_abort("{.arg {name}} must be a single positive integer value or NA.")
  }

  as.integer(value)
}

normalize_diagnostic_location <- function(location) {
  if (!is.list(location)) {
    cli::cli_abort("{.arg location} must be a list with file and/or field pointers.")
  }

  normalized <- list(
    file = normalize_optional_character(location[["file"]], "location$file"),
    field = normalize_optional_character(location[["field"]], "location$field"),
    line = normalize_optional_integer(location[["line"]], "location$line"),
    column = normalize_optional_integer(location[["column"]], "location$column")
  )

  if (is.na(normalized$file) && is.na(normalized$field)) {
    cli::cli_abort("{.arg location} must include {.field file} or {.field field}.")
  }

  normalized
}

validate_diagnostic_codebook <- function(codebook,
                                         reference = DIAGNOSTIC_CODEBOOK_REFERENCE) {
  if (!is.character(codebook) || is.null(names(codebook)) || any(names(codebook) == "")) {
    cli::cli_abort("{.arg codebook} must be a named character vector.")
  }

  codes <- unname(codebook)
  if (any(!grepl(DIAGNOSTIC_CODE_PATTERN, codes))) {
    cli::cli_abort("All diagnostic codes must match {.val {DIAGNOSTIC_CODE_PATTERN}}.")
  }

  if (length(unique(codes)) != length(codes)) {
    cli::cli_abort("Diagnostic codes must be unique across issue keys.")
  }

  if (!setequal(names(codebook), names(reference))) {
    cli::cli_abort("Diagnostic codebook keys must match the canonical key set.")
  }

  for (issue_key in names(reference)) {
    if (!identical(unname(codebook[[issue_key]]), unname(reference[[issue_key]]))) {
      cli::cli_abort(
        "Diagnostic code for {.field {issue_key}} must remain assigned to {.val {reference[[issue_key]]}}."
      )
    }
  }

  invisible(codebook)
}

diagnostics_codebook <- function() {
  validate_diagnostic_codebook(DIAGNOSTIC_CODEBOOK)
  DIAGNOSTIC_CODEBOOK
}

new_diagnostic <- function(code,
                           severity,
                           location,
                           hint,
                           message = NULL,
                           details = NULL) {
  code <- normalize_optional_character(code, "code")
  if (is.na(code) || !grepl(DIAGNOSTIC_CODE_PATTERN, code)) {
    cli::cli_abort("{.arg code} must match {.val {DIAGNOSTIC_CODE_PATTERN}}.")
  }

  if (!is.character(severity) || length(severity) != 1 || is.na(severity)) {
    cli::cli_abort("{.arg severity} must be a single character value.")
  }

  if (!(severity %in% DIAGNOSTIC_SEVERITIES)) {
    cli::cli_abort(
      "{.arg severity} must be one of: {.val {DIAGNOSTIC_SEVERITIES}}."
    )
  }

  hint <- normalize_optional_character(hint, "hint")
  if (is.na(hint)) {
    cli::cli_abort("{.arg hint} must be a single non-empty character value.")
  }

  if (is.null(message)) {
    message <- NA_character_
  } else {
    message <- normalize_optional_character(message, "message")
  }

  structure(
    list(
      code = code,
      severity = severity,
      location = normalize_diagnostic_location(location),
      hint = hint,
      message = message,
      details = details
    ),
    class = c("typstR_diagnostic", "list")
  )
}

diagnostic_sort_string <- function(value) {
  if (is.null(value) || length(value) != 1 || is.na(value) || !nzchar(value)) {
    return("~")
  }

  value
}

validate_diagnostics_list <- function(diagnostics) {
  if (!is.list(diagnostics) || length(diagnostics) == 0) {
    cli::cli_abort("{.arg diagnostics} must be a non-empty list of diagnostics.")
  }

  required_fields <- c("code", "severity", "location", "hint")
  for (index in seq_along(diagnostics)) {
    diagnostic <- diagnostics[[index]]
    if (!is.list(diagnostic)) {
      cli::cli_abort(
        "Diagnostic entry {.val {index}} must be a list produced by {.fn new_diagnostic}."
      )
    }

    missing <- setdiff(required_fields, names(diagnostic))
    if (length(missing) > 0) {
      cli::cli_abort(
        "Diagnostic entry {.val {index}} is missing required fields: {.val {missing}}."
      )
    }
  }

  diagnostics
}

sort_diagnostics <- function(diagnostics) {
  diagnostics <- validate_diagnostics_list(diagnostics)

  severity_rank <- c(error = 1L, warning = 2L)
  severity <- vapply(diagnostics, function(diagnostic) {
    value <- diagnostic[["severity"]]
    if (is.null(value) || length(value) != 1 || is.na(value)) {
      return(NA_character_)
    }

    as.character(value)
  }, character(1))

  if (any(!severity %in% names(severity_rank))) {
    cli::cli_abort(
      "Each diagnostic must include {.field severity} as {.val error} or {.val warning}."
    )
  }

  file_key <- vapply(diagnostics, function(diagnostic) {
    location <- diagnostic[["location"]]
    if (!is.list(location)) {
      return("~")
    }

    diagnostic_sort_string(location[["file"]])
  }, character(1))

  field_key <- vapply(diagnostics, function(diagnostic) {
    location <- diagnostic[["location"]]
    if (!is.list(location)) {
      return("~")
    }

    diagnostic_sort_string(location[["field"]])
  }, character(1))

  code_key <- vapply(diagnostics, function(diagnostic) {
    diagnostic_sort_string(diagnostic[["code"]])
  }, character(1))

  order_index <- order(
    unname(severity_rank[severity]),
    file_key,
    field_key,
    code_key,
    seq_along(diagnostics)
  )

  diagnostics[order_index]
}

emit_diagnostics_error <- function(diagnostics,
                                   message = "Validation failed.",
                                   hint = "Review diagnostics and retry the command.") {
  sorted <- sort_diagnostics(diagnostics)

  cli::cli_abort(
    c(message, "i" = hint),
    class = c("typstR_diagnostics_error", "typstR_error"),
    diagnostics = sorted
  )
}


validate_diagnostic_codebook(DIAGNOSTIC_CODEBOOK)
