-- GoogleSQL. Run each section separately; no source tables are modified.
-- Adapted from the supplied course. Results have not been independently verified.

-- 1. Profile records and missing identifiers before defining metrics.
SELECT COUNT(*) AS total_records,
  COUNT(DISTINCT fullVisitorId) AS unique_visitors,
  MIN(date) AS first_stored_date, MAX(date) AS last_stored_date,
  COUNTIF(fullVisitorId IS NULL) AS missing_visitor_records,
  COUNTIF(productSKU IS NULL OR TRIM(productSKU) = '') AS missing_sku_records
FROM `data-to-insights.ecommerce.all_sessions`;

-- 2. Raw duplicate groups. Field list retained from the course;
-- confirm it covers the current schema before calling this an all-column comparison.
SELECT COUNT(*) AS records_in_group, fullVisitorId, channelGrouping, time, country,
  city, totalTransactionRevenue, transactions, timeOnSite, pageviews,
  sessionQualityDim, date, visitId, type, productRefundAmount, productQuantity,
  productPrice, productRevenue, productSKU, v2ProductName, v2ProductCategory,
  productVariant, currencyCode, itemQuantity, itemRevenue, transactionRevenue,
  transactionId, pageTitle, searchKeyword, pagePathLevel1,
  eCommerceAction_type, eCommerceAction_step, eCommerceAction_option
FROM `data-to-insights.ecommerce.all_sessions_raw`
GROUP BY fullVisitorId, channelGrouping, time, country, city, totalTransactionRevenue,
  transactions, timeOnSite, pageviews, sessionQualityDim, date, visitId, type,
  productRefundAmount, productQuantity, productPrice, productRevenue, productSKU,
  v2ProductName, v2ProductCategory, productVariant, currencyCode, itemQuantity,
  itemRevenue, transactionRevenue, transactionId, pageTitle, searchKeyword,
  pagePathLevel1, eCommerceAction_type, eCommerceAction_step, eCommerceAction_option
HAVING COUNT(*) > 1;

-- 3. Distinguish duplicate groups, affected rows, and removable excess rows.
WITH duplicate_groups AS (
  SELECT COUNT(*) AS records_in_group
  FROM `data-to-insights.ecommerce.all_sessions_raw`
  GROUP BY fullVisitorId, channelGrouping, time, country, city, totalTransactionRevenue,
    transactions, timeOnSite, pageviews, sessionQualityDim, date, visitId, type,
    productRefundAmount, productQuantity, productPrice, productRevenue, productSKU,
    v2ProductName, v2ProductCategory, productVariant, currencyCode, itemQuantity,
    itemRevenue, transactionRevenue, transactionId, pageTitle, searchKeyword,
    pagePathLevel1, eCommerceAction_type, eCommerceAction_step, eCommerceAction_option
  HAVING COUNT(*) > 1
)
SELECT COUNT(*) AS duplicate_groups,
  COALESCE(SUM(records_in_group), 0) AS rows_in_duplicate_groups,
  COALESCE(SUM(records_in_group - 1), 0) AS excess_rows_if_retaining_one
FROM duplicate_groups;

-- 4. Course composite-key check on supplied cleaned table. Expected: zero groups.
SELECT fullVisitorId, visitId, date, time, v2ProductName, productSKU, type,
  eCommerceAction_type, eCommerceAction_step, eCommerceAction_option,
  transactionRevenue, transactionId, COUNT(*) AS row_count
FROM `data-to-insights.ecommerce.all_sessions`
GROUP BY fullVisitorId, visitId, date, time, v2ProductName, productSKU, type,
  eCommerceAction_type, eCommerceAction_step, eCommerceAction_option,
  transactionRevenue, transactionId
HAVING COUNT(*) > 1;

-- 5. Distinct visitors per channel are not necessarily additive across channels.
SELECT channelGrouping, COUNT(DISTINCT fullVisitorId) AS unique_visitors
FROM `data-to-insights.ecommerce.all_sessions`
GROUP BY channelGrouping ORDER BY channelGrouping DESC;

-- 6. Course reports 633 names; verify independently.
SELECT DISTINCT v2ProductName AS product_name
FROM `data-to-insights.ecommerce.all_sessions`
ORDER BY product_name;

-- 7. Course's PAGE-record proxy for views, with deterministic name tie-break.
SELECT v2ProductName AS product_name, COUNT(*) AS page_records
FROM `data-to-insights.ecommerce.all_sessions`
WHERE type = 'PAGE'
GROUP BY v2ProductName ORDER BY page_records DESC, product_name LIMIT 5;

-- 8. One visitor/name pair across the whole observed period (including NULL groups).
WITH unique_product_views_by_person AS (
  SELECT fullVisitorId, v2ProductName AS product_name
  FROM `data-to-insights.ecommerce.all_sessions`
  WHERE type = 'PAGE'
  GROUP BY fullVisitorId, v2ProductName
)
SELECT product_name, COUNT(*) AS visitor_product_pairs
FROM unique_product_views_by_person
GROUP BY product_name ORDER BY visitor_product_pairs DESC, product_name LIMIT 5;

-- 9. Course quantity metrics, renamed to avoid asserting records are orders.
-- SAFE_DIVIDE is a robustness change from the original course query.
SELECT v2ProductName AS product_name, COUNT(*) AS page_records,
  COUNT(productQuantity) AS quantity_records,
  SUM(productQuantity) AS total_recorded_quantity,
  SAFE_DIVIDE(SUM(productQuantity), COUNT(productQuantity)) AS avg_quantity_per_quantity_record
FROM `data-to-insights.ecommerce.all_sessions`
WHERE type = 'PAGE'
GROUP BY v2ProductName ORDER BY page_records DESC, product_name LIMIT 5;

-- 10. Investigate event/action representation before proposing purchase metrics.
SELECT type, eCommerceAction_type, COUNT(*) AS records,
  COUNTIF(transactionId IS NOT NULL AND TRIM(transactionId) != '') AS records_with_transaction_id,
  COUNT(productQuantity) AS quantity_records
FROM `data-to-insights.ecommerce.all_sessions`
GROUP BY type, eCommerceAction_type ORDER BY records DESC;

-- 11. Product names with multiple non-null SKUs.
SELECT v2ProductName AS product_name, COUNT(DISTINCT productSKU) AS sku_count
FROM `data-to-insights.ecommerce.all_sessions`
GROUP BY v2ProductName HAVING COUNT(DISTINCT productSKU) > 1
ORDER BY sku_count DESC, product_name;

-- 12. SKUs with multiple non-null names.
SELECT productSKU, COUNT(DISTINCT v2ProductName) AS name_count
FROM `data-to-insights.ecommerce.all_sessions`
GROUP BY productSKU HAVING COUNT(DISTINCT v2ProductName) > 1
ORDER BY name_count DESC, productSKU;
