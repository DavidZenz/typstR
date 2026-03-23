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

.load_scaffolding_functions <- function() {
  repo_root <- .repo_root()
  source(file.path(repo_root, "R", "create_working_paper.R"), local = FALSE)
  source(file.path(repo_root, "R", "create_article.R"), local = FALSE)
  source(file.path(repo_root, "R", "create_policy_brief.R"), local = FALSE)
}

test_that("create_working_paper() scaffolds expected files and title override", {
  repo_root <- .repo_root()
  .load_scaffolding_functions()

  withr::with_tempdir({
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

    assign("system.file", local_system_file, envir = environment(create_working_paper))
    on.exit(rm("system.file", envir = environment(create_working_paper)), add = TRUE)

    create_working_paper("wp-project", title = "My Working Paper", open = FALSE)

    expect_true(file.exists("wp-project/template.qmd"))
    expect_true(file.exists("wp-project/_quarto.yml"))
    expect_true(file.exists("wp-project/references.bib"))
    expect_true(dir.exists("wp-project/_extensions/typstR"))

    qmd <- readLines("wp-project/template.qmd")
    expect_true(any(grepl('title: "My Working Paper"', qmd, fixed = TRUE)))
    expect_true(any(grepl("report-number", qmd, fixed = TRUE)))
  })
})

test_that("create_article() scaffolds expected files and article markers", {
  repo_root <- .repo_root()
  .load_scaffolding_functions()

  withr::with_tempdir({
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

    assign("system.file", local_system_file, envir = environment(create_article))
    on.exit(rm("system.file", envir = environment(create_article)), add = TRUE)

    create_article("article-project", title = "My Article", open = FALSE)

    expect_true(file.exists("article-project/template.qmd"))
    expect_true(file.exists("article-project/_quarto.yml"))
    expect_true(file.exists("article-project/references.bib"))
    expect_true(dir.exists("article-project/_extensions/typstR"))

    qmd <- readLines("article-project/template.qmd")
    expect_true(any(grepl('title: "My Article"', qmd, fixed = TRUE)))
    expect_true(any(grepl("format-variant: article", qmd, fixed = TRUE)))
  })
})

test_that("create_policy_brief() scaffolds expected files and brief markers", {
  repo_root <- .repo_root()
  .load_scaffolding_functions()

  withr::with_tempdir({
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

    assign("system.file", local_system_file, envir = environment(create_policy_brief))
    on.exit(rm("system.file", envir = environment(create_policy_brief)), add = TRUE)

    create_policy_brief("brief-project", title = "My Brief", open = FALSE)

    expect_true(file.exists("brief-project/template.qmd"))
    expect_true(file.exists("brief-project/_quarto.yml"))
    expect_true(file.exists("brief-project/references.bib"))
    expect_true(dir.exists("brief-project/_extensions/typstR"))

    qmd <- readLines("brief-project/template.qmd")
    expect_true(any(grepl('title: "My Brief"', qmd, fixed = TRUE)))
    expect_true(any(grepl("format-variant: brief", qmd, fixed = TRUE)))
  })
})
