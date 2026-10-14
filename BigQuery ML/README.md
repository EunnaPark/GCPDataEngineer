# Predict Visitor Purchases with BigQuery ML

Date organized: 2026-10-14
Goal: prepare labeled session data, train a classification model, evaluate it, and predict purchasing sessions by country and visitor.

Status: course-based study. The learner supplied the course instructions and discussed the workflow. No training jobs, evaluation metrics, prediction outputs, or grader outcomes were supplied. No cloud jobs were executed while organizing these files.

## Files

- [Original course instructions](Predict%20Visitor%20Purchases%20with%20BigQuery%20ML.txt), preserved unchanged.
- [Course workflow SQL](course-workflow.sql): dataset/view setup, model training, course-style evaluation, prediction view, and country ranking.
- [Visitor challenge SQL](visitor-challenge.sql): final challenge grouped by visitor.
- [Separate evaluation SQL](heldout-evaluation.sql): proposed July evaluation, not a verified course submission.

SQL files contain independent statements. Run them in order, one at a time, after replacing YOUR_PROJECT with the actual execution project. Creating views and training a model changes cloud resources and can incur charges. These files are saved examples, not automatically executed scripts.

## Scenario and service choice

The course uses Google Merchandise Store Google Analytics sessions to predict whether a session contains a transaction. BigQuery ML lets the learner prepare data, train a logistic-regression model, and run predictions in SQL near the stored data.

BigQuery ML is prescribed by the lab. A separate Python training workflow is an alternative when different modeling tools or deployment requirements are needed; no such implementation or architecture comparison was performed here. Gemini assists with explaining and generating SQL in the course, but the predictive artifact is the trained BigQuery ML model. Gemini is not the sample_model used by ML.PREDICT.

## The four-step workflow

1. **Prepare labeled data:** choose input features and the known outcome; define training and evaluation populations.
2. **Train a model:** CREATE MODEL learns patterns from labeled training rows.
3. **Evaluate the model:** ML.EVALUATE compares predictions with known labels, preferably on separate data.
4. **Make predictions:** ML.PREDICT applies the trained model to input rows.

The final step is using the model to predict outcomes, not predicting the model itself.

## Why sample_model is needed

sample_model is the saved model name chosen in the course, not a special required name. It stores the learned relationship between features and labels. A different name such as purchase_prediction_model would work if subsequent queries reference it consistently.

Training uses sessions with known outcomes. Prediction applies those learned patterns to session features. Input data alone does not contain learned rules, so ML.PREDICT needs a model reference as well as prediction rows.

## 1. Prepare the data

Source: `bigquery-public-data.google_analytics_sample.ga_sessions_*`.

| Column | Preparation and role |
|---|---|
| label | 0 when totals.transactions is NULL, otherwise 1; course definition of outcome |
| os | Operating system, missing values replaced with empty string |
| is_mobile | Device mobile indicator |
| country | Country, missing values replaced with empty string |
| pageviews | Pageviews, missing values replaced with zero |
| fullVisitorId | Identifier retained for prediction aggregation, not a training feature in this example |

Each source row represents a session. The label tests whether transactions is non-null, rather than directly testing transactions > 0. Inspect whether explicit zero values exist before assuming these definitions are equivalent.

The original training range ends at suffix 20170631. June has only 30 days. Because _TABLE_SUFFIX is compared as a string, that expression is not a date-construction error, but the intended valid endpoint should be explicit. The organized SQL uses 20170630 and notes this change.

The course limits training_data to 10,000 rows without ORDER BY. This is a convenience sample, not a guaranteed random or representative sample. Saving the query as a view does not materialize a fixed sample, so do not assume repeated view queries select identical rows. For a stronger independent project, materialize a documented reproducible sample and record class balance and coverage.

The workflow creates bqml_lab in US if it does not exist, to match the US public source. If a dataset already exists elsewhere, check its location rather than assuming the creation statement changes it.

## 2. Train logistic regression

The training SQL selects label and four features from training_data, sets MODEL_TYPE to LOGISTIC_REG, and specifies INPUT_LABEL_COLS as label. Logistic regression is a classifier here: it predicts a class such as transaction/no transaction, not the exact number of orders.

CREATE MODEL starts a training job. Wait for success before evaluating or predicting. The organized file uses CREATE MODEL rather than CREATE OR REPLACE MODEL so rerunning it does not silently replace an existing model. Inspect the existing artifact or choose a new name when repeating training.

## 3. Evaluate carefully

The course explicitly passes training_data to ML.EVALUATE. This means evaluation queries the same source view used for model creation and does not demonstrate an independent holdout. It may include training rows. The non-deterministic limited view adds another reproducibility concern.

Keep that course example for reference, but use a separate labeled date range to assess generalization. `heldout-evaluation.sql` proposes July 1–31, after the training period. This is a time holdout, not a guarantee of unseen visitors: the same visitor may occur in both periods. Match the split method to the intended prediction goal.

Review precision, recall, ROC AUC, log loss, and class balance together. Accuracy alone can be misleading when transactions are rare. No metric values are claimed in this record.

## 4. Predict sessions and aggregate by country

The course saves july_data for suffixes 20170701 through 20170801 inclusive. Despite its name, that range includes August 1. The course workflow preserves that range for traceability; change it deliberately if a July-only analysis is intended.

ML.PREDICT receives the trained model and feature columns. Additional columns such as fullVisitorId can pass through for reporting. The prediction queries omit the known label from their input because it is not needed to score a session.

The course deliberately uses TOTAL(predicted_label), producing Function not found: TOTAL. The corrected aggregate is SUM. The organized SQL uses SUM(CAST(predicted_label AS INT64)) to make binary class-label summation explicit. This failure is a course exercise, not a personally confirmed runtime incident.

A sum of 0/1 predicted labels counts sessions classified as purchasing. It does not predict exact transaction counts or sum probabilities. The country ranking is also affected by the number of sessions per country; it is not a conversion-rate ranking.

## Final challenge — Predict purchases per user

Course question: predict transactions per visitor, sort results, and select the top ten visitors.

The saved [challenge answer](visitor-challenge.sql) follows the course aggregation pattern, replacing country with fullVisitorId, grouping by visitor, summing binary predictions, and sorting descending. The second sort key makes ties reproducible.

The measure is named predicted_purchasing_sessions to communicate its actual meaning. This is an explanatory example; exact grader alias requirements were not supplied. Repeated visitors can have multiple sessions. The model predicts each session first, then SQL aggregates by visitor. It is not a separately trained visitor-level model.

## Prediction timing and interpretation

The features include total session pageviews. Those may not be available at the start of a visit. Before claiming a deployable prediction of future purchases, define when the prediction is made and restrict inputs to information available then. Using completed-session features can answer a retrospective classification question rather than a pre-purchase targeting question.

The historical public dataset is useful for learning but does not establish performance on current customers. Session predictions and country rankings should not be presented as proven business improvements.

## Validation

| Check | Expected | Actual evidence |
|---|---|---|
| training_data | View with label and four feature columns | Instructions supplied; execution not reported |
| Model training | Successful sample_model job | Not reported |
| Course evaluation | Classification metrics returned | No metric output supplied |
| Separate evaluation | Metrics from later labeled sessions | Proposed query; not executed |
| Invalid TOTAL function | Course error corrected to SUM | Described by course, not independently observed |
| Country predictions | Ten ranked country groups | Query supplied; no output |
| Visitor challenge | Ten ranked visitor groups | Explained and saved; no output |
| Lab completion | Grader confirms completion | Not reported |

## Problems and resolutions to remember

| Issue | Resolution / interpretation |
|---|---|
| Confusing model name with sample data | sample_model is a trained artifact created from labeled rows |
| Predicting the model | Use the model to predict session outcomes |
| Literal lab-start project placeholder | Replace YOUR_PROJECT with the actual project ID everywhere |
| Invalid TOTAL aggregate | Use SUM for numeric binary predictions |
| Evaluating on training source | Add a separate labeled evaluation population |
| 20170631 suffix | Use valid intended endpoint 20170630 |
| july_data includes August 1 | Document the inclusive range or explicitly adjust it |
| Session class counts described as transactions | Label them predicted purchasing sessions |

No unexpected personal failure has been reported for this lab. These notes separate course-provided errors and review observations from actual learner outcomes.

## Future portfolio extension

Record a reproducible training sample, feature availability at prediction time, label checks, class balance, a justified split, heldout metrics, a baseline, and actual prediction output. If using the July period for evaluation, use a later untouched period for a final predictive assessment after model selection; do not describe the evaluated period as an untouched test after tuning on it.

## References

- [ML.PREDICT](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-predict)
- [Logistic regression model creation](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-glm)
