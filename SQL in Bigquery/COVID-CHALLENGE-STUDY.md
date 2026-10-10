# COVID-19 BigQuery Challenge — Answers and Study Notes

Date recorded: 2026-10-09
Status: learner-submitted answers; no completion score, grader acceptance, or numerical query results were supplied.

Source lab: [Google Skills lab](https://www.skills.google/paths/1336/course_templates/623/labs/629091).

## Goal and scenario

Practice aggregation, filtering, window functions, ranking, and compound growth calculations using the public COVID-19 dataset in BigQuery. The learner supplied ten SQL answers during the exercise. This record places each answer immediately below its task summary and keeps review notes separate.

The authenticated lab instructions were not accessible. The headings below summarize the supplied answers; they are not quoted official questions. Replace them with the exact question wording when available. The SQL file preserves submitted logic, with formatting and quote-style normalization; Q2 uses the output alias count_of_states supplied in the conversation.

## Service and implementation

BigQuery and the public table are specified by the exercise; no independent architecture comparison was performed. Run each statement separately using GoogleSQL. For the command line, explicitly use --use_legacy_sql=false. All examples are read-only. No cloud queries were executed while preparing these files.

Reusable answers: [covid-challenge-answers.sql](covid-challenge-answers.sql).

## Data interpretation to revisit

The source contains multiple geographic levels. A country or state name can occur on both aggregate and subordinate-location records. Summing these records together can count the same people more than once. Grader behavior and epidemiologically valid aggregation are separate questions. Preserve the submitted answers as a course record and validate geographic grain before presenting the output as independent findings.

Reference: [Google dataset documentation](https://github.com/GoogleCloudPlatform/covid-19-open-data).

## Q1 — Worldwide confirmed cases on May 10

Question wording: not supplied; summary inferred from the answer.

### My answer

```sql
SELECT SUM(cumulative_confirmed) AS total_cases_worldwide
FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE date = '2020-05-10';
```

### Study note

The submitted query sums every geographic record on the selected date. Country and subcountry records may overlap; do not treat this as an independently validated world total.

## Q2 — US states above 150 deaths

Question wording: not supplied; summary inferred from the answer.

### My answer

```sql
WITH total_death_count AS (
  SELECT SUM(cumulative_deceased) AS total_death, subregion1_name AS states
  FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE date = '2020-05-10' AND country_name = 'United States of America'
    AND subregion1_name IS NOT NULL
  GROUP BY subregion1_name
)
SELECT COUNT(*) AS count_of_states FROM total_death_count WHERE total_death > 150;
```

### Study note

The original COUNT(DISTINCT state) query was rejected by the grader. The learner revised it to aggregate deaths by state before applying the threshold. This captures the learning point about filtering aggregate totals. The revised answer's grader acceptance was not reported. Repeated state names can also reflect overlapping geographic levels, so summing all such rows may double-count.

## Q3 — US states above 1,500 confirmed cases

Question wording: not supplied; summary inferred from the answer.

### My answer

```sql
WITH total_confirmed AS (
  SELECT SUM(cumulative_confirmed) AS total_confirmed_cases, subregion1_name AS states
  FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE date = '2020-05-10' AND country_name = 'United States of America'
    AND subregion1_name IS NOT NULL
  GROUP BY subregion1_name
)
SELECT states, total_confirmed_cases FROM total_confirmed
WHERE total_confirmed_cases > 1500 ORDER BY total_confirmed_cases DESC;
```

### Study note

Aggregates by state, filters above 1,500, and sorts descending. Geographic-level overlap remains a separate data-quality question.

## Q4 — Italy case-fatality calculation across April

Question wording: not supplied; summary inferred from the answer.

### My answer

```sql
WITH total AS (
  SELECT SUM(cumulative_confirmed) AS total_confirmed,
    SUM(cumulative_deceased) AS total_death
  FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE date BETWEEN '2020-04-01' AND '2020-04-30' AND country_name = 'Italy'
)
SELECT total_confirmed AS total_confirmed_cases, total_death AS total_deaths,
  (total_death / total_confirmed) * 100 AS case_fatality_ratio FROM total;
```

### Study note

Summing cumulative values across April repeatedly includes earlier cases and deaths. The sums are neither April incident totals nor April 30 endpoint totals. Preserve the course answer, but label its ratio accurately when interpreting it.

## Q5 — First date Italy exceeded 8,000 deaths

Question wording: not supplied; summary inferred from the answer.

### My answer

```sql
WITH total AS (
  SELECT SUM(cumulative_deceased) AS total_death, date
  FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE country_name = 'Italy' GROUP BY date
)
SELECT date FROM total WHERE total_death > 8000 ORDER BY date LIMIT 1;
```

### Study note

Crossing 8,000 was interpreted as strictly greater than 8,000. ORDER BY date with LIMIT 1 selects the earliest qualifying date under this aggregation.

## Q6 — India dates with no increase in confirmed cases

Question wording: not supplied; summary inferred from the answer.

### My answer

```sql
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
```

### Study note

LAG compares each row to the previous available date. The first date in the filtered input has a NULL predecessor and is excluded. Missing dates would make the previous row different from the previous calendar day.

## Q7 — US dates with increases above 10 percent

Question wording: not supplied; summary inferred from the answer.

### My answer

```sql
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
```

### Study note

The first date has no prior row because the input begins March 22. No final ORDER BY guarantees output order. Division by a zero predecessor is an additional robustness concern; it was not an observed failure.

## Q8 — Top ten recovery-rate country groups

Question wording: not supplied; summary inferred from the answer.

### My answer

```sql
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
```

### Study note

The filter keeps country groups above 50,000 summed cases. Missing recovery data is not zero recovery, and geographic overlap can distort numerator and denominator.

## Q9 — France cumulative daily growth rate

Question wording: not supplied; summary inferred from the answer.

### My answer

```sql
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
```

### Study note

The learner asked to retain this answer for study. It uses April 10, although an earlier discussion used May 10. January 24 to April 10 is 77 elapsed days; to May 10 it is 107. LIMIT 1 in summary lacks ORDER BY and may select the row with NULL LEAD values. Keep the original answer intact; the study example below explains a deterministic alternative.

## Q10 — US daily cumulative cases and deaths

Question wording: not supplied; summary inferred from the answer.

### My answer

```sql
WITH total AS (
  SELECT SUM(cumulative_deceased) AS total_death,
    SUM(cumulative_confirmed) AS total_confirmed, date
  FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE country_name = 'United States of America'
    AND date BETWEEN '2020-03-15' AND '2020-04-30' GROUP BY date
)
SELECT date, total_death, total_confirmed FROM total ORDER BY date;
```

### Study note

Returns chronological daily summed cumulative counts for March 15 through April 30. These are not daily new cases/deaths. Geographic overlap still needs validation before charting.

## CDGR study reference

CDGR expresses an equivalent constant compounded daily growth rate between two endpoint counts. It does not require summing the intervening daily records.

Formula: (last_day_cases / first_day_cases) raised to (1 / elapsed_days), minus 1. Multiply by 100 only when a percentage is requested. The starting count and elapsed days must be positive for the usual interpretation. In BigQuery use POW or POWER; ^ is not exponentiation.

The following is a proposed study revision, not a replacement for the learner's Q9 answer and not a verified grader submission. It selects country-level records to avoid adding subordinate regions, pivots the two endpoints explicitly, and handles invalid inputs. Confirm the dataset schema and task dates before running.

```sql
WITH endpoints AS (
  SELECT
    SUM(IF(date = '2020-01-24', cumulative_confirmed, NULL)) AS first_day_cases,
    SUM(IF(date = '2020-04-10', cumulative_confirmed, NULL)) AS last_day_cases
  FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE country_name = 'France'
    AND aggregation_level = 0
    AND date IN ('2020-01-24', '2020-04-10')
), summary AS (
  SELECT *, DATE_DIFF(DATE '2020-04-10', DATE '2020-01-24', DAY) AS days_diff
  FROM endpoints
)
SELECT *,
  CASE WHEN first_day_cases > 0 AND last_day_cases >= 0 AND days_diff > 0
    THEN POWER(SAFE_DIVIDE(last_day_cases, first_day_cases), 1.0 / days_diff) - 1
    ELSE NULL
  END AS cdgr
FROM summary;
```

## Validation and actual problems

| Check | Expected | Actual evidence |
|---|---|---|
| Q1–Q10 syntax and numerical outputs | Individually executed queries | SQL supplied; numerical outputs not recorded |
| Initial Q2 attempt | Grader accepts the requested answer | Learner reported rejection |
| Revised Q2 aggregate-before-filter | State groups filtered by summed total | Revised query supplied; grader outcome not reported |
| Q9 endpoint dates and row selection | Correct dates and deterministic endpoint comparison | Retained for study; date discrepancy and LIMIT issue noted |
| Geographic grain | No overlap in population totals | Not independently validated |
| Full challenge completion | Verified lab result | Not reported |

## Learning reflection and future use

The strongest recorded learning points are aggregating before filtering, using LAG and LEAD, interpreting strict thresholds, and understanding the exponent in CDGR. Retain this as course practice. For portfolio use, add the official question wording, actual outputs, grader outcomes, geographic-grain validation, and interpretation of cumulative versus incident counts. Do not claim that a grader accepted answers merely because they were saved or repeated in chat.
