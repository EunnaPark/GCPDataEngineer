# BigQuery Through the Console

Date organized: 2026-10-08
Goal: query a public table, create a dataset, load a CSV from Cloud Storage, and query the resulting table.

## Scenario

An analyst needs to explore a public dataset and then analyze a small external file. BigQuery stores the loaded data and executes SQL; Cloud Storage provides the source file. The Console makes schema, table metadata, previews, and query validation visible during learning.

## My assessment of the service choice

BigQuery fits this exercise because the work is SQL analysis and loading tabular data. The Console is useful for learning the resources and checking a load visually. The bq command line is an alternative for repeating the same steps; the command-line guide covers that approach. A separate Cloud SQL instance is unnecessary for this analytical exercise. These are documented design observations, not a claim that every alternative was implemented.

## 1. Query a public dataset

Open BigQuery in the Cloud Console and create a SQL query. Run the first statement in `console-queries.sql` against `bigquery-public-data.samples.natality`.

The query selects weight, state, year, and gestation weeks, sorts by descending weight, and returns ten rows. This explores an existing public table; it does not copy that table into my project. A project is still needed to run the query job.

Check the validator and estimated bytes before running. LIMIT controls the returned rows; it does not by itself guarantee that only ten rows are scanned. Record bytes processed and the job location from job details when executing.

## 2. Create the destination dataset

In Explorer, use the project actions to create dataset `babynames`. Record the selected location. The course leaves defaults in place; for reuse, choose and document the location deliberately and check compatibility with the source bucket before loading.

A dataset is the container for tables and views. Creating a dataset does not load any data.

## 3. Load the source CSV

Under `babynames`, choose Create table with these settings:

| Setting | Course value |
|---|---|
| Source | Google Cloud Storage |
| Source URI | `gs://spls/gsp072/baby-names/yob2014.txt` |
| File format | CSV |
| Destination table | `names_2014` |
| Explicit schema | `name:STRING, gender:STRING, count:INTEGER` |
| Header rows | 0: the source is data without a header |

The `.txt` suffix does not determine the file format: the rows are comma-separated. Use the explicit three-column schema. Wait for the load job to complete; table visibility alone does not demonstrate the expected rows were loaded.

## 4. Inspect and query

Use Schema to check types, Details for metadata, and Preview to inspect sample rows. Run the second query in `console-queries.sql` to find the five most frequent male names in 2014. The table is `names_2014`, whereas the separate command-line exercise uses `names2010`; these names are not interchangeable.

The final validation statement checks row count, missing names, unsupported gender values, and missing or negative counts. Review the result rather than assuming every check passes. A source row is an annual name/gender aggregate, not an individual baby.

## Validation

| Check | Expected | Actual evidence |
|---|---|---|
| Public query | Up to ten rows ordered by weight | Course describes output; no independent result captured here |
| Dataset | `babynames` visible in intended project/location | Not independently recorded |
| Load | Completed CSV load with three typed columns | Course text includes assessment messages; no separate job evidence recorded |
| Name ranking | Up to five male names sorted by count | No result supplied |
| Data quality | Inspect counts and investigate unexpected values | Pending execution |

## Problems and resolutions to use when needed

- Table not found: check project, dataset, exact table name, and job location. Do not change the table name to the dataset name.
- CSV parsing failure: check delimiter, schema order, header setting, and source encoding against the actual file.
- Query returns surprising rows: inspect the filter and sort before interpreting the result.
- Permission failure: distinguish permission to read the source from permission to create a table and run jobs.

These are troubleshooting checks, not failures observed in this exercise. The confirmed dialect failures are in `SQL-DIALECT-EXPERIMENT.md`.

## Portfolio evidence to add

Capture the load configuration, successful job details, quality-check results, and one short explanation of why explicit types were chosen. This exercise demonstrates a basic load-and-query workflow; it does not yet demonstrate automated ingestion.

Source: `BigQuery - Console.txt`. Complete course text is preserved there.
