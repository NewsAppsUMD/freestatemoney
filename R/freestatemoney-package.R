#' freestatemoney: Load and Parse Maryland Campaign Finance Data
#'
#' Provides functions to download, parse, and analyze campaign finance data
#' from the Maryland State Board of Elections. The package returns tidy data
#' frames for easy analysis with tidyverse tools.
#'
#' @section Main Functions:
#' \itemize{
#'   \item \code{\link{md_download}}: Download bulk data from the SBE API
#'   \item \code{\link{md_committees}}: Load committee registration data
#'   \item \code{\link{md_contributions}}: Load contribution and loan transactions
#'   \item \code{\link{md_expenditures}}: Load expenditure and IE/EC transactions
#' }
#'
#' @section Data Sources:
#' All data comes from the Maryland State Board of Elections Campaign
#' Reporting Information System (CRIS), available at:
#' https://campaignfinance.maryland.gov/public/cf/downloads
#'
#' @keywords internal
"_PACKAGE"

# Columns referenced via dplyr non-standard evaluation
utils::globalVariables(c(
  "filing_entity_id", "committee_name", "committee_type",
  "transaction_amount", "transaction_type", "total_raised", "total_spent",
  "n_contributions", "n_expenditures", "contributor", "contributor_type",
  "contributor_company_name", "contributor_last_name", "contributor_first_name",
  "total", "candidate_ballot_issue", "position"
))
