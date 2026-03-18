# How to Download Maryland Campaign Finance Data

The `freestatemoney` package works with CSV files that you download manually from the Maryland State Board of Elections website. The downloads are triggered by JavaScript, so they cannot be automated directly.

## Download Steps

1. **Visit the download page**:
   https://campaignfinance.maryland.gov/public/cf/downloads

2. **Select your data type**:
   - **Committees**: Registration and metadata for all committees
   - **Contributions and Loans**: All contribution transactions
   - **Expenditures**: All spending transactions (includes IE/EC)

3. **Select time period**:
   - Current year, current cycle (most recent data)
   - Previous year
   - Or specific cycles/years as available

4. **Click the download button** to save the CSV file

5. **Note the file location** (typically `~/Downloads/`)

## File Naming

Files downloaded from the Maryland SBE typically follow naming patterns like:
- `Committee_2024.csv`
- `Contributions_2024.csv`
- `Expenditures_2024.csv`

Or similar variations depending on the cycle/year selected.

## Using the Files

Once downloaded, use the file paths with the package functions:

```r
library(freestatemoney)

# Load the data from your downloads
committees <- md_committees("~/Downloads/Committee_2024.csv")
contributions <- md_contributions("~/Downloads/Contributions_2024.csv")
expenditures <- md_expenditures("~/Downloads/Expenditures_2024.csv")
```

## Tips

- **Download all three files** if you plan to link data across datasets using `filing_entity_id`
- **Check dates**: The download page typically offers current cycle and previous year data
- **File size**: These files can be large (especially contributions and expenditures)
- **Keep organized**: Consider creating a dedicated folder for Maryland campaign finance data
- **Update regularly**: Download fresh files periodically to get the latest filings

## Data Freshness

The Maryland State Board of Elections updates the downloadable files periodically as new reports are filed. Check the "last modified" date on the download page to see when data was last updated.

## Automation Alternatives

If you need automated downloads, you could:
1. Use browser automation tools like Selenium to trigger the JavaScript downloads
2. Check if Maryland SBE offers an API (as of this writing, downloads are JS-triggered)
3. Set up a scheduled task to manually download and process files

However, for most users, manual downloads work well since the data doesn't change minute-to-minute.
