fixture <- function(name) {
  system.file("extdata", name, package = "freestatemoney", mustWork = TRUE)
}

# Real CRIS files contain rows broken by a bare LF inside an unquoted field
# (a multi-line address), and Windows-1252 bytes appearing megabytes into the
# file, past encoding-sniffing windows. Build a dirty file exhibiting both
# from the clean sample.
make_dirty_contributions <- function(env = parent.frame()) {
  raw_bytes <- readBin(fixture("contributions_sample.csv"), "raw",
                       file.size(fixture("contributions_sample.csv")))
  text <- rawToChar(raw_bytes)

  # Split one address across two physical lines with a bare LF (no CR)
  text <- sub("1001 Spring Gate Rd", "1001 Spring Gate Rd\nApt 2", text, fixed = TRUE)
  dirty <- charToRaw(text)

  # Give one contributor a Windows-1252 e-acute: 0xE9 = é, invalid as UTF-8
  heath <- grepRaw("HEATH", dirty)[1]
  dirty[heath + 1L] <- as.raw(0xE9)

  path <- withr::local_tempfile(fileext = ".csv", .local_envir = env)
  writeBin(dirty, path)
  path
}

test_that("md_contributions repairs bare in-field line breaks", {
  dirty <- make_dirty_contributions()

  expect_message(result <- md_contributions(dirty), "line break")

  expect_equal(nrow(result), 8)
  # The split address is rejoined with a space
  expect_true(any(grepl("1001 Spring Gate Rd Apt 2",
                        result$contributor_mailing_address1)))
})

test_that("md_contributions decodes Windows-1252 bytes anywhere in the file", {
  dirty <- make_dirty_contributions()
  result <- suppressMessages(md_contributions(dirty))

  expect_true("HéATH" %in% result$contributor_last_name)
})

test_that("quoted CRLF line breaks are left alone", {
  clean <- readLines(fixture("contributions_sample.csv"))
  # A legitimately quoted multi-line field, CRLF flavor (legal CSV)
  quoted_row <- sub(
    "Check #50269 was written on 1/8/25 and was lost in the mail.",
    "\"line one\r\nline two\"",
    clean[grepl("Check #50269", clean)],
    fixed = TRUE
  )
  path <- withr::local_tempfile(fileext = ".csv")
  write_crlf_lines(c(clean[1:2], quoted_row), path)

  expect_no_message(result <- md_contributions(path))
  expect_equal(nrow(result), 1)
  expect_true(any(grepl("line one\r\nline two", result$description)))
})

test_that("clean files are read without a repair pass or message", {
  expect_no_message(
    result <- md_contributions(fixture("contributions_sample.csv"))
  )
  expect_equal(nrow(result), 8)
})

test_that("md_db_load repairs the same defects", {
  skip_if_not_installed("duckdb")
  dirty <- make_dirty_contributions()

  con <- md_db(withr::local_tempfile(fileext = ".duckdb"))
  withr::defer(DBI::dbDisconnect(con))

  suppressMessages(md_db_load(con, "contributions", file = dirty))
  result <- dplyr::tbl(con, "contributions") |> dplyr::collect()

  expect_equal(nrow(result), 8)
  expect_true(any(grepl("1001 Spring Gate Rd Apt 2",
                        result$contributor_mailing_address1)))
  expect_true("HéATH" %in% result$contributor_last_name)
})
