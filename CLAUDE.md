# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`freestatemoney` is an R package for loading and parsing campaign finance data from Maryland. The package will provide functions to access and analyze Maryland's campaign finance reporting data.

## R Package Structure

This follows standard R package conventions:

- `R/` - R source code for package functions
- `man/` - Documentation files (generated from roxygen2 comments)
- `tests/testthat/` - Unit tests using testthat framework
- `data/` - Data files included with the package (if any)
- `vignettes/` - Long-form documentation and tutorials
- `DESCRIPTION` - Package metadata and dependencies
- `NAMESPACE` - Function exports (generated from roxygen2)

## Development Commands

### Package Setup and Building
```r
# Install development dependencies
install.packages("devtools")
install.packages("roxygen2")
install.packages("testthat")

# Load package for development
devtools::load_all()

# Build documentation from roxygen2 comments
devtools::document()

# Install package locally
devtools::install()

# Build package tarball
devtools::build()
```

### Testing
```r
# Run all tests
devtools::test()

# Run a specific test file
testthat::test_file("tests/testthat/test-filename.R")

# Check package for CRAN compliance
devtools::check()
```

### Code Quality
```r
# Check code style
lintr::lint_package()

# Run R CMD check (comprehensive package validation)
devtools::check()
```

## Development Workflow

1. **Function Development**: Create functions in `R/` directory with roxygen2 documentation comments
2. **Documentation**: Use roxygen2 format (`#'`) above each exported function with `@export` tag
3. **Testing**: Write tests in `tests/testthat/` following the naming convention `test-*.R`
4. **Updates**: Run `devtools::document()` after changing roxygen2 comments to update `NAMESPACE` and `man/` files

## Roxygen2 Documentation Format

Every exported function should have:
```r
#' Brief one-line description
#'
#' More detailed description if needed.
#'
#' @param param_name Description of parameter
#' @return Description of return value
#' @export
#' @examples
#' \dontrun{
#' example_code()
#' }
```

## Data Sources

Maryland campaign finance data is available from the Maryland State Board of Elections at https://campaignfinance.maryland.gov/public/cf/downloads

The data is provided in three main datasets:

### 1. Committees
Committee registration and metadata including:
- Committee identification (Filing Entity ID, name, type)
- Officers (treasurer/authorized agent, chairperson/principal officer with addresses)
- Committee contact information (address, phone, email, website, social media)
- Registration dates (submission, approval, dissolution)
- Candidate information (name, DOB, address, office sought, jurisdiction, party)
- Committee-specific fields for PACs, ballot issues, IE/EC committees, public financing

**Key fields**: Filing Entity ID (unique identifier), Committee Type (Candidate/PAC/Party/etc), Election

### 2. Contributions and Loans
Individual contribution and loan transactions including:
- Committee information (Filing Entity ID, name, type)
- Contributor details (type, name, company, address)
- Transaction details (type, date, amount, payment method)
- Fund type (electoral, administrative, compliance)
- Public funding eligibility (for qualifying contributions)
- Aggregates as of download date

**Key fields**: Filing Entity ID, Transaction Date, Transaction Amount, Transaction Type, Contributor Type, Fund Type
**Special handling**: Lump sum contributions have blank contributor details

### 3. Expenditures, Outstanding Obligations, IE/EC
Spending transactions including:
- Committee information (Filing Entity ID, name, type)
- Payee details (type, name/company, address)
- Vendor information (optional secondary recipient)
- Transaction details (date, amount, category, purpose, fund type)
- In-kind contribution tracking
- Independent Expenditure specific fields (candidate/ballot issue, office sought, position, amount applied)

**Key fields**: Filing Entity ID, Transaction Type, Transaction Date, Transaction Amount, Category, Purpose, Fund Type
**Transaction Types**: Expenditure, Outstanding Obligation, Independent Expenditure (IE), Electioneering Communication (EC)

## Data Architecture Considerations

When implementing data loading functions:

1. **Field Naming**: Convert field positions (A, B, C...) to readable column names using snake_case
2. **Date Handling**: Parse date fields (Transaction Date, Registration dates) as Date objects
3. **Amount Handling**: Parse amount fields as numeric, handling any currency formatting
4. **Nullable Fields**: Many fields are nullable - handle NAs appropriately
5. **Relationships**: Filing Entity ID links all three datasets
6. **Data Types**: Consider appropriate R data types:
   - IDs as character (preserve leading zeros if any)
   - Amounts as numeric
   - Dates as Date
   - Categorical fields (Committee Type, Transaction Type, etc.) as factors or character

## Common Use Cases

Functions should support:
- Loading complete datasets or filtering by date ranges
- Aggregating contributions by contributor, committee, or time period
- Tracking expenditures by category, purpose, or payee
- Linking contributions to expenditures via Filing Entity ID
- Analyzing Independent Expenditures by candidate/issue
- Committee lookups and metadata queries

## License

MIT License - Copyright (c) 2026 NewsAppsUMD
