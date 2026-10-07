#!/usr/bin/env bash
# Commands from the supplied lab; Dataflow/dashboard setup remains in README.md.
# Usage: bash run-lab.sh setup|artifacts|preview YOUR_PROJECT_ID YOUR_BUCKET
set -euo pipefail
MODE="${1:-}"
PROJECT_ID="${2:-}"
BUCKET="${3:-}"
REGION="${REGION:-us-central1}"
if [[ ! "$MODE" =~ ^(setup|artifacts|preview)$ || -z "$PROJECT_ID" || -z "$BUCKET" ]]; then
  echo 'Usage: bash run-lab.sh setup|artifacts|preview YOUR_PROJECT_ID YOUR_BUCKET' >&2
  exit 2
fi
BUCKET="${BUCKET#gs://}"
BUCKET="${BUCKET%/}"
case "$MODE" in
  setup)
    # Run once in a fresh lab; the bucket is provided by the training environment.
    bq --project_id="$PROJECT_ID" --location="$REGION" mk --dataset taxirides
    bq --project_id="$PROJECT_ID" --location="$REGION" mk \
      --time_partitioning_field=timestamp \
      --schema='ride_id:STRING,point_idx:INTEGER,latitude:FLOAT,longitude:FLOAT,timestamp:TIMESTAMP,meter_reading:FLOAT,meter_increment:FLOAT,ride_status:STRING,passenger_count:INTEGER' \
      --table taxirides.realtime
    # Enable the API without disabling an API potentially used by existing jobs.
    gcloud services enable dataflow.googleapis.com --project="$PROJECT_ID"
    ;;
  artifacts)
    for artifact in schema.json transform.js rt_taxidata.csv; do
      gcloud storage cp "gs://cloud-training/bdml/taxisrcdata/${artifact}" \
        "gs://${BUCKET}/tmp/${artifact}" --project="$PROJECT_ID"
    done
    printf 'Next: create the streaming Dataflow template job using README.md.\n'
    ;;
  preview)
    bq --project_id="$PROJECT_ID" --location="$REGION" query \
      --use_legacy_sql=false \
      "SELECT * FROM \`${PROJECT_ID}.taxirides.realtime\` LIMIT 10;"
    ;;
esac
