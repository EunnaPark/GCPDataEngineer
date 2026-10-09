# BigQuery SQL Study Collection

Study notes organized on 2026-10-08. This collection combines course exercises with my own SQL experiments. Course sample outputs are not evidence that I executed a query successfully.

## Study map

| Topic | Detailed guide | Reusable code |
|---|---|---|
| Console: public queries and loading CSV from Cloud Storage | [Console study guide](CONSOLE-STUDY.md) | [Console queries](console-queries.sql) |
| Command line: inspect, load, query, and compare years | [Command-line study guide](COMMAND-LINE-STUDY.md) | [Cloud Shell commands](command-line-lab.sh), [baby-name queries](babynames-queries.sql) |
| SQL dialect errors and corrections | [SQL dialect experiment](SQL-DIALECT-EXPERIMENT.md) | Examples in the experiment and command-line guide |
| Ecommerce: duplicate checks and trustworthy product metrics | [Ecommerce study guide](ECOMMERCE-STUDY.md) | [Ecommerce queries](ecommerce-queries.sql) |
| Earlier SQL and Cloud SQL exercises | [Original SQL lecture](SQL%20in%20Bigquery.txt) | [Resolved Cloud SQL issue](TROUBLESHOOTING.md) |

## How to use this collection

Start with the Console guide to understand projects, datasets, tables, schema, and previews. Repeat the loading and querying steps with the command-line guide. Review the dialect experiment before trying UNION ALL. Then use the ecommerce guide to practice defining data quality and business metrics rather than only writing syntactically correct SQL.

SQL files contain multiple independent examples; run one statement at a time in the BigQuery editor. The Bash file provides separate modes and requires an explicit project ID. Read each mode before running it. No cloud jobs were run while organizing these files.

## Evidence and portfolio status

The supplied transcript confirms the Legacy SQL project-identifier error and the UNION parsing error. Corrected query outputs have not been supplied. The ecommerce material is a guided course, with an independent investigation proposed in its guide. It is not yet a completed business analysis or a production pipeline.

Original new `.txt` files remain alongside these guides for complete context, including course instructions, sample outputs, and captured help text. CSV files are the previously supplied London bikeshare exports; they are separate from the baby-name and ecommerce exercises.

## Additional course record — 2026-10-09

[BigQuery: Troubleshooting Common SQL Errors](TROUBLESHOOTING-COMMON-SQL-ERRORS.md) reviews familiar SQL syntax and aggregation concepts. Retained as a course taken, with [corrected SQL examples](troubleshooting-common-errors.sql); it is not presented as a new independent portfolio project.
