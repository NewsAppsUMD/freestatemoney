# Quick Start Guide

## Initial Setup

1. **Download data files**:
   - Visit https://campaignfinance.maryland.gov/public/cf/downloads
   - Download Committee, Contributions, and/or Expenditures CSV files
   - Note where files are saved (e.g., `~/Downloads/`)

2. **Install the package**:
   ```r
   # Install from GitHub
   devtools::install_github("NewsAppsUMD/freestatemoney")
   ```

3. **Load the library**:
   ```r
   library(freestatemoney)
   library(dplyr)  # recommended for data manipulation
   ```

## Three Simple Functions

### 1. Load Committee Data

```r
committees <- md_committees("~/Downloads/Committee_2024.csv")
```

Returns information about all registered campaign finance committees including:
- Committee names and types
- Officers and treasurers
- Candidates (if applicable)
- Registration dates
- Contact information

### 2. Load Contributions

```r
contributions <- md_contributions("~/Downloads/Contributions_2024.csv")
```

Returns all contribution and loan transactions including:
- Who gave money (contributor details)
- How much (transaction amounts)
- When (transaction dates)
- To whom (committee information)
- Payment method

### 3. Load Expenditures

```r
expenditures <- md_expenditures("~/Downloads/Expenditures_2024.csv")
```

Returns all spending transactions including:
- Regular expenditures
- Outstanding obligations
- Independent expenditures
- Electioneering communications

## Common Tasks

### Find a specific committee

```r
# Search by name
committees %>%
  filter(grepl("Moore", committee_name, ignore.case = TRUE))

# Get candidate committees only
committees %>%
  filter(committee_type == "Candidate")
```

### Analyze contributions for a committee

```r
# Load the data first
committees <- md_committees("~/Downloads/Committee_2024.csv")
contributions <- md_contributions("~/Downloads/Contributions_2024.csv")

# Get Filing Entity ID from committees table
committee_id <- "YOUR_COMMITTEE_ID"

# Get all contributions to that committee
committee_contributions <- contributions %>%
  filter(filing_entity_id == committee_id) %>%
  arrange(desc(transaction_amount))
```

### Find large contributions

```r
large_contributions <- contributions %>%
  filter(transaction_amount >= 1000) %>%
  select(
    committee_name,
    contributor_last_name,
    contributor_first_name,
    transaction_amount,
    transaction_date
  ) %>%
  arrange(desc(transaction_amount))
```

### Summarize spending by category

```r
expenditures %>%
  group_by(category) %>%
  summarize(
    total = sum(transaction_amount, na.rm = TRUE),
    count = n()
  ) %>%
  arrange(desc(total))
```

### Track Independent Expenditures

```r
independent_exp <- expenditures %>%
  filter(transaction_type == "Independent Expenditure") %>%
  select(
    committee_name,
    candidate_ballot_issue,
    position,
    transaction_amount,
    transaction_date,
    purpose
  )
```

### Join datasets together

```r
# Add committee details to contributions
contributions_detailed <- contributions %>%
  left_join(
    committees %>% select(filing_entity_id, committee_type, office_sought),
    by = "filing_entity_id"
  )

# Calculate total raised and spent per committee
committee_finances <- committees %>%
  left_join(
    contributions %>%
      group_by(filing_entity_id) %>%
      summarize(raised = sum(transaction_amount, na.rm = TRUE)),
    by = "filing_entity_id"
  ) %>%
  left_join(
    expenditures %>%
      group_by(filing_entity_id) %>%
      summarize(spent = sum(transaction_amount, na.rm = TRUE)),
    by = "filing_entity_id"
  ) %>%
  mutate(balance = raised - spent)
```

## Important Fields

### Key Identifiers
- `filing_entity_id`: Unique committee ID (links all three datasets)
- `transaction_id`: Unique transaction ID (expenditures only)

### Key Dates
- `transaction_date`: When the transaction occurred
- `registration_submission_date`: When committee registered
- `registration_approval_date`: When committee approved

### Key Amounts
- `transaction_amount`: Dollar amount of transaction
- All amounts are numeric (not character strings)

### Key Categories
- `committee_type`: Candidate, PAC, Party, Public financing, etc.
- `contributor_type`: Individual, Business, PAC, etc.
- `transaction_type`: Contribution, Loan, Expenditure, IE, EC, etc.
- `fund_type`: Electoral, Administrative, Compliance

## Tips

1. **Use `clean_names = TRUE`** (the default) for consistent snake_case column names
2. **Filter by date** to focus on specific time periods
3. **Use `filing_entity_id`** to link data across the three datasets
4. **Check for NAs** - many fields are nullable
5. **Aggregate amounts** using `sum()` with `na.rm = TRUE`

## Next Steps

- See `inst/examples/basic_analysis.R` for more detailed examples
- Read the full documentation: `?md_committees`, `?md_contributions`, `?md_expenditures`
- Check out the tidyverse documentation: https://www.tidyverse.org/
