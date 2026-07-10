fixture <- function(name) {
  system.file("extdata", name, package = "freestatemoney", mustWork = TRUE)
}

test_that("md_contributions returns a tibble with clean names", {
  result <- md_contributions(fixture("contributions_sample.csv"))

  expect_s3_class(result, "tbl_df")
  expect_true("filing_entity_id" %in% names(result))
  expect_true("contributor_type" %in% names(result))
  expect_true("transaction_date" %in% names(result))
  expect_true("transaction_amount" %in% names(result))
  expect_equal(nrow(result), 8)
})

test_that("md_contributions parses dollar-formatted amounts as numeric", {
  result <- md_contributions(fixture("contributions_sample.csv"))

  # Raw values look like $3.60 / $3000.00
  expect_type(result$transaction_amount, "double")
  expect_equal(result$transaction_amount[1], 3.60)
  expect_true(3000 %in% result$transaction_amount)

  expect_type(result$amount_eligible_for_public_funding, "double")
  expect_type(result$aggregate_as_of_download_date, "double")
})

test_that("md_contributions parses dates", {
  result <- md_contributions(fixture("contributions_sample.csv"))

  expect_s3_class(result$transaction_date, "Date")
  expect_equal(result$transaction_date[1], as.Date("2024-11-20"))
})

test_that("md_contributions strips Excel formula armor from zip codes", {
  result <- md_contributions(fixture("contributions_sample.csv"))

  zips <- result$contributor_zip_code
  expect_false(any(grepl("=", zips[!is.na(zips)]), na.rm = TRUE))
  expect_equal(result$contributor_zip_code[1], "21228")
})

test_that("md_contributions rejects a file from a different dataset", {
  expect_error(
    md_contributions(fixture("expenditures_sample.csv")),
    "md_expenditures"
  )
})

test_that("md_contributions errors helpfully on missing input", {
  expect_error(md_contributions(), "file_path is required")
  expect_error(md_contributions("no/such/file.csv"), "File not found")
})
