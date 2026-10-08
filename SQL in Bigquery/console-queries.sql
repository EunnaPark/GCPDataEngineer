-- GoogleSQL. Run statements individually in the intended project.
SELECT weight_pounds, state, year, gestation_weeks
FROM `bigquery-public-data.samples.natality`
ORDER BY weight_pounds DESC
LIMIT 10;

-- Prerequisite: load yob2014.txt into babynames.names_2014.
SELECT name, count
FROM `babynames.names_2014`
WHERE gender = 'M'
ORDER BY count DESC, name
LIMIT 5;

SELECT COUNT(*) AS total_rows,
  COUNTIF(name IS NULL OR TRIM(name) = '') AS missing_names,
  COUNTIF(gender IS NULL OR gender NOT IN ('F', 'M')) AS invalid_gender_rows,
  COUNTIF(count IS NULL OR count < 0) AS invalid_count_rows
FROM `babynames.names_2014`;
