#' Download Maryland Campaign Finance Data
#'
#' Downloads a bulk data CSV directly from the Maryland State Board of
#' Elections Campaign Reporting Information System (CRIS) API - the same
#' endpoint the download page at
#' https://campaignfinance.maryland.gov/public/cf/downloads uses.
#'
#' The contributions and expenditures files for a full cycle can be large
#' (hundreds of megabytes); passing a `year` limits the download to a single
#' filing year. Committee data is only available as a complete file, so
#' `year` is ignored for `type = "committees"`.
#'
#' @param type Which dataset to download: "committees", "contributions", or
#'   "expenditures".
#' @param year Optional four-digit filing year (e.g. 2025). If NULL (default),
#'   downloads the current-cycle file. The SBE typically offers the most
#'   recent several years.
#' @param path Where to save the CSV. Defaults to a file named after the
#'   dataset (and year, if given) in the current working directory.
#' @param quiet Logical. If FALSE (default), shows a download progress bar.
#'
#' @return The path to the downloaded CSV file, invisibly suitable for
#'   passing straight to [md_committees()], [md_contributions()], or
#'   [md_expenditures()].
#' @export
#'
#' @examples
#' \dontrun{
#' # Current-cycle committee list
#' committees <- md_committees(md_download("committees"))
#'
#' # Contributions for a single filing year
#' contributions <- md_contributions(md_download("contributions", year = 2025))
#' }
md_download <- function(type = c("committees", "contributions", "expenditures"),
                        year = NULL, path = NULL, quiet = FALSE) {
  type <- match.arg(type)

  if (!is.null(year)) {
    year_num <- suppressWarnings(as.integer(year))
    if (is.na(year_num) || year_num < 1900 || year_num > 2100) {
      stop("year must be a four-digit filing year, e.g. 2025.", call. = FALSE)
    }
    year <- as.character(year_num)
  }
  filing_year <- if (is.null(year)) "0" else year

  if (is.null(path)) {
    suffix <- if (is.null(year)) "current" else year
    path <- paste0("md_", type, "_", suffix, ".csv")
  }

  body <- list(
    filingYear = filing_year,
    transactionTypeCode = md_datasets[[type]]$type_code,
    type = "CSV",
    fileName = paste0(type, "_download")
  )

  response <- httr::POST(
    "https://api-campaignfinance.maryland.gov/api/ExportPublicData/GetExportPublicDownloadData",
    body = body,
    encode = "json",
    httr::write_disk(path, overwrite = TRUE),
    if (quiet) NULL else httr::progress()
  )
  httr::stop_for_status(response, task = paste("download Maryland", type, "data"))

  if (file.size(path) == 0) {
    unlink(path)
    stop(
      "No data returned for ", type, if (!is.null(year)) paste0(" in ", year),
      ". The SBE typically offers only the most recent several filing years.",
      call. = FALSE
    )
  }

  path
}

#' Download and load all three Maryland datasets at once
#'
#' Convenience wrapper that downloads committees, contributions, and
#' expenditures via [md_download()] and loads each with its parser. The
#' `year` applies to contributions and expenditures; committee data is only
#' available as one complete file.
#'
#' @param year Optional four-digit filing year passed to [md_download()] for
#'   the transaction datasets. If NULL, downloads current-cycle files, which
#'   can be very large.
#' @param dir Directory to save the downloaded CSVs (default: a temporary
#'   directory).
#' @param quiet Logical. If FALSE (default), shows download progress bars.
#'
#' @return A named list with `committees`, `contributions`, and
#'   `expenditures` tibbles, ready for joining on `filing_entity_id`.
#' @export
#'
#' @examples
#' \dontrun{
#' md <- md_load_all(year = 2025)
#' summary <- md_committee_summary(md$committees, md$contributions, md$expenditures)
#' }
md_load_all <- function(year = NULL, dir = tempdir(), quiet = FALSE) {
  dest <- function(name) file.path(dir, paste0("md_", name, ".csv"))

  list(
    committees = md_committees(
      md_download("committees", path = dest("committees"), quiet = quiet)
    ),
    contributions = md_contributions(
      md_download("contributions", year = year, path = dest("contributions"), quiet = quiet)
    ),
    expenditures = md_expenditures(
      md_download("expenditures", year = year, path = dest("expenditures"), quiet = quiet)
    )
  )
}
