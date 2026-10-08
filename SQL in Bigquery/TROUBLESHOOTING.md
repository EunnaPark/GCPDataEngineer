# Troubleshooting: Cloud SQL connection during instance creation

Date: 2026-10-08
Status: Resolved — successful retry confirmed by the user.
Related lab: `SQL in Bigquery.txt`

## Situation

Attempted to connect to the MySQL instance `my-demo` from Cloud Shell while Cloud SQL was still processing its creation.

```bash
gcloud sql connect my-demo --user=root --quiet
```

## Failure and evidence

The Cloud SQL Auth Proxy reported that it started successfully and was listening locally on port `9470`. The MySQL connection then failed before login completed:

```text
ERROR 2013 (HY000): Lost connection to MySQL server at 'reading initial communication packet', system error: 2
```

A proxy listening locally did not establish that the database instance had finished provisioning.

## Cause and resolution

The instance was still being created during the initial connection attempt. After creation completed and the instance was up, the user retried the connection and confirmed that it succeeded.

Resolution: Wait for the instance to finish provisioning, then rerun the connection command. No password, IAM, or network changes were reported as necessary for this resolution.

## Verification

| Check | Expected result | Actual result |
| --- | --- | --- |
| Initial attempt during provisioning | Database must be ready before a successful connection | Proxy started, but MySQL returned ERROR 2013. |
| Retry after the instance was up | Successful MySQL connection | User confirmed the retry resolved the issue. |

## Lesson for future use

Check instance readiness before debugging credentials or changing configuration. This session was resolved by waiting for creation to complete; ERROR 2013 can have other causes in other circumstances. The successful connection does not by itself verify subsequent SQL or data-loading tasks.
