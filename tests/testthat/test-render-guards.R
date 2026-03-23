test_that("render_pub() aborts cleanly when Quarto is unavailable", {
  local_mocked_bindings(
    quarto_available = function() FALSE,
    .package = "quarto"
  )

  expect_error(
    render_pub("paper.qmd", open = FALSE),
    "Quarto is not installed or not on PATH\\."
  )
})

test_that("render_working_paper() aborts cleanly when Quarto is unavailable", {
  local_mocked_bindings(
    quarto_available = function() FALSE,
    .package = "quarto"
  )

  expect_error(
    render_working_paper("paper.qmd", open = FALSE),
    "Quarto is not installed or not on PATH\\."
  )
})
