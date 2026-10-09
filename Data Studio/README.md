# Ecommerce Product Operations Report — Data Studio

Date: 2026-10-09
Goal: connect BigQuery data to a visual report, customize tables and charts, and review the report for future reuse.

Status: course-based dashboard created and exported. The connection issue was resolved by opening the reporting tool from BigQuery. Report metrics and business assumptions still require independent validation before operational use.

## Files

| File | Purpose |
|---|---|
| [Original course notes](Data%20studio.txt) | Course overview and learning objectives, preserved unchanged |
| [Report PDF](Ecommerce_Product_Operations_Report.pdf) | Static one-page export of the created dashboard |
| [Report screenshot](%7BA006B1CF-2F7C-4C69-9199-88492266CC18%7D.png) | Editor screenshot showing the connected source and chart layout |
| [Troubleshooting](TROUBLESHOOTING.md) | Actual connection error, unsuccessful restart, and confirmed solution |
| [Validation SQL template](validate-sales-report.sql) | Proposed read-only checks; replace the source path before use |

The original notes are short and contain no detailed lab steps or SQL used to build `sales_report`. This guide adds a reuse procedure based on the supplied report evidence; it does not claim to reconstruct the missing source transformation or the full course instructions.

## Scenario

An ecommerce operations team wants to view product ordering activity alongside inventory and replenishment information. The report is titled Ecommerce Product Operations Report and its page is Product Inventory Watchlist.

The course describes Google Merchandise Store analytics in BigQuery. The report's connected source is named `sales_report`. Its fully qualified project/dataset/table path and creation query were not supplied, so the exact lineage from the course dataset remains to be documented.

## Service choice and my assessment

BigQuery provides the analytical data source, and Data Studio provides report authoring and visualization. Opening the table from BigQuery successfully established the reporting connection in this lab.

The course specifies these services; no independent architecture comparison was performed. BigQuery's editor is an alternative for examining raw query results, but the report offers a visual way to compare products. The separate Looker product is not required for this exercise. Dataform could later manage the underlying transformation and checks, but no Dataform integration was implemented here.

Data Studio and Looker Studio refer to the same reporting product across naming changes. Looker is a separate business-intelligence product. The lab menu may still say Looker Studio.

## Implementation and observed configuration

### 1. Connect from BigQuery

The route that worked:

1. Open the `sales_report` table in BigQuery.
2. Choose **Open in** beside **Export / sync**.
3. Choose **Looker Studio** (or Data Studio if renamed in the interface).
4. Continue in the new reporting tab and confirm that the source fields and chart data load.

This route was suggested by Gemini and confirmed by the learner. It does not bypass permissions and does not establish that administrative credentials were used. The exact reason the previous connection failed is unknown; see the troubleshooting record.

### 2. Inspect available fields

The screenshot shows these fields in the source panel:

| Field | Visible role / interpretation to verify |
|---|---|
| `name` | Product display name; repeated names appear in the report |
| `productSKU` | Candidate product identifier; validate uniqueness at source grain |
| `total_ordered` | Ordering metric; units, aggregation, and time period were not captured |
| `stockLevel` | Inventory value; snapshot time and units were not captured |
| `ratio` | Numeric metric; formula was not supplied |
| `restockingLeadTime` | Replenishment lead-time value; units were not supplied |
| `sentimentScore`, `sentimentMagnitude` | Available source fields, not used in the visible charts |
| Record Count | Connector-provided metric visible in the source panel |

Do not infer ratio's formula solely from rounded displayed values. Save its exact calculation before reusing it.

### 3. Current report components

| Component | Visible setup |
|---|---|
| Upper-left table | productSKU and total_ordered, descending by total_ordered |
| Bar chart | stockLevel on horizontal axis; total_ordered on vertical axis |
| Lower table | name, stockLevel, ratio, restockingLeadTime, total_ordered |

The PDF and screenshot show pagination totals of 454 rows in both tables. This is report-level evidence, not an independently verified source row count or proof of 454 distinct products. Chart aggregation, filters, and dimensions can affect the visible row count.

The leading SKU in the exported table is GGOEGOAQ012899 with displayed total_ordered 456. Hard Cover Journal is shown with stockLevel 2046, ratio 0.04, lead time 13, and total_ordered 85. These are observed display values, not independently reconciled business facts.

### 4. Interactive filtering

Creating an interactive filter is a stated course objective. The screenshot shows an Add filter interface, but it does not demonstrate that a report-view filter control was configured or tested. Do not mark this objective as verified solely from the screenshot.

For future reuse, add a product/SKU or category control using a field that exists in the source. Test one selection, multiple selections if enabled, and reset. Record which charts respond. A PDF is static and cannot preserve live filter behavior.

## Future reuse procedure

1. Identify the full source table path and recover the query that creates it.
2. Confirm the current account, data credentials, and query/billing project in the connection.
3. Inspect schema, row grain, source date range, inventory snapshot time, and metric units.
4. Replace the placeholder source path in `validate-sales-report.sql` and run statements individually in BigQuery.
5. Check chart aggregation: avoid summing repeated inventory snapshots or pre-aggregated totals without understanding the source grain.
6. Recreate the observed components, or copy the original report if its editable link is available. No editable report URL was supplied here.
7. Test filtering and reconcile a selected SKU against BigQuery.
8. Export a new PDF and save the date, source version, and settings with it.

No cloud resources were created or queried during documentation. The supplied PDF and screenshot remain unchanged.

## Improvements to consider, not implemented

- Use productSKU or product name as the bar-chart dimension if the goal is to rank products. The current stockLevel dimension compares order totals by stock value and can combine products sharing that value.
- Include SKU in the lower table. Repeated Men's Fleece Hoodie Black names may represent variants; investigate before deduplicating.
- Document ratio's exact formula and show sufficient precision. A displayed zero may reflect rounding rather than no activity.
- Add the ordering date range and inventory snapshot timestamp to the report.
- Define a real watchlist rule before flagging stockout risk. Historical orders, current stock, and lead time alone do not establish a forecast without time units and assumptions.

## Validation

| Check | Expected | Actual evidence |
|---|---|---|
| Source connection | Data loads in report | Confirmed by learner; screenshot and PDF contain data |
| Browser restart | Determine whether session issue resolves access | Tried; same error persisted |
| BigQuery Open in route | Report opens with working connection | Confirmed successful |
| Report layout | Tables and chart visible | Confirmed in supplied screenshot and one-page PDF |
| Data reconciliation | Displayed values match correct source grain | Not independently tested |
| Interactive filter | Intended charts update and reset correctly | Not demonstrated in supplied evidence |
| Inventory watchlist rule | Defined metric and decision threshold | Formula and rule not supplied |

## Problems and resolution

The actual failure was No dataset access / Insufficient permissions to the underlying data set. Multiple signed-in learner sessions were suspected, but restarting did not help. Opening `sales_report` directly from BigQuery through Open in → Looker Studio resolved it. The original cause remains unconfirmed; public data access does not establish every required connection or job permission.

The full chronology, Gemini attribution, and distinction between observed success and an unverified credential explanation are in [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

## What this study demonstrates

A working BigQuery-to-report connection, basic report composition, an exported dashboard, and a documented troubleshooting outcome. Treat this as a course-based visualization exercise. Independent metric definitions, source reconciliation, filter validation, and a documented inventory rule would be needed for a stronger operational portfolio claim.

## References

- [Data Studio naming](https://cloud.google.com/blog/products/data-analytics/looker-studio-is-data-studio)
- [Looker and Data Studio comparison](https://docs.cloud.google.com/looker/docs/studio-comparison)
- [BigQuery connector requirements](https://docs.cloud.google.com/data-studio/connect-to-google-bigquery)
