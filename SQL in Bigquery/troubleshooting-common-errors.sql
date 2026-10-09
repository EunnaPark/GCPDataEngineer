-- GoogleSQL. Corrected course examples; run separately.
-- No source tables are changed. Actual result counts have not been recorded.

-- 1. Preview two columns; the comma prevents accidental aliasing.
SELECT fullVisitorId, hits_page_pageTitle
FROM `data-to-insights.ecommerce.rev_transactions`
LIMIT 1000;

-- 2. Distinct visitors within each page-title group.
SELECT hits_page_pageTitle, COUNT(DISTINCT fullVisitorId) AS visitor_count
FROM `data-to-insights.ecommerce.rev_transactions`
GROUP BY hits_page_pageTitle
ORDER BY visitor_count DESC, hits_page_pageTitle;

-- 3. Course checkout-page proxy: one-row total, not an order count.
SELECT COUNT(DISTINCT fullVisitorId) AS checkout_page_visitors
FROM `data-to-insights.ecommerce.rev_transactions`
WHERE hits_page_pageTitle = 'Checkout Confirmation';

-- 4. Course city aggregates. Verify row grain before interpreting transaction sums.
SELECT geoNetwork_city,
  SUM(totals_transactions) AS recorded_transactions,
  COUNT(DISTINCT fullVisitorId) AS distinct_visitors
FROM `data-to-insights.ecommerce.rev_transactions`
GROUP BY geoNetwork_city
ORDER BY distinct_visitors DESC, geoNetwork_city;

-- 5. Explicit course exclusion; NULL cities also do not pass this predicate.
SELECT geoNetwork_city,
  SUM(totals_transactions) AS recorded_transactions,
  COUNT(DISTINCT fullVisitorId) AS distinct_visitors
FROM `data-to-insights.ecommerce.rev_transactions`
WHERE geoNetwork_city != 'not available in this demo dataset'
GROUP BY geoNetwork_city
ORDER BY distinct_visitors DESC, geoNetwork_city;

-- 6. Course ratio with precise naming and safe division.
-- It does NOT calculate products per order.
SELECT geoNetwork_city,
  SUM(totals_transactions) AS recorded_transactions,
  COUNT(DISTINCT fullVisitorId) AS distinct_visitors,
  SAFE_DIVIDE(SUM(totals_transactions), COUNT(DISTINCT fullVisitorId))
    AS recorded_transactions_per_visitor
FROM `data-to-insights.ecommerce.rev_transactions`
GROUP BY geoNetwork_city
HAVING recorded_transactions_per_visitor > 20
ORDER BY recorded_transactions_per_visitor DESC, geoNetwork_city;

-- 7. Distinct name/category combinations are valid without an aggregate.
SELECT DISTINCT hits_product_v2ProductName, hits_product_v2ProductCategory
FROM `data-to-insights.ecommerce.rev_transactions`;

-- 8. Distinct non-null product names by category, not sales volume or SKU count.
SELECT hits_product_v2ProductCategory,
  COUNT(DISTINCT hits_product_v2ProductName) AS distinct_product_names
FROM `data-to-insights.ecommerce.rev_transactions`
WHERE hits_product_v2ProductName IS NOT NULL
GROUP BY hits_product_v2ProductCategory
ORDER BY distinct_product_names DESC, hits_product_v2ProductCategory
LIMIT 5;

-- 9. Diagnose missing names and placeholder categories before excluding them.
SELECT hits_product_v2ProductCategory, COUNT(*) AS records,
  COUNTIF(hits_product_v2ProductName IS NULL) AS null_name_records,
  COUNTIF(TRIM(hits_product_v2ProductName) = '') AS empty_name_records
FROM `data-to-insights.ecommerce.rev_transactions`
WHERE hits_product_v2ProductCategory IS NULL
   OR hits_product_v2ProductCategory IN ('(not set)', '${productitem.product.origCatName}')
GROUP BY hits_product_v2ProductCategory
ORDER BY records DESC;
