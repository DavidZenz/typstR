#' Validate a typstR manuscript
#'
#' Checks manuscript and project YAML, publication metadata, supported output
#' formats, and configured local resources. The same checks run before rendering.
#'
#' @param path A `.qmd` file, directory containing one `.qmd`, or `NULL` for the
#'   current directory. Defaults to `"."`.
#' @param output_format Optional format override. The bundled format is
#'   `"typstR-typst"`; select article or brief with `typstR: format-variant`.
#' @param check_environment Also check Quarto, Typst and the bundled extension.
#'   Defaults to `FALSE`, allowing manuscript checks without Quarto installed.
#' @return A `typstR_validation_report`, including resolved context and metadata.
#'   Invalid input raises `typstR_diagnostics_error` with ordered diagnostics.
#' @details
#' Project YAML, directory `_metadata.yml` and document YAML are merged in that
#' order. Relative resource paths are based on the configuration file that
#' declares them. Profiles, local configuration, executable YAML, metadata-files,
#' and generated resources are not supported by this static preflight.
#' See the getting-started article for the validation contract and limitations.
#' @examples
#' \dontrun{
#' validate_manuscript("my-paper/template.qmd")
#' validate_manuscript("my-paper", check_environment = TRUE)
#' }
#' @export
validate_manuscript <- function(path = ".", output_format = NULL,
                                check_environment = FALSE) {
  context <- resolve_render_context(path)
  validate_manuscript_context(context, output_format, check_environment)
}

is_yaml_mapping <- function(x) {
  is.list(x) && (length(x) == 0L || (!is.null(names(x)) && all(nzchar(names(x)))))
}

is_text_scalar <- function(x) {
  is.character(x) && length(x) == 1L && !is.na(x) && nzchar(trimws(x))
}

is_text_sequence <- function(x) {
  if (is.character(x)) return(length(x) > 0L && all(!is.na(x) & nzchar(x)))
  is.list(x) && is.null(names(x)) && length(x) > 0L && all(vapply(x, is_text_scalar, logical(1)))
}

# Citation syntax in literal code is not a manuscript citation. Ignore YAML,
# fenced code blocks and inline code; generated citations remain Quarto's job.
manuscript_prose_lines <- function(lines) {
  if (length(lines) && grepl("^---\\s*$", sub("^\ufeff", "", lines[[1]]))) {
    end <- which(grepl("^(---|\\.\\.\\.)\\s*$", lines[-1]))
    if (length(end)) lines <- lines[-seq_len(end[[1]] + 1L)]
  }
  prose <- character(length(lines))
  kept <- 0L
  fence <- NULL
  for (line in lines) {
    marker <- regmatches(line, regexpr("^ {0,3}(`{3,}|~{3,})", line))
    if (is.null(fence) && length(marker) && nzchar(marker)) {
      fence <- trimws(marker)
    } else if (!is.null(fence)) {
      closing <- paste0("^ {0,3}", substr(fence, 1L, 1L), "{", nchar(fence), ",}\\s*$")
      if (grepl(closing, line)) fence <- NULL
    } else {
      kept <- kept + 1L
      prose[[kept]] <- gsub("`+[^`]*`+", "", line)
    }
  }
  prose[seq_len(kept)]
}

# Quarto merges mappings and sequences; scalar values override. Document format
# names replace the project selection, but matching format options inherit.
merge_manuscript_metadata <- function(base, override) {
  if (is_yaml_mapping(base) && is_yaml_mapping(override)) {
    for (key in names(override)) {
      base[key] <- list(merge_manuscript_metadata(base[[key]], override[[key]]))
    }
    return(base)
  }
  if (is.list(base) && is.null(names(base)) && is.list(override) && is.null(names(override))) {
    return(c(base, override))
  }
  override
}

manuscript_resource_path <- function(value, base) {
  if (!is_text_scalar(value)) return(value)
  if (grepl("^[A-Za-z][A-Za-z0-9+.-]*://", value)) return(value)
  as.character(fs::path_abs(value, start = base))
}

normalize_resource_metadata <- function(meta, base) {
  for (key in c("bibliography", "csl", "include-in-header", "include-before-body", "include-after-body")) {
    value <- meta[[key]]
    if (is_text_sequence(value)) {
      meta[[key]] <- lapply(as.list(value), manuscript_resource_path, base = base)
    } else if (is_yaml_mapping(value) && is_text_scalar(value$file)) {
      meta[[key]]$file <- manuscript_resource_path(value$file, base)
    }
  }
  if (is_yaml_mapping(meta$typstR) && is_text_scalar(meta$typstR$logo)) {
    meta$typstR$logo <- manuscript_resource_path(meta$typstR$logo, base)
  }
  if (is_yaml_mapping(meta$format)) {
    for (name in names(meta$format)) {
      if (is_yaml_mapping(meta$format[[name]])) {
        meta$format[[name]] <- normalize_resource_metadata(meta$format[[name]], base)
      }
    }
  }
  meta
}

validate_manuscript_context <- function(context, output_format, check_environment) {
  diagnostics <- list()
  add <- function(key, message, field, file = context$input, hint = "Correct the field in manuscript or project YAML.") {
    diagnostics[[length(diagnostics) + 1L]] <<- new_diagnostic(
      diagnostics_codebook()[[key]], "error", list(file = file, field = field), hint, message
    )
  }
  read_metadata <- function(file, document = FALSE) {
    lines <- readLines(file, warn = FALSE, encoding = "UTF-8")
    if (document) {
      if (!length(lines) || !grepl("^---\\s*$", sub("^\ufeff", "", lines[[1]]))) return(list())
      end <- which(grepl("^(---|\\.\\.\\.)\\s*$", lines[-1]))
      if (!length(end)) {
        add("manuscript_yaml_invalid", "YAML front matter is not closed.", "yaml", file)
        return(list())
      }
      lines <- if (end[[1]] == 1L) character() else lines[seq.int(2L, end[[1]])]
    }
    meta <- tryCatch(
      withCallingHandlers(yaml::yaml.load(paste(lines, collapse = "\n"), eval.expr = FALSE,
                                         handlers = list(seq = function(x) as.list(x))),
                          warning = function(w) stop(conditionMessage(w))),
      error = function(e) {
        add("manuscript_yaml_invalid", paste("Invalid YAML:", conditionMessage(e)), "yaml", file)
        NULL
      }
    )
    if (is.null(meta)) return(list())
    if (!is_yaml_mapping(meta)) {
      add("manuscript_yaml_invalid", "YAML must be a mapping of named fields.", "yaml", file)
      return(list())
    }
    for (key in intersect(names(meta), c("metadata-files", "profile"))) {
      add("manuscript_unsupported", paste("Static validation does not support", key), key, file,
          "Inline the effective settings into project/directory/document YAML before using typstR helpers.")
    }
    if (any(grepl("!expr\\b", lines))) add("manuscript_unsupported", "Executable YAML is unsupported.", "yaml", file)
    normalize_resource_metadata(meta, dirname(file))
  }

  sources <- context$project_file
  dirs <- context$manuscript_dir
  while (!identical(dirs[[1]], context$project_dir)) dirs <- c(dirname(dirs[[1]]), dirs)
  for (dir in dirs) {
    candidates <- file.path(dir, c("_metadata.yml", "_metadata.yaml"))
    sources <- c(sources, candidates[file.exists(candidates)])
  }
  meta <- list()
  for (file in sources) meta <- merge_manuscript_metadata(meta, read_metadata(file))
  document <- read_metadata(context$input, document = TRUE)
  inherited_format <- meta$format
  meta <- merge_manuscript_metadata(meta, document)
  if (!is.null(meta$project) && !is_yaml_mapping(meta$project)) {
    add("manuscript_metadata_invalid", "Project settings must be a mapping, such as project: {type: default}.", "project",
        file = if (is.null(context$project_file)) context$input else context$project_file)
  }
  # Respect document format selection rather than adding project output formats.
  if (!is.null(document$format)) {
    selected_format <- document$format
    if (is_text_scalar(selected_format)) selected_format <- stats::setNames(list("default"), selected_format)
    meta$format <- selected_format
    if (is_yaml_mapping(selected_format) && is_yaml_mapping(inherited_format)) {
      for (key in names(selected_format)) {
        old <- inherited_format[[key]]
        new <- selected_format[[key]]
        if (identical(new, "default")) new <- list()
        if (is_yaml_mapping(old) && is_yaml_mapping(new)) meta$format[[key]] <- merge_manuscript_metadata(old, new)
      }
    }
  }
  local_configs <- if (is.null(context$project_file)) character() else paste0(context$project_file, ".local")
  if (nzchar(Sys.getenv("QUARTO_PROFILE")) || any(file.exists(local_configs))) {
    add("manuscript_unsupported", "Profiles and local project overrides require Quarto-specific evaluation.", "profile",
        hint = "Remove active profiles/local overrides or render directly with Quarto after manual validation.")
  }
  formats <- if (is_text_scalar(meta$format)) meta$format else if (is_yaml_mapping(meta$format)) names(meta$format) else character()
  if (!is.null(output_format)) {
    if (!is_text_scalar(output_format)) {
      add("manuscript_format_invalid", "output_format must be one non-empty format name.", "format")
    }
    formats <- output_format
  }
  if (length(formats) != 1L || !identical(formats, "typstR-typst")) {
    add("manuscript_format_invalid", "Select the bundled typstR-typst output format.", "format",
        hint = "Use format: {typstR-typst: default}; choose workingpaper, article or brief in typstR.format-variant.")
  } else if (is_yaml_mapping(meta$format) && is_yaml_mapping(meta$format[[formats]])) {
    meta <- merge_manuscript_metadata(meta, meta$format[[formats]])
  } else if (is_yaml_mapping(meta$format) && !is.null(meta$format[[formats]]) && !identical(meta$format[[formats]], "default")) {
    add("manuscript_format_invalid", "Format options must be a mapping or default.", "format")
  }
  if (!is_text_scalar(meta$title)) add("manuscript_metadata_invalid", "A non-empty title is required for all publication variants.", "title")
  for (key in intersect(names(meta), c("subtitle", "abstract"))) {
    if (!is_text_scalar(meta[[key]])) add("manuscript_metadata_invalid", paste(key, "must be non-empty text."), key)
  }
  typ <- meta$typstR
  if (!is.null(typ) && !is_yaml_mapping(typ)) {
    add("manuscript_metadata_invalid", "typstR must be a mapping.", "typstR")
    typ <- list()
  }
  variant <- if (is.null(typ$`format-variant`)) "workingpaper" else typ$`format-variant`
  if (!is_text_scalar(variant) || !variant %in% c("workingpaper", "article", "brief")) {
    add("manuscript_format_invalid", "Unknown publication variant.", "typstR.format-variant")
  }
  for (key in intersect(names(typ), c("logo", "primary-font", "title-font", "footer", "report-number", "abstract-label", "acknowledgements", "funding", "data-availability", "code-availability", "disclaimer-text", "accent-color"))) {
    if (!is_text_scalar(typ[[key]])) add("manuscript_metadata_invalid", paste(key, "must be non-empty text."), paste0("typstR.", key))
  }
  for (key in intersect(names(typ), c("anonymized", "disclaimer-page"))) {
    if (!is.logical(typ[[key]]) || length(typ[[key]]) != 1L || is.na(typ[[key]])) add("manuscript_metadata_invalid", paste(key, "must be true or false."), paste0("typstR.", key))
  }
  for (key in intersect(names(typ), c("keywords", "jel"))) {
    if (!is_text_sequence(typ[[key]])) add("manuscript_metadata_invalid", paste(key, "must contain text values."), paste0("typstR.", key))
  }
  if (is_text_sequence(typ$jel) && any(!grepl("^[A-Z][0-9]{1,2}$", unlist(typ$jel)))) add("manuscript_metadata_invalid", "Invalid JEL code.", "typstR.jel")
  if (!is.null(typ$`disclaimer-position`) && !identical(typ$`disclaimer-position`, "first") && !identical(typ$`disclaimer-position`, "last")) add("manuscript_metadata_invalid", "Disclaimer position must be first or last.", "typstR.disclaimer-position")
  if (is_text_scalar(typ$`accent-color`) && !grepl("^#[0-9a-fA-F]{6}$", typ$`accent-color`)) add("manuscript_metadata_invalid", "Accent color must be a six-digit hex color.", "typstR.accent-color")
  if (!is.null(typ$margins)) {
    if (!is_yaml_mapping(typ$margins) || any(!names(typ$margins) %in% c("x", "y")) ||
        any(!vapply(typ$margins, function(x) is_text_scalar(x) && grepl("^[0-9]+(\\.[0-9]+)?(in|cm|mm|pt|em)$", x), logical(1)))) {
      add("manuscript_metadata_invalid", "Margins must map x/y to lengths such as 1in or 25mm.", "typstR.margins")
    }
  }

  # Author names may use Quarto's string or structured-name representation.
  authors <- meta$author
  if (is.character(authors)) authors <- as.list(authors)
  if (is_yaml_mapping(authors) && length(authors)) authors <- list(authors)
  if (!is.null(authors) && !is.list(authors)) {
    add("manuscript_metadata_invalid", "author must be text, an author mapping, or a sequence of authors.", "author")
    authors <- list()
  }
  affiliations <- meta$affiliations
  if (!is.null(affiliations) && (!is.list(affiliations) || !is.null(names(affiliations)))) {
    add("manuscript_metadata_invalid", "affiliations must be a sequence of mappings.", "affiliations")
    affiliations <- list()
  }
  ids <- character()
  for (aff in affiliations) {
    if (!is_yaml_mapping(aff) || !is_text_scalar(aff$id) || !is_text_scalar(aff$name)) {
      add("manuscript_metadata_invalid", "Each affiliation needs text id and name.", "affiliations")
    } else ids <- c(ids, aff$id)
  }
  if (anyDuplicated(ids)) add("manuscript_metadata_invalid", "Affiliation IDs must be unique.", "affiliations")
  for (i in seq_along(authors)) {
    a <- authors[[i]]
    if (is_text_scalar(a)) next
    field <- paste0("author[", i, "]")
    if (!is_yaml_mapping(a)) {
      add("manuscript_metadata_invalid", "Each author must be text or a mapping.", field)
      next
    }
    name <- a$name
    if (is_yaml_mapping(name)) name <- if (!is.null(name$literal)) name$literal else paste(name$given, name$family)
    if (!is_text_scalar(name)) add("manuscript_metadata_invalid", "Author name must be non-empty text.", paste0(field, ".name"))
    for (key in intersect(names(a), c("email", "orcid"))) {
      if (!is_text_scalar(a[[key]])) add("manuscript_metadata_invalid", paste(key, "must be text."), paste0(field, ".", key))
    }
    if (is_text_scalar(a$email) && !grepl("^[^[:space:]@]+@[^[:space:]@]+\\.[^[:space:]@]+$", a$email)) add("manuscript_metadata_invalid", "Malformed author email.", paste0(field, ".email"))
    if (is_text_scalar(a$orcid) && !grepl("^[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9X]$", a$orcid)) add("manuscript_metadata_invalid", "Malformed ORCID.", paste0(field, ".orcid"))
    if (!is.null(a$corresponding) && (!is.logical(a$corresponding) || length(a$corresponding) != 1L || is.na(a$corresponding))) add("manuscript_metadata_invalid", "corresponding must be true or false.", paste0(field, ".corresponding"))
    refs <- a$affiliation
    if (is_text_sequence(refs) && length(ids) && any(!unlist(refs) %in% ids)) add("manuscript_metadata_invalid", "Author references undefined affiliation IDs.", paste0(field, ".affiliation"))
    if (!is.null(refs) && !is_text_sequence(refs)) {
      entries <- if (is_yaml_mapping(refs)) list(refs) else refs
      if (!is.list(entries) || !all(vapply(entries, function(x) is_yaml_mapping(x) && (is_text_scalar(x$name) || is_text_scalar(x$ref)), logical(1)))) {
        add("manuscript_metadata_invalid", "Author affiliations must be text references or named institution mappings.", paste0(field, ".affiliation"))
      } else {
        for (entry in entries) {
          if (is_text_scalar(entry$ref) && !entry$ref %in% ids) add("manuscript_metadata_invalid", "Author references undefined affiliation IDs.", paste0(field, ".affiliation"))
        }
      }
    }
  }

  check_resource <- function(value, field) {
    if (!is_text_sequence(value)) {
      add("manuscript_metadata_invalid", paste(field, "must name local files."), field)
      return(invisible(NULL))
    }
    for (file in unlist(value, use.names = FALSE)) {
      if (grepl("^[A-Za-z][A-Za-z0-9+.-]*://", file)) {
        add("manuscript_unsupported", "Remote resources cannot be validated reproducibly.", field, hint = "Download the resource and configure a local file.")
      } else if (!file.exists(file) || dir.exists(file)) {
        add("manuscript_resource_missing", paste("Configured resource does not exist:", file), field, file,
            "Create the file or correct its path relative to the YAML file that declares it.")
      }
    }
  }
  for (key in intersect(names(meta), c("bibliography", "csl"))) {
    check_resource(meta[[key]], key)
  }
  if (!is.null(meta$references)) {
    refs <- meta$references
    if (!is.list(refs) || !is.null(names(refs)) || !length(refs) ||
        !all(vapply(refs, function(x) is_yaml_mapping(x) && is_text_scalar(x$id), logical(1)))) {
      add("manuscript_metadata_invalid", "Inline references must be a sequence of mappings with text IDs.", "references")
    } else if (anyDuplicated(vapply(refs, `[[`, character(1), "id"))) {
      add("manuscript_metadata_invalid", "Inline reference IDs must be unique.", "references")
    }
  }
  if (!is.null(typ$logo)) check_resource(typ$logo, "typstR.logo")
  for (key in intersect(names(meta), c("include-in-header", "include-before-body", "include-after-body"))) {
    value <- meta[[key]]
    if (is_yaml_mapping(value) && !is.null(value$text)) {
      if (!is_text_scalar(value$text)) add("manuscript_metadata_invalid", "Inline include text must be non-empty text.", key)
      next
    }
    if (is_yaml_mapping(value)) value <- value$file
    check_resource(value, key)
  }
  body <- manuscript_prose_lines(readLines(context$input, warn = FALSE))
  narrative <- c(list(meta$abstract), unname(typ[intersect(names(typ),
    c("acknowledgements", "funding", "data-availability", "code-availability", "disclaimer-text"))]))
  for (text in Filter(is_text_scalar, narrative)) {
    body <- c(body, manuscript_prose_lines(strsplit(text, "\n", fixed = TRUE)[[1]]))
  }
  if (any(grepl("(^|[[:space:]\\[;])@[-A-Za-z0-9_:.]+", body)) && is.null(meta$bibliography) && is.null(meta$references)) {
    add("manuscript_resource_missing", "Citations require bibliography or inline references.", "bibliography",
        hint = "Set bibliography to a local .bib/CSL file, or supply Quarto inline references.")
  }
  if (isTRUE(check_environment)) {
    checks <- collect_environment_checks(context$extension_dir)
    if (!environment_checks_pass(checks)) diagnostics <- c(diagnostics, diagnostics_from_environment_checks(checks, context$extension_dir))
  } else checks <- list()
  if (length(diagnostics)) {
    diagnostics <- sort_diagnostics(diagnostics)
    emit_diagnostics_error(diagnostics, diagnostics[[1]]$message, diagnostics[[1]]$hint)
  }
  structure(list(ok = TRUE, path = context$input, context = context, metadata = meta, checks = checks),
            class = c("typstR_validation_report", "list"))
}
