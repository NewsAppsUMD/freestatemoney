#' Summarize fundraising and spending by committee
#'
#' Joins the three CRIS datasets on `filing_entity_id` and totals what each
#' committee raised and spent. Outstanding obligations (unpaid debts) are
#' excluded from spending totals. Committees with no transactions get zeros
#' rather than NAs.
#'
#' Note that `net_raised` reflects only the transactions in the data you
#' loaded - it is not the committee's official cash balance, which also
#' depends on prior balances and non-itemized activity.
#'
#' @param committees Tibble from [md_committees()]
#' @param contributions Tibble from [md_contributions()]
#' @param expenditures Tibble from [md_expenditures()]
#'
#' @return A tibble with one row per committee: `filing_entity_id`,
#'   `committee_name`, `committee_type`, `total_raised`, `n_contributions`,
#'   `total_spent`, `n_expenditures`, and `net_raised`, sorted by
#'   `total_raised` descending.
#' @export
#'
#' @importFrom dplyr group_by summarize left_join mutate arrange select
#'   distinct n desc coalesce filter
#'
#' @examples
#' sample_file <- function(name) {
#'   system.file("extdata", name, package = "freestatemoney")
#' }
#' committees <- md_committees(sample_file("committees_sample.csv"))
#' contributions <- md_contributions(sample_file("contributions_sample.csv"))
#' expenditures <- md_expenditures(sample_file("expenditures_sample.csv"))
#'
#' md_committee_summary(committees, contributions, expenditures)
md_committee_summary <- function(committees, contributions, expenditures) {
  raised <- contributions |>
    dplyr::group_by(filing_entity_id) |>
    dplyr::summarize(
      total_raised = sum(transaction_amount, na.rm = TRUE),
      n_contributions = dplyr::n(),
      .groups = "drop"
    )

  spending <- expenditures
  if ("transaction_type" %in% names(spending)) {
    spending <- dplyr::filter(
      spending, !grepl("Outstanding Obligation", transaction_type)
    )
  }
  spent <- spending |>
    dplyr::group_by(filing_entity_id) |>
    dplyr::summarize(
      total_spent = sum(transaction_amount, na.rm = TRUE),
      n_expenditures = dplyr::n(),
      .groups = "drop"
    )

  committees |>
    dplyr::select(filing_entity_id, committee_name, committee_type) |>
    dplyr::distinct(filing_entity_id, .keep_all = TRUE) |>
    dplyr::left_join(raised, by = "filing_entity_id") |>
    dplyr::left_join(spent, by = "filing_entity_id") |>
    dplyr::mutate(
      total_raised = dplyr::coalesce(total_raised, 0),
      n_contributions = dplyr::coalesce(n_contributions, 0L),
      total_spent = dplyr::coalesce(total_spent, 0),
      n_expenditures = dplyr::coalesce(n_expenditures, 0L),
      net_raised = total_raised - total_spent
    ) |>
    dplyr::arrange(dplyr::desc(total_raised))
}

#' Rank contributors by total amount given
#'
#' Aggregates contributions by contributor. Organizations are identified by
#' their company name; individuals by "Last, First". Lump-sum rows with no
#' contributor details are dropped.
#'
#' Contributors are grouped by name as reported, so the same person reported
#' under different spellings appears as separate rows.
#'
#' @param contributions Tibble from [md_contributions()]
#' @param n Maximum number of contributors to return (default 25)
#'
#' @return A tibble with `contributor`, `contributor_type`, `total`, and
#'   `n_contributions`, sorted by `total` descending.
#' @export
#'
#' @importFrom dplyr case_when group_by summarize arrange slice_head
#'
#' @examples
#' contributions <- md_contributions(
#'   system.file("extdata", "contributions_sample.csv", package = "freestatemoney")
#' )
#' md_top_contributors(contributions, n = 10)
md_top_contributors <- function(contributions, n = 25) {
  contributions |>
    dplyr::mutate(
      contributor = dplyr::case_when(
        !is.na(contributor_company_name) ~ contributor_company_name,
        !is.na(contributor_last_name) & !is.na(contributor_first_name) ~
          paste0(contributor_last_name, ", ", contributor_first_name),
        !is.na(contributor_last_name) ~ contributor_last_name,
        TRUE ~ NA_character_
      )
    ) |>
    dplyr::filter(!is.na(contributor)) |>
    dplyr::group_by(contributor, contributor_type) |>
    dplyr::summarize(
      total = sum(transaction_amount, na.rm = TRUE),
      n_contributions = dplyr::n(),
      .groups = "drop"
    ) |>
    dplyr::arrange(dplyr::desc(total)) |>
    dplyr::slice_head(n = n)
}

#' Summarize independent expenditures and electioneering communications
#'
#' Filters expenditure data to independent expenditure (IE) and
#' electioneering communication (EC) transactions and totals spending by
#' committee, target candidate or ballot issue, and position.
#'
#' Note: CRIS reports these with transaction types like
#' "Independent Expenditure / Electioneering Communication", so matching is
#' by pattern, not exact equality.
#'
#' @param expenditures Tibble from [md_expenditures()]
#'
#' @return A tibble with `committee_name`, `candidate_ballot_issue`,
#'   `position`, `total_spent`, and `n_expenditures`, sorted by `total_spent`
#'   descending.
#' @export
#'
#' @examples
#' expenditures <- md_expenditures(
#'   system.file("extdata", "expenditures_sample.csv", package = "freestatemoney")
#' )
#' md_independent_expenditures(expenditures)
md_independent_expenditures <- function(expenditures) {
  expenditures |>
    dplyr::filter(grepl(
      "Independent Expenditure|Electioneering", transaction_type
    )) |>
    dplyr::group_by(committee_name, candidate_ballot_issue, position) |>
    dplyr::summarize(
      total_spent = sum(transaction_amount, na.rm = TRUE),
      n_expenditures = dplyr::n(),
      .groups = "drop"
    ) |>
    dplyr::arrange(dplyr::desc(total_spent))
}
