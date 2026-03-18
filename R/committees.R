#' Load Maryland Committee Data
#'
#' Parses committee registration data from the Maryland State Board of Elections.
#' Returns a tidy data frame with committee metadata including registration
#' information, officers, and contact details.
#'
#' You must first download the committee CSV file manually from the Maryland SBE
#' website at https://campaignfinance.maryland.gov/public/cf/downloads
#'
#' @param file_path Character string. Path to the local committee CSV file
#'   downloaded from Maryland SBE. This parameter is required.
#' @param clean_names Logical. If TRUE (default), converts column names to
#'   snake_case using janitor::clean_names().
#'
#' @return A tibble with committee data including:
#'   \itemize{
#'     \item filing_entity_id: Unique committee identifier
#'     \item committee_name: Full committee name
#'     \item committee_type: Type (Candidate, PAC, Party, etc.)
#'     \item election: Assigned election
#'     \item registration_submission_date: Date registration submitted
#'     \item registration_approval_date: Date registration approved
#'     \item registration_dissolved_date: Date committee dissolved (if applicable)
#'   }
#'   And many additional fields for officers, candidates, and contact information.
#'
#' @export
#'
#' @importFrom readr read_csv cols col_character col_date
#' @importFrom janitor clean_names
#' @importFrom lubridate mdy
#' @importFrom dplyr mutate
#'
#' @examples
#' \dontrun{
#' # Load committee data from downloaded file
#' committees <- md_committees("~/Downloads/Committee_2024.csv")
#'
#' # With original column names (not snake_case)
#' committees <- md_committees("path/to/committees.csv", clean_names = FALSE)
#' }
md_committees <- function(file_path, clean_names = TRUE) {

  # Validate file path
  if (missing(file_path)) {
    stop("file_path is required. Download the committee CSV from ",
         "https://campaignfinance.maryland.gov/public/cf/downloads")
  }

  if (!file.exists(file_path)) {
    stop("File not found: ", file_path)
  }

  # Column specification based on MD CRIS Committee Download Data Key
  col_spec <- readr::cols(
    .default = readr::col_character(),
    registration_submission_date = readr::col_date(format = "%m/%d/%Y"),
    registration_approval_date = readr::col_date(format = "%m/%d/%Y"),
    registration_dissolved_date = readr::col_date(format = "%m/%d/%Y"),
    candidate_dob = readr::col_date(format = "%m/%d/%Y")
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
