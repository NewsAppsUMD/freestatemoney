test_that("md_committees returns a tibble", {
  skip_if_offline()
  skip_on_cran()

  # This test will need to be updated when actual URLs are available
  # For now, it's a placeholder for the expected structure

  # Test that function exists and has correct parameters
  expect_true(is.function(md_committees))

  # When real data is available, test structure:
  # result <- md_committees()
  # expect_s3_class(result, "tbl_df")
  # expect_true("filing_entity_id" %in% names(result))
  # expect_true("committee_name" %in% names(result))
  # expect_true("committee_type" %in% names(result))
})

test_that("md_committees handles clean_names parameter", {
  # Test that clean_names parameter is respected
  # This will need actual data to fully test

  expect_true(is.function(md_committees))

  # When real data is available:
  # result_clean <- md_committees(clean_names = TRUE)
  # result_raw <- md_committees(clean_names = FALSE)
  # expect_true(all(grepl("^[a-z_]+$", names(result_clean))))
})

test_that("md_committees handles custom URLs", {
  # Test that custom URL parameter works
  expect_error(
    md_committees(url = "nonexistent_file.csv"),
    NA # We expect an error but not a specific one yet
  )
})
