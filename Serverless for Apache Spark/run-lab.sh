#!/usr/bin/env bash
# Commands organized from the supplied training lab. Run with Bash.
# Usage: bash run-lab.sh setup|run|verify YOUR_PROJECT_ID
set -euo pipefail

MODE="${1:-}"
GCP_PROJECT="${2:-${GCP_PROJECT:-}}"
if [[ ! "$MODE" =~ ^(setup|run|verify)$ || -z "$GCP_PROJECT" ]]; then
  echo 'Usage: bash run-lab.sh setup|run|verify YOUR_PROJECT_ID' >&2
  exit 2
fi
export GCP_PROJECT
export REGION="${REGION:-us-east1}"
STAGING_BUCKET="${STAGING_BUCKET:-$GCP_PROJECT}"
TEMP_BUCKET="${TEMP_BUCKET:-${GCP_PROJECT}-bqtemp}"
DATASET="${DATASET:-loadavro}"
TABLE="${TABLE:-campaigns}"
export GCS_STAGING_LOCATION="gs://${STAGING_BUCKET}"
export JARS="${JARS:-gs://cloud-training/dataengineering/lab_assets/idegc/spark-bigquery_2.12-20221021-2134.jar}"
ASSET_BASE='https://storage.googleapis.com/cloud-training/dataengineering/lab_assets/idegc'

case "$MODE" in
  setup)
    # Task 1: run in Cloud Shell, before connecting to lab-vm.
    gcloud compute networks subnets update default \
      --project="$GCP_PROJECT" --region="$REGION" \
      --enable-private-ip-google-access
    gsutil mb -p "$GCP_PROJECT" "gs://${STAGING_BUCKET}"
    gsutil mb -p "$GCP_PROJECT" "gs://${TEMP_BUCKET}"
    bq --project_id="$GCP_PROJECT" mk -d "$DATASET"
    ;;
  run)
    # Tasks 2 and 3: run in the SSH terminal of the lab-vm instance.
    # Use a fresh working directory for the downloaded template archive.
    # The lab template uses overwrite mode for the destination table.
    if [[ -e campaigns.avro || -e dataproc-templates.zip || -e dataproc-templates ]]; then
      echo 'Use a fresh working directory; lab assets already exist here.' >&2
      exit 1
    fi
    wget -O campaigns.avro "${ASSET_BASE}/campaigns.avro"
    gcloud storage cp campaigns.avro "gs://${STAGING_BUCKET}/campaigns.avro" \
      --project="$GCP_PROJECT"
    wget -O dataproc-templates.zip "${ASSET_BASE}/dataproc-templates.zip"
    unzip dataproc-templates.zip
    cd dataproc-templates/python
    ./bin/start.sh \
      -- --template=GCSTOBIGQUERY \
      --gcs.bigquery.input.format=avro \
      --gcs.bigquery.input.location="gs://${STAGING_BUCKET}" \
      --gcs.bigquery.input.inferschema=true \
      --gcs.bigquery.output.dataset="$DATASET" \
      --gcs.bigquery.output.table="$TABLE" \
      --gcs.bigquery.output.mode=overwrite \
      --gcs.bigquery.temp.bucket.name="$TEMP_BUCKET"
    ;;
  verify)
    # Task 4: inspect the loaded table; does not submit another Spark batch.
    bq --project_id="$GCP_PROJECT" query --use_legacy_sql=false \
      "SELECT * FROM \`${GCP_PROJECT}.${DATASET}.${TABLE}\`;"
    ;;
esac
