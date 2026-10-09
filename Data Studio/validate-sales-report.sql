-- Proposed GoogleSQL validation template, not the course's source transformation.
-- Replace YOUR_PROJECT.YOUR_DATASET.sales_report with the actual table path.
-- Run statements separately. No checks were executed during organization.

-- Profile rows versus candidate product identifiers.
SELECT COUNT(*) AS source_rows,
  COUNT(DISTINCT productSKU) AS distinct_non_null_skus,
  COUNTIF(productSKU IS NULL OR TRIM(productSKU) = '') AS missing_sku_rows,
  COUNTIF(name IS NULL OR TRIM(name) = '') AS missing_name_rows
FROM `YOUR_PROJECT.YOUR_DATASET.sales_report`;

-- Repeated SKUs require grain investigation; they are not automatically errors.
SELECT productSKU, COUNT(*) AS source_rows
FROM `YOUR_PROJECT.YOUR_DATASET.sales_report`
GROUP BY productSKU HAVING COUNT(*) > 1
ORDER BY source_rows DESC, productSKU;

-- Names can represent multiple variants/SKUs.
SELECT name, COUNT(DISTINCT productSKU) AS distinct_skus
FROM `YOUR_PROJECT.YOUR_DATASET.sales_report`
GROUP BY name HAVING COUNT(DISTINCT productSKU) > 1
ORDER BY distinct_skus DESC, name;

-- Inspect missing or negative measures; decide validity from the source contract.
SELECT COUNTIF(stockLevel IS NULL) AS missing_stock_rows,
  COUNTIF(stockLevel < 0) AS negative_stock_rows,
  COUNTIF(total_ordered IS NULL) AS missing_ordered_rows,
  COUNTIF(total_ordered < 0) AS negative_ordered_rows,
  COUNTIF(restockingLeadTime IS NULL) AS missing_lead_time_rows,
  COUNTIF(restockingLeadTime < 0) AS negative_lead_time_rows,
  COUNTIF(ratio IS NULL) AS missing_ratio_rows
FROM `YOUR_PROJECT.YOUR_DATASET.sales_report`;

-- Inspect source records without imposing an unverified aggregation rule.
SELECT productSKU, name, stockLevel, total_ordered, ratio, restockingLeadTime
FROM `YOUR_PROJECT.YOUR_DATASET.sales_report`
ORDER BY total_ordered DESC, productSKU
LIMIT 20;
