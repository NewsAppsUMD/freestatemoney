# Basic Analysis Examples for freestatemoney
#
# This script demonstrates common analysis patterns using the freestatemoney package
#
# Prerequisites:
# 1. Download CSV files from https://campaignfinance.maryland.gov/public/cf/downloads
# 2. Update the file paths below to match your download locations

library(freestatemoney)
library(dplyr)
library(ggplot2)

# Load data ---------------------------------------------------------------

# Update these paths to match where you saved the downloaded CSV files
committees <- md_committees("~/Downloads/Committee_2024.csv")
contributions <- md_contributions("~/Downloads/Contributions_2024.csv")
expenditures <- md_expenditures("~/Downloads/Expenditures_2024.csv")

# Basic exploration -------------------------------------------------------

# How many committees of each type?
committees %>%
  count(committee_type, sort = TRUE)

# What's the distribution of contribution amounts?
contributions %>%
  filter(transaction_amount > 0) %>%
  summary(transaction_amount)

# Top payees by total spending
expenditures %>%
  group_by(payee_company_name) %>%
  summarize(
    total_spent = sum(transaction_amount, na.rm = TRUE),
    num_transactions = n()
  ) %>%
  arrange(desc(total_spent)) %>%
  head(10)

# Committee analysis ------------------------------------------------------

# Find candidate committees with their details
candidate_committees <- committees %>%
  filter(committee_type == "Candidate") %>%
  select(
    filing_entity_id,
    committee_name,
    candidate_last_name,
    candidate_first_name,
    office_sought,
    jurisdiction,
    party_affiliation
  )

# Contribution analysis ---------------------------------------------------

# Top contributors by total amount
top_contributors <- contributions %>%
  group_by(contributor_last_name, contributor_first_name, contributor_type) %>%
  summarize(
    total_contributed = sum(transaction_amount, na.rm = TRUE),
    num_contributions = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(total_contributed)) %>%
  head(20)

# Contributions over time
contributions_by_month <- contributions %>%
  mutate(month = lubridate::floor_date(transaction_date, "month")) %>%
  group_by(month) %>%
  summarize(
    total = sum(transaction_amount, na.rm = TRUE),
    count = n()
  )

# Expenditure analysis ----------------------------------------------------

# Spending by category
spending_by_category <- expenditures %>%
  group_by(category) %>%
  summarize(
    total = sum(transaction_amount, na.rm = TRUE),
    avg = mean(transaction_amount, na.rm = TRUE),
    count = n()
  ) %>%
  arrange(desc(total))

# Independent Expenditures
independent_expenditures <- expenditures %>%
  filter(transaction_type == "Independent Expenditure") %>%
  group_by(candidate_ballot_issue, position) %>%
  summarize(
    total_spent = sum(transaction_amount, na.rm = TRUE),
    num_expenditures = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(total_spent))

# Combined analysis -------------------------------------------------------

# Committee fundraising and spending summary
committee_summary <- committees %>%
  left_join(
    contributions %>%
      group_by(filing_entity_id) %>%
      summarize(total_raised = sum(transaction_amount, na.rm = TRUE)),
    by = "filing_entity_id"
  ) %>%
  left_join(
    expenditures %>%
      group_by(filing_entity_id) %>%
      summarize(total_spent = sum(transaction_amount, na.rm = TRUE)),
    by = "filing_entity_id"
  ) %>%
  mutate(
    cash_on_hand = total_raised - total_spent,
    burn_rate = total_spent / total_raised
  ) %>%
  filter(!is.na(total_raised) | !is.na(total_spent))

# Top fundraisers by committee type
top_fundraisers_by_type <- committee_summary %>%
  group_by(committee_type) %>%
  arrange(desc(total_raised)) %>%
  slice_head(n = 5) %>%
  select(committee_type, committee_name, total_raised, total_spent, cash_on_hand)

# Visualization examples --------------------------------------------------

# Plot contributions over time
ggplot(contributions_by_month, aes(x = month, y = total)) +
  geom_line() +
  geom_point() +
  scale_y_continuous(labels = scales::dollar) +
  labs(
    title = "Total Contributions Over Time",
    x = "Month",
    y = "Total Contributions"
  ) +
  theme_minimal()

# Plot spending by category
spending_by_category %>%
  head(10) %>%
  ggplot(aes(x = reorder(category, total), y = total)) +
  geom_col() +
  coord_flip() +
  scale_y_continuous(labels = scales::dollar) +
  labs(
    title = "Top 10 Spending Categories",
    x = "Category",
    y = "Total Spent"
  ) +
  theme_minimal()
