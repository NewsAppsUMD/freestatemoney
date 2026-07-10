test_that("md_download validates its arguments without touching the network", {
  expect_error(md_download("ballots"))
  expect_error(md_download("committees", year = "not-a-year"), "year")
})

test_that("md_download fetches committee data that md_committees can read", {
  skip_on_cran()
  skip_if_offline("api-campaignfinance.maryland.gov")

  path <- withr::local_tempfile(fileext = ".csv")
  result <- md_download("committees", path = path, quiet = TRUE)

  expect_equal(result, path)
  expect_gt(file.size(path), 1000)

  committees <- md_committees(path)
  expect_s3_class(committees, "tbl_df")
  expect_true("filing_entity_id" %in% names(committees))
})

test_that("md_download errors when a year returns no data", {
  skip_on_cran()
  skip_if_offline("api-campaignfinance.maryland.gov")

  expect_error(
    md_download("contributions", year = 1990,
                path = withr::local_tempfile(fileext = ".csv"), quiet = TRUE),
    "No data"
  )
})
