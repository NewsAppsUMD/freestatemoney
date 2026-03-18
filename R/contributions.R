#' Load Maryland Contributions and Loans Data
#'
#' Parses contribution and loan transaction data from the Maryland State Board
#' of Elections. Returns a tidy data frame with contributor details, transaction
#' amounts, and dates.
#'
#' You must first download the contributions CSV file manually from the Maryland
#' SBE website at https://campaignfinance.maryland.gov/public/cf/downloads
#'
#' @param file_path Character string. Path to the local contributions CSV file
#'   downloaded from Maryland SBE. This parameter is required.
#' @param clean_names Logical. If TRUE (default), converts column names to
#'   snake_case using janitor::clean_names().
#'
#' @return A tibble with contribution and loan data including:
#'   \itemize{
#'     \item filing_entity_id: Committee identifier (links to committees)
#'     \item committee_name: Name of receiving committee
#'     \item committee_type: Type of committee
#'     \item contributor_type: Type of contributor (Individual, Business, PAC, etc.)
#'     \item contributor_name: Full contributor name or company
#'     \item transaction_type: Type of transaction (contribution, loan, etc.)
#'     \item transaction_date: Date of transaction
#'     \item transaction_amount: Amount of transaction
#'     \item payment_type: Payment method (Cash, Check, Credit Card, etc.)
#'     \item fund_type: Fund type (electoral, administrative, compliance)
#'   }
#'   And additional fields for contributor address, public funding eligibility, etc.
#'
#' @export
#'
#' @importFrom readr read_csv cols col_character col_date col_double
#' @importFrom janitor clean_names
#' @importFrom dplyr mutate
#'
#' @examples
#' \dontrun{
#' # Load contribution data from downloaded file
#' contributions <- md_contributions("~/Downloads/Contributions_2024.csv")
#'
#' # Filter for large contributions
#' library(dplyr)
#' large_contributions <- md_contributions("path/to/contributions.csv") %>%
#'   filter(transaction_amount >= 500)
#' }
md_contributions <- function(file_path, clean_names = TRUE) {

  # Validate file path
  if (missing(file_path)) {
    stop("file_path is required. Download the contributions CSV from ",
         "https://campaignfinance.maryland.gov/public/cf/downloads")
  }

  if (!file.exists(file_path)) {
    stop("File not found: ", file_path)
  }

  # Column specification based on MD CRIS Contributions Download Data Key
  col_spec <- readr::cols(
    .default = readr::col_character(),
    transaction_date = readr::col_date(format = "%m/%d/%Y"),
    transaction_amount = readr::col_double(),
    number_of_people_purchasing_or_making_contributions = readr::col_double(),
    price_per_person_or_average_contribution = readr::col_double(),
    amount_eligible_for_public_funding = readr::col_double(),
    aggregate_as_of_download_date = readr::col_double()
  )

  # Read the CSV file
  data <- readr::read_csv(
    file_path,
    col_types = col_spec,
    na = c("", "NA", "N/A")
  )

  # Clean column names if requested
  if (clean_names) {
    data <- janitor::clean_names(data)
  }

  return(data)
}
