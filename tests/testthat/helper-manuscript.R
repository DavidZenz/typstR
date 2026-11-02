manuscript_fixture <- function(yaml = c("title: Test", "format: typstR-typst"), body = "Body") {
  root <- withr::local_tempdir(.local_envir = parent.frame())
  file <- file.path(root, "paper.qmd")
  writeLines(c("---", yaml, "---", body), file)
  file
}

manuscript_codes <- function(path, ...) {
  err <- tryCatch(validate_manuscript(path, ...), error = identity)
  expect_s3_class(err, "typstR_diagnostics_error")
  vapply(err$diagnostics, `[[`, character(1), "code")
}
