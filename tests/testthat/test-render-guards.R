test_that("render_pub() aborts cleanly when Quarto is unavailable", {
  env <- environment(render_pub)
  old <- get("quarto_available", envir = env)
  assign("quarto_available", function() FALSE, envir = env)
  on.exit(assign("quarto_available", old, envir = env), add = TRUE)

  expect_error(
    render_pub("paper.qmd", open = FALSE),
    "Quarto is not installed or not on PATH\\."
  )
})

test_that("render_working_paper() aborts cleanly when Quarto is unavailable", {
  env <- environment(render_working_paper)
  old <- get("quarto_available", envir = env)
  assign("quarto_available", function() FALSE, envir = env)
  on.exit(assign("quarto_available", old, envir = env), add = TRUE)

  expect_error(
    render_working_paper("paper.qmd", open = FALSE),
    "Quarto is not installed or not on PATH\\."
  )
})
