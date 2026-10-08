-- GoogleSQL: run each example separately in the project containing babynames.
SELECT name, count FROM `babynames.names2010`
WHERE gender = 'F' ORDER BY count DESC, name LIMIT 5;

-- Lowest published counts, not suppressed names.
SELECT name, count FROM `babynames.names2010`
WHERE gender = 'M' ORDER BY count ASC, name LIMIT 5;

SELECT COUNT(*) AS rows_loaded,
  COUNTIF(name IS NULL OR TRIM(name) = '') AS missing_names,
  COUNTIF(gender IS NULL OR gender NOT IN ('F', 'M')) AS invalid_gender_rows,
  COUNTIF(count IS NULL OR count < 0) AS invalid_count_rows
FROM `babynames.names2010`;

-- Check duplicate annual name/gender aggregates.
SELECT name, gender, COUNT(*) AS row_count
FROM `babynames.names2010`
GROUP BY name, gender HAVING COUNT(*) > 1;

-- Prerequisite for following examples: names2025 exists and its provenance is verified.
-- Top ten overall: may include two rows for one name, or mostly one year.
SELECT name, count, '2010' AS year FROM `babynames.names2010` WHERE gender = 'F'
UNION ALL
SELECT name, count, '2025' AS year FROM `babynames.names2025` WHERE gender = 'F'
ORDER BY count DESC, year, name
LIMIT 10;

-- Ten per year: separate ranking within each year.
WITH annual_names AS (
  SELECT name, count, '2010' AS year FROM `babynames.names2010` WHERE gender = 'F'
  UNION ALL
  SELECT name, count, '2025' AS year FROM `babynames.names2025` WHERE gender = 'F'
)
SELECT name, count, year
FROM annual_names
QUALIFY ROW_NUMBER() OVER (PARTITION BY year ORDER BY count DESC, name) <= 10
ORDER BY year, count DESC, name;
