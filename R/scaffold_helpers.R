scaffold_copy_template_files <- function(path, template_dir) {
  template_src <- system.file(paste0("templates/", template_dir), package = "typstR", mustWork = TRUE)
  template_files <- fs::dir_ls(template_src, all = TRUE, recurse = FALSE)
  fs::file_copy(template_files, fs::path(path, fs::path_file(template_files)))
}

scaffold_copy_extension <- function(path) {
  ext_src <- system.file("quarto/extensions/typstR", package = "typstR", mustWork = TRUE)
  ext_dest <- fs::path(path, "_extensions", "typstR")

  fs::dir_create(fs::path(path, "_extensions"))
  fs::dir_copy(ext_src, ext_dest)
}

scaffold_apply_title_override <- function(path, title) {
  if (is.null(title)) {
    return(invisible(NULL))
  }

  qmd_path <- fs::path(path, "template.qmd")
  lines <- readLines(qmd_path)
  lines <- sub('^title: ".*"$', paste0('title: "', title, '"'), lines)
  writeLines(lines, qmd_path)

  invisible(NULL)
}

scaffold_emit_success <- function(path, label) {
  cli::cli_alert_success(sprintf("Created %s project at {.path {path}}", label))
  cli::cli_bullets(c(
    "*" = "{.file template.qmd}",
    "*" = "{.file _quarto.yml}",
    "*" = "{.file references.bib}",
    "*" = "{.file _extensions/typstR/}"
  ))

  invisible(NULL)
}

scaffold_project_from_template <- function(path, template_dir, success_label, title = NULL) {
  if (fs::dir_exists(path)) {
    cli::cli_abort(c(
      "Directory {.path {path}} already exists.",
      "i" = "Choose a different path or remove the existing directory."
    ))
  }

  fs::dir_create(path)
  scaffold_copy_template_files(path, template_dir)
  scaffold_copy_extension(path)
  scaffold_apply_title_override(path, title)
  scaffold_emit_success(path, success_label)

  invisible(path)
}
