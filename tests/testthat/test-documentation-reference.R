documentation_repo_root <- local({
  candidates <- c(
    getwd(),
    file.path(getwd(), ".."),
    file.path(getwd(), "..", "..")
  )

  for (candidate in candidates) {
    candidate <- normalizePath(candidate, winslash = "/", mustWork = FALSE)
    if (file.exists(file.path(candidate, "DESCRIPTION")) &&
        file.exists(file.path(candidate, "NAMESPACE")) &&
        dir.exists(file.path(candidate, "man"))) {
      return(candidate)
    }
  }

  NA_character_
})

resolve_documentation_file <- function(relative_path) {
  candidates <- c(
    relative_path,
    file.path("..", "..", relative_path),
    file.path(getwd(), relative_path),
    if (!is.na(documentation_repo_root)) file.path(documentation_repo_root, relative_path)
  )

  existing <- candidates[file.exists(candidates)]
  if (length(existing) == 0) {
    stop(sprintf("Could not locate %s", relative_path), call. = FALSE)
  }

  normalizePath(existing[[1]], winslash = "/", mustWork = TRUE)
}

namespace_exports <- function(path = resolve_documentation_file("NAMESPACE")) {
  lines <- readLines(path, warn = FALSE)
  exports <- grep("^export\\(", lines, value = TRUE)
  sub("^export\\((.*)\\)$", "\\1", exports)
}

rd_index <- function(man_dir = resolve_documentation_file("man")) {
  files <- Sys.glob(file.path(man_dir, "*.Rd"))

  stats::setNames(
    lapply(files, function(path) readLines(path, warn = FALSE)),
    basename(files)
  )
}

rd_file_for_alias <- function(alias, docs = rd_index()) {
  alias_pattern <- paste0("^\\\\alias\\{", alias, "\\}$")

  matches <- names(docs)[vapply(
    docs,
    function(lines) any(grepl(alias_pattern, lines)),
    logical(1)
  )]

  if (length(matches) == 0) {
    return(NA_character_)
  }

  matches[[1]]
}

rd_has_section <- function(lines, section) {
  any(grepl(paste0("^\\\\", section, "\\{"), lines))
}

test_that("exported help pages include title and description sections", {
  docs <- rd_index()
  issues <- character()

  for (alias in namespace_exports()) {
    rd_file <- rd_file_for_alias(alias, docs)

    if (is.na(rd_file)) {
      issues <- c(issues, paste0(alias, ": missing Rd file"))
      next
    }

    lines <- docs[[rd_file]]

    if (!rd_has_section(lines, "title")) {
      issues <- c(issues, paste0(alias, ": missing \\\\title{}"))
    }

    if (!rd_has_section(lines, "description")) {
      issues <- c(issues, paste0(alias, ": missing \\\\description{}"))
    }
  }

  expect_equal(length(issues), 0, info = paste(issues, collapse = "\n"))
})

test_that("exported function pages include arguments and examples sections", {
  docs <- rd_index()
  exempt_aliases <- "typstR-package"
  issues <- character()

  for (alias in setdiff(namespace_exports(), exempt_aliases)) {
    rd_file <- rd_file_for_alias(alias, docs)

    if (is.na(rd_file)) {
      issues <- c(issues, paste0(alias, ": missing Rd file"))
      next
    }

    lines <- docs[[rd_file]]

    if (!rd_has_section(lines, "arguments")) {
      issues <- c(issues, paste0(alias, ": missing \\\\arguments{}"))
    }

    if (!rd_has_section(lines, "examples")) {
      issues <- c(issues, paste0(alias, ": missing \\\\examples{}"))
    }
  }

  expect_equal(length(issues), 0, info = paste(issues, collapse = "\n"))
})

test_that("validate_render_environment keeps a generated help page", {
  exports <- namespace_exports()

  expect_true("validate_render_environment" %in% exports)
  expect_true(file.exists(resolve_documentation_file("man/validate_render_environment.Rd")))
})
