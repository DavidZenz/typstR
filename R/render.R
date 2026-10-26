#' Render a Quarto document to PDF
#'
#' Renders a Quarto document using the Quarto CLI after running the shared
#' environment validation checks that typstR uses before rendering.
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
#'   output_format = "typstR-typst",
#'   quiet = TRUE,
#'   open = FALSE
#' )
#' }
#' @export
render_pub <- function(input = NULL, output_format = NULL, quiet = FALSE,
                       open = interactive()) {
  # Resolve manuscript and project before probing the environment.
  context <- resolve_render_context(input)
  resolved_input <- context$input
  report <- validate_manuscript_context(context, output_format, check_environment = TRUE)
  pdf_path <- resolve_render_output(context, output_format, report$metadata)
  render_metadata <- list("typstR-extension-path" = as.character(fs::path_rel(
    file.path(context$extension_dir, "_extensions", "typstR"), start = context$manuscript_dir
  )))
  if (!is.null(report$metadata$typstR$logo)) {
    render_metadata$typstR <- list(logo = as.character(
      fs::path_rel(report$metadata$typstR$logo, start = context$manuscript_dir)
    ))
  }

  # Render via quarto R package (never shell out directly)
  render_args <- list(
    input = resolved_input,
    output_format = output_format,
    quiet = quiet
  )
  if (!is.null(render_metadata)) render_args$metadata <- render_metadata
  if (identical(report$checks$typst$provider, "standalone")) {
    previous_root <- Sys.getenv("TYPST_ROOT", unset = NA_character_)
    on.exit({
      if (is.na(previous_root)) Sys.unsetenv("TYPST_ROOT") else Sys.setenv(TYPST_ROOT = previous_root)
    }, add = TRUE)
    Sys.setenv(TYPST_ROOT = if (is.null(context$project_file)) context$extension_dir else context$project_dir)
  }
  do.call(quarto::quarto_render, render_args)

  # Open PDF in system viewer (locked decision: open = interactive())
  if (!fs::file_exists(pdf_path)) {
    cli::cli_abort("Rendering finished but the expected PDF is missing: {.path {pdf_path}}")
  }
  if (open) open_file(pdf_path)

  invisible(NULL)
}

# Ask Quarto for its effective output configuration rather than duplicating its
# project/format merge semantics. No document code is executed by inspect.
resolve_render_output <- function(context, output_format = NULL, metadata = list()) {
  format <- if (is.null(output_format)) "typstR-typst" else output_format
  info <- tryCatch(quarto::quarto_inspect(context$input, quiet = TRUE), error = function(error) {
    # Early inspect resolves document formats without its discovered project
    # context, so ancestor extensions fail even though rendering supports them.
    if (quarto::quarto_version() >= "1.5.0") stop(error)
    project <- quarto::quarto_inspect(context$project_dir, quiet = TRUE)
    list(formats = stats::setNames(list(list(pandoc = list(
      `output-file` = metadata[["output-file"]]
    ))), format), project = project)
  })
  selected <- info$formats[[format]]
  if (is.null(selected)) cli::cli_abort("Quarto did not resolve the {.val {format}} format.")
  filename <- selected$pandoc[["output-file"]]
  if (!is_text_scalar(filename)) filename <- paste0(fs::path_ext_remove(basename(context$input)), ".pdf")
  output_dir <- info$project$config$project[["output-dir"]]
  if (is_text_scalar(output_dir)) {
    root <- info$project$dir
    if (!is_text_scalar(root)) root <- context$project_dir
    if (dir.exists(root)) root <- as.character(fs::path_real(root))
    base <- fs::path_abs(output_dir, start = root)
    relative_dir <- fs::path_rel(context$manuscript_dir, start = root)
    base <- fs::path(base, relative_dir)
  } else base <- context$manuscript_dir
  as.character(fs::path_abs(filename, start = base))
}

#' Render a working paper to PDF
#'
#' Convenience wrapper that renders a document using the `typstR-typst`
#' working-paper format.
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
