#' Utility functions for freestatemoney package
#'
#' Internal utility functions used across the package.
#'
#' @keywords internal
#' @name utils

#' Check if URL or file path is accessible
#'
#' @param url Character string of URL or file path
#' @return Logical indicating if the resource is accessible
#' @keywords internal
check_url <- function(url) {
  if (file.exists(url)) {
    return(TRUE)
  }

  # For URLs, try a HEAD request
  if (grepl("^https?://", url)) {
    tryCatch({
      response <- httr::HEAD(url)
      return(httr::status_code(response) == 200)
    }, error = function(e) {
      return(FALSE)
    })
  }

  return(FALSE)
}

#' Parse Maryland date format
#'
#' Helper function to consistently parse dates from Maryland data files
#'
#' @param date_string Character string with date
#' @return Date object
#' @importFrom lubridate mdy
#' @keywords internal
parse_md_date <- function(date_string) {
  lubridate::mdy(date_string)
}
