#' Load Maryland Expenditures, Outstanding Obligations, and IE/EC Data
#'
#' Parses expenditure transaction data from the Maryland State Board of
#' Elections. Returns a tidy data frame with payee details, transaction
#' amounts, purposes, and categories. Includes regular expenditures,
#' outstanding obligations, independent expenditures (IE), and electioneering
#' communications (EC).
#'
#' Download the expenditures CSV with
#' [md_download("expenditures")][md_download], or manually from the Maryland
#' SBE website at https://campaignfinance.maryland.gov/public/cf/downloads
#'
#' The raw file has a metadata line ("Expenditure Download as of ...") before
#' the header; it is skipped automatically and its timestamp is stored in the
#' `download_date` attribute of the result. Dollar-formatted amounts
#' (`$1,320.00`) are parsed as numeric, and values wrapped for Excel such as
#' `="20814"` (zip codes) are unwrapped to plain strings.
#'
#' @param file_path Character string. Path to the local expenditures CSV file
#'   downloaded from Maryland SBE. This parameter is required.
#' @param clean_names Logical. If TRUE (default), converts column names to
#'   snake_case. Date and amount columns are parsed either way.
#'
#' @return A tibble with expenditure data including:
#'   \itemize{
#'     \item filing_entity_id: Committee identifier (links to committees)
#'     \item committee_name: Name of spending committee
#'     \item committee_type: Type of committee
#'     \item transaction_type: Type (Expenditure, Outstanding Obligation, IE, EC)
#'     \item payee_type: Type of payee (Business, Self, Candidate, PAC, etc.)
#'     \item transaction_date: Date of transaction (Date)
#'     \item transaction_amount: Amount of transaction (numeric)
#'     \item category: Expenditure category
#'     \item purpose: Purpose of expenditure
#'     \item fund_type: Fund type (electoral, administrative, compliance)
#'   }
#'   And additional fields for vendor information, IE-specific fields, etc.
#'   The tibble carries a `download_date` attribute with the file's "as of"
#'   timestamp.
#'
#' @export
#'
#' @examples
#' # Sample data included with the package
#' expenditures <- md_expenditures(
#'   system.file("extdata", "expenditures_sample.csv", package = "freestatemoney")
#' )
#' head(expenditures)
#'
#' \dontrun{
#' # Download a single filing year and load it
#' expenditures <- md_expenditures(md_download("expenditures", year = 2025))
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
  if (missing(file_path)) {
    stop(
      "file_path is required. Use md_download(\"expenditures\") or download the ",
      "expenditures CSV from https://campaignfinance.maryland.gov/public/cf/downloads",
      call. = FALSE
    )
  }

  read_md_csv(file_path, "expenditures", clean_names = clean_names)
}
