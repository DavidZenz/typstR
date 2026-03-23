mock_quarto_unavailable <- function() {
  if (nzchar(system.file(package = "typstR"))) {
    env <- asNamespace("typstR")
    old <- get("quarto_available", envir = env)
    was_locked <- bindingIsLocked("quarto_available", env)

    if (was_locked) {
      unlockBinding("quarto_available", env)
    }

    assign("quarto_available", function() FALSE, envir = env)

    withr::defer({
      if (bindingIsLocked("quarto_available", env)) {
        unlockBinding("quarto_available", env)
      }
      assign("quarto_available", old, envir = env)
      if (was_locked) {
        lockBinding("quarto_available", env)
      }
    })

    return(invisible(NULL))
  }

  env <- environment(render_pub)
  old <- get("quarto_available", envir = env)
  assign("quarto_available", function() FALSE, envir = env)
  withr::defer(assign("quarto_available", old, envir = env))
}

test_that("render_pub() aborts cleanly when Quarto is unavailable", {
  mock_quarto_unavailable()

  expect_error(
    render_pub("paper.qmd", open = FALSE),
    "Quarto is not installed or not on PATH\\."
  )
})

test_that("render_working_paper() aborts cleanly when Quarto is unavailable", {
  mock_quarto_unavailable()

  expect_error(
    render_working_paper("paper.qmd", open = FALSE),
    "Quarto is not installed or not on PATH\\."
  )
})
