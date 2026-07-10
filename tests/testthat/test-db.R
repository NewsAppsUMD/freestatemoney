fixture <- function(name) {
  system.file("extdata", name, package = "freestatemoney", mustWork = TRUE)
}

local_md_db <- function(env = parent.frame()) {
  skip_if_not_installed("duckdb")
  skip_if_not_installed("DBI")
  path <- withr::local_tempfile(fileext = ".duckdb", .local_envir = env)
  con <- md_db(path)
  withr::defer(DBI::dbDisconnect(con), envir = env)
  con
}

test_that("md_db creates a persistent database and returns a connection", {
  skip_if_not_installed("duckdb")
  path <- withr::local_tempfile(fileext = ".duckdb")

  con <- md_db(path)
  withr::defer(DBI::dbDisconnect(con))

  expect_s4_class(con, "duckdb_connection")
  expect_true(file.exists(path))
})

test_that("md_db_load ingests a file with full parsing parity to the loaders", {
  con <- local_md_db()

  md_db_load(con, "contributions", file = fixture("contributions_sample.csv"))

  from_db <- dplyr::tbl(con, "contributions") |> dplyr::collect()
  in_memory <- md_contributions(fixture("contributions_sample.csv"))

  expect_true("filing_year" %in% names(from_db))
  expect_setequal(setdiff(names(from_db), "filing_year"), names(in_memory))

  # download_date lives in md_meta for the db path, as an attribute in memory
  ord <- function(d) {
    d <- d[order(d$transaction_amount, d$transaction_date), names(in_memory)]
    attr(d, "download_date") <- NULL
    as.data.frame(d)
  }
  expect_equal(ord(from_db), ord(in_memory))

  # Types survive the SQL path
  expect_s3_class(from_db$transaction_date, "Date")
  expect_type(from_db$transaction_amount, "double")
  # Excel armor stripped
  expect_false(any(grepl("=", from_db$contributor_zip_code), na.rm = TRUE))
})

test_that("md_db_load types committee dates", {
  con <- local_md_db()
  md_db_load(con, "committees", file = fixture("committees_sample.csv"))

  committees <- dplyr::tbl(con, "committees") |> dplyr::collect()
  expect_s3_class(committees$registration_submission_date, "Date")
  expect_equal(nrow(committees), 8)
})

test_that("md_db_load accumulates years and replaces re-ingested ones", {
  con <- local_md_db()
  testthat::local_mocked_bindings(
    md_download = function(type, year = NULL, path = NULL, quiet = FALSE) {
      fixture(paste0(type, "_sample.csv"))
    }
  )

  md_db_load(con, "contributions", year = 2024, quiet = TRUE)
  md_db_load(con, "contributions", year = 2025, quiet = TRUE)

  contributions <- dplyr::tbl(con, "contributions") |> dplyr::collect()
  expect_equal(nrow(contributions), 16)
  expect_setequal(unique(contributions$filing_year), c("2024", "2025"))

  # Re-ingesting the same year replaces, not duplicates
  md_db_load(con, "contributions", year = 2025, quiet = TRUE)
  n <- dplyr::tbl(con, "contributions") |> dplyr::count() |> dplyr::collect()
  expect_equal(n$n, 16)
})

test_that("md_db_load truncates over-long CRIS records like the loaders do", {
  # Real CRIS files contain records with unquoted commas in the description,
  # giving them too many fields. Extra fields must be dropped (as readr
  # does), never wrapped into fragment rows.
  lines <- readLines(fixture("contributions_sample.csv"))
  lines[length(lines)] <- paste0(lines[length(lines)], ",stray overflow,text")
  path <- withr::local_tempfile(fileext = ".csv")
  writeLines(lines, path, sep = "\r\n")

  con <- local_md_db()
  md_db_load(con, "contributions", file = path)

  result <- dplyr::tbl(con, "contributions") |> dplyr::collect()
  expect_equal(nrow(result), 8)
  expect_true(all(grepl("^[0-9]+$", result$filing_entity_id)))
})

test_that("md_db_load rejects a file from the wrong dataset", {
  con <- local_md_db()
  expect_error(
    md_db_load(con, "contributions", file = fixture("committees_sample.csv")),
    "md_committees"
  )
})

test_that("md_db_tables reports what has been loaded", {
  con <- local_md_db()

  expect_equal(nrow(md_db_tables(con)), 0)

  md_db_load(con, "contributions", file = fixture("contributions_sample.csv"))
  info <- md_db_tables(con)

  expect_equal(info$dataset, "contributions")
  expect_equal(info$n_rows, 8)
  expect_s3_class(info$download_date, "POSIXct")
  expect_false(is.na(info$download_date))
})
