#!/usr/bin/env bash
# Local review draft: no deployment mode until the sample handler is reviewed.
# Usage: bash run-lab.sh setup|permissions|upload|verify|logs PROJECT_ID REGION
set -euo pipefail
MODE="${1:-}"
PROJECT_ID="${2:-}"
REGION="${3:-}"
if [[ ! "$MODE" =~ ^(setup|permissions|upload|verify|logs)$ || -z "$PROJECT_ID" || -z "$REGION" ]]; then
  echo 'Usage: bash run-lab.sh setup|permissions|upload|verify|logs PROJECT_ID REGION' >&2
  exit 2
fi
if [[ "$REGION" == "YOUR_LAB_REGION" || "$REGION" == "REGION" || "$PROJECT_ID" == *'{{'* || "$PROJECT_ID" == YOUR_* ]]; then
  echo 'Replace project and region placeholders with actual lab values.' >&2
  exit 2
fi
case "$MODE" in
  setup)
    gcloud config set compute/region "$REGION"
    gcloud config set run/region "$REGION"
    gcloud config set run/platform managed
    gcloud config set eventarc/location "$REGION"
    gcloud services enable artifactregistry.googleapis.com cloudfunctions.googleapis.com \
      cloudbuild.googleapis.com eventarc.googleapis.com run.googleapis.com \
      logging.googleapis.com pubsub.googleapis.com --project="$PROJECT_ID"
    gcloud storage buckets create "gs://${PROJECT_ID}" --location="$REGION" --project="$PROJECT_ID"
    # Location made explicit for review instead of relying on CLI defaults.
    bq --project_id="$PROJECT_ID" --location="$REGION" mk -d loadavro
    ;;
  permissions)
    PROJECT_NUMBER="$(gcloud projects describe "$PROJECT_ID" --format='value(projectNumber)')"
    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
      --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
      --role=roles/eventarc.eventReceiver
    gcloud beta services identity create --service=storage.googleapis.com --project="$PROJECT_ID"
    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
      --member="serviceAccount:service-${PROJECT_NUMBER}@gs-project-accounts.iam.gserviceaccount.com" \
      --role=roles/pubsub.publisher
    ;;
  upload)
    # Run only after deploying a reviewed function; upload triggers its load.
    if [[ -e campaigns.avro ]]; then
      echo 'campaigns.avro already exists; use a fresh directory.' >&2
      exit 1
    fi
    wget -O campaigns.avro https://storage.googleapis.com/cloud-training/dataengineering/lab_assets/idegc/campaigns.avro
    gcloud storage cp campaigns.avro "gs://${PROJECT_ID}/campaigns.avro" --project="$PROJECT_ID"
    ;;
  verify)
    gcloud eventarc triggers list --location="$REGION" --project="$PROJECT_ID"
    bq --project_id="$PROJECT_ID" query --use_legacy_sql=false \
      "SELECT * FROM \`${PROJECT_ID}.loadavro.campaigns\`;"
    ;;
  logs)
    # Override if the deployed Cloud Run service has another name.
    SERVICE_NAME="${SERVICE_NAME:-loadbigqueryfromavro}"
    gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=\"${SERVICE_NAME}\"" \
      --project="$PROJECT_ID" --limit=50
    ;;
esac
