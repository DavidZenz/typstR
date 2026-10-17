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

test_that("all scaffold defaults validate without Quarto", {
  root <- withr::local_tempdir()
  for (create in list(create_working_paper, create_article, create_policy_brief)) {
    project <- tempfile("valid scaffold ", tmpdir = root)
    create(project, open = FALSE)
    expect_true(validate_manuscript(project)$ok)
    expect_true(validate_manuscript(file.path(project, "template.qmd"))$ok)
  }
})

test_that("malformed YAML and invalid top-level shapes give structured errors", {
  for (yaml in list("title: [", "- sequence", "title: Test\ntitle: Again")) {
    file <- manuscript_fixture(yaml)
    expect_true("DIAG-MANUSCRIPT-001" %in% manuscript_codes(file))
  }
  file <- manuscript_fixture()
  writeLines(c("---", "title: Test"), file)
  expect_true("DIAG-MANUSCRIPT-001" %in% manuscript_codes(file))
})

test_that("format, title and optional metadata shapes are validated", {
  cases <- list(
    c("title: Test", "format: html"),
    c("title: Test", "format: {typstR-typst: 123}"),
    c("title: Test", "format: typstR-typst", "typstR: {format-variant: unknown}"),
    c("title: 123", "format: typstR-typst"),
    c("title: Test", "format: typstR-typst", "typstR: text"),
    c("title: Test", "format: typstR-typst", "typstR: {anonymized: yesplease}"),
    c("title: Test", "format: typstR-typst", "author: [42]"),
    c("title: Test", "format: typstR-typst", "affiliations: [bad]"),
    c("title: Test", "format: typstR-typst", "typstR: {jel: [invalid]}"),
    c("title: Test", "format: typstR-typst", "typstR: {accent-color: blue}")
  )
  for (yaml in cases) {
    codes <- manuscript_codes(manuscript_fixture(yaml))
    expect_true(any(codes %in% c("DIAG-MANUSCRIPT-002", "DIAG-MANUSCRIPT-003")))
  }
  # Optional publication fields remain optional in every variant.
  for (variant in c("workingpaper", "article", "brief")) {
    file <- manuscript_fixture(c("title: Minimal", "format: typstR-typst", paste0("typstR: {format-variant: ", variant, "}")))
    expect_true(validate_manuscript(file)$ok)
  }
})

test_that("configured files and citations fail before invoking Quarto", {
  for (field in c("bibliography", "csl", "include-before-body")) {
    file <- manuscript_fixture(c("title: Test", "format: typstR-typst", paste0(field, ": missing.file")))
    expect_true("DIAG-MANUSCRIPT-004" %in% manuscript_codes(file))
  }
  file <- manuscript_fixture(c("title: Test", "format: typstR-typst", "typstR: {logo: missing.png}"))
  expect_true("DIAG-MANUSCRIPT-004" %in% manuscript_codes(file))
  file <- manuscript_fixture(body = "See @smith2020.")
  expect_true("DIAG-MANUSCRIPT-004" %in% manuscript_codes(file))
  expect_true("DIAG-MANUSCRIPT-005" %in% manuscript_codes(manuscript_fixture(c("title: Test", "format: typstR-typst", "bibliography: https://example.org/refs.bib"))))
})

test_that("project and directory settings merge with document resources using source directories", {
  root <- withr::local_tempdir()
  dir.create(file.path(root, "nested space"))
  writeLines(c("project: default", "title: Project title", "bibliography: [root.bib]", "format: {typstR-typst: {toc: true}}"), file.path(root, "_quarto.yml"))
  writeLines("", file.path(root, "root.bib"))
  nested <- file.path(root, "nested space")
  writeLines(c("bibliography: [local.bib]", "typstR: {footer: Directory}"), file.path(nested, "_metadata.yml"))
  writeLines("", file.path(nested, "local.bib"))
  file <- file.path(nested, "paper.qmd")
  writeLines(c("---", "title: Document title", "format: {typstR-typst: default}", "---", "Cite @key."), file)
  withr::local_dir(tempdir())
  report <- validate_manuscript(file)
  expect_identical(report$metadata$title, "Document title")
  expect_identical(report$metadata$typstR$footer, "Directory")
  expect_true(report$metadata$toc)
  expect_equal(unname(unlist(report$metadata$bibliography)), file.path(normalizePath(c(root, nested), winslash = "/"), c("root.bib", "local.bib")))
  unlink(file.path(root, "root.bib"))
  expect_true("DIAG-MANUSCRIPT-004" %in% manuscript_codes(file))
})

test_that("unsupported dynamic configuration is explicit and diagnostics are deterministic", {
  file <- manuscript_fixture(c("title: Test", "format: typstR-typst", "metadata-files: extra.yml", "bibliography: missing.bib", "typstR: {logo: missing.png}"))
  first <- tryCatch(validate_manuscript(file), error = identity)
  second <- tryCatch(validate_manuscript(file), error = identity)
  expect_identical(first$diagnostics, second$diagnostics)
  expect_true("DIAG-MANUSCRIPT-005" %in% vapply(first$diagnostics, `[[`, character(1), "code"))
  for (entry in first$diagnostics) {
    expect_identical(entry$severity, "error")
    expect_true(nzchar(entry$hint))
    expect_true(nzchar(entry$location$file))
    expect_true(nzchar(entry$location$field))
  }
  rendered <- tryCatch(render_pub(file, open = FALSE), error = identity)
  # Resource/metadata checks are identical; render also checks runtime.
  expect_identical(Filter(function(x) startsWith(x$code, "DIAG-MANUSCRIPT"), rendered$diagnostics), first$diagnostics)
})

test_that("valid local resources, inline references and author IDs are accepted", {
  file <- manuscript_fixture(c(
    "title: Test", "format: typstR-typst", "bibliography: refs.bib",
    "csl: style.csl", "include-before-body: {file: intro.typ}",
    "typstR: {logo: logo.svg, margins: {x: 1in}}",
    "author: [{name: Ada, affiliation: [econ], email: ada@example.org}]",
    "affiliations: [{id: econ, name: Institute}]"
  ))
  for (name in c("refs.bib", "style.csl", "intro.typ", "logo.svg")) writeLines("", file.path(dirname(file), name))
  expect_true(validate_manuscript(file)$ok)
  lines <- readLines(file)
  writeLines(sub("affiliation: \\[econ\\]", "affiliation: [{ref: econ}]", lines), file)
  expect_true(validate_manuscript(file)$ok)
  writeLines(sub("affiliation: \\[econ\\]", "affiliation: [missing]", lines), file)
  expect_true("DIAG-MANUSCRIPT-003" %in% manuscript_codes(file))
  file <- manuscript_fixture(c("title: Test", "format: typstR-typst", "references: [{id: key, title: Example}]"), body = "@key")
  expect_true(validate_manuscript(file)$ok)
})

test_that("extension preflight detects missing required templates", {
  root <- withr::local_tempdir()
  create_article(file.path(root, "article"), open = FALSE)
  project <- file.path(root, "article")
  unlink(file.path(project, "_extensions", "typstR", "templates", "branding.typ"))
  expect_false(probe_extension(project)$ok)
  expect_identical(probe_extension(project)$missing_files, "templates/branding.typ")
})

test_that("scalar document format inherits selected project format resources", {
  file <- manuscript_fixture(c("title: Test", "format: typstR-typst"))
  root <- dirname(file)
  writeLines(c("project: default", "format:", "  typstR-typst:", "    typstR:", "      logo: missing.svg"), file.path(root, "_quarto.yml"))
  expect_true("DIAG-MANUSCRIPT-004" %in% manuscript_codes(file))
  writeLines("<svg/>", file.path(root, "missing.svg"))
  expect_true(validate_manuscript(file)$ok)
})
