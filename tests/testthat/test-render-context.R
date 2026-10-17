test_that("all scaffolders resolve file, directory and NULL inputs outside the project", {
  root <- withr::local_tempdir(pattern = "outside project ")
  withr::local_dir(root)
  observed <- character()
  testthat::local_mocked_bindings(
    quarto_render = function(input, output_format, quiet, metadata) {
      observed <<- c(observed, input)
    }, .package = "quarto"
  )
  testthat::local_mocked_bindings(
    probe_quarto = function() list(ok = TRUE, available = TRUE),
    probe_typst = function(x) list(ok = TRUE),
    probe_quarto_floor = function(x, required) list(ok = TRUE),
    .package = "typstR"
  )

  for (create in list(create_working_paper, create_article, create_policy_brief)) {
    project <- tempfile("my paper ", tmpdir = root)
    create(project, open = FALSE)
    qmd <- file.path(project, "template.qmd")
    context <- resolve_render_context(qmd)
    expect_identical(context$project_dir, normalizePath(project, winslash = "/"))
    expect_identical(context$extension_dir, context$project_dir)
    render_pub(qmd, open = FALSE)
    render_pub(project, open = FALSE)
    withr::with_dir(project, render_pub(NULL, open = FALSE))
    expect_identical(tail(observed, 3L), rep(normalizePath(qmd, winslash = "/"), 3L))
  }

  # Literal README workflow from its parent directory.
  create_working_paper("my-paper", open = FALSE)
  expect_no_error(render_working_paper("my-paper/template.qmd", open = FALSE))
})

test_that("context finds the nearest project and ancestor extension for nested manuscripts", {
  root <- withr::local_tempdir()
  create_article(file.path(root, "project"), open = FALSE)
  project <- file.path(root, "project")
  dir.create(file.path(project, "chapters"))
  qmd <- file.path(project, "chapters", "paper.qmd")
  writeLines("---\ntitle: Nested\n---", qmd)
  context <- resolve_render_context(qmd)
  expect_identical(context$extension_dir, normalizePath(project, winslash = "/"))
  expect_identical(context$project_file, file.path(context$project_dir, "_quarto.yml"))
  writeLines("project: default", file.path(dirname(qmd), "_quarto.yml"))
  context <- resolve_render_context(qmd)
  expect_identical(context$extension_dir, dirname(normalizePath(qmd, winslash = "/")))
})

test_that("input errors precede runtime checks and keep their diagnostic codes", {
  root <- withr::local_tempdir()
  withr::local_dir(root)
  for (input in list("missing.qmd", root)) {
    err <- tryCatch(render_pub(input, open = FALSE), error = identity)
    expect_s3_class(err, "typstR_diagnostics_error")
    expect_true(err$diagnostics[[1]]$code %in% c("DIAG-INPUT-003", "DIAG-INPUT-001"))
  }
  writeLines("", "a.qmd")
  writeLines("", "b.qmd")
  err <- tryCatch(render_pub(NULL, open = FALSE), error = identity)
  expect_identical(err$diagnostics[[1]]$code, "DIAG-INPUT-002")
  expect_error(resolve_input(NA_character_), "single non-empty")
})
