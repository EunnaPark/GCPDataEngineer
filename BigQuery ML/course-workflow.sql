-- GoogleSQL. Replace YOUR_PROJECT throughout. Run each statement separately.
-- Course workflow organized for reference; no jobs were executed here.
-- Existing datasets must be in the same location as the public source.
CREATE SCHEMA IF NOT EXISTS `YOUR_PROJECT.bqml_lab` OPTIONS(location='US');

-- Corrected valid June endpoint. Course's LIMIT is retained; this is not random sampling.
CREATE VIEW `YOUR_PROJECT.bqml_lab.training_data` AS
SELECT IF(totals.transactions IS NULL, 0, 1) AS label,
  IFNULL(device.operatingSystem, '') AS os,
  device.isMobile AS is_mobile,
  IFNULL(geoNetwork.country, '') AS country,
  IFNULL(totals.pageviews, 0) AS pageviews
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170630'
LIMIT 10000;

-- Train. Repeated execution will fail if the model already exists; inspect it first.
CREATE MODEL `YOUR_PROJECT.bqml_lab.sample_model`
OPTIONS(model_type='LOGISTIC_REG', input_label_cols=['label']) AS
SELECT label, os, is_mobile, country, pageviews
FROM `YOUR_PROJECT.bqml_lab.training_data`;

-- Course-style evaluation: same source view, not an independent holdout.
SELECT * FROM ML.EVALUATE(
  MODEL `YOUR_PROJECT.bqml_lab.sample_model`,
  TABLE `YOUR_PROJECT.bqml_lab.training_data`
);

-- Course range retained: includes August 1 despite the view name.
CREATE VIEW `YOUR_PROJECT.bqml_lab.july_data` AS
SELECT IF(totals.transactions IS NULL, 0, 1) AS label,
  IFNULL(device.operatingSystem, '') AS os,
  device.isMobile AS is_mobile,
  IFNULL(geoNetwork.country, '') AS country,
  IFNULL(totals.pageviews, 0) AS pageviews,
  fullVisitorId
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20170701' AND '20170801';

-- Fix for the course's invalid TOTAL() example.
-- Binary session predictions, not an exact transaction-count forecast.
SELECT country,
  SUM(CAST(predicted_label AS INT64)) AS total_predicted_purchases
FROM ML.PREDICT(
  MODEL `YOUR_PROJECT.bqml_lab.sample_model`,
  (SELECT os, is_mobile, country, pageviews FROM `YOUR_PROJECT.bqml_lab.july_data`)
)
GROUP BY country
ORDER BY total_predicted_purchases DESC, country
LIMIT 10;
