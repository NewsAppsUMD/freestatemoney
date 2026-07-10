#' Open a DuckDB database for Maryland campaign finance data
#'
#' Creates (or reopens) a persistent DuckDB database to hold CRIS bulk data.
#' Use this when files are too large to work with comfortably in memory —
#' full-cycle contribution files run to hundreds of megabytes, and multi-year
#' analyses multiply that. Ingest data once with [md_db_load()], then query
#' lazily with `dplyr::tbl()`; only your results ever come into R.
#'
#' Requires the suggested packages duckdb and DBI:
#' `install.packages(c("duckdb", "DBI"))`.
#'
#' @param path Path for the DuckDB database file (default
#'   `"freestatemoney.duckdb"` in the working directory). Created if it does
#'   not exist; reopened with previously ingested data intact otherwise.
#'
#' @return A DBI connection to the database. Close it with
#'   `DBI::dbDisconnect()` when finished.
#' @export
#'
#' @examples
#' \dontrun{
#' con <- md_db("maryland.duckdb")
#' md_db_load(con, "contributions", year = 2024)
#' md_db_load(con, "contributions", year = 2025)
#'
#' dplyr::tbl(con, "contributions") |>
#'   dplyr::filter(transaction_amount >= 1000) |>
#'   dplyr::collect()
#'
#' DBI::dbDisconnect(con)
#' }
md_db <- function(path = "freestatemoney.duckdb") {
  require_db_packages()
  DBI::dbConnect(duckdb::duckdb(), dbdir = path)
}

#' Ingest a Maryland dataset into a DuckDB database
#'
#' Loads a CRIS bulk CSV into a table in a database opened with [md_db()],
#' applying the same parsing as the in-memory loaders — the metadata line is
#' skipped, column names are cleaned to snake_case, dates and dollar amounts
#' are typed, and Excel armor (`="21228"`) is stripped — but inside DuckDB,
#' so the file never has to fit in R's memory.
#'
#' Each ingest is tagged with a `filing_year` column (`"current"` when
#' `year` is NULL). Ingesting the same dataset and year again replaces that
#' year's rows, so refreshes are idempotent; different years accumulate.
#' Provenance (row counts, the file's "as of" timestamp) is recorded and
#' visible via [md_db_tables()].
#'
#' @param con Connection from [md_db()]
#' @param type Which dataset: "committees", "contributions", or
#'   "expenditures". Used as the table name.
#' @param year Optional four-digit filing year, passed to [md_download()]
#'   when downloading and used as the `filing_year` tag.
#' @param file Optional path to an already-downloaded CSV. If NULL, the data
#'   is downloaded via [md_download()] to a temporary file.
#' @param quiet Logical. If FALSE (default), shows a download progress bar.
#'
#' @return The lazy table (`dplyr::tbl(con, type)`), invisibly.
#' @export
#'
#' @importFrom janitor make_clean_names
#'
#' @examples
#' \dontrun{
#' con <- md_db()
#' md_db_load(con, "expenditures", year = 2025)
#' md_db_load(con, "expenditures", file = "already_downloaded.csv")
#' }
md_db_load <- function(con, type = c("committees", "contributions", "expenditures"),
                       year = NULL, file = NULL, quiet = FALSE) {
  require_db_packages()
  type <- match.arg(type)
  spec <- md_datasets[[type]]

  if (is.null(file)) {
    file <- md_download(type, year = year,
                        path = tempfile(fileext = ".csv"), quiet = quiet)
  }

  info <- inspect_md_file(file, type)
  file <- prepare_md_csv(file)$path
  filing_year <- if (is.null(year)) "current" else as.character(year)

  # Column names come from the header row, cleaned exactly as the loaders do
  header <- readr::read_csv(
    file,
    skip = if (info$has_metadata) 1L else 0L,
    n_max = 0L,
    col_types = readr::cols(.default = readr::col_character()),
    show_col_types = FALSE
  )
  original_names <- names(header)
  clean_names <- janitor::make_clean_names(original_names)

  select_exprs <- vapply(seq_along(original_names), function(i) {
    ident <- DBI::dbQuoteIdentifier(con, original_names[i])
    # strict_mode=false doubles literal quotes in unquoted fields (Excel
    # armor, stray quotes); halve them back, then strip the armor
    expr <- sprintf("replace(%s, '\"\"', '\"')", ident)
    expr <- sprintf("regexp_replace(%s, '^=\"(.*)\"$', '\\1')", expr)
    clean <- clean_names[i]
    if (clean %in% spec$date_cols) {
      expr <- sprintf("strptime(nullif(%s, ''), '%%m/%%d/%%Y')::DATE", expr)
    } else if (clean %in% c(spec$amount_cols, spec$numeric_cols)) {
      expr <- sprintf("TRY_CAST(regexp_replace(%s, '[$,]', '', 'g') AS DOUBLE)", expr)
    }
    paste0(expr, " AS ", DBI::dbQuoteIdentifier(con, clean))
  }, character(1))

  # Specify the dialect and columns outright: CRIS files confuse duckdb's
  # sniffer (stray quotes, occasional wrong field counts)
  column_spec <- paste(
    sprintf("%s: 'VARCHAR'",
            vapply(original_names, function(n) DBI::dbQuoteString(con, n),
                   character(1))),
    collapse = ", "
  )
  source_sql <- sprintf(
    "SELECT %s, %s AS filing_year FROM read_csv(%s, skip = %d, header = true, auto_detect = false, columns = {%s}, delim = ',', quote = '\"', escape = '\"', strict_mode = false, null_padding = true)",
    paste(select_exprs, collapse = ", "),
    DBI::dbQuoteString(con, filing_year),
    DBI::dbQuoteString(con, file),
    if (info$has_metadata) 1L else 0L,
    column_spec
  )

  table <- DBI::dbQuoteIdentifier(con, type)
  if (DBI::dbExistsTable(con, type)) {
    DBI::dbExecute(con, sprintf(
      "DELETE FROM %s WHERE filing_year = %s",
      table, DBI::dbQuoteString(con, filing_year)
    ))
    DBI::dbExecute(con, sprintf("INSERT INTO %s BY NAME %s", table, source_sql))
  } else {
    DBI::dbExecute(con, sprintf("CREATE TABLE %s AS %s", table, source_sql))
  }

  # A few CRIS records have unquoted commas (mis-quoted descriptions) and so
  # too many fields; duckdb wraps the overflow into fragment rows. Real
  # filing entity IDs are numeric, so fragments are identifiable. Removing
  # them matches the loaders, which truncate the extra fields.
  fragments <- DBI::dbExecute(con, sprintf(
    "DELETE FROM %s WHERE filing_year = %s AND
       (filing_entity_id IS NULL OR NOT regexp_matches(filing_entity_id, '^[0-9]+$'))",
    table, DBI::dbQuoteString(con, filing_year)
  ))
  if (fragments > 0) {
    message("Removed ", fragments,
            " fragment row(s) from malformed records in ", basename(file))
  }

  n_rows <- DBI::dbGetQuery(con, sprintf(
    "SELECT count(*) AS n FROM %s WHERE filing_year = %s",
    table, DBI::dbQuoteString(con, filing_year)
  ))$n

  record_md_meta(con, type, filing_year, info$download_date, n_rows)

  invisible(dplyr::tbl(con, type))
}

#' List what has been ingested into a Maryland DuckDB database
#'
#' @param con Connection from [md_db()]
#'
#' @return A tibble with one row per ingested dataset/year: `dataset`,
#'   `filing_year`, `n_rows`, `download_date` (the file's "as of" timestamp),
#'   and `ingested_at`.
#' @export
#'
#' @examples
#' \dontrun{
#' con <- md_db()
#' md_db_load(con, "contributions", year = 2025)
#' md_db_tables(con)
#' }
md_db_tables <- function(con) {
  require_db_packages()
  if (!DBI::dbExistsTable(con, "md_meta")) {
    return(dplyr::tibble(
      dataset = character(), filing_year = character(),
      n_rows = numeric(),
      download_date = as.POSIXct(character()),
      ingested_at = as.POSIXct(character())
    ))
  }
  result <- DBI::dbGetQuery(
    con, "SELECT * FROM md_meta ORDER BY dataset, filing_year"
  )
  dplyr::as_tibble(result)
}

record_md_meta <- function(con, dataset, filing_year, download_date, n_rows) {
  DBI::dbExecute(con, "
    CREATE TABLE IF NOT EXISTS md_meta (
      dataset VARCHAR,
      filing_year VARCHAR,
      n_rows BIGINT,
      download_date TIMESTAMP,
      ingested_at TIMESTAMP
    )")
  DBI::dbExecute(con, sprintf(
    "DELETE FROM md_meta WHERE dataset = %s AND filing_year = %s",
    DBI::dbQuoteString(con, dataset), DBI::dbQuoteString(con, filing_year)
  ))
  DBI::dbExecute(
    con,
    "INSERT INTO md_meta VALUES (?, ?, ?, ?, ?)",
    params = list(dataset, filing_year, n_rows, download_date, Sys.time())
  )
}

require_db_packages <- function() {
  missing <- c("duckdb", "DBI")[!vapply(
    c("duckdb", "DBI"), requireNamespace, logical(1), quietly = TRUE
  )]
  if (length(missing) > 0) {
    stop(
      "The md_db() functions require the ", paste(missing, collapse = " and "),
      " package", if (length(missing) > 1) "s", ". Install with: ",
      'install.packages(c("duckdb", "DBI"))',
      call. = FALSE
    )
  }
}
