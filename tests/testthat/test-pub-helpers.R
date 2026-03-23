test_that("keywords() returns correct S3 class and structure", {
  result <- keywords("trade", "policy")
  expect_s3_class(result, "typstR_keywords")
  expect_s3_class(result, "list")
  expect_length(result, 2L)
  expect_equal(result[[1]], "trade")
  expect_equal(result[[2]], "policy")
})

test_that("keywords() with single value returns list of one", {
  result <- keywords("economics")
  expect_s3_class(result, "typstR_keywords")
  expect_length(result, 1L)
})

test_that("keywords() errors when given non-character input", {
  expect_error(keywords(123), "must be character")
  expect_error(keywords("trade", 456), "must be character")
})

test_that("jel_codes() returns correct S3 class and structure", {
  result <- jel_codes("F10", "L52")
  expect_s3_class(result, "typstR_jel")
  expect_s3_class(result, "list")
  expect_length(result, 2L)
  expect_equal(result[[1]], "F10")
  expect_equal(result[[2]], "L52")
})

test_that("jel_codes() accepts single-digit codes", {
  result <- jel_codes("F1", "L5")
  expect_s3_class(result, "typstR_jel")
  expect_length(result, 2L)
})

test_that("jel_codes() accepts single code", {
  result <- jel_codes("F10")
  expect_s3_class(result, "typstR_jel")
  expect_length(result, 1L)
})

test_that("jel_codes() errors on invalid codes", {
  expect_error(jel_codes("F10", "bad"), "Invalid JEL codes")
  expect_error(jel_codes("F10", "bad"), "bad")
})

test_that("jel_codes() errors on lowercase codes", {
  expect_error(jel_codes("f10"), "Invalid JEL codes")
})

test_that("jel_codes() errors on non-character input", {
  expect_error(jel_codes(123), "character")
})

test_that("report_number() returns correct S3 class and value", {
  result <- report_number("WP 001")
  expect_s3_class(result, "typstR_report_number")
  expect_s3_class(result, "character")
  expect_equal(as.character(result), "WP 001")
})

test_that("report_number() errors when given non-character input", {
  expect_error(report_number(123), "single character string")
})

test_that("report_number() errors when given vector", {
  expect_error(report_number(c("a", "b")), "single character string")
})

test_that("funding() returns correct S3 class and value", {
  result <- funding("ERC Grant 12345")
  expect_s3_class(result, "typstR_funding")
  expect_s3_class(result, "character")
  expect_equal(as.character(result), "ERC Grant 12345")
})

test_that("funding() errors when given vector", {
  expect_error(funding(c("a", "b")), "single character string")
})

test_that("funding() errors when given non-character input", {
  expect_error(funding(123), "single character string")
})

test_that("data_availability() returns correct S3 class", {
  result <- data_availability("Data at https://example.com")
  expect_s3_class(result, "typstR_data_availability")
  expect_s3_class(result, "character")
  expect_equal(as.character(result), "Data at https://example.com")
})

test_that("code_availability() returns correct S3 class", {
  result <- code_availability("Code at https://github.com/example")
  expect_s3_class(result, "typstR_code_availability")
  expect_s3_class(result, "character")
  expect_equal(as.character(result), "Code at https://github.com/example")
})
