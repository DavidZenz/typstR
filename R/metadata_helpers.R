#' Create an author metadata object
#'
#' Returns an S3 object of class `typstR_author` representing a manuscript
#' author. Fields are serializable to Quarto-compatible YAML via
#' `yaml::as.yaml()`.
#'
#' @param name Character scalar. Author's full name (required).
#' @param affiliation Character vector of affiliation IDs, or `NULL`.
#' @param email Character scalar email address, or `NULL`.
#' @param orcid Character scalar ORCID identifier in `XXXX-XXXX-XXXX-XXXX`
#'   format, or `NULL`.
#' @param corresponding Logical scalar. Whether this author is the
#'   corresponding author. Defaults to `FALSE`.
#'
#' @return An S3 object with class `c("typstR_author", "list")`.
#' @export
author <- function(name,
                   affiliation = NULL,
                   email = NULL,
                   orcid = NULL,
                   corresponding = FALSE) {
  if (!is.character(name) || length(name) != 1L) {
    cli::cli_abort(c(
      "{.arg name} must be a single character string.",
      "i" = "Received: {.obj_type_friendly {name}}"
    ))
  }

  if (!is.null(orcid)) {
    if (!grepl("^[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9X]$", orcid)) {
      cli::cli_abort(c(
        "Invalid ORCID format: {.val {orcid}}",
        "i" = "Expected format: XXXX-XXXX-XXXX-XXXX (digits, last character may be X)"
      ))
    }
  }

  if (!is.null(affiliation)) {
    affiliation <- as.character(affiliation)
  }

  if (!is.null(corresponding) && (!is.logical(corresponding) || length(corresponding) != 1L)) {
    cli::cli_abort(c(
      "{.arg corresponding} must be a single logical value (`TRUE` or `FALSE`).",
      "i" = "Received: {.obj_type_friendly {corresponding}}"
    ))
  }

  fields <- Filter(Negate(is.null), list(
    name = name,
    affiliation = affiliation,
    email = email,
    orcid = orcid,
    corresponding = if (isTRUE(corresponding)) corresponding else NULL
  ))

  structure(fields, class = c("typstR_author", "list"))
}

#' Create an affiliation metadata object
#'
#' Returns an S3 object of class `typstR_affiliation` representing an
#' institutional affiliation. Fields are serializable to Quarto-compatible
#' YAML via `yaml::as.yaml()`.
#'
#' @param id Character scalar. Unique identifier used to link authors to this
#'   affiliation (required).
#' @param name Character scalar. Institution name (required).
#' @param department Character scalar department name, or `NULL`.
#' @param address Character scalar address, or `NULL`.
#' @param country Character scalar country name, or `NULL`.
#'
#' @return An S3 object with class `c("typstR_affiliation", "list")`.
#' @export
affiliation <- function(id, name,
                        department = NULL,
                        address = NULL,
                        country = NULL) {
  if (!is.character(id) || length(id) != 1L) {
    cli::cli_abort(c(
      "{.arg id} must be a single character string.",
      "i" = "Received: {.obj_type_friendly {id}}"
    ))
  }

  if (!is.character(name) || length(name) != 1L) {
    cli::cli_abort(c(
      "{.arg name} must be a single character string.",
      "i" = "Received: {.obj_type_friendly {name}}"
    ))
  }

  fields <- Filter(Negate(is.null), list(
    id = id,
    name = name,
    department = department,
    address = address,
    country = country
  ))

  structure(fields, class = c("typstR_affiliation", "list"))
}

#' Create a manuscript metadata object
#'
#' Combines authors, affiliations, and optional metadata fields into a single
#' serializable object. Performs cross-validation: every affiliation ID
#' referenced by an author must have a matching `affiliation()` object.
#'
#' @param authors A list of `typstR_author` objects created by [author()].
#' @param affiliations A list of `typstR_affiliation` objects created by
#'   [affiliation()]. Defaults to an empty list.
#' @param keywords Character vector of keywords, or `NULL`.
#' @param jel Character vector of JEL classification codes, or `NULL`.
#' @param acknowledgements Character scalar acknowledgement text, or `NULL`.
#' @param report_number Character scalar report number, or `NULL`.
#' @param funding Character scalar funding statement, or `NULL`.
#' @param data_availability Character scalar data availability statement,
#'   or `NULL`.
#' @param code_availability Character scalar code availability statement,
#'   or `NULL`.
#'
#' @return An S3 object with class `c("typstR_meta", "list")`.
#' @export
manuscript_meta <- function(authors,
                            affiliations = list(),
                            keywords = NULL,
                            jel = NULL,
                            acknowledgements = NULL,
                            report_number = NULL,
                            funding = NULL,
                            data_availability = NULL,
                            code_availability = NULL) {
  # Extract all affiliation IDs referenced by authors
  author_aff_ids <- unlist(lapply(authors, function(a) {
    ids <- a[["affiliation"]]
    if (is.null(ids)) character(0L) else as.character(ids)
  }))

  # Extract defined affiliation IDs
  defined_aff_ids <- vapply(affiliations, function(aff) aff[["id"]], character(1L))

  # Cross-validate: find dangling references
  if (length(author_aff_ids) > 0L) {
    dangling <- setdiff(author_aff_ids, defined_aff_ids)
    if (length(dangling) > 0L) {
      cli::cli_abort(c(
        "Author references undefined affiliation IDs: {.val {dangling}}",
        "i" = "Add a matching {.fn affiliation} object for each ID referenced by an author."
      ))
    }
  }

  # Build the typstR namespace block
  typstR_block <- Filter(Negate(is.null), list(
    keywords = keywords,
    jel = jel,
    acknowledgements = acknowledgements,
    "report-number" = report_number,
    funding = funding,
    "data-availability" = data_availability,
    "code-availability" = code_availability
  ))

  # Assemble result
  result <- list(
    author = lapply(authors, unclass),
    affiliations = lapply(affiliations, unclass)
  )

  if (length(typstR_block) > 0L) {
    result[["typstR"]] <- typstR_block
  }

  structure(result, class = c("typstR_meta", "list"))
}

#' Print method for typstR_author
#'
#' @param x A `typstR_author` object.
#' @param ... Additional arguments (unused).
#' @return The input `x`, invisibly.
#' @method print typstR_author
#' @export
print.typstR_author <- function(x, ...) {
  cat("<typstR_author>", x[["name"]], "\n")
  invisible(x)
}

#' Print method for typstR_affiliation
#'
#' @param x A `typstR_affiliation` object.
#' @param ... Additional arguments (unused).
#' @return The input `x`, invisibly.
#' @method print typstR_affiliation
#' @export
print.typstR_affiliation <- function(x, ...) {
  cat("<typstR_affiliation> [", x[["id"]], "] ", x[["name"]], "\n", sep = "")
  invisible(x)
}

#' Print method for typstR_meta
#'
#' @param x A `typstR_meta` object.
#' @param ... Additional arguments (unused).
#' @return The input `x`, invisibly.
#' @method print typstR_meta
#' @export
print.typstR_meta <- function(x, ...) {
  n_authors <- length(x[["author"]])
  n_affils <- length(x[["affiliations"]])
  cat("<typstR_meta>", n_authors, "author(s),", n_affils, "affiliation(s)\n")
  invisible(x)
}
