# Cloud Run Functions to Load BigQuery

## Local review draft

This guide organizes all seven tasks from your text file. [run-lab.sh](run-lab.sh) contains the non-deployment Cloud Shell commands in separate modes. The JavaScript function and deployment command are preserved below for review; no cloud actions have been run and these files have not been committed or pushed.

The original `.txt` is unchanged. Replace `YOUR_LAB_REGION` with your assigned region. The sample output’s `europe-west1` and timestamps describe an earlier session, not a requirement for your project.

### Review these source-code issues before deployment

1. The deployment specifies `--gen2`, while the example function uses the `(event, context)` background-event signature. Review the generation-appropriate event handler before treating this as a deployable example.
2. `loadJob` holds the promise returned by `.load()`. Awaiting it does not replace that variable with the resolved job, so `loadJob.id` is undefined. The supplied sample log actually shows `Job undefined`; that message alone does not establish a load failure.
3. The function accepts any object name and uses `fileName.replace('.avro', '')` as the table name. It does not filter non-Avro objects or handle nested object paths explicitly.
4. `WRITE_TRUNCATE` replaces existing destination data on each load. Repeated uploads are not an append-only event history.
5. The listed IAM grants cover event delivery and publication. They do not by themselves establish that the runtime account can read storage or create BigQuery load jobs and tables; confirm those permissions in the actual lab.
6. The dataset command does not specify a location. Check dataset and bucket location compatibility before deployment.
7. The sample log’s service name is lowercase `loadbigqueryfromavro`, whereas the original logging command uses mixed case. Use the actual deployed service name when filtering logs.

These are review notes about the supplied material, not silent changes to its JavaScript. The function code below is retained for comparison.

## Command script usage

Run with Bash in Cloud Shell after reviewing the intended project and region:

```bash
bash run-lab.sh setup YOUR_PROJECT_ID YOUR_LAB_REGION
bash run-lab.sh permissions YOUR_PROJECT_ID YOUR_LAB_REGION
```

Create `index.js` from Task 3, then review Task 5 before deploying manually. Once an appropriate function and trigger are deployed:

```bash
bash run-lab.sh upload YOUR_PROJECT_ID YOUR_LAB_REGION
bash run-lab.sh verify YOUR_PROJECT_ID YOUR_LAB_REGION
bash run-lab.sh logs YOUR_PROJECT_ID YOUR_LAB_REGION
```

Setup creates resources and is intended for a fresh training project. `permissions` changes IAM. `upload` triggers the deployed function, which uses overwrite semantics. The script intentionally has no deployment mode while the supplied handler/deployment pairing needs review.

| Resource | Lab setting |
| --- | --- |
| Function entry point | `loadBigQueryFromAvro` |
| Runtime in supplied command | `nodejs24` |
| Bucket name | Project ID |
| BigQuery dataset/table | `loadavro.campaigns` |
| Input | `campaigns.avro` |
| Memory / timeout | `512Mi` / `540s` |
| Runtime account in supplied command | Default Compute Engine service account |
| Trigger | Cloud Storage object finalized |

## Overview
A Cloud Run function is a piece of code that runs in response to an event, such as an HTTP request, a message from a messaging service, or a file upload. Cloud events are things that happen in your cloud environment. These might be things like changes to data in a database, files added to a storage system, or a new virtual machine instance being created.

Since Cloud Run functions are event-driven, they only run when something happens. This makes them a good choice for tasks that need to be done quickly or that don't need to be running all the time.

This hands-on lab shows you how to create, deploy, and test a Cloud Run function which will load a BigQuery table using the Google Cloud SDK.

## Learning objectives
Create a Cloud Run function
Deploy and test the Cloud Run function
View data in BigQuery and Cloud Run function logs


## Task 1. Enable APIs
In this task, you enable the relevant APIs before you create the Cloud Run functions.

In Cloud Shell, run the following command to set your Project ID variable:
```bash
export PROJECT_ID=$(gcloud config get-value project)
```
Run the following commands to set the Region variable:
```bash
export REGION="YOUR_LAB_REGION"
```
```bash
gcloud config set compute/region $REGION
```
Run the following commands to set the configuration variables:
```bash
gcloud config set run/region $REGION
```
```bash
gcloud config set run/platform managed
```
```bash
gcloud config set eventarc/location $REGION
```
Run the following commands to enable all necessary services:
```bash
gcloud services enable \
  artifactregistry.googleapis.com \
  cloudfunctions.googleapis.com \
  cloudbuild.googleapis.com \
  eventarc.googleapis.com \
  run.googleapis.com \
  logging.googleapis.com \
  pubsub.googleapis.com
```
Note: For Eventarc, It may take a few minutes before all of the permissions are propagated to the service agent
## Task 2. Set required permissions
In this task, you grant the default Compute Engine service account the ability to receive Eventarc events, and the Cloud Storage service agent the permission to publish messages to Pub/Sub topics, enabling event-driven workflows and storage-triggered actions.

In Cloud Shell, run the following command to set the PROJECT_NUMBER variable:
```bash
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
```
Run the following command to grant the default Compute Engine service account within your project the necessary permissions to receive events from Eventarc:
```bash
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
    --role="roles/eventarc.eventReceiver"
```
Run the following commands to retrieve the Cloud Storage service agent for your project, and grant it the permission to publish messages to Pub/Sub topics:
```bash
gcloud beta services identity create --service=storage.googleapis.com --project=$PROJECT_ID
```

```bash
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:service-$PROJECT_NUMBER@gs-project-accounts.iam.gserviceaccount.com" \
    --role='roles/pubsub.publisher'
```
## Task 3. Create the function
In this task, you create a simple function named loadBigQueryFromAvro. This function reads an Avro file that is uploaded to Cloud Storage and then creates and loads a table in BigQuery.

In Cloud Shell, run the following command to create and open a file named index.js:
```bash
nano index.js
```
Copy the following code for the Cloud Function into the index.js file:
```javascript
/**
* index.js Cloud Function - Avro on GCS to BQ
*/
const {Storage} = require('@google-cloud/storage');
const {BigQuery} = require('@google-cloud/bigquery');

const storage = new Storage();
const bigquery = new BigQuery();

exports.loadBigQueryFromAvro = async (event, context) => {
    try {
        // Check for valid event data and extract bucket name
        if (!event || !event.bucket) {
            throw new Error('Invalid event data. Missing bucket information.');
        }

        const bucketName = event.bucket;
        const fileName = event.name;

        // BigQuery configuration
        const datasetId = 'loadavro';
        const tableId = fileName.replace('.avro', '');

        const options = {
            sourceFormat: 'AVRO',
            autodetect: true,
            createDisposition: 'CREATE_IF_NEEDED',
            writeDisposition: 'WRITE_TRUNCATE',
        };

        // Load job configuration
        const loadJob = bigquery
            .dataset(datasetId)
            .table(tableId)
            .load(storage.bucket(bucketName).file(fileName), options);

        await loadJob;
        console.log(`Job ${loadJob.id} completed. Created table ${tableId}.`);

    } catch (error) {
        console.error('Error loading data into BigQuery:', error);
        throw error;
    }
};
```
In nano press (Ctrl+x) , and then press (Y), and then press Enter to save the file.

## Task 4. Create a Cloud Storage bucket and BigQuery dataset
In this task, you set up the background infrastructure to store assets used to invoke the Cloud Run function (a Cloud Storage bucket), and then store the output in BigQuery when it completes.

In Cloud Shell, run the following command to create a new Cloud Storage bucket as a staging location:
```bash
gcloud storage buckets create gs://$PROJECT_ID --location=$REGION
```
Run the following command to create a BQ dataset to store the data:
```bash
bq mk -d  loadavro
```



## Task 5. Deploy your function
In this task, you deploy the new Cloud Run function and trigger it so that the data is loaded into BigQuery.

In Cloud Shell, run the following command to install the two javascript libraries to read from Cloud Storage and store the output in BigQuery:
```bash
npm install @google-cloud/storage @google-cloud/bigquery
```
Run the following command to deploy the function:
```bash
gcloud functions deploy loadBigQueryFromAvro \
    --gen2 \
    --runtime nodejs24 \
    --source . \
    --region $REGION \
    --trigger-resource gs://$PROJECT_ID \
    --trigger-event google.storage.object.finalize \
    --memory=512Mi \
    --timeout=540s \
    --service-account=$PROJECT_NUMBER-compute@developer.gserviceaccount.com
```
Note: If you see an error message relating to eventarc service agent propagation, wait a few minutes and try the command again.
Run the following command to confirm that the trigger was successfully created. The output will be similar to the following:
```bash
gcloud eventarc triggers list --location=$REGION
```
```text
NAME: loadbigqueryfromavro-177311
TYPE: google.cloud.storage.object.v1.finalized
DESTINATION: Cloud Functions: loadBigQueryFromAvro
ACTIVE: Yes
LOCATION: europe-west1
```
Run the following command to download the Avro file that will be processed by the Cloud Run function for storage in BigQuery:
```bash
wget https://storage.googleapis.com/cloud-training/dataengineering/lab_assets/idegc/campaigns.avro
```
Run the following command to move the Avro file to the staging Cloud Storage bucket you created earlier. This action will trigger the Cloud Run function:
```bash
gcloud storage cp campaigns.avro gs://$PROJECT_ID
```



## Task 6. Confirm that the data was loaded into BigQuery
In this task, you confirm that the data processed by the Cloud Run function has been successfully loaded into BigQuery by querying the loadavro.campaigns table using the bq command

In Cloud Shell, run the following command to view the data in the new table in BigQuery, using the bq command:
```bash
bq query \
 --use_legacy_sql=false \
 'SELECT * FROM `loadavro.campaigns`;'
```
Note: The Cloud Run function will typically process very quickly but it is possible the query run against BigQuery may not return results. If that is the case for you please wait a moment and run the query again.
The query should return results similar to the following:

Example output:

```text
+------------+--------+---------------------+--------+---------------------+----------+-----+
| created_at | period |    campaign_name    | amount | advertising_channel | bid_type | id  |
+------------+--------+---------------------+--------+---------------------+----------+-----+
| 2020-09-17 |     90 | NA - Video - Other  |     41 | Video               | CPC      |  81 |
| 2021-01-19 |     30 | NA - Video - Promo  |    325 | Video               | CPC      | 137 |
| 2021-06-28 |     30 | NA - Video - Promo  |     78 | Video               | CPC      | 214 |
| 2021-03-15 |     30 | EU - Search - Brand |    465 | Search              | CPC      | 170 |
| 2022-01-01 |     30 | EU - Search - Brand |     83 | Search              | CPC      | 276 |
| 2020-02-18 |     30 | EU - Search - Brand |     30 | Search              | CPC      |  25 |
| 2021-06-08 |     30 | EU - Search - Brand |    172 | Search              | CPC      | 201 |
| 2020-11-29 |     60 | EU - Search - Other |     83 | Search              | CPC      | 115 |
| 2021-09-11 |     30 | EU - Search - Other |     86 | Search              | CPC      | 237 |
| 2022-02-17 |     30 | EU - Search - Other |     64 | Search              | CPC      | 296 |
+------------+--------+---------------------+--------+---------------------+----------+-----+
```

## Task 7. View logs
In this task, you retrieve all log entries that are associated with your service named loadBigQueryFromAvro.

In Cloud Shell, run the following command to examine the logs for your Cloud Run function:
```bash
gcloud logging read "resource.labels.service_name=loadBigQueryFromAvro"
```
Messages in the log appear similar to the following:

```yaml
resource:
  labels:
    configuration_name: loadbigqueryfromavro
    location: europe-west1
    project_id: YOUR_PROJECT_ID
    revision_name: loadbigqueryfromavro-00001-wim
    service_name: loadbigqueryfromavro
  type: cloud_run_revision
spanId: '5804952652695382607'
textPayload: |
  Job undefined completed. Created table campaigns.
timestamp: '2025-03-10T17:24:43.560594Z'
```

## Study explanation

```mermaid
flowchart LR
    A[Upload campaigns.avro] --> B[Cloud Storage finalized event]
    B --> C[Eventarc delivery]
    C --> D[Cloud Run function]
    D --> E[BigQuery load job]
    E --> F[loadavro.campaigns]
    D --> G[Cloud Logging]
```

The event identifies the object’s bucket and name. The function uses the Cloud Storage client to reference the object and the BigQuery client to submit a load. `CREATE_IF_NEEDED` permits table creation, but does not create the dataset. `WRITE_TRUNCATE` determines the replacement behavior. Avro supplies a structured file format for the load.

The event-delivery identity and runtime data-access permissions are different concerns. Receiving an event does not automatically grant permission to read its object or write the destination table.

## Verification checklist

- [ ] Active project and assigned region confirmed.
- [ ] APIs enabled and event-delivery permissions propagated.
- [ ] Bucket and `loadavro` dataset exist in compatible locations.
- [ ] Handler shape, dependencies, and trigger configuration reviewed together.
- [ ] Runtime account has the required storage and BigQuery permissions.
- [ ] Trigger is active.
- [ ] Upload completes and a function invocation is recorded.
- [ ] `loadavro.campaigns` returns records.
- [ ] Logs checked using the actual service name.

The supplied output lists ten sample rows. It does not establish a total row count for every execution. The query has no `ORDER BY`, so row order can vary.

## Troubleshooting

| Symptom | Review |
| --- | --- |
| Trigger creation fails | Eventarc setup, account permissions, and propagation time. |
| Event is reported as invalid | Event payload/handler compatibility with the deployed function generation. |
| Storage or BigQuery access denied | Runtime identity, bucket access, job permissions, and destination permissions. |
| Dataset not found | Correct project and creation of `loadavro` before upload. |
| Unexpected table name | Uploaded object name and the simple `.replace('.avro', '')` expression. |
| `Job undefined` in logs | The promise/job variable issue described above; also inspect the actual BigQuery result. |
| No query results yet | Invocation state, load errors, and a short processing delay. |
| No logs returned | Actual lowercase service name, project, and logging filter. |

## Review questions

1. **What triggers the load?** Finalization of an object uploaded to the configured bucket.
2. **Does the function create the dataset?** No; it is created separately in Task 4.
3. **Why can a later upload replace rows?** The function specifies `WRITE_TRUNCATE`.
4. **Why is `loadJob.id` undefined in the supplied example?** The variable still holds the promise instead of the resolved job object.
5. **Does event-receiver permission grant BigQuery write access?** No; these are distinct permissions.
6. **What should verify success?** The invocation/load status and actual table results, alongside logs.

## Source and scope

Organized from `Cloud Run Functions to Load BigQuery.txt`, preserving all seven tasks, the supplied JavaScript, deployment command, and sample output. The literal upload placeholder is corrected to `$PROJECT_ID`, reusable region placeholders are clarified, and review notes are added. No runtime compatibility test or cloud deployment has been performed. These files are a local review draft.

## Failure case study and reusable recovery procedure

This section records the errors encountered during the lab and the fixes discussed. Successful redeployment and a completed BigQuery load have not yet been confirmed. Treat the following as a recovery procedure to verify, not a record of a successful run.

### Failure summary

| Failure | Evidence / cause | Resolution | Confirmation |
| --- | --- | --- | --- |
| `loadavro.campaigns was not found in location US` | The query could not resolve the table in its job location. A missing table or a dataset-location mismatch can produce this error. In this session, a later log showed that load submission failed. | Inspect dataset location and table existence, then fix the load failure before querying again. | Table appears in `bq ls`; query succeeds in the dataset location. |
| HTTP 400: real project ID does not agree with `{{projectId}}` | The request URL contained the literal placeholder `{{projectId}}`, while its body used the real project ID. The log establishes the mismatch, but not which configuration introduced the placeholder. | Remove the placeholder from deployed configuration; explicitly configure the BigQuery client with the current project. | A new invocation submits the job without the project-mismatch error. |
| HTTP 403: `Location YOUR_LAB_REGION is not found or access is unauthorized` | `YOUR_LAB_REGION` was passed literally rather than replaced with the assigned region. | Set the existing function’s actual region; do not invent a new region. | Deployment targets the existing region instead of the placeholder. |
| Container failed to listen on `PORT=8080` | Generic startup/health-check symptom. The shared `npm ls` and `package.json` output confirmed that `@google-cloud/functions-framework` was missing although the updated code imports it. | Install the framework in the deployment source directory and redeploy. If startup still fails, inspect that new revision’s logs for another cause. | Dependency appears in `npm ls` and deployment becomes ready. |
| `Job undefined completed` | The original code logs `.id` on the promise instead of the resolved job. This is a logging defect, not by itself proof that the load failed. | Use `const [job] = await ...load(...)`, then log `job.id`. | Completion log contains the resolved job ID and table results are checked. |
| Potential missing bucket event data | The original background-event signature is paired with a Gen 2 deployment. This was identified during review, not confirmed as an observed session error. | Register a CloudEvent handler and read `cloudEvent.data.bucket` / `.name`. | Uploaded object reaches the handler with both fields present. |

### 1. Check the project, dataset, and existing region

Run in Cloud Shell:

```bash
export PROJECT_ID="$(gcloud config get-value project)"
printf 'Active project: %s\n' "$PROJECT_ID"

gcloud functions list --project="$PROJECT_ID"
bq show --format=prettyjson "${PROJECT_ID}:loadavro"
bq ls "${PROJECT_ID}:loadavro"
```

Read the dataset’s `location` from `bq show`. Use the existing function’s region from `gcloud functions list` when redeploying. Function region and BigQuery dataset location are separate settings; a regional location such as `us-central1` is not the same location as multi-region `US`.

Set `REGION` to the actual lab region before continuing. Do not run a command with the literal value `YOUR_LAB_REGION`.

### 2. Work in the correct deployment directory

Use the directory containing `index.js` and `package.json`. Because deployment uses `--source=.`, running it from another directory can deploy different code.

```bash
pwd
ls index.js package.json
npm install @google-cloud/functions-framework @google-cloud/storage @google-cloud/bigquery
npm ls @google-cloud/functions-framework @google-cloud/storage @google-cloud/bigquery
node --check index.js
```

`npm install` must save all three packages under `dependencies` in `package.json`. Keep the resulting `package-lock.json` with the source for repeatable installs. `node --check` checks syntax only; it does not establish that cloud permissions, event delivery, or load configuration work.

The code below uses CommonJS `require()`. Ensure `package.json` does not declare `"type": "module"` for this version.

### 3. Replacement Gen 2 function example

The original JavaScript remains in Task 3 for comparison. For the recovery version, replace `index.js` with the following. Its project comes from `LAB_PROJECT_ID`, which is supplied by the deployment command in the next step.

```javascript
const functions = require('@google-cloud/functions-framework');
const {Storage} = require('@google-cloud/storage');
const {BigQuery} = require('@google-cloud/bigquery');

const projectId = process.env.LAB_PROJECT_ID;
if (!projectId || projectId.includes('{{') || projectId.includes('YOUR_')) {
  throw new Error('Set LAB_PROJECT_ID to the actual Google Cloud project ID.');
}

const storage = new Storage({projectId});
const bigquery = new BigQuery({projectId});

functions.cloudEvent('loadBigQueryFromAvro', async (cloudEvent) => {
  try {
    const file = cloudEvent.data;
    if (!file?.bucket || !file?.name) {
      throw new Error('Missing bucket or file name in event.');
    }

    if (!file.name.endsWith('.avro')) {
      console.log(`Skipping non-Avro file: ${file.name}`);
      return;
    }

    const tableId = file.name.split('/').pop().replace(/\.avro$/, '');
    const [job] = await bigquery
      .dataset('loadavro')
      .table(tableId)
      .load(storage.bucket(file.bucket).file(file.name), {
        sourceFormat: 'AVRO',
        autodetect: true,
        createDisposition: 'CREATE_IF_NEEDED',
        writeDisposition: 'WRITE_TRUNCATE',
      });

    console.log(`Job ${job.id} completed. Loaded loadavro.${tableId}.`);
  } catch (error) {
    console.error('Error loading data into BigQuery:', error);
    throw error;
  }
});
```

The example preserves the lab’s replacement behavior. Another upload can replace the destination table data. Files with the same basename in different object folders target the same table. This is a lab example, not an append-only or deduplicated ingestion design.

### 4. Redeploy after validating variables

Set `REGION` to the actual region found in step 1. This block deliberately refuses empty variables and the previous region placeholder:

```bash
: "${PROJECT_ID:?Set PROJECT_ID to your current lab project}"
: "${REGION:?Set REGION to the existing function region}"
if [[ "$REGION" == "YOUR_LAB_REGION" || "$REGION" == "REGION" ]]; then
  echo 'Replace the region placeholder before deployment.' >&2
  exit 1
fi

export PROJECT_NUMBER="$(gcloud projects describe "$PROJECT_ID" \
  --format='value(projectNumber)')"

gcloud functions deploy loadBigQueryFromAvro \
  --project="$PROJECT_ID" \
  --gen2 \
  --runtime=nodejs24 \
  --entry-point=loadBigQueryFromAvro \
  --source=. \
  --region="$REGION" \
  --trigger-bucket="$PROJECT_ID" \
  --memory=512Mi \
  --timeout=540s \
  --service-account="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
  --update-env-vars="LAB_PROJECT_ID=${PROJECT_ID}"
```

This retains the lab assumption that the bucket name equals the project ID and the runtime identity is the default Compute Engine account. Adapt those settings if your lab uses a different bucket or account. Updating a local file does not update an already deployed revision; deployment must succeed first.

### 5. Trigger a fresh invocation and verify

After deployment succeeds, upload the input again:

```bash
gcloud storage cp campaigns.avro "gs://${PROJECT_ID}/campaigns.avro" \
  --project="$PROJECT_ID"
bq ls "${PROJECT_ID}:loadavro"
```

Allow time for the function to process the event. Once `campaigns` appears, set `BQ_LOCATION` to the dataset’s actual `location` from step 1, then query:

```bash
: "${BQ_LOCATION:?Set BQ_LOCATION to the actual loadavro dataset location}"
bq --project_id="$PROJECT_ID" --location="$BQ_LOCATION" query \
  --use_legacy_sql=false \
  "SELECT * FROM \`${PROJECT_ID}.loadavro.campaigns\` LIMIT 10;"
```

### 6. If startup still fails, inspect the failed revision

Do not assume every `PORT=8080` error has the same cause. First inspect service logs:

```bash
gcloud logging read \
  'resource.type="cloud_run_revision" AND resource.labels.service_name="loadbigqueryfromavro"' \
  --project="$PROJECT_ID" --freshness=1h --limit=50 --order=asc --format=json
```

For a specific failed deployment, additionally filter `resource.labels.revision_name` using the exact revision from that deployment’s error message. Look for `Cannot find module`, syntax errors, entry-point errors, or configuration errors preceding the health-check failure. The Functions Framework supplies the HTTP listener; do not add a separate `app.listen(8080)` to this handler.

### Recovery completion record

- [ ] Actual project and region substituted; no literal placeholders remain.
- [ ] All three dependencies are in the deployment source’s `package.json`.
- [ ] Updated CloudEvent handler deployed successfully.
- [ ] `LAB_PROJECT_ID` set on the deployed function.
- [ ] New upload produces a successful invocation/load.
- [ ] `loadavro.campaigns` exists and can be queried in its dataset location.

### Official references

- [BigQuery error messages: missing resources and location mismatches](https://docs.cloud.google.com/bigquery/docs/error-messages)
- [Gen 2 Cloud Storage CloudEvent example](https://docs.cloud.google.com/functions/docs/samples/functions-cloudevent-storage)
- [BigQuery Node.js client configuration](https://googleapis.dev/nodejs/bigquery/latest/BigQuery.html)
- [Cloud Run startup troubleshooting](https://docs.cloud.google.com/run/docs/troubleshooting#container-failed-to-start)
- [Node.js Functions Framework](https://github.com/GoogleCloudPlatform/functions-framework-nodejs)
