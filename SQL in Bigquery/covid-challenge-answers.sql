-- GoogleSQL. Learner answers preserved; run each task separately.
-- Grader acceptance and numerical outputs have not been confirmed.

-- Q1
SELECT SUM(cumulative_confirmed) AS total_cases_worldwide
FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE date = '2020-05-10';

-- Q2
WITH total_death_count AS (
  SELECT SUM(cumulative_deceased) AS total_death, subregion1_name AS states
  FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE date = '2020-05-10' AND country_name = 'United States of America'
    AND subregion1_name IS NOT NULL
  GROUP BY subregion1_name
)
SELECT COUNT(*) AS count_of_states FROM total_death_count WHERE total_death > 150;

-- Q3
WITH total_confirmed AS (
  SELECT SUM(cumulative_confirmed) AS total_confirmed_cases, subregion1_name AS states
  FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE date = '2020-05-10' AND country_name = 'United States of America'
    AND subregion1_name IS NOT NULL
  GROUP BY subregion1_name
)
SELECT states, total_confirmed_cases FROM total_confirmed
WHERE total_confirmed_cases > 1500 ORDER BY total_confirmed_cases DESC;

-- Q4
WITH total AS (
  SELECT SUM(cumulative_confirmed) AS total_confirmed,
    SUM(cumulative_deceased) AS total_death
  FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE date BETWEEN '2020-04-01' AND '2020-04-30' AND country_name = 'Italy'
)
SELECT total_confirmed AS total_confirmed_cases, total_death AS total_deaths,
  (total_death / total_confirmed) * 100 AS case_fatality_ratio FROM total;

-- Q5
WITH total AS (
  SELECT SUM(cumulative_deceased) AS total_death, date
  FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE country_name = 'Italy' GROUP BY date
)
SELECT date FROM total WHERE total_death > 8000 ORDER BY date LIMIT 1;

-- Q6
WITH india_cases_by_date AS (
  SELECT date, SUM(cumulative_confirmed) AS cases
  FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE country_name = 'India' AND date BETWEEN '2020-02-24' AND '2020-03-12'
  GROUP BY date ORDER BY date ASC
), india_previous_day_comparison AS (
  SELECT date, cases, LAG(cases) OVER (ORDER BY date) AS previous_day,
    cases - LAG(cases) OVER (ORDER BY date) AS net_new_cases
  FROM india_cases_by_date
)
SELECT COUNT(date) FROM india_previous_day_comparison WHERE net_new_cases = 0;

-- Q7
WITH cases_by_date AS (
  SELECT date, SUM(cumulative_confirmed) AS cases
  FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE country_name = 'United States of America'
    AND date BETWEEN '2020-03-22' AND '2020-04-20'
  GROUP BY date ORDER BY date ASC
), previous_day_comparison AS (
  SELECT date, cases AS Confirmed_Cases_On_Day,
    LAG(cases) OVER (ORDER BY date) AS Confirmed_Cases_Previous_Day,
    cases - LAG(cases) OVER (ORDER BY date) AS net_new_cases FROM cases_by_date
), increase_percentage AS (
  SELECT date, Confirmed_Cases_On_Day, Confirmed_Cases_Previous_Day,
    (net_new_cases / Confirmed_Cases_Previous_Day) * 100 AS Percentage_Increase_In_Cases
  FROM previous_day_comparison
)
SELECT date, Confirmed_Cases_On_Day, Confirmed_Cases_Previous_Day,
  Percentage_Increase_In_Cases FROM increase_percentage
WHERE Percentage_Increase_In_Cases > 10;

-- Q8
WITH total_recover_count AS (
  SELECT SUM(cumulative_confirmed) AS confirmed_cases,
    SUM(cumulative_recovered) AS recovered_cases, country_name AS country
  FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE date = '2020-05-10' AND country_name IS NOT NULL
  GROUP BY country_name HAVING confirmed_cases > 50000
)
SELECT country, recovered_cases, confirmed_cases,
  (recovered_cases / confirmed_cases) * 100 AS recovery_rate FROM total_recover_count
ORDER BY recovery_rate DESC LIMIT 10;

-- Q9
WITH france_cases AS (
  SELECT date, SUM(cumulative_confirmed) AS total_cases
  FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE country_name = 'France' AND date IN ('2020-01-24', '2020-04-10') GROUP BY date
), summary AS (
  SELECT total_cases AS first_day_cases,
    LEAD(total_cases) OVER (ORDER BY date) AS last_day_cases,
    DATE_DIFF(LEAD(date) OVER (ORDER BY date), date, DAY) AS days_diff
  FROM france_cases LIMIT 1
)
SELECT first_day_cases, last_day_cases, days_diff,
  POWER(last_day_cases / first_day_cases, 1 / days_diff) - 1 AS cdgr FROM summary;

-- Q10
WITH total AS (
  SELECT SUM(cumulative_deceased) AS total_death,
    SUM(cumulative_confirmed) AS total_confirmed, date
  FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE country_name = 'United States of America'
    AND date BETWEEN '2020-03-15' AND '2020-04-30' GROUP BY date
)
SELECT date, total_death, total_confirmed FROM total ORDER BY date;
