# Supplied Flight Result Exports

Date added: 2026-10-10

These two original tab-separated `.txt` files are result artifacts. They are separate from the year-2000 city/elevation merged-results exercise; their query definitions, filters, and measure definitions were not supplied.

| File | Contents |
|---|---|
| [Cancelled Flight Count by Week in 2004](Cancelled%20Flight%20Count%20by%20Week%20in%202004%202026-10-10T1339.txt) | Depart Week and Cancelled Count |
| [Total Distance and Long Flight Count by Carrier](Total%20Distance%20and%20Long%20Flight%20Count%20by%20Carrier%202026-10-10T1339.txt) | Carrier Name, Count Long Flight, and Total Distance |

## Observed values

The weekly file contains a row labeled 2003-12-29 despite its title referring to 2004. A calendar-year filter can include a week bucket starting in the preceding year; the exact filter and week definition need confirmation rather than treating that row as an error.

The row for 2004-12-20 has a displayed cancellation count of 8,701. This is an export observation, not an independently rerun query result or explanation of why cancellations occurred.

The carrier file shows Delta Air Lines with Count Long Flight 1,155,194 and Total Distance 3,664,796,433. The definition of long flight, distance units, and date range are not recorded. Do not infer them from the column titles or equate long-flight count with all-flight count.

## Reuse

Import as tab-separated text. Numeric cells contain comma thousands separators; remove those separators when converting to numeric types. Preserve the original files as source artifacts. Record source Explore, selected fields, filters, sorts, row limits, measure definitions, and units before extending the analysis.

These files supply result evidence for their own tables, not evidence that the merged-results dashboard was saved or that airport elevations matched.
