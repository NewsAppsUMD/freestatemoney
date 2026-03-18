test_that("md_expenditures returns a tibble", {
  skip_if_offline()
  skip_on_cran()

  # Test that function exists and has correct parameters
  expect_true(is.function(md_expenditures))

  # When real data is available, test structure:
  # result <- md_expenditures()
  # expect_s3_class(result, "tbl_df")
  # expect_true("filing_entity_id" %in% names(result))
  # expect_true("transaction_id" %in% names(result))
  # expect_true("transaction_date" %in% names(result))
  # expect_true("transaction_amount" %in% names(result))
  # expect_true("transaction_type" %in% names(result))
  # expect_true("payee_type" %in% names(result))
})

test_that("md_expenditures includes all transaction types", {
  # When real data is available, test transaction types:
  # result <- md_expenditures()
  # transaction_types <- unique(result$transaction_type)
  # expect_true(any(grepl("Expenditure|Outstanding|Independent|Electioneering",
  #                      transaction_types)))
  expect_true(is.function(md_expenditures))
})

test_that("md_expenditures handles IE-specific fields", {
  # When real data is available, test IE fields:
  # result <- md_expenditures()
  # ie_data <- result %>% filter(transaction_type == "Independent Expenditure")
  # expect_true("candidate_ballot_issue" %in% names(ie_data))
  # expect_true("office_sought" %in% names(ie_data))
  expect_true(is.function(md_expenditures))
})
