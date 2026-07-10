#' Load Maryland Contributions and Loans Data
#'
#' Parses contribution and loan transaction data from the Maryland State Board
#' of Elections. Returns a tidy data frame with contributor details,
#' transaction amounts, and dates.
#'
#' Download the contributions CSV with
#' [md_download("contributions")][md_download], or manually from the Maryland
#' SBE website at https://campaignfinance.maryland.gov/public/cf/downloads
#'
#' The raw file has a metadata line ("Contributions and Loan Download as of
#' ...") before the header; it is skipped automatically and its timestamp is
#' stored in the `download_date` attribute of the result. Dollar-formatted
#' amounts (`$3,000.00`) are parsed as numeric, and values wrapped for Excel
#' such as `="21228"` (zip codes) are unwrapped to plain strings.
#'
#' @param file_path Character string. Path to the local contributions CSV file
#'   downloaded from Maryland SBE. This parameter is required.
#' @param clean_names Logical. If TRUE (default), converts column names to
#'   snake_case. Date and amount columns are parsed either way.
#'
#' @return A tibble with contribution and loan data including:
#'   \itemize{
#'     \item filing_entity_id: Committee identifier (links to committees)
#'     \item committee_name: Name of receiving committee
#'     \item committee_type: Type of committee
#'     \item contributor_type: Type of contributor (Individual, Business, PAC, etc.)
#'     \item transaction_type: Type of transaction (contribution, loan, etc.)
#'     \item transaction_date: Date of transaction (Date)
#'     \item transaction_amount: Amount of transaction (numeric)
#'     \item payment_type: Payment method (Cash, Check, Credit Card, etc.)
#'     \item fund_type: Fund type (electoral, administrative, compliance)
#'   }
#'   And additional fields for contributor address, public funding
#'   eligibility, etc. The tibble carries a `download_date` attribute with the
#'   file's "as of" timestamp.
#'
#' @export
#'
#' @examples
#' # Sample data included with the package
#' contributions <- md_contributions(
#'   system.file("extdata", "contributions_sample.csv", package = "freestatemoney")
#' )
#' head(contributions)
#'
#' \dontrun{
#' # Download a single filing year and load it
#' contributions <- md_contributions(md_download("contributions", year = 2025))
#'
#' # Filter for large contributions
#' library(dplyr)
#' large_contributions <- md_contributions("path/to/contributions.csv") %>%
#'   filter(transaction_amount >= 500)
#' }
md_contributions <- function(file_path, clean_names = TRUE) {
  if (missing(file_path)) {
    stop(
      "file_path is required. Use md_download(\"contributions\") or download the ",
      "contributions CSV from https://campaignfinance.maryland.gov/public/cf/downloads",
      call. = FALSE
    )
  }

  read_md_csv(file_path, "contributions", clean_names = clean_names)
}
