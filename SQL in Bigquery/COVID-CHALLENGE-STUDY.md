# COVID-19 BigQuery Challenge — Answers and Study Notes

Date recorded: 2026-10-09
Status: learner-submitted answers; no completion score, grader acceptance, or numerical query results were supplied.

Source lab: [Google Skills lab](https://www.skills.google/paths/1336/course_templates/623/labs/629091).

## Goal and scenario

Practice aggregation, filtering, window functions, ranking, and compound growth calculations using the public COVID-19 dataset in BigQuery. The learner supplied ten SQL answers during the exercise. This record places each answer immediately below its task summary and keeps review notes separate.

The learner subsequently supplied the lab instructions in [BigQuery - Challenge Lab.txt](BigQuery%20-%20Challenge%20Lab.txt). Each task below now includes its supplied question text above the learner answer. The instruction file uses placeholders for several lab parameters; the answer values are recorded as the learner's chosen values, not independently verified assignments. The SQL file preserves submitted logic, with formatting and quote-style normalization; Q2 uses the output alias count_of_states supplied in the conversation.

## Service and implementation

BigQuery and the public table are specified by the exercise; no independent architecture comparison was performed. Run each statement separately using GoogleSQL. For the command line, explicitly use --use_legacy_sql=false. All examples are read-only. No cloud queries were executed while preparing these files.

Reusable answers: [covid-challenge-answers.sql](covid-challenge-answers.sql).

## Data interpretation to revisit

The source contains multiple geographic levels. A country or state name can occur on both aggregate and subordinate-location records. Summing these records together can count the same people more than once. Grader behavior and epidemiologically valid aggregation are separate questions. Preserve the submitted answers as a course record and validate geographic grain before presenting the output as independent findings.

Reference: [Google dataset documentation](https://github.com/GoogleCloudPlatform/covid-19-open-data).

## Q1 — Worldwide confirmed cases on May 10

### Course question — Total confirmed cases

> Build a query that will answer "What was the total count of confirmed cases on Date?" The query needs to return a single row containing the sum of confirmed cases across all countries. The name of the column should be total_cases_worldwide.

### My answer

```sql
SELECT SUM(cumulative_confirmed) AS total_cases_worldwide
FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE date = '2020-05-10';
```

### Study note

The submitted query sums every geographic record on the selected date. Country and subcountry records may overlap; do not treat this as an independently validated world total.

## Q2 — US states above 150 deaths

### Course question — Worst affected areas

> Build a query for answering "How many states in the US had more than Death Count deaths on Date?" The query needs to list the output in the field count_of_states.
> Note: Don't include NULL values.

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

### Course question — Identify hotspots

> Build a query that will answer "List all the states in the United States of America that had more than Confirmed Cases confirmed cases on Date?" The query needs to return the State Name and the corresponding confirmed cases arranged in descending order. Name of the fields to return state and total_confirmed_cases.

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

Aggregates by state, filters above 1,500, and sorts descending. The supplied question requires output fields state and total_confirmed_cases; this original answer uses states instead of state. To match the output contract, change both occurrences of the output alias states to state. Geographic-level overlap remains a separate data-quality question.

## Q4 — Italy case-fatality calculation across April

### Course question — Fatality ratio

> Build a query that will answer "What was the case-fatality ratio in Italy for the month of Month 2020?" Case-fatality ratio here is defined as (total deaths / total confirmed cases) * 100.
> Write a query to return the ratio for the month of Month 2020 and contain the following fields in the output: total_confirmed_cases, total_deaths, case_fatality_ratio.

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

### Course question — Identify a specific day

> Build a query that will answer: "On what day did the total number of deaths cross Death count in Italy in Italy?" The query should return the date in the format yyyy-mm-dd.

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

### Course question — Find days with zero net new cases

> The following query is written to identify the number of days in India between Start date in India and Close date in India when there were zero increases in the number of confirmed cases. However it is not executing properly.
>
> You need to update the query to complete it and obtain the result:

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

### Course question — Doubling rate

> Using the previous query as a template, write a query to find out the dates on which the confirmed cases increased by more than Limit Value% compared to the previous day (indicating doubling rate of ~ 7 days) in the US between the dates March 22, 2020 and April 20, 2020. The query needs to return the list of dates, the confirmed cases on that day, the confirmed cases the previous day, and the percentage increase in cases between the days.
> Use the following names for the returned fields: Date, Confirmed_Cases_On_Day, Confirmed_Cases_Previous_Day and Percentage_Increase_In_Cases.

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

### Course question — Recovery rate

> Build a query to list the recovery rates of countries arranged in descending order (limit to Limit Value) on the date May 10, 2020.
> Restrict the query to only those countries having more than 50K confirmed cases.
> The query needs to return the following fields: country, recovered_cases, confirmed_cases, recovery_rate.

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

### Course question — CDGR - Cumulative daily growth rate

> The following query is trying to calculate the CDGR on Date(Cumulative Daily Growth Rate) for France since the day the first case was reported.The first case was reported on Jan 24, 2020.
>
> The CDGR is calculated as:
>
> ((last_day_cases/first_day_cases)^1/days_diff)-1)
>
> Where :
>
> last_day_cases is the number of confirmed cases on May 10, 2020
>
> first_day_cases is the number of confirmed cases on Jan 24, 2020
>
> days_diff is the number of days between Jan 24 - May 10, 2020
>
> The query isn’t executing properly. Can you fix the error to make the query execute successfully?

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

The learner asked to retain this answer for study. It uses April 10, although an earlier discussion used May 10. January 24 to April 10 is 77 elapsed days; to May 10 it is 107. The newly supplied Q9 instructions explicitly define May 10 as the endpoint, so the learner's April 10 answer does not match that definition. LIMIT 1 in summary lacks ORDER BY and may select the row with NULL LEAD values. Keep the original answer intact; the study example below explains a deterministic alternative.

## Q10 — US daily cumulative cases and deaths

### Course question — Create a Data Studio report

> Create a Data Studio report that plots the following for the United States:
>
> Use the BigQuery connector, authorize access, select Custom Query under your project Project_ID, enter the query, then click Add and Add to report.
>
> Number of Confirmed Cases
> Number of Deaths
> Date range : Date Range

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

The instructions require creating a Data Studio report using the BigQuery connector and a Custom Query under the lab project. This answer supplies the query only; no report link, screenshot, or completion evidence for Q10 was supplied. It returns chronological daily summed cumulative counts for March 15 through April 30. These are not daily new cases/deaths. Geographic overlap still needs validation before charting.

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

The strongest recorded learning points are aggregating before filtering, using LAG and LEAD, interpreting strict thresholds, and understanding the exponent in CDGR. Retain this as course practice. The question text is now linked. For portfolio use, add actual outputs, grader outcomes, geographic-grain validation, and interpretation of cumulative versus incident counts. Do not claim that a grader accepted answers merely because they were saved or repeated in chat.

## Instruction-to-answer reconciliation

| Task | Supplied instruction | Recorded answer / remaining action |
|---|---|---|
| Q1 | Output total_cases_worldwide; Date placeholder | Alias matches; learner used May 10 |
| Q2 | Output count_of_states; Date and Death Count placeholders | Alias matches; learner used May 10 and 150 |
| Q3 | Output state and total_confirmed_cases | Original uses states; rename output alias to state when submitting |
| Q4 | Italy ratio for Month 2020 | Learner used April; cumulative-value interpretation remains noted |
| Q5 | Earliest Italy date crossing Death count | Learner used strictly greater than 8,000 |
| Q6 | India between Start date and Close date placeholders | Learner used February 24 through March 12 |
| Q7 | US March 22 through April 20, Limit Value percent | Dates match; learner threshold is greater than 10 percent |
| Q8 | May 10, above 50K cases, Limit Value rows | Date and threshold match; learner limit is 10 |
| Q9 | End May 10; start January 24 | Original ends April 10. May 10 requires 107 elapsed days and deterministic endpoint selection |
| Q10 | Create a Data Studio report with a Custom Query | SQL supplied; report creation is not yet evidenced for this challenge |

The proposed CDGR study revision above intentionally retains April 10 for comparison with the original answer. To align it with the supplied instructions, replace every April 10 date in that revision with May 10; DATE_DIFF will then calculate 107. This does not claim a verified grader submission.

Full original instructions, including incomplete starter queries and their errors, are preserved in [BigQuery - Challenge Lab.txt](BigQuery%20-%20Challenge%20Lab.txt). Its malformed CDGR expression is course material to troubleshoot, not the corrected mathematical formula.
