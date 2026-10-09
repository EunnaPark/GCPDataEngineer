# Resolved: No dataset access in Data Studio

Date: 2026-10-09
Status: resolved, confirmed by the learner.

## Error

```text
No dataset access
Insufficient permissions to the underlying data set.
You don't have access to the underlying data.
```

## Investigation

The learner initially suspected multiple signed-in learner sessions. Restarting the browser did not resolve the error. The learner described the dataset as public. The exact failing connection settings, credential identity, and query-job project were not captured, so the underlying cause remains unconfirmed.

## Working solution

Suggested by Gemini and successfully tried by the learner:

1. Open the `sales_report` table in BigQuery.
2. Click **Open in** near **Export / sync**.
3. Choose **Looker Studio** (or Data Studio if the menu uses the newer name).
4. Continue in the newly opened reporting tab.

The learner confirmed that starting the reporting tool from BigQuery resolved the error. No IAM or billing changes were reported.

## What this demonstrates

The BigQuery entry point provided a working reporting connection in this lab. It does not prove that administrative credentials were used, or that permissions were bypassed. Gemini's proposed explanation about administrative credentials was not independently verified. The successful route still relies on an authorized connection and does not guarantee a fix for every dataset-access error.

## Product naming

Data Studio and Looker Studio refer to the same reporting product across name changes. Google now documents it as Data Studio, formerly Looker Studio. **Looker** is a separate business-intelligence product.

References:
- https://cloud.google.com/blog/products/data-analytics/looker-studio-is-data-studio
- https://docs.cloud.google.com/looker/docs/studio-comparison

This solution was initially saved locally while the course was in progress. The course documentation and supplied report artifacts were subsequently organized for publication at the learner's request on 2026-10-09.
