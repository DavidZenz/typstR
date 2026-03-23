test_that("fig_note() outputs '*Note:* text' with trailing newline", {
  output <- capture.output(fig_note("Source: World Bank."))
  expect_equal(output, "*Note:* Source: World Bank.")
})

test_that("fig_note() concatenates multiple arguments with no separator", {
  output <- capture.output(fig_note("Part 1", " Part 2"))
  expect_equal(output, "*Note:* Part 1 Part 2")
})

test_that("fig_note() output starts with '*Note:*'", {
  output <- capture.output(fig_note("any text"))
  expect_true(startsWith(output, "*Note:*"))
})

test_that("fig_note() returns invisible", {
  result <- fig_note("Source: World Bank.")
  expect_equal(result, "Source: World Bank.")
})

test_that("tab_note() outputs '*Note:* text' with trailing newline", {
  output <- capture.output(tab_note("Source: IMF."))
  expect_equal(output, "*Note:* Source: IMF.")
})

test_that("tab_note() concatenates multiple arguments with no separator", {
  output <- capture.output(tab_note("Part 1", " Part 2"))
  expect_equal(output, "*Note:* Part 1 Part 2")
})

test_that("tab_note() output starts with '*Note:*'", {
  output <- capture.output(tab_note("any text"))
  expect_true(grepl("\\*Note:\\*", output))
})

test_that("tab_note() returns invisible", {
  result <- tab_note("Source: IMF.")
  expect_equal(result, "Source: IMF.")
})

test_that("appendix_title() outputs a markdown header with {.appendix}", {
  output <- capture.output(appendix_title("Data Sources"))
  expect_equal(output, "# Appendix: Data Sources {.appendix}")
})

test_that("appendix_title() respects level argument", {
  output <- capture.output(appendix_title("Methods", level = 2))
  expect_equal(output, "## Appendix: Methods {.appendix}")
})

test_that("appendix_title() contains {.appendix} class", {
  output <- capture.output(appendix_title("Data Sources"))
  expect_true(grepl("\\{\\.appendix\\}", output))
})

test_that("appendix_title() returns invisible title", {
  result <- appendix_title("Data Sources")
  expect_equal(result, "Data Sources")
})

test_that("appendix_title() errors when title is not a single string", {
  expect_error(appendix_title(123), "single character string")
  expect_error(appendix_title(c("a", "b")), "single character string")
})
