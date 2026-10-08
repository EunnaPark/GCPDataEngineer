# Ecommerce Data Quality and Product Analysis in BigQuery

Date organized: 2026-10-08
Goal: understand the course's raw-data-to-analysis story and develop it into a defensible portfolio investigation.

Status: guided study plus a proposed independent extension. No ecommerce query results have been independently supplied or executed during this organization.

## Scenario

An analyst team has exported Google Merchandise Store analytics into BigQuery. Before deciding which products are popular, the team needs to understand the records, investigate duplicates, and decide what views and orders mean in this dataset.

The useful business question is: **Are the most-viewed products also the most-purchased, and can we trust the counts?** The course starts this investigation, but its SQL labels alone do not establish the business meaning of the metrics.

## Service choice and alternatives

BigQuery fits SQL exploration and aggregation over the existing analytical dataset. Starting with the supplied public tables avoids building an ingestion service before learning the data. Dataform would be a useful next step for saving transformation dependencies and automated quality checks; it has not been implemented here.

Cloud Storage is useful when owning source files and replaying ingestion. It is not necessary for the current public-table exercise. Cloud SQL would add database provisioning without serving a requirement in this workflow. These are design assessments, not implemented comparisons.

## Data sources and row grain

| Table | Role in the course |
|---|---|
| `data-to-insights.ecommerce.all_sessions_raw` | Raw records used to investigate identical rows |
| `data-to-insights.ecommerce.all_sessions` | Already-cleaned table supplied by the course |

Do not assume that a table with sessions in its name has one row per session. The course uses visitor, visit, hit time, product, event type, action, and transaction fields together, suggesting a finer grain that must be profiled.

Important identifiers:

- `fullVisitorId`: visitor identifier; preserve its type rather than converting it to a numeric value.
- `visitId`: session identifier scoped to a visitor; do not assume it is globally unique by itself.
- `time` and `type`: help distinguish activity within a visit.
- `productSKU` and `v2ProductName`: product identity and display name; inspect their relationship.
- `transactionId`: candidate transaction identifier; inspect missing values and scope before counting orders.
- `eCommerceAction_type`: distinguishes ecommerce actions; verify the flattened table's representation against the source schema.

The reference schema is historical Universal Analytics, not GA4. The course tables are flattened teaching tables, not the original nested export. Schema documentation helps interpretation but is not proof that these transformed fields behave identically.

## 1. Explore metadata and samples

In BigQuery, star project `data-to-insights`, expand ecommerce, and inspect both tables. Schema shows types, Details shows metadata, and Preview shows sample records. Record the actual row count, date range, field types, missing values, and job location before analysis.

Run section 1 of `ecommerce-queries.sql` to profile the cleaned table. The date-range query reports the stored string range; confirm YYYYMMDD formatting before using it as a calendar range.

## 2. Investigate exact duplicates

The course groups the raw table by all listed fields and keeps groups whose COUNT exceeds one. The SQL file preserves that field list.

There are three different quantities:

- Duplicate groups: number of result rows from the grouped query.
- Rows in duplicate groups: sum of the group counts.
- Excess rows: sum of group count minus one, if keeping one record per group is the chosen cleaning rule.

The course alias num_duplicate_rows describes the count inside a group; it is not the total number of extra records in the source. The summary query makes these meanings explicit.

An exact match is not automatically an ingestion error. Explain the row grain and decide whether identical records can represent legitimate repeated activity before applying a cleaning rule. Also confirm that the grouped field list still covers the full schema; added fields could change the definition of an exact match.

## 3. Validate the supplied cleaned table

The next course query groups a selected twelve-field composite key in `all_sessions`. The course states that it returns zero records. This is an expected course result, not a result independently confirmed here.

This check differs from comparing every raw column. Passing it only establishes uniqueness under those selected fields in that table snapshot. It does not prove completeness, correct revenue, or absence of every data-quality problem.

The course switches to a table someone else already cleaned. It does not implement the cleaning transformation. For an independent portfolio extension, create a separate model in your own dataset, document the chosen rule, and reconcile raw rows, retained rows, and removed rows. Do not overwrite the public source.

## 4. Reproduce the course analysis with precise labels

The SQL file covers each analytical step:

1. Count table rows and unique visitor IDs.
2. Count unique visitors within each channel.
3. List distinct product names.
4. Rank product names by PAGE-record counts.
5. Count one visitor/product-name pair across the observed period.
6. Compare non-null quantity-record counts and summed quantities.
7. Calculate average quantity per non-null quantity record.

COUNT(*) counts records. Calling every record a product view requires evidence about the table grain and event types. For this reason, the organized queries use labels such as page_records and quantity_records where the original course uses product_views and orders.

Distinct visitors by channel are distinct within each group. A visitor can appear in more than one channel, so summing channel counts need not equal overall unique visitors.

The unique-product-view CTE groups by visitor and product name over the entire available period. It does not count one view per session or per day. NULL visitor IDs also require attention: COUNT(DISTINCT fullVisitorId) ignores NULL, while grouping visitor/product pairs can retain a NULL visitor group.

## 5. Investigate views, orders, and quantity

`COUNT(productQuantity)` counts records where quantity is not NULL. It does not independently count distinct orders, and it also includes zero values. `SUM(productQuantity)` adds available quantity values. Dividing them produces average quantity per non-null record.

The organized example uses SAFE_DIVIDE so a zero denominator produces NULL. This is a deliberate robustness change from the course's direct division. NULL means unavailable/undefined here, not zero purchases.

A candidate purchase analysis could filter completed-purchase actions and count transaction IDs. Before building that metric, inspect action values, missing transaction IDs, transaction scope, repeated product lines, and quantities. Do not treat a bare COUNT(DISTINCT transactionId) as a universal fix.

The source UA schema maps completed purchases to action type 6. Confirm that mapping and representation in this flattened dataset before using it. The supplied PAGE filter alone is not a verified purchase filter.

## 6. Product names and ranking limitations

The course groups by name. Inspect whether one name maps to multiple SKUs or one SKU maps to multiple names. Choose product grain explicitly before interpreting rankings.

The final average is computed only for the five most-viewed product names. A maximum among those five is not necessarily the maximum across all products. The course reports 633 distinct names and describes the 22 oz YouTube Bottle Infuser as having 9.38 units per order; both remain course-provided statements, and the denominator requires investigation before repeating the latter as a business finding.

## Validation

| Check | Expected or intended result | Actual evidence |
|---|---|---|
| Raw duplicate grouping | Identify repeated field combinations | Query supplied; execution pending |
| Duplicate summary | Distinguish groups, affected rows, and excess rows | Proposed extension; pending |
| Cleaned composite key | Course expects zero duplicate groups | Course statement only |
| Product-name list | Course reports 633 names | Not independently reproduced |
| View rankings | Compare record counts and distinct visitor/product pairs | No actual output supplied |
| Quantity metric | Establish whether records correspond to orders | Open investigation |
| Independent cleaning | Reconcile before/after row counts | Not implemented |

## Problems and resolutions

No runtime failure was supplied for this ecommerce course. The issues below are interpretation risks identified during review, not invented execution incidents.

| Issue | Resolution or next test |
|---|---|
| Duplicate-group count mistaken for removed rows | Report groups, affected rows, and excess rows separately |
| Provided cleaned table presented as my transformation | Implement and validate my own model before claiming ownership |
| Quantity records labeled orders | Validate transaction grain and purchase-event conditions |
| Product name treated as a unique ID | Profile name/SKU mappings and document grouping choice |
| Highest average among top-viewed five presented as global maximum | State the restricted population or rank all qualifying products |
| Course output presented as my execution | Save actual job results and label expected vs observed values |

## Portfolio completion plan

1. Execute the source profiling and save results with dates and job details.
2. Explain the row grain and choose a defensible duplicate rule.
3. Build a cleaned model in an owned dataset and reconcile row counts.
4. Define views, unique viewers, purchase transactions, and units with explicit inclusion rules.
5. Compare course-style and revised metrics using real results; explain differences.
6. Add Dataform models and assertions only after the assumptions are understood.
7. Publish a concise findings table, reproducible SQL, quality checks, limitations, and source attribution.

Until those steps are completed, describe this as a guided ecommerce SQL study with a metric-quality investigation, not a completed production pipeline or proven revenue improvement.

## References

- Original course notes: `BigQuery - Ecommerce Dataset with SQL.txt` (preserved).
- [Universal Analytics export schema](https://support.google.com/analytics/answer/3437719?hl=en)
- [BigQuery aggregate functions](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/aggregate_functions)
- [Dataform quality assertions](https://docs.cloud.google.com/dataform/docs/test-data)
