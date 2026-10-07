# Create and Execute a SQL Workflow in Dataform
## Overview
This lab walks you through the process to create and execute a SQL workflow in Dataform to load data in BigQuery.

## Learning objectives
Create a Dataform repository.
Create and initialize a Dataform development workspace.
Create and execute a SQL workflow.
View execution logs in Dataform.



## Task 1. Create a Dataform repository
In the Console, expand the Navigation menu, then select BigQuery > Dataform.

Click CREATE REPOSITORY.

On the Create repository page, do the following:

In the Repository ID field, enter quickstart-repository.

In the Region list, select us-west1.

Click CREATE.

Once the repository is created, you will see the Dataform service account. Copy and save the service account. You will need to use it later to assign necessary permissions.


Dataform will execute workflows as the service account YOUR_DATAFORM_SERVICE_ACCOUNT.
To execute queries in Dataform, you need the following roles:
for YOUR_DATAFORM_SERVICE_ACCOUNT:
roles/bigquery.jobUser on YOUR_PROJECT_ID


Ignore the warning regarding the role needed to execure queries. You will grant the necessary permissions in a later step using the service account name you copied in the prior step.

Click Go to Repositories.

Note: If you get permission denied error related to API request wait for few minutes and create the repository again.
Test completed task
Progress check
Complete all progress checks to get credit for your lab!
Before continuing, please refer back to the overview page to check your progress.

Look for the Checkpoints section then click Check my progress to verify the objective for this task.


## Task 2. Create and initialize a Dataform development workspace
On the Dataform page, click on the quickstart-repository repository you just created.

Click CREATE DEVELOPMENT WORKSPACE.

In the Create development workspace window, do the following:

In the Workspace ID field, enter quickstart-workspace.

Click CREATE.

Once created, click on the quickstart-workspace development workspace.

Click INITIALIZE WORKSPACE.

Test completed task


## Task 3. Create a SQLX file for defining a view
In this section, you define a view that you will later use as a data source for a table.

In the Files pane, next to definitions, click the More menu (the 3 vertical dots that appear to the right of definitions when you hover over it).

Click Create file.

In the Create new file pane, do the following:

In the Add a file path field, enter definitions/quickstart-source.sqlx.

Click CREATE FILE.

Define a view
In the Files pane, expand the definitions folder.

Click quickstart-source.sqlx.

In the file, enter the following code snippet:

```sql
config {
  type: "view"
}

SELECT
  "apples" AS fruit,
  2 AS count
UNION ALL
SELECT
  "oranges" AS fruit,
  5 AS count
UNION ALL
SELECT
  "pears" AS fruit,
  1 AS count
UNION ALL
SELECT
  "bananas" AS fruit,
  0 AS count
```



## Task 4. Create a SQLX file for table definition
In the following sections, you define the table type in a SQLX file, and then write a SELECT statement to define the table structure within the same file.

In the Files pane, next to definitions, click the More menu, and then select Create file.

In the Add a file path field, enter definitions/quickstart-table.sqlx.

Click CREATE FILE.

Define the table type, structure and dependencies
In the Files pane, expand the definitions directory.

Select quickstart-table.sqlx, and then enter the following table type and SELECT statement:

```sql
config {
  type: "table"
}

SELECT
  fruit,
  SUM(count) as count
FROM ${ref("quickstart-source")}
GROUP BY 1
```


## Task 5. Grant Dataform access to BigQuery
In the Google Cloud console, on the Navigation menu (Navigation menu icon), select IAM & Admin > IAM.

Click VIEW BY PRINCIPALS. Next, click GRANT ACCESS

In the New principals field, enter the Dataform service account ID you copied in Task 1.

In the Select a role drop-down list, select the BigQuery Job User role.

Click Add another role, and then in the Select a role drop-down list, select the BigQuery Data Editor role.

Click Add another role, and then in the Select a role drop-down list, select the BigQuery Data Viewer role.

Click Save.

Test completed task
The new roles can take a couple of minutes to process, so if the check fails, wait a few minutes and try again.

## Study notes: how the workflow works

The repository contains your workflow project. The development workspace is where you edit and initialize its files. SQLX combines a configuration block with a SQL query.

| File | Action type | Purpose |
| --- | --- | --- |
| `definitions/quickstart-source.sqlx` | `view` | Defines four fruit records directly in SQL. |
| `definitions/quickstart-table.sqlx` | `table` | Stores the result of grouping the source records and summing their counts. |

The table depends on the view through `${ref("quickstart-source")}`. This reference resolves the source relation and declares the dependency. `UNION ALL` preserves every input record, including duplicates. `GROUP BY 1` groups by the first selected expression, `fruit`.

There is only one row for each fruit in the supplied source, so aggregation leaves each count unchanged. If you added another apple row with a count of 3, the table query would produce one apple row with a count of 5.

### Settings to remember

- Repository: `quickstart-repository`
- Repository region: `us-west1`
- Workspace: `quickstart-workspace`
- Execution service account: copy it from your own repository.
- Destination project, dataset, and BigQuery location: inspect your initialized workspace configuration.

The placeholders `YOUR_PROJECT_ID` and `YOUR_DATAFORM_SERVICE_ACCOUNT` replace identifiers from a temporary lab session. Use your current project and execution identity.

### Understand the lab permissions

| Role | Role ID | Purpose |
| --- | --- | --- |
| BigQuery Job User | `roles/bigquery.jobUser` | Submit BigQuery jobs. |
| BigQuery Data Editor | `roles/bigquery.dataEditor` | Create and update output data. |
| BigQuery Data Viewer | `roles/bigquery.dataViewer` | Read data and metadata. |

Task 5 preserves the training lab’s role assignments. The service account running the workflow needs the access; signing in to the console as a user is a separate identity.

## Task 6. Run the workflow

The supplied notes stop after granting access. These execution steps supplement them using [Google’s Dataform quickstart](https://docs.cloud.google.com/dataform/docs/quickstart-create-workflow).

1. Open `quickstart-repository`, then `quickstart-workspace`.
2. Select **Start execution**.
3. Select **All actions**, then start the execution.
4. Follow any authentication prompt appropriate to your configured execution identity.

The quickstart uses the default destination dataset `dataform`. Check your workspace settings if your destination differs.

## Task 7. Inspect logs and verify results

Open **Workflow Execution Logs** in the workspace and select the latest execution to inspect its details, as described in [Google’s quickstart](https://docs.cloud.google.com/dataform/docs/quickstart-create-workflow). Confirm both actions succeeded before checking the output in BigQuery.

Use this verification query, replacing the project and dataset if needed:

```sql
SELECT fruit, count
FROM `YOUR_PROJECT_ID.dataform.quickstart-table`
ORDER BY fruit;
```

Expected output, derived from the supplied SQL:

| fruit | count |
| --- | ---: |
| apples | 2 |
| bananas | 0 |
| oranges | 5 |
| pears | 1 |

```sql
SELECT COUNT(*) AS fruit_rows, SUM(count) AS total_count
FROM `YOUR_PROJECT_ID.dataform.quickstart-table`;
```

Expected values: **4 rows** and **total count 8**. These are expected results, not results of a cloud execution performed for this guide.

## Troubleshooting

| Symptom | What to check |
| --- | --- |
| API-related permission error when creating a repository | Active project and API setup; the lab notes suggest waiting a few minutes and retrying. |
| Access denied during execution | The actual execution service account, its roles, and the destination project/dataset. |
| Progress check fails after assigning roles | Allow time for IAM propagation, then retry. |
| Source reference cannot resolve | The action name `quickstart-source` and spelling inside `ref()`. |
| Output table is missing | Execution status and configured destination dataset. |
| Rows appear in another order | Add `ORDER BY`; SQL does not otherwise guarantee row order. |

## Review questions

1. How does a workspace differ from a repository?
2. What changes when `type` is `view` instead of `table`?
3. What does `ref()` contribute besides the source relation name?
4. Why does the aggregation initially leave the counts unchanged?
5. Which role allows the execution account to submit jobs?
6. Where do you investigate a failed action?

### Answer key

1. The repository contains the workflow project; the workspace is an editing environment for it.
2. A view defines a query; the table action stores its query result when run.
3. It declares the dependency on the referenced action.
4. There is only one input row per fruit.
5. BigQuery Job User.
6. The action details in the latest Workflow Execution Logs entry.

## Sources

Tasks 1–5 and both SQLX examples are preserved from `execute a SQL workflow in Dataform.txt`, with headings, fenced SQL, and reusable identity placeholders. Study explanations, verification queries, and review questions are added here. Execution and log navigation are supplemented from [Google Cloud’s Dataform quickstart](https://docs.cloud.google.com/dataform/docs/quickstart-create-workflow). No cloud resources were created or SQL executed while preparing this guide.
