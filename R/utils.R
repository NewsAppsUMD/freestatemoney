#' Utility functions for freestatemoney package
#'
#' Internal utility functions used across the package.
#'
#' @keywords internal
#' @name utils
NULL

# Registry describing each Maryland CRIS bulk download. The marker is the
# start of the metadata line that precedes the header row in every file.
md_datasets <- list(
  committees = list(
    marker = "Committee Download",
    label = "Committee",
    loader = "md_committees()",
    type_code = "TCMD",
    date_cols = c(
      "registration_submission_date", "registration_approval_date",
      "registration_dissolved_date", "candidate_dob"
    ),
    amount_cols = character(),
    numeric_cols = character()
  ),
  contributions = list(
    marker = "Contributions and Loan Download",
    label = "Contributions and Loans",
    loader = "md_contributions()",
    type_code = "TCON",
    date_cols = "transaction_date",
    amount_cols = c(
      "transaction_amount", "price_per_person_or_average_contribution",
      "amount_eligible_for_public_funding"
    ),
    numeric_cols = c(
      "number_of_people_purchasing_or_making_contributions",
      "aggregate_as_of_download_date"
    )
  ),
  expenditures = list(
    marker = "Expenditure Download",
    label = "Expenditure",
    loader = "md_expenditures()",
    type_code = "TEXP",
    date_cols = "transaction_date",
    amount_cols = c("transaction_amount", "amount_applied"),
    numeric_cols = character()
  )
)

#' Strip Excel formula armor from a character vector
#'
#' CRIS wraps values with leading zeros (zip codes) as `="21228"` so Excel
#' preserves them. This returns the bare value.
#'
#' @param x Character vector
#' @return Character vector without the `="..."` wrapper
#' @keywords internal
strip_excel_armor <- function(x) {
  sub('^="(.*)"$', "\\1", x)
}

#' Parse Maryland date format
#'
#' Helper function to consistently parse dates from Maryland data files
#'
#' @param date_string Character string with date in MM/DD/YYYY format
#' @return Date object
#' @importFrom lubridate mdy
#' @keywords internal
parse_md_date <- function(date_string) {
  lubridate::mdy(date_string, quiet = TRUE)
}

#' Parse Maryland currency format
#'
#' Amounts arrive dollar-formatted, e.g. `$3,000.00`.
#'
#' @param x Character vector of amounts
#' @return Numeric vector
#' @importFrom readr parse_number
#' @keywords internal
parse_md_amount <- function(x) {
  suppressWarnings(readr::parse_number(x, na = c("", "NA", "N/A")))
}

#' Validate a Maryland CRIS file and read its metadata line
#'
#' Checks that a file is the expected CRIS dataset (erroring with a pointer
#' to the right loader when it is another dataset's file), and parses the
#' "... Download as of" metadata line if present.
#'
#' @param file_path Path to the downloaded CSV file
#' @param dataset One of "committees", "contributions", "expenditures"
#' @return A list with `has_metadata` (logical) and `download_date` (POSIXct,
#'   NA if the metadata line was absent)
#' @importFrom lubridate mdy_hm
#' @keywords internal
inspect_md_file <- function(file_path, dataset) {
  spec <- md_datasets[[dataset]]

  if (!file.exists(file_path)) {
    stop("File not found: ", file_path, call. = FALSE)
  }

  first_line <- readLines(file_path, n = 1L, warn = FALSE)

  # Guard against loading the wrong dataset's file
  for (other in names(md_datasets)) {
    if (other != dataset && startsWith(first_line, md_datasets[[other]]$marker)) {
      stop(
        "This file appears to be a ", md_datasets[[other]]$label,
        " download; use ", md_datasets[[other]]$loader, " instead.",
        call. = FALSE
      )
    }
  }

  has_metadata <- startsWith(first_line, spec$marker)
  download_date <- as.POSIXct(NA)
  if (has_metadata) {
    stamp <- sub(paste0("^", spec$marker, "[^0-9]*"), "", first_line)
    download_date <- lubridate::mdy_hm(stamp, quiet = TRUE)
  } else if (!grepl("Filing Entity", first_line, fixed = TRUE)) {
    stop(
      "This file does not look like a Maryland CRIS ", spec$label,
      " download. Expected a first line starting with \"", spec$marker,
      "\" or a header containing \"Filing Entity Id\".",
      call. = FALSE
    )
  }

  list(has_metadata = has_metadata, download_date = download_date)
}

#' Find bare line breaks inside fields
#'
#' CRIS records are terminated by CRLF; a bare LF (not preceded by CR) is
#' field content — typically a multi-line address — that breaks the row for
#' every CSV parser. Returns positions of such LF bytes in `chunk`. Quote
#' state is deliberately not tracked: CRIS data contains stray literal
#' quotes in unquoted fields, which make quote-parity unreliable, and legal
#' quoted line breaks in a CRLF file use CRLF (which this leaves alone).
#'
#' @param chunk Raw vector of file bytes
#' @param prev_byte Last byte of the preceding chunk
#' @return Integer positions within `chunk`
#' @keywords internal
bare_lf_positions <- function(chunk, prev_byte) {
  lf <- which(chunk == as.raw(0x0a))
  if (length(lf) == 0) {
    return(integer(0))
  }
  prev <- raw(length(lf))
  first <- lf == 1L
  prev[first] <- prev_byte
  prev[!first] <- chunk[lf[!first] - 1L]

  lf[prev != as.raw(0x0d)]
}

# How many trailing bytes of a chunk might be a split UTF-8 character and
# should be validated together with the next chunk
utf8_tail_hold <- function(chunk) {
  n <- length(chunk)
  k <- 0L
  while (k < 4L && n - k > 0L) {
    b <- as.integer(chunk[n - k])
    if (b < 0x80) return(0L) # ASCII: nothing split
    if (b >= 0xC0) return(k + 1L) # lead byte: hold from here
    k <- k + 1L # continuation byte: keep looking
  }
  0L
}

#' Repair CRIS CSV defects before parsing
#'
#' Streams a file in chunks looking for two defects real CRIS exports have:
#' bare LF line breaks inside unquoted fields (which split rows), and
#' Windows-1252 bytes (which appear megabytes in, past encoding-sniffing
#' windows, and break UTF-8 parsers). Clean files are returned untouched;
#' defective ones are rewritten to a temporary file with bare LFs replaced
#' by spaces and text transcoded to UTF-8. CRLF line breaks inside quoted
#' fields are legal CSV and are left alone.
#'
#' @param file_path Path to the downloaded CSV file
#' @return A list with `path` (the file to parse), `repaired` (number of
#'   line breaks fixed), and `reencoded` (logical)
#' @keywords internal
prepare_md_csv <- function(file_path) {
  chunk_size <- 8L * 1024L^2

  scan_pass <- function(on_chunk) {
    con <- file(file_path, "rb")
    on.exit(close(con), add = TRUE)
    prev_byte <- as.raw(0x0d)
    repeat {
      chunk <- readBin(con, "raw", chunk_size)
      if (length(chunk) == 0) break
      on_chunk(chunk, prev_byte)
      prev_byte <- chunk[length(chunk)]
    }
  }

  # Pass 1: detect defects
  n_bare <- 0L
  n_lf <- 0L
  valid_utf8 <- TRUE
  has_high <- FALSE
  utf8_carry <- raw(0)
  scan_pass(function(chunk, prev_byte) {
    n_bare <<- n_bare + length(bare_lf_positions(chunk, prev_byte))
    n_lf <<- n_lf + sum(chunk == as.raw(0x0a))
    if (valid_utf8) {
      seg <- c(utf8_carry, chunk)
      if (any(seg > as.raw(0x7f))) {
        has_high <<- TRUE
        hold <- utf8_tail_hold(seg)
        head_end <- length(seg) - hold
        utf8_carry <<- if (hold > 0L) seg[(head_end + 1L):length(seg)] else raw(0)
        head_seg <- seg[seq_len(head_end)]
        head_seg <- head_seg[head_seg != as.raw(0)]
        if (!all(validUTF8(rawToChar(head_seg)))) valid_utf8 <<- FALSE
      } else {
        utf8_carry <<- raw(0)
      }
    }
  })
  if (valid_utf8 && length(utf8_carry) > 0 &&
      !all(validUTF8(rawToChar(utf8_carry)))) {
    valid_utf8 <- FALSE
  }

  # Bare LFs are defects only in CRLF-terminated files; in an LF-terminated
  # file (e.g. one re-saved by a Unix tool) they are the record separators.
  if (n_bare > 0L && n_lf - n_bare <= n_bare) {
    n_bare <- 0L
  }

  reencode <- has_high && !valid_utf8
  if (n_bare == 0L && !reencode) {
    return(list(path = file_path, repaired = 0L, reencoded = FALSE))
  }

  # Pass 2: rewrite
  out_path <- tempfile(fileext = ".csv")
  out <- file(out_path, "wb")
  on.exit(close(out), add = TRUE)
  scan_pass(function(chunk, prev_byte) {
    if (n_bare > 0L) {
      chunk[bare_lf_positions(chunk, prev_byte)] <- as.raw(0x20)
    }
    if (reencode) {
      chunk[chunk == as.raw(0)] <- as.raw(0x20)
      text <- iconv(rawToChar(chunk), "WINDOWS-1252", "UTF-8")
      if (is.na(text)) text <- iconv(rawToChar(chunk), "latin1", "UTF-8")
      chunk <- charToRaw(text)
    }
    writeBin(chunk, out)
  })

  message(
    "Repaired ", basename(file_path), ": ",
    paste(c(
      if (n_bare > 0) paste0(n_bare, " unquoted line break(s) inside fields"),
      if (reencode) "converted Windows-1252 text to UTF-8"
    ), collapse = "; ")
  )

  list(path = out_path, repaired = n_bare, reencoded = reencode)
}

#' Read a Maryland CRIS bulk download CSV
#'
#' Shared reader for the three CRIS datasets. Validates that the file is the
#' expected dataset, skips the "... Download as of" metadata line, repairs
#' CRIS export defects (see [prepare_md_csv()]), reads all columns as
#' character, strips Excel formula armor, converts date and amount columns,
#' and optionally cleans column names.
#'
#' @param file_path Path to the downloaded CSV file
#' @param dataset One of "committees", "contributions", "expenditures"
#' @param clean_names Logical; convert names to snake_case
#' @return A tibble with a `download_date` attribute (POSIXct, or NA if the
#'   metadata line was absent)
#' @importFrom readr read_csv cols col_character
#' @importFrom janitor make_clean_names
#' @importFrom lubridate mdy_hm
#' @keywords internal
read_md_csv <- function(file_path, dataset, clean_names = TRUE) {
  spec <- md_datasets[[dataset]]
  info <- inspect_md_file(file_path, dataset)
  has_metadata <- info$has_metadata
  download_date <- info$download_date

  prepared <- prepare_md_csv(file_path)

  data <- readr::read_csv(
    prepared$path,
    skip = if (has_metadata) 1L else 0L,
    col_types = readr::cols(.default = readr::col_character()),
    na = c("", "NA", "N/A"),
    show_col_types = FALSE
  )

  data[] <- lapply(data, strip_excel_armor)

  original_names <- names(data)
  names(data) <- janitor::make_clean_names(original_names)

  for (col in intersect(spec$date_cols, names(data))) {
    data[[col]] <- parse_md_date(data[[col]])
  }
  for (col in intersect(c(spec$amount_cols, spec$numeric_cols), names(data))) {
    data[[col]] <- parse_md_amount(data[[col]])
  }

  if (!clean_names) {
    names(data) <- original_names
  }

  attr(data, "download_date") <- download_date
  data
}
