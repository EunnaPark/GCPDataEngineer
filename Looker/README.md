# Looker — Airport Measures and Visualizations

Date organized: 2026-10-09
Source: [Google Skills lab](https://www.skills.google/paths/1336/course_templates/628/labs/593325), with supplied instructions preserved in [Looker.txt](Looker.txt).

Goal: use the FAA Airports Explore to visualize an aggregate measure, combine dimensions and measures, and save two tiles to a dashboard.

Status: course instructions organized for study. No learner execution results, screenshots, dashboard exports, or grader outcomes have been supplied for this Looker lab.

## Scenario

An analyst wants an overview of airport facility elevation and a comparison by facility type. The first tile shows average elevation across all airport facilities. The second compares facility types using average elevation and facility count.

These are descriptive visualizations. They do not establish flight performance, operational safety, or a causal relationship between elevation and facility type.

## Service choice and concepts

The course specifies Looker and provides an existing FAA semantic model. The learner selects modeled fields in Explore rather than building a BigQuery table or writing a new LookML model.

- **Dimension:** an attribute used to group or describe data, such as Facility type.
- **Measure:** a modeled aggregation, such as Average elevation or Count. Inspect its definition before assuming its exact SQL, grain, treatment of NULL, or distinct-count behavior.
- **Explore:** the interface for selecting fields, filtering, running a query, and visualizing the results.
- **Dashboard:** a saved collection of tiles.

Looker is separate from Data Studio, formerly Looker Studio. The earlier Data Studio sales_report exercise belongs to a different tool. No architecture comparison or new LookML development was performed in this lab record.

## Setup and credentials

Start the lab only when ready to complete it within the allocated time. Open the provided Looker instance and use the temporary Looker username and password shown in Lab Details. The course explicitly distinguishes those credentials from the training-platform login and personal Looker accounts.

No credentials are stored in this repository. The words Username and Password in the original text are placeholders, not actual account values.

## Task 1 — Visualize the first measure

### Question / objective

Determine average elevation across all airport facilities and display it as a single-value visualization. Save it to a new Airports/Flights dashboard.

### Course procedure

1. Open **Explore → FAA → Airports**.
2. Under **Airports → Measures**, select **Average elevation**.
3. Click **Run** and inspect the result.
4. Expand **Visualization** and choose **Single value**.
5. Open visualization settings, then **Edit → Style**.
6. Choose a value color, enable **Show title**, and set a title override.
7. Close visualization settings.
8. Use the settings menu beside Run and select **Save → To an existing dashboard**.
9. Set the visualization title to **Average elevation**.
10. Choose **New Dashboard**, name it **Airports/Flights**, confirm, and save the tile.
11. Check lab progress if required by the course.

### Why this result is different from Task 2

Selecting a measure without a grouping dimension produces an overall aggregate for the current filters and modeled query. Adding Facility type in Task 2 changes the grouping. The average of the grouped averages generally does not equal the overall average when group sizes differ.

Record the measure definition, elevation units, source coverage, and active filters before interpreting the number. The supplied notes do not state the units or numerical result.

## Task 2 — Visualize dimensions and measures

### Question / objective

Identify the five facility types with the highest average elevation. Show both average elevation and the total facility count in a horizontal bar chart, then save it to the same dashboard.

### Course procedure and ranking clarification

1. Return to **Explore → FAA → Airports**.
2. Select **Airports → Dimensions → Facility type**.
3. Select **Airports → Measures → Average Elevation** and **Count**.
4. Set **Row limit = 5**.
5. To meet the stated highest-average-elevation objective, explicitly sort **Average elevation descending** before running. This is a clarification: the supplied procedure sets a limit but does not explicitly describe the sort.
6. Click **Run** and inspect the five groups.
7. Expand Visualization and choose **Bar** for a horizontal chart.
8. Open visualization settings and enable **Values → Value labels**.
9. Open **Y** settings and inspect which series are assigned to each axis.
10. The supplied text says to drag the Airports series to Top Axes, leave Average elevation on Bottom Axes, and name Bottom 1 Count. Inspect the actual series and rendered axes before applying those labels: the written axis name appears inconsistent with the described assignment.
11. Label the count axis **Count** and the elevation axis **Average elevation**, including confirmed units when known. Treat this as a proposed correction rather than a verified completed change.
12. Save the visualization as **Average elevation by facility type** to **Airports/Flights**.
13. Check lab progress if required.

### Interpretation and chart checks

The two measures have different meanings and potentially different units. Separate axes can show both, but bar lengths on different scales are not directly comparable. Confirm series colors, labels, and axis assignment. If the chart is difficult to interpret, separate charts are an alternative for a future revision; the course exercise requests a combined chart.

A row limit of five alone returns five rows under the existing ordering. It does not guarantee the five largest average values. Inspect the result table ordering, including ties, before describing the chart as top five.

Count is a modeled measure. Verify whether it counts facilities, distinct facilities, or joined rows rather than inferring its exact definition from the label.

## Validation

| Check | Expected | Actual evidence |
|---|---|---|
| Lab login | Correct temporary Looker account accesses provided instance | Not reported |
| Overall measure | One aggregate displayed in Single value | Course procedure only |
| Dashboard | Airports/Flights contains Average elevation tile | Not reported |
| Grouping | One result row per selected Facility type | Not independently executed |
| Ranking | Descending average elevation, five returned groups | Explicit sort recommended; result pending |
| Combined chart | Both measures displayed with accurate axis names | Axis instructions require review; no screenshot supplied |
| Saved second tile | Average elevation by facility type in same dashboard | Not reported |
| Course completion | Lab checks pass | No grader outcome supplied |

## Problems and resolutions

No unexpected runtime error has been reported for this lab. These are instruction-review points, not invented execution incidents:

| Potential issue | Action |
|---|---|
| Wrong login account | Use the temporary credentials for the provided Looker instance |
| Five rows mistaken for highest five | Explicitly sort the average-elevation measure descending |
| Count label applied to elevation axis | Inspect series assignment and label each axis by its actual measure |
| Group averages interpreted as overall average | Use the overall modeled measure and inspect how NULLs and group sizes are handled |
| Dashboard save assumed successful | Open the dashboard and verify both tile titles and their queries |

## Future reuse and evidence to add

Use [REUSE-CHECKLIST.md](REUSE-CHECKLIST.md) when repeating the exercise. Save a dashboard screenshot or export, the overall measure value, the top-five table, active filters, elevation units, measure definitions, and lab outcome. Never save temporary credentials.

This is a course study record. It currently demonstrates the intended Explore workflow, not independently verified analytical findings or a newly developed semantic model. Original SQL and LookML were not supplied, so this folder does not invent replacement code for the existing model.

## Related study

The separate [Data Studio folder](../Data%20Studio/README.md) documents the BigQuery sales_report dashboard and its resolved connection issue. That issue is not assumed to apply to this Looker instance.
