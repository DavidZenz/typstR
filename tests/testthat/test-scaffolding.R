.repo_root <- function() {
  candidates <- c(
    getwd(),
    file.path(getwd(), ".."),
    file.path(getwd(), "..", "..")
  )

  for (candidate in candidates) {
    candidate <- normalizePath(candidate, winslash = "/", mustWork = FALSE)
    if (file.exists(file.path(candidate, "DESCRIPTION")) &&
        dir.exists(file.path(candidate, "R")) &&
        dir.exists(file.path(candidate, "inst"))) {
      return(candidate)
    }
  }

  stop("Could not locate repository root for scaffolding tests.")
}

.using_installed_package <- function() {
  nzchar(system.file(package = "typstR")) &&
    exists("create_working_paper", mode = "function", inherits = TRUE) &&
    exists("create_article", mode = "function", inherits = TRUE) &&
    exists("create_policy_brief", mode = "function", inherits = TRUE)
}

.load_scaffolding_functions <- function() {
  if (.using_installed_package()) {
    return(NULL)
  }

  repo_root <- .repo_root()
  source(file.path(repo_root, "R", "create_working_paper.R"), local = FALSE)
  source(file.path(repo_root, "R", "create_article.R"), local = FALSE)
  source(file.path(repo_root, "R", "create_policy_brief.R"), local = FALSE)

  repo_root
}

.with_template_lookup <- function(fn_name, repo_root, code) {
  fn <- get(fn_name, inherits = TRUE)

  if (is.null(repo_root)) {
    force(code)
    return(invisible(NULL))
  }

  local_system_file <- function(..., package = NULL, mustWork = FALSE) {
    rel <- file.path(...)
    if (identical(package, "typstR")) {
      path <- file.path(repo_root, "inst", rel)
      if (dir.exists(path) || file.exists(path)) {
        return(path)
      }
    }
    base::system.file(..., package = package, mustWork = mustWork)
  }

  assign("system.file", local_system_file, envir = environment(fn))
  on.exit(rm("system.file", envir = environment(fn)), add = TRUE)

  force(code)
}

.scaffold_specs <- function() {
  list(
    list(
      label = "working paper",
      fn_name = "create_working_paper",
      project = "wp-project",
      format_variant = NULL,
      expects_jel = TRUE,
      expects_report_number = TRUE
    ),
    list(
      label = "article",
      fn_name = "create_article",
      project = "article-project",
      format_variant = "article",
      expects_jel = TRUE,
      expects_report_number = FALSE
    ),
    list(
      label = "policy brief",
      fn_name = "create_policy_brief",
      project = "brief-project",
      format_variant = "brief",
      expects_jel = FALSE,
      expects_report_number = TRUE
    )
  )
}

.shared_baseline_markers <- function() {
  c(
    "author:",
    "affiliations:",
    "abstract: |",
    "bibliography: references.bib",
    "format:",
    "typstR:",
    "keywords:",
    "funding: |",
    "## References"
  )
}

.guidance_markers <- function() {
  c(
    "# Edit first: update title, authors, and affiliations.",
    "# Replace abstract with your project summary before sharing.",
    "<!-- Replace this starter narrative with your project-specific text. -->"
  )
}

.scaffold_project <- function(spec, repo_root, title) {
  .with_template_lookup(spec$fn_name, repo_root, {
    helper <- get(spec$fn_name, inherits = TRUE)
    helper(spec$project, title = title, open = FALSE)
  })

  list(
    project = spec$project,
    qmd = readLines(file.path(spec$project, "template.qmd"), warn = FALSE)
  )
}

test_that("create_* helpers scaffold shared baseline and only allowed format deltas", {
  repo_root <- .load_scaffolding_functions()

  withr::with_tempdir({
    for (spec in .scaffold_specs()) {
      output <- .scaffold_project(spec, repo_root, title = paste("Starter", spec$label))

      expect_true(file.exists(file.path(output$project, "template.qmd")), info = spec$label)
      expect_true(file.exists(file.path(output$project, "_quarto.yml")), info = spec$label)
      expect_true(file.exists(file.path(output$project, "references.bib")), info = spec$label)
      expect_true(dir.exists(file.path(output$project, "_extensions", "typstR")), info = spec$label)

      for (marker in .shared_baseline_markers()) {
        expect_true(any(grepl(marker, output$qmd, fixed = TRUE)),
          info = paste(spec$label, "missing baseline marker", marker)
        )
      }

      if (is.null(spec$format_variant)) {
        expect_false(any(grepl("format-variant:", output$qmd, fixed = TRUE)),
          info = paste(spec$label, "should not declare format-variant")
        )
      } else {
        expect_true(any(grepl(paste0("format-variant: ", spec$format_variant), output$qmd, fixed = TRUE)),
          info = paste(spec$label, "missing format-variant")
        )
      }

      expect_equal(any(grepl("jel:", output$qmd, fixed = TRUE)), spec$expects_jel,
        info = paste(spec$label, "JEL expectation mismatch")
      )
      expect_equal(any(grepl("report-number:", output$qmd, fixed = TRUE)), spec$expects_report_number,
        info = paste(spec$label, "report-number expectation mismatch")
      )
    }
  })
})

test_that("create_* helpers scaffold inline onboarding guidance near editable fields", {
  repo_root <- .load_scaffolding_functions()

  withr::with_tempdir({
    for (spec in .scaffold_specs()) {
      output <- .scaffold_project(spec, repo_root, title = paste("Guided", spec$label))

      for (marker in .guidance_markers()) {
        expect_true(any(grepl(marker, output$qmd, fixed = TRUE)),
          info = paste(spec$label, "missing guidance marker", marker)
        )
      }
    }
  })
})

test_that("create_* helpers preserve title override behavior", {
  repo_root <- .load_scaffolding_functions()

  withr::with_tempdir({
    for (spec in .scaffold_specs()) {
      title <- paste("Custom", tools::toTitleCase(spec$label))
      output <- .scaffold_project(spec, repo_root, title = title)
      expect_true(any(grepl(paste0('title: "', title, '"'), output$qmd, fixed = TRUE)),
        info = paste(spec$label, "title override did not persist")
      )
    }
  })
})