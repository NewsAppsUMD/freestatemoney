fixture <- function(name) {
  system.file("extdata", name, package = "freestatemoney", mustWork = TRUE)
}

test_that("md_committees returns a tibble with clean names", {
  result <- md_committees(fixture("committees_sample.csv"))

  expect_s3_class(result, "tbl_df")
  expect_true("filing_entity_id" %in% names(result))
  expect_true("committee_name" %in% names(result))
  expect_true("committee_type" %in% names(result))
  expect_equal(nrow(result), 8)
})

test_that("md_committees skips the metadata line and parses dates", {
  result <- md_committees(fixture("committees_sample.csv"))

  # First line of the file is "Committee Download as of ...", not data
  expect_false(any(grepl("Download as of", result$filing_entity_id)))

  expect_s3_class(result$registration_submission_date, "Date")
  expect_s3_class(result$registration_approval_date, "Date")
  expect_s3_class(result$registration_dissolved_date, "Date")
  expect_s3_class(result$candidate_dob, "Date")
  expect_equal(result$registration_submission_date[1], as.Date("1998-06-29"))
})

test_that("md_committees strips Excel formula armor from zip codes", {
  result <- md_committees(fixture("committees_sample.csv"))

  # Raw values look like ="21085"; they should come back as plain strings
  zips <- result$candidate_zip_code
  expect_false(any(grepl("=", zips[!is.na(zips)]), na.rm = TRUE))
  expect_equal(result$candidate_zip_code[1], "21085")
})

test_that("md_committees records the download date attribute", {
  result <- md_committees(fixture("committees_sample.csv"))
  expect_s3_class(attr(result, "download_date"), "POSIXct")
})

test_that("md_committees keeps original names with clean_names = FALSE but still types dates", {
  result <- md_committees(fixture("committees_sample.csv"), clean_names = FALSE)

  expect_true("Filing Entity Id" %in% names(result))
  expect_s3_class(result[["Registration Submission Date"]], "Date")
})

test_that("md_committees handles files saved without the metadata line", {
  lines <- readLines(fixture("committees_sample.csv"))
  no_meta <- withr::local_tempfile(fileext = ".csv")
  writeLines(lines[-1], no_meta)

  result <- md_committees(no_meta)
  expect_equal(nrow(result), 8)
  expect_true("filing_entity_id" %in% names(result))
})

test_that("md_committees rejects a file from a different dataset", {
  expect_error(
    md_committees(fixture("contributions_sample.csv")),
    "md_contributions"
  )
})

test_that("md_committees errors helpfully on missing input", {
  expect_error(md_committees(), "file_path is required")
  expect_error(md_committees("no/such/file.csv"), "File not found")
})
