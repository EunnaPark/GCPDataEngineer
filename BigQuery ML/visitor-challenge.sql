-- Final course challenge: assumes the model and july_data already exist.
-- Replace YOUR_PROJECT. No predictions have been executed or verified here.
SELECT fullVisitorId,
  SUM(CAST(predicted_label AS INT64)) AS predicted_purchasing_sessions
FROM ML.PREDICT(
  MODEL `YOUR_PROJECT.bqml_lab.sample_model`,
  (SELECT os, is_mobile, country, pageviews, fullVisitorId
   FROM `YOUR_PROJECT.bqml_lab.july_data`)
)
GROUP BY fullVisitorId
ORDER BY predicted_purchasing_sessions DESC, fullVisitorId
LIMIT 10;
