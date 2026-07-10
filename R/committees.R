#' Load Maryland Committee Data
#'
#' Parses committee registration data from the Maryland State Board of
#' Elections. Returns a tidy data frame with committee metadata including
#' registration information, officers, and contact details.
#'
#' Download the committee CSV with [md_download("committees")][md_download],
#' or manually from the Maryland SBE website at
#' https://campaignfinance.maryland.gov/public/cf/downloads
#'
#' The raw file has a metadata line ("Committee Download as of ...") before
#' the header; it is skipped automatically and its timestamp is stored in the
#' `download_date` attribute of the result. Values wrapped for Excel such as
#' `="21085"` (zip codes) are unwrapped to plain strings.
#'
#' @param file_path Character string. Path to the local committee CSV file
#'   downloaded from Maryland SBE. This parameter is required.
#' @param clean_names Logical. If TRUE (default), converts column names to
#'   snake_case. Date columns are parsed either way.
#'
#' @return A tibble with committee data including:
#'   \itemize{
#'     \item filing_entity_id: Unique committee identifier
#'     \item committee_name: Full committee name
#'     \item committee_type: Type (Candidate, PAC, Party, etc.)
#'     \item election: Assigned election(s)
#'     \item registration_submission_date: Date registration submitted
#'     \item registration_approval_date: Date registration approved
#'     \item registration_dissolved_date: Date committee dissolved (if applicable)
#'   }
#'   And many additional fields for officers, candidates, and contact
#'   information. The tibble carries a `download_date` attribute with the
#'   file's "as of" timestamp.
#'
#' @export
#'
#' @examples
#' # Sample data included with the package
#' committees <- md_committees(
#'   system.file("extdata", "committees_sample.csv", package = "freestatemoney")
#' )
#' head(committees)
#'
#' \dontrun{
#' # Download and load in one go
#' committees <- md_committees(md_download("committees"))
#'
#' # With original column names (not snake_case)
#' committees <- md_committees("path/to/committees.csv", clean_names = FALSE)
#' }
md_committees <- function(file_path, clean_names = TRUE) {
  if (missing(file_path)) {
    stop(
      "file_path is required. Use md_download(\"committees\") or download the ",
      "committee CSV from https://campaignfinance.maryland.gov/public/cf/downloads",
      call. = FALSE
    )
  }

  read_md_csv(file_path, "committees", clean_names = clean_names)
}
