# BigQuery — Troubleshooting Common SQL Errors

Date recorded: 2026-10-09
Status: course taken; guided review of familiar SQL concepts.

## Goal and learning reflection

Review syntax and logic errors using BigQuery's query editor and validator. I had already encountered most of these concepts, so this course is retained as a learning record rather than presented as a new independent portfolio project.

The original course text is preserved in `BigQuery - Troubleshooting Common SQL Errors.txt`. Corrected examples are collected in `troubleshooting-common-errors.sql`; run statements separately. No queries were executed while organizing this record, and no numerical results or lab assessment scores are claimed.

## Scenario

The course asks me to review a new analyst's queries about ecommerce checkout visitors, city-level activity, and product categories. The supplied table is `data-to-insights.ecommerce.rev_transactions`. Its flattened column names differ from the `all_sessions` table in the earlier ecommerce course; queries cannot be copied between them without checking the schema.

## Service and approach

BigQuery and its SQL editor are provided by the course. The validator helps identify syntax errors before execution; job details provide errors for failed jobs. A successful validation does not establish that the query answers the business question. This exercise did not involve an independent service selection or comparison of alternative architectures.

Star `data-to-insights` in Explorer, inspect the table schema, and use GoogleSQL. In Cloud Shell, select `--use_legacy_sql=false` explicitly. A bracketed Legacy SQL table identifier is incompatible with a query explicitly marked `#standardSQL`.

## 1. Columns, identifiers, and aliases

The first example has two issues: an empty SELECT list and a misspelled project ID, `data-to-inghts`. Correct the project identifier and select actual columns. The typo is in the project component, not the dataset `ecommerce`.

```sql
SELECT fullVisitorId, hits_page_pageTitle
FROM `data-to-insights.ecommerce.rev_transactions`
LIMIT 1000;
```

A missing comma can cause a valid but unintended alias:

```sql
SELECT fullVisitorId hits_page_pageTitle
FROM `data-to-insights.ecommerce.rev_transactions`
LIMIT 1000;
```

This selects one column, fullVisitorId, with output name hits_page_pageTitle. It does not select both fields. Use a comma for two fields or explicit AS when an alias is intentional.

A query returning visitor IDs without a LIMIT or aggregation is not inherently invalid. It simply does not answer the question of how many unique visitors reached checkout. LIMIT restricts returned rows; it is not a complete cost-control strategy.

## 2. Unique checkout visitors and GROUP BY

COUNT(fullVisitorId) counts non-null records and can count the same visitor repeatedly. COUNT(DISTINCT fullVisitorId) counts distinct non-null visitor identifiers. When selecting page title alongside a count, group by page title.

Filter the course's checkout proxy with `hits_page_pageTitle = 'Checkout Confirmation'`. The SQL file includes a breakdown by page title and a one-row total for that filter. The total version returns zero when no matching visitor IDs exist, while the grouped version can return no rows.

A confirmation-page title is the course's operational definition. It is not independent proof of completed payment or a unique transaction. Do not present the visitor count as an order count.

## 3. City aggregation, sorting, and HAVING

The course aggregates SUM(totals_transactions) and distinct visitors by geoNetwork_city. ORDER BY distinct_visitors DESC answers the visitor-ranking question; ordering by summed transactions would answer a different ranking question.

The course asks readers to ignore 'not available in this demo dataset'. The reusable file includes an explicitly filtered ranking example. Keep the unfiltered result available when checking how much data the exclusion removes.

The course then renames SUM(totals_transactions) as total_products_ordered and divides it by distinct visitors. Those labels are misleading: the expression does not use a product-quantity field or an order-count denominator. The organized example names it recorded_transactions_per_visitor, while still requiring verification that transaction values are not repeated across rows.

The original formula is:

```sql
SUM(totals_transactions) / COUNT(DISTINCT fullVisitorId)
```

The reusable version uses SAFE_DIVIDE to handle a zero denominator. This is a documented robustness adjustment, not a claim that a division error was observed.

WHERE filters input rows before aggregation. It cannot filter this SELECT alias or its aggregate result in the same query block. Use HAVING after GROUP BY, or filter the completed aggregation in an outer query. The SQL example retains the course threshold of greater than 20 under the more precise metric label.

## 4. Product categories and NULL

Grouping product name and category without an aggregate is valid SQL; it lists distinct combinations. It does not by itself answer how many products each category contains.

COUNT(product_name) counts non-null records, so repeated names inflate a count intended to represent distinct names. The course correction uses COUNT(DISTINCT hits_product_v2ProductName), grouped by category, with IS NOT NULL to exclude missing names.

This measures distinct product names, not necessarily distinct SKUs or products sold. It includes empty strings unless those are excluded separately. It does not establish top-selling categories because it does not measure sales quantity or revenue.

The course notes two unusual category labels:

- `(not set)`: may indicate missing category assignment.
- `${productitem.product.origCatName}`: an unresolved template expression. The course suggests tracking may have fired before rendering completed; that is a hypothesis to investigate, not a confirmed root cause.

The SQL file includes a diagnostic count of these category values and missing/empty product names. Do not silently remove them before assessing their extent.

## Validation record

| Check | Expected behavior | Actual evidence |
|---|---|---|
| Missing comma | One aliased column rather than two fields | Course example; no new run captured |
| Corrected visitor query | Distinct visitors under checkout-page filter | Expected output shape only; no count supplied |
| GROUP BY | Non-aggregated selected fields grouped | Covered in the course |
| HAVING | Filters city-level aggregate results | Corrected example supplied; no run captured |
| Category count | Distinct non-null names within each category | Corrected example supplied; no count supplied |
| Course participation | Retain a record of course taken | User confirmed taking the course and knowing most concepts |

## Problems and resolutions reviewed

| Course issue | Correction |
|---|---|
| Empty SELECT list | Specify columns |
| Misspelled project ID | Use data-to-insights |
| Legacy table brackets under GoogleSQL | Use a fully qualified backtick table path |
| Missing comma interpreted as alias | Separate selected columns with commas |
| Duplicate visitor counting | Use COUNT(DISTINCT) for unique visitors |
| Selected field missing from GROUP BY | Group the non-aggregated field |
| Aggregate alias filtered in WHERE | Use HAVING or an outer query |
| Repeated names counted as distinct products | Use COUNT(DISTINCT), with documented product identity |
| Formula mislabeled as products per order | Describe the actual numerator and denominator |

These are intentionally supplied course exercises, not personal production incidents. The earlier personally observed dialect failures remain in `SQL-DIALECT-EXPERIMENT.md`.

## Files and related study

- Original transcript: `BigQuery - Troubleshooting Common SQL Errors.txt`
- Corrected examples: [troubleshooting-common-errors.sql](troubleshooting-common-errors.sql)
- Related analysis: [Ecommerce study](ECOMMERCE-STUDY.md)
- Related personal experiment: [SQL dialect experiment](SQL-DIALECT-EXPERIMENT.md)
