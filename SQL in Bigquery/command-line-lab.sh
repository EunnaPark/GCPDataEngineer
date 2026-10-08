#!/usr/bin/env bash
# Run from Cloud Shell. Modes perform only the explicitly selected operation.
set -euo pipefail
: "${PROJECT_ID:?Set PROJECT_ID to your actual Google Cloud project}"
: "${BQ_LOCATION:?Set BQ_LOCATION to the custom dataset location}"
case "${1:-}" in
  inspect)
    bq show bigquery-public-data:samples.shakespeare
    bq help query
    bq --project_id="$PROJECT_ID" --location=US query --use_legacy_sql=false \
      'SELECT word, SUM(word_count) AS count FROM `bigquery-public-data.samples.shakespeare` WHERE word LIKE "%raisin%" GROUP BY word ORDER BY word'
    bq --project_id="$PROJECT_ID" --location=US query --use_legacy_sql=false \
      'SELECT word FROM `bigquery-public-data.samples.shakespeare` WHERE word = "huzzah"'
    ;;
  create)
    bq --project_id="$PROJECT_ID" ls
    bq --project_id="$PROJECT_ID" --location="$BQ_LOCATION" mk --dataset "$PROJECT_ID:babynames"
    ;;
  load)
    test -f yob2010.txt || { echo 'Missing yob2010.txt: download and extract the SSA archive first.' >&2; exit 1; }
    if bq --project_id="$PROJECT_ID" show "$PROJECT_ID:babynames.names2010" >/dev/null 2>&1; then
      echo 'Target table already exists; inspect it before repeating a load.' >&2
      exit 1
    fi
    bq --project_id="$PROJECT_ID" --location="$BQ_LOCATION" load --source_format=CSV \
      "$PROJECT_ID:babynames.names2010" yob2010.txt name:STRING,gender:STRING,count:INTEGER
    bq --project_id="$PROJECT_ID" show "$PROJECT_ID:babynames.names2010"
    ;;
  query)
    bq --project_id="$PROJECT_ID" --location="$BQ_LOCATION" query --use_legacy_sql=false \
      "SELECT name, count FROM babynames.names2010 WHERE gender = 'F' ORDER BY count DESC, name LIMIT 5"
    ;;
  *) echo 'Usage: bash command-line-lab.sh inspect|create|load|query' >&2; exit 2 ;;
esac
