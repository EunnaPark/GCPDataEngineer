# BigQuery Through the Command Line

Date organized: 2026-10-08
Goal: inspect a public table, create and load a custom table, run analytical SQL, and investigate SQL dialect behavior.

## Scenario and choice

The Console exercise introduces resources visually. This exercise repeats an analytical workflow with `bq` in Cloud Shell so that commands can be saved and repeated. BigQuery is the analytical engine; Cloud Shell is the command environment. GoogleSQL is selected explicitly to make the examples independent of a user's default dialect configuration.

A script is useful for repeatability, while the Console remains useful for previews and job inspection. A client library is another automation option, but is unnecessary for this short exercise. These are design observations; no client-library implementation was performed.

## Resources and prerequisites

- An active lab or personal project with permission to run jobs and create datasets/tables.
- Cloud Shell with `bq`, `curl`, and `unzip` available.
- Read access to the public Shakespeare table.
- A dataset location chosen before creation.
- SSA baby-name files available locally after downloading and extracting the archive.

`command-line-lab.sh` has inspect, create, load, and query modes. It does not delete resources. Read the script, set `PROJECT_ID` and `BQ_LOCATION`, then run the relevant mode. It uses the current directory for `yob2010.txt`; download and extraction are separate manual steps below.

```bash
export PROJECT_ID="$(gcloud config get-value project)"
# Set BQ_LOCATION to the location selected for your lab dataset.
export BQ_LOCATION=US
bash command-line-lab.sh inspect
bash command-line-lab.sh create
curl -fL https://www.ssa.gov/OACT/babynames/names.zip -o names.zip
unzip names.zip
bash command-line-lab.sh load
bash command-line-lab.sh query
```

The public-table query uses US separately. The custom dataset modes use BQ_LOCATION. The load mode refuses to load when the target table exists, preventing an accidental repeated append. Inspect the existing table before deciding whether to skip loading or use a new table name.

## 1. Inspect and get help

`bq show bigquery-public-data:samples.shakespeare` displays schema and metadata. In this command syntax, a colon separates project from dataset. GoogleSQL table paths use a fully qualified backtick identifier instead.

`bq help query` describes query flags; `bq help` lists commands. The full help output is retained in the original notes instead of repeated throughout this guide.

The course's metadata example lists 164,656 Shakespeare rows. Treat this as a supplied snapshot, not a new measurement.

## 2. Search Shakespeare

The inspect mode runs the course substring search using `LIKE "%raisin%"`. This matches the sequence of letters inside a word, including words such as praising; it is not a search for an exact word. The original sample includes praising=8 and Praising=4, showing why case interpretation matters when analyzing those rows.

The same mode searches for the exact word huzzah. The course expects no matches; no independent execution is claimed here.

## 3. Create and load baby-name data

Create `babynames`, download the SSA archive, and inspect `yob2010.txt`. The explicit load schema is name, gender, count. These are annual aggregate rows. The course sample reports 34,073 rows in names2010; verify the current source rather than hard-coding that as an invariant.

The course explains that names with fewer than five occurrences are omitted. Consequently, sorting ascending shows the lowest published counts, not every rare name that existed. It cannot reveal suppressed records.

## 4. Query rankings

`babynames-queries.sql` contains top female names, lowest published male counts, data-quality checks, and year comparisons. Sorting by name as a secondary key makes tied results easier to reproduce.

The original sample's most frequent female name is Isabella with 22,913 occurrences. This is course-provided output; it has not been independently reproduced during this organization.

## 5. My experiments: SQL dialect and UNION ALL

### Changing false to true

The supplied transcript shows `--use_legacy_sql=true` with a GoogleSQL-style backtick table reference. The error includes backticks inside the alleged project ID. The flag chooses a parser, not a query translator. See the full [dialect experiment](SQL-DIALECT-EXPERIMENT.md) for both syntaxes.

### Omitting the dialect flag

The transcript also records a baby-name UNION ALL query without an explicit dialect flag:

```text
Unrecognized token UNION.
Try using standard SQL
```

In this observed execution, the query was parsed as Legacy SQL. The correction is to select `--use_legacy_sql=false`. This does not imply that UNION ALL itself is invalid GoogleSQL.

### Adding year labels

The follow-up query labels the first source as 2010 and the second as 2025. This makes provenance visible. UNION ALL preserves the separate source rows; it does not add counts for the same name across years.

Without ORDER BY, LIMIT 10 does not guarantee the ten highest counts or representation from both years. The SQL file includes both an overall top ten and a separate ten-per-year example using ROW_NUMBER.

The 2025 examples require an existing `babynames.names2025` table containing the intended year. A table name and a string label do not prove its contents. Inspect how that table was loaded and confirm source provenance before interpreting a comparison. No result for the corrected query was supplied.

## Validation

| Check | Expected | Actual evidence |
|---|---|---|
| Public table inspection | Schema visible | Course sample supplied |
| CSV load | Typed rows in names2010 | Course sample supplied; not independently verified here |
| Legacy flag with backticks | Parser rejects incompatible identifier | Confirmed error in supplied transcript |
| UNION without dialect flag | Determine whether parser accepts query | Confirmed UNION token error |
| Corrected UNION | Two sources with explicit year labels | Query supplied; result pending |
| Ten per year | At most ten rows for each year | Proposed query; not executed |

## Troubleshooting

- Table not found: inspect exact table names; names2010 and names_2014 belong to different exercises.
- Invalid project with backticks: align identifier syntax and SQL dialect.
- UNION parser error: explicitly select GoogleSQL before rewriting the set operation.
- Existing table on load: do not rerun a load blindly; an append can double counts.
- Zero rows: distinguish a valid empty result from a failed job.

## Portfolio evidence to add

Save actual job results, load row counts, file provenance, and the before/after parser behavior. Explain why explicit dialect selection and deterministic ordering improved reproducibility. This records experimentation rather than claiming a production pipeline.

Source: `BigQuery - Command Line.txt`; original help text, sample output, and errors are preserved.
