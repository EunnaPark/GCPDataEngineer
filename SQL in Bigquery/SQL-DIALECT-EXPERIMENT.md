# BigQuery SQL Dialect Experiment

Date: 2026-10-08

## Goal
Understand what happens when `bq query --use_legacy_sql=false` is changed to `true` without changing the SQL text.

## Scenario
The lecture queries the public Shakespeare table. I tried selecting Legacy SQL to see whether the same query would work.

## Service and syntax choice
BigQuery supports GoogleSQL and Legacy SQL. The command flag selects the parser; it does not translate SQL.

| Flag | SQL dialect | Table reference used in this experiment |
|---|---|---|
| `--use_legacy_sql=false` | GoogleSQL | `` `bigquery-public-data.samples.shakespeare` `` |
| `--use_legacy_sql=true` | Legacy SQL | `[bigquery-public-data:samples.shakespeare]` |

Use GoogleSQL for new study queries. Legacy SQL is useful here for understanding an older syntax and reproducing the experiment.

## Implementation
Run these commands in Cloud Shell (Bash). Both query the same public table. Sorting makes the results easier to compare.

### GoogleSQL version

```bash
bq query --use_legacy_sql=false \
'SELECT
   word,
   SUM(word_count) AS count
 FROM `bigquery-public-data.samples.shakespeare`
 WHERE word LIKE "%raisin%"
 GROUP BY word
 ORDER BY word'
```

### Legacy SQL version

```bash
bq query --use_legacy_sql=true \
'SELECT
   word,
   SUM(word_count) AS count
 FROM [bigquery-public-data:samples.shakespeare]
 WHERE word LIKE "%raisin%"
 GROUP BY word
 ORDER BY word'
```

## Validation

| Check | Expected result | Actual result |
|---|---|---|
| Original query with flag changed to `true` | Test whether the existing syntax is accepted by Legacy SQL | Failed: invalid project ID containing backticks |
| Corrected GoogleSQL command above | Matching words and their summed counts | Not yet confirmed for this documented command |
| Corrected Legacy SQL command above | Same words and counts as the GoogleSQL version | Not yet tested/confirmed |

## Problem and resolution

### Observed failure

The supplied transcript contains this table reference with Legacy SQL enabled:

```sql
FROM `bigquery-public-data`.samples.shakespeare
```

BigQuery returned:

```text
Invalid project ID '`bigquery-public-data`'.
```

The error includes the backticks in the project ID. The Legacy SQL parser did not interpret the GoogleSQL identifier quoting as intended. This error does not mean the public project ID itself is invalid.

**Resolution to test:** either retain `--use_legacy_sql=false` and use the GoogleSQL command above, or select `true` and replace the table reference with `[bigquery-public-data:samples.shakespeare]`.

### Follow-up attempt in the notes

```sql
FROM 'qwiklabs-gcp-03-e5b26ad52b8b'.'bigquery-public-data'.samples.shakespeare
```

This does not fix the table reference. The source table belongs to project `bigquery-public-data`, dataset `samples`, table `shakespeare`. The lab project is the project used to run the job; it is not an additional part of the source table name.

The inner single quotes also terminate and restart the outer Bash single-quoted query, so the shell does not pass those quote characters as written. Use the complete commands above instead.

No output was supplied for this follow-up attempt, so its actual result is not recorded as another confirmed failure.

## Study takeaway
Changing a SQL dialect flag can require changing query syntax. When investigating a parser error, check both the selected dialect and the table identifier format before changing project configuration.

## References

- [BigQuery SQL dialects](https://docs.cloud.google.com/bigquery/docs/introduction-sql)
- [Migrating from Legacy SQL to GoogleSQL](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/migrating-from-legacy-sql)

Original lecture notes and experiment transcript are preserved in `BigQuery - Command Line.txt`. This document records the observed error and a proposed correction; it does not claim the corrected commands have been executed.
