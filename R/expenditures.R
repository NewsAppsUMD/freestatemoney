#' Load Maryland Expenditures, Outstanding Obligations, and IE/EC Data
#'
#' Parses expenditure transaction data from the Maryland State Board of Elections.
#' Returns a tidy data frame with payee details, transaction amounts, purposes,
#' and categories. Includes regular expenditures, outstanding obligations,
#' independent expenditures (IE), and electioneering communications (EC).
#'
#' You must first download the expenditures CSV file manually from the Maryland
#' SBE website at https://campaignfinance.maryland.gov/public/cf/downloads
#'
#' @param file_path Character string. Path to the local expenditures CSV file
#'   downloaded from Maryland SBE. This parameter is required.
#' @param clean_names Logical. If TRUE (default), converts column names to
#'   snake_case using janitor::clean_names().
#'
#' @return A tibble with expenditure data including:
#'   \itemize{
#'     \item filing_entity_id: Committee identifier (links to committees)
#'     \item committee_name: Name of spending committee
#'     \item committee_type: Type of committee
#'     \item transaction_id: Unique transaction identifier
#'     \item transaction_type: Type (Expenditure, Outstanding Obligation, IE, EC)
#'     \item payee_type: Type of payee (Business, Self, Candidate, PAC, etc.)
#'     \item payee_name: Payee company name or full name
#'     \item transaction_date: Date of transaction
#'     \item transaction_amount: Amount of transaction
#'     \item category: Expenditure category
#'     \item purpose: Purpose of expenditure
#'     \item fund_type: Fund type (electoral, administrative, compliance)
#'   }
#'   And additional fields for vendor information, IE-specific fields, etc.
#'
#' @export
#'
#' @importFrom readr read_csv cols col_character col_date col_double
#' @importFrom janitor clean_names
#' @importFrom dplyr mutate
#'
#' @examples
#' \dontrun{
#' # Load expenditure data from downloaded file
#' expenditures <- md_expenditures("~/Downloads/Expenditures_2024.csv")
#'
#' # Analyze spending by category
#' library(dplyr)
#' by_category <- md_expenditures("path/to/expenditures.csv") %>%
#'   group_by(category) %>%
#'   summarize(total = sum(transaction_amount, na.rm = TRUE))
#'
#' # Filter for Independent Expenditures only
#' ie_only <- md_expenditures("path/to/expenditures.csv") %>%
#'   filter(transaction_type == "Independent Expenditure")
#' }
md_expenditures <- function(file_path, clean_names = TRUE) {

  # Validate file path
  if (missing(file_path)) {
    stop("file_path is required. Download the expenditures CSV from ",
         "https://campaignfinance.maryland.gov/public/cf/downloads")
  }

  if (!file.exists(file_path)) {
    stop("File not found: ", file_path)
  }

  # Column specification based on MD CRIS Expenditures Download Data Key
  col_spec <- readr::cols(
    .default = readr::col_character(),
    transaction_date = readr::col_date(format = "%m/%d/%Y"),
    transaction_amount = readr::col_double(),
    amount_applied = readr::col_double()
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
