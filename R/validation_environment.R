#' Validate render environment prerequisites
#'
#' Runs pre-render environment checks for Quarto/Typst/runtime prerequisites and
#' confirms the typstR extension is present in the target project.
#'
#' @param path Project path to validate. Defaults to current directory.
#' @return A `typstR_validation_report` object when all checks pass.
#'   On failure, aborts with class `typstR_diagnostics_error` and structured
#'   diagnostics payload.
#' @export
validate_render_environment <- function(path = ".") {
  checks <- collect_environment_checks(path)
  diagnostics <- diagnostics_from_environment_checks(checks, path)

  if (length(diagnostics) > 0) {
    emit_diagnostics_error(
      diagnostics = diagnostics,
      message = "Render environment validation failed.",
      hint = "Resolve the reported environment issues before rendering."
    )
  }

  structure(
    list(
      ok = TRUE,
      path = normalize_validation_path(path),
      checks = checks
    ),
    class = c("typstR_validation_report", "list")
  )
}

collect_environment_checks <- function(path) {
  normalized_path <- normalize_validation_path(path)
  required_floor <- required_quarto_floor()

  quarto_check <- probe_quarto()
  typst_check <- probe_typst(quarto_check)
  floor_check <- probe_quarto_floor(quarto_check, required_floor)
  extension_check <- probe_extension(normalized_path)

  list(
    quarto = quarto_check,
    typst = typst_check,
    quarto_floor = floor_check,
    extension = extension_check
  )
}

normalize_validation_path <- function(path) {
  if (!is.character(path) || length(path) != 1 || is.na(path) || !nzchar(path)) {
    cli::cli_abort("{.arg path} must be a single non-empty character path.")
  }

  as.character(fs::path_abs(path))
}

probe_quarto <- function() {
  if (!requireNamespace("quarto", quietly = TRUE)) {
    return(list(
      ok = FALSE,
      available = FALSE,
      version = NA_character_,
      reason = "quarto R package is unavailable"
    ))
  }

  available <- tryCatch(
    isTRUE(quarto::quarto_available()),
    error = function(error) FALSE
  )

  version <- if (available) {
    tryCatch(
      as.character(quarto::quarto_version()),
      error = function(error) NA_character_
    )
  } else {
    NA_character_
  }

  list(
    ok = available,
    available = available,
    version = version
  )
}

probe_typst <- function(quarto_check) {
  if (!isTRUE(quarto_check$available) || !requireNamespace("quarto", quietly = TRUE)) {
    return(list(
      ok = FALSE,
      available = FALSE,
      version = NA_character_,
      raw = NA_character_,
      reason = "Quarto is unavailable"
    ))
  }

  quarto_path <- tryCatch(
    quarto::quarto_path(),
    error = function(error) NA_character_
  )

  if (!is.character(quarto_path) || length(quarto_path) != 1 || !nzchar(quarto_path)) {
    return(list(
      ok = FALSE,
      available = FALSE,
      version = NA_character_,
      raw = NA_character_,
      reason = "Unable to resolve Quarto executable path"
    ))
  }

  output <- tryCatch(
    system2(
      quarto_path,
      c("typst", "--version"),
      stdout = TRUE,
      stderr = TRUE
    ),
    error = function(error) structure(error$message, status = 1L)
  )

  status <- attr(output, "status")
  if (is.null(status)) {
    status <- 0L
  }

  raw <- if (length(output) == 0) NA_character_ else paste(output, collapse = "\n")
  version <- parse_typst_version(raw)
  available <- identical(status, 0L)

  list(
    ok = available,
    available = available,
    version = version,
    raw = raw,
    status = status
  )
}

parse_typst_version <- function(raw_output) {
  if (!is.character(raw_output) || length(raw_output) != 1 || is.na(raw_output)) {
    return(NA_character_)
  }

  match <- regexpr("[0-9]+\\.[0-9]+\\.[0-9]+", raw_output)
  if (identical(match, -1L)) {
    return(NA_character_)
  }

  regmatches(raw_output, match)
}

probe_quarto_floor <- function(quarto_check, required) {
  min_version <- parse_quarto_required_floor(required)

  compatible <- if (requireNamespace("quarto", quietly = TRUE)) {
    tryCatch(
      isTRUE(quarto::quarto_available(min = min_version)),
      error = function(error) FALSE
    )
  } else {
    FALSE
  }

  list(
    ok = compatible,
    required = required,
    min_version = min_version,
    compatible = compatible,
    available = isTRUE(quarto_check$available)
  )
}

parse_quarto_required_floor <- function(required) {
  if (!is.character(required) || length(required) != 1 || is.na(required) || !nzchar(required)) {
    cli::cli_abort("{.arg required} must be a non-empty character value.")
  }

  floor <- sub("^\\s*>?=\\s*", "", required)
  if (!nzchar(floor)) {
    cli::cli_abort("Could not parse Quarto floor from {.arg required}.")
  }

  floor
}

required_quarto_floor <- function() {
  manifest <- extension_manifest_source()
  data <- yaml::read_yaml(manifest)
  required <- data[["quarto-required"]]

  if (!is.character(required) || length(required) != 1 || is.na(required) || !nzchar(required)) {
    cli::cli_abort("Extension manifest is missing a valid {.field quarto-required} value.")
  }

  required
}

extension_manifest_source <- function() {
  installed <- system.file(
    "quarto",
    "extensions",
    "typstR",
    "_extension.yml",
    package = "typstR"
  )

  candidates <- c(
    installed,
    "inst/quarto/extensions/typstR/_extension.yml",
    "../inst/quarto/extensions/typstR/_extension.yml",
    file.path(getwd(), "inst", "quarto", "extensions", "typstR", "_extension.yml")
  )

  existing <- candidates[nzchar(candidates) & file.exists(candidates)]
  if (length(existing) == 0) {
    cli::cli_abort("Could not locate typstR extension manifest for Quarto floor checks.")
  }

  normalizePath(existing[[1]], winslash = "/", mustWork = TRUE)
}

probe_extension <- function(path) {
  manifest <- as.character(fs::path(path, "_extensions", "typstR", "_extension.yml"))
  manifest <- as.character(fs::path_abs(manifest))
  present <- fs::file_exists(manifest)

  list(
    ok = present,
    present = present,
    manifest = manifest
  )
}

diagnostics_from_environment_checks <- function(checks, path) {
  codebook <- diagnostics_codebook()
  diagnostics <- list()
  project_path <- normalize_validation_path(path)

  if (!isTRUE(checks$quarto$ok)) {
    diagnostics[[length(diagnostics) + 1L]] <- new_diagnostic(
      code = codebook[["env_quarto_unavailable"]],
      severity = "error",
      location = list(file = project_path),
      hint = "Install Quarto from https://quarto.org and ensure it is on PATH.",
      message = "Quarto is not installed or not on PATH.",
      details = checks$quarto
    )
  }

  if (!isTRUE(checks$typst$ok)) {
    diagnostics[[length(diagnostics) + 1L]] <- new_diagnostic(
      code = codebook[["env_typst_unavailable"]],
      severity = "error",
      location = list(file = project_path),
      hint = "Run `quarto typst --version` and reinstall Quarto if Typst support is missing.",
      message = "Typst is not available through the Quarto CLI.",
      details = checks$typst
    )
  }

  if (!isTRUE(checks$quarto_floor$ok)) {
    diagnostics[[length(diagnostics) + 1L]] <- new_diagnostic(
      code = codebook[["env_quarto_floor_incompatible"]],
      severity = "error",
      location = list(file = project_path),
      hint = "Upgrade Quarto to satisfy the typstR minimum required version.",
      message = sprintf(
        "Installed Quarto does not satisfy required version floor %s.",
        checks$quarto_floor$required
      ),
      details = checks$quarto_floor
    )
  }

  if (!isTRUE(checks$extension$ok)) {
    diagnostics[[length(diagnostics) + 1L]] <- new_diagnostic(
      code = codebook[["env_extension_missing"]],
      severity = "error",
      location = list(file = checks$extension$manifest),
      hint = "Ensure the project contains _extensions/typstR/_extension.yml.",
      message = "typstR extension manifest is missing from the target project.",
      details = checks$extension
    )
  }

  diagnostics
}
