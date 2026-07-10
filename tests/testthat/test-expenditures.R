fixture <- function(name) {
  system.file("extdata", name, package = "freestatemoney", mustWork = TRUE)
}

test_that("md_expenditures returns a tibble with clean names", {
  result <- md_expenditures(fixture("expenditures_sample.csv"))

  expect_s3_class(result, "tbl_df")
  expect_true("filing_entity_id" %in% names(result))
  expect_true("payee_type" %in% names(result))
  expect_true("transaction_type" %in% names(result))
  expect_true("transaction_date" %in% names(result))
  expect_true("transaction_amount" %in% names(result))
  expect_equal(nrow(result), 10)
})

test_that("md_expenditures parses dollar-formatted amounts as numeric", {
  result <- md_expenditures(fixture("expenditures_sample.csv"))

  expect_type(result$transaction_amount, "double")
  expect_equal(result$transaction_amount[1], 27.71)
  expect_type(result$amount_applied, "double")
})

test_that("md_expenditures parses dates", {
  result <- md_expenditures(fixture("expenditures_sample.csv"))

  expect_s3_class(result$transaction_date, "Date")
  expect_equal(result$transaction_date[1], as.Date("2023-09-13"))
})

test_that("md_expenditures strips Excel formula armor from zip codes", {
  result <- md_expenditures(fixture("expenditures_sample.csv"))

  zips <- result$payee_zip_code
  expect_false(any(grepl("=", zips[!is.na(zips)]), na.rm = TRUE))
  expect_equal(result$payee_zip_code[1], "78256")
})

test_that("md_expenditures includes IE-specific columns", {
  result <- md_expenditures(fixture("expenditures_sample.csv"))

  expect_true("candidate_ballot_issue" %in% names(result))
  expect_true("office_sought" %in% names(result))
  expect_true("position" %in% names(result))
})

test_that("md_expenditures rejects a file from a different dataset", {
  expect_error(
    md_expenditures(fixture("committees_sample.csv")),
    "md_committees"
  )
})

test_that("md_expenditures errors helpfully on missing input", {
  expect_error(md_expenditures(), "file_path is required")
  expect_error(md_expenditures("no/such/file.csv"), "File not found")
})
