test_that("author() returns correct S3 class", {
  a <- author("Jane Doe")
  expect_s3_class(a, "typstR_author")
  expect_s3_class(a, "list")
  expect_equal(a$name, "Jane Doe")
})

test_that("author() stores all fields when provided", {
  a <- author("Jane Doe",
              affiliation = c("1", "2"),
              email = "j@e.org",
              corresponding = TRUE)
  expect_equal(a$affiliation, c("1", "2"))
  expect_equal(a$email, "j@e.org")
  expect_equal(a$corresponding, TRUE)
})

test_that("author() accepts valid ORCID", {
  expect_no_error(author("Jane Doe", orcid = "0000-0001-2345-6789"))
  expect_no_error(author("Jane Doe", orcid = "0000-0001-2345-678X"))
})

test_that("author() rejects invalid ORCID format", {
  expect_error(author("Jane Doe", orcid = "invalid"), "Invalid ORCID format")
  expect_error(author("Jane Doe", orcid = "0000-0001-2345-678"), "Invalid ORCID format")
})

test_that("author() removes NULL fields", {
  a <- author("Jane Doe")
  expect_null(a$affiliation)
  expect_null(a$email)
  expect_null(a$orcid)
  # NULL fields should not be present at all (Filter(Negate(is.null)) removes them)
  expect_false("affiliation" %in% names(a))
  expect_false("email" %in% names(a))
  expect_false("orcid" %in% names(a))
})

test_that("affiliation() returns correct S3 class", {
  aff <- affiliation("1", "MIT")
  expect_s3_class(aff, "typstR_affiliation")
  expect_s3_class(aff, "list")
  expect_equal(aff$id, "1")
  expect_equal(aff$name, "MIT")
})

test_that("affiliation() stores optional fields", {
  aff <- affiliation("1", "MIT",
                     department = "Econ",
                     address = "Cambridge",
                     country = "USA")
  expect_equal(aff$department, "Econ")
  expect_equal(aff$address, "Cambridge")
  expect_equal(aff$country, "USA")
})

test_that("affiliation() requires id argument", {
  expect_error(affiliation(name = "MIT"))
})

test_that("manuscript_meta() returns correct S3 class", {
  m <- manuscript_meta(
    authors = list(author("Jane", affiliation = "1")),
    affiliations = list(affiliation("1", "MIT"))
  )
  expect_s3_class(m, "typstR_meta")
  expect_s3_class(m, "list")
})

test_that("manuscript_meta() succeeds with valid cross-references", {
  expect_no_error(
    manuscript_meta(
      authors = list(author("Jane", affiliation = "1")),
      affiliations = list(affiliation("1", "MIT"))
    )
  )
})

test_that("manuscript_meta() errors on dangling affiliation references", {
  expect_error(
    manuscript_meta(
      authors = list(author("Jane", affiliation = "99")),
      affiliations = list(affiliation("1", "MIT"))
    ),
    "undefined affiliation IDs"
  )
  expect_error(
    manuscript_meta(
      authors = list(author("Jane", affiliation = "99")),
      affiliations = list(affiliation("1", "MIT"))
    ),
    "99"
  )
})

test_that("manuscript_meta() populates typstR block with optional fields", {
  m <- manuscript_meta(
    authors = list(author("Jane")),
    affiliations = list(),
    keywords = c("economics", "labor"),
    jel = c("J01", "J21"),
    acknowledgements = "Thanks",
    report_number = "WP-001",
    funding = "NSF",
    data_availability = "Available on request",
    code_availability = "GitHub"
  )
  expect_true(!is.null(m[["typstR"]]))
  expect_equal(m[["typstR"]][["keywords"]], c("economics", "labor"))
  expect_equal(m[["typstR"]][["jel"]], c("J01", "J21"))
  expect_equal(m[["typstR"]][["acknowledgements"]], "Thanks")
})

test_that("yaml::as.yaml() on manuscript_meta produces valid YAML", {
  m <- manuscript_meta(
    authors = list(author("Jane", affiliation = "1")),
    affiliations = list(affiliation("1", "MIT"))
  )
  yaml_str <- yaml::as.yaml(unclass(m))
  expect_true(is.character(yaml_str))
  expect_true(nchar(yaml_str) > 0)
  expect_true(grepl("author:", yaml_str))
  expect_true(grepl("affiliations:", yaml_str))
})

test_that("yaml::as.yaml() on manuscript_meta does not emit ~ for NULL fields", {
  m <- manuscript_meta(
    authors = list(author("Jane")),
    affiliations = list()
  )
  yaml_str <- yaml::as.yaml(unclass(m))
  # Should not have tilde (null) for missing optional author fields
  expect_false(grepl("affiliation: ~", yaml_str))
  expect_false(grepl("email: ~", yaml_str))
  expect_false(grepl("orcid: ~", yaml_str))
})

test_that("print.typstR_author outputs correct text", {
  a <- author("Jane Doe")
  expect_output(print(a), "<typstR_author>")
  expect_output(print(a), "Jane Doe")
})

test_that("print.typstR_affiliation outputs correct text", {
  aff <- affiliation("1", "MIT")
  expect_output(print(aff), "<typstR_affiliation>")
  expect_output(print(aff), "MIT")
})

test_that("print.typstR_meta outputs correct text", {
  m <- manuscript_meta(
    authors = list(author("Jane"), author("Bob")),
    affiliations = list()
  )
  expect_output(print(m), "<typstR_meta>")
  expect_output(print(m), "2")
})
