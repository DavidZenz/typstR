get_validation_fn <- function(name) getFromNamespace(name, "typstR")

with_validation_bindings <- function(bindings, code) {
  do.call(testthat::local_mocked_bindings,
          c(bindings, list(.package = "typstR", .env = environment())))
  force(code)
}

passing_checks <- function(path) {
  list(
    quarto = list(
      ok = TRUE,
      available = TRUE,
      version = "1.5.1"
    ),
    typst = list(
      ok = TRUE,
      available = TRUE,
      version = "0.13.1",
      raw = "typst 0.13.1"
    ),
    quarto_floor = list(
      ok = TRUE,
      required = ">=1.4.11",
      compatible = TRUE,
      available = TRUE
    ),
    extension = list(
      ok = TRUE,
      present = TRUE,
      manifest = as.character(fs::path_abs(file.path(path, "_extensions", "typstR", "_extension.yml")))
    )
  )
}

failing_checks <- function(path) {
  list(
    quarto = list(
      ok = FALSE,
      available = FALSE,
      version = NA_character_,
      reason = "quarto CLI unavailable"
    ),
    typst = list(
      ok = FALSE,
      available = FALSE,
      version = NA_character_,
      raw = NA_character_,
      reason = "quarto typst --version failed"
    ),
    quarto_floor = list(
      ok = FALSE,
      required = ">=1.4.11",
      compatible = FALSE,
      available = FALSE
    ),
    extension = list(
      ok = FALSE,
      present = FALSE,
      manifest = as.character(fs::path_abs(file.path(path, "_extensions", "typstR", "_extension.yml")))
    )
  )
}
