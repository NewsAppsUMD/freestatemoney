#' freestatemoney: Load and Parse Maryland Campaign Finance Data
#'
#' Provides functions to download, parse, and analyze campaign finance data
#' from the Maryland State Board of Elections. The package returns tidy data
#' frames for easy analysis with tidyverse tools.
#'
#' @section Main Functions:
#' \itemize{
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
#' @docType package
#' @name freestatemoney-package
#' @aliases freestatemoney
#'
#' @importFrom tibble tibble
#' @importFrom dplyr mutate rename
#' @importFrom readr read_csv cols col_character col_date col_double
#' @importFrom janitor clean_names
#' @importFrom lubridate mdy
NULL
