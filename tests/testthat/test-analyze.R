fixture <- function(name) {
  system.file("extdata", name, package = "freestatemoney", mustWork = TRUE)
}

# md_committee_summary ------------------------------------------------------

toy_committees <- tibble::tibble(
  filing_entity_id = c("1", "2", "3"),
  committee_name = c("Friends of A", "B PAC", "Dormant Committee"),
  committee_type = c("Candidate", "PAC", "Candidate")
)

toy_contributions <- tibble::tibble(
  filing_entity_id = c("1", "1", "2"),
  transaction_amount = c(100, 50, 25)
)

toy_expenditures <- tibble::tibble(
  filing_entity_id = c("1", "2", "2"),
  transaction_amount = c(60, 10, 5),
  transaction_type = c("Expenditure", "Expenditure", "Outstanding Obligation")
)

test_that("md_committee_summary totals raised and spent per committee", {
  result <- md_committee_summary(toy_committees, toy_contributions, toy_expenditures)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3)

  a <- result[result$filing_entity_id == "1", ]
  expect_equal(a$total_raised, 150)
  expect_equal(a$n_contributions, 2L)
  expect_equal(a$total_spent, 60)
  expect_equal(a$n_expenditures, 1L)
  expect_equal(a$net_raised, 90)
})

test_that("md_committee_summary excludes outstanding obligations from spending", {
  result <- md_committee_summary(toy_committees, toy_contributions, toy_expenditures)

  b <- result[result$filing_entity_id == "2", ]
  expect_equal(b$total_spent, 10)
  expect_equal(b$n_expenditures, 1L)
})

test_that("md_committee_summary reports zero, not NA, for inactive committees", {
  result <- md_committee_summary(toy_committees, toy_contributions, toy_expenditures)

  dormant <- result[result$filing_entity_id == "3", ]
  expect_equal(dormant$total_raised, 0)
  expect_equal(dormant$total_spent, 0)
  expect_equal(dormant$n_contributions, 0L)
})

# md_top_contributors -------------------------------------------------------

test_that("md_top_contributors aggregates and ranks contributors", {
  contributions <- md_contributions(fixture("contributions_sample.csv"))
  result <- md_top_contributors(contributions)

  expect_s3_class(result, "tbl_df")
  expect_true(all(c("contributor", "contributor_type", "total", "n_contributions")
                  %in% names(result)))

  # Highest single giver in the sample is a $3,000 organization check
  expect_equal(result$contributor[1], "Friends of Jessica Feldmark")
  expect_equal(result$total[1], 3000)

  # Repeat givers are aggregated
  feldmark <- result[result$contributor == "Feldmark, Joshua", ]
  expect_equal(feldmark$total, 20.53)
  expect_equal(feldmark$n_contributions, 2L)

  # Sorted by total descending
  expect_false(is.unsorted(rev(result$total)))
})

test_that("md_top_contributors respects n", {
  contributions <- md_contributions(fixture("contributions_sample.csv"))
  expect_lte(nrow(md_top_contributors(contributions, n = 3)), 3)
})

# md_independent_expenditures ------------------------------------------------

test_that("md_independent_expenditures summarizes IE/EC spending", {
  expenditures <- md_expenditures(fixture("expenditures_sample.csv"))
  result <- md_independent_expenditures(expenditures)

  expect_s3_class(result, "tbl_df")
  expect_true(all(c("committee_name", "candidate_ballot_issue", "position",
                    "total_spent", "n_expenditures") %in% names(result)))

  # The sample holds two $3,965 IE/EC transactions by the same committee
  expect_equal(nrow(result), 1)
  expect_equal(result$committee_name, "Casa in Action PAC")
  expect_equal(result$position, "Support")
  expect_equal(result$total_spent, 7930)
  expect_equal(result$n_expenditures, 2L)
})

# md_load_all -----------------------------------------------------------------

test_that("md_load_all downloads and loads all three datasets", {
  testthat::local_mocked_bindings(
    md_download = function(type, year = NULL, path = NULL, quiet = FALSE) {
      fixture(paste0(type, "_sample.csv"))
    }
  )

  result <- md_load_all(year = 2025)

  expect_named(result, c("committees", "contributions", "expenditures"))
  expect_s3_class(result$committees, "tbl_df")
  expect_true("filing_entity_id" %in% names(result$contributions))
  expect_true("transaction_amount" %in% names(result$expenditures))
})
