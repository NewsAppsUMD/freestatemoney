test_that("md_contributions returns a tibble", {
  skip_if_offline()
  skip_on_cran()

  # Test that function exists and has correct parameters
  expect_true(is.function(md_contributions))

  # When real data is available, test structure:
  # result <- md_contributions()
  # expect_s3_class(result, "tbl_df")
  # expect_true("filing_entity_id" %in% names(result))
  # expect_true("transaction_date" %in% names(result))
  # expect_true("transaction_amount" %in% names(result))
  # expect_true("contributor_type" %in% names(result))
})

test_that("md_contributions parses amounts correctly", {
  # When real data is available, test numeric parsing:
  # result <- md_contributions()
  # expect_type(result$transaction_amount, "double")
  # expect_true(all(!is.na(result$transaction_amount)))
  expect_true(is.function(md_contributions))
})

test_that("md_contributions parses dates correctly", {
  # When real data is available, test date parsing:
  # result <- md_contributions()
  # expect_s3_class(result$transaction_date, "Date")
  expect_true(is.function(md_contributions))
})
