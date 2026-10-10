# Looker — Merging Results from Different Explores

Date organized: 2026-10-10
Goal: create Flights and Airports queries, merge their results by city, edit the primary query, and save the merged table to a dashboard.

## Files and evidence

- [Original instructions](Different%20Explores%20in%20Looker.txt), preserved unchanged.
- [Learner screenshot](Different%20Explores%20in%20Looker.jpg), showing the merge configuration and returned table.
- [Earlier airport visualization study](README.md).
- [Flight export notes](FLIGHT-EXPORTS.md), covering two separately supplied tab-separated result files.

![Merged Results screenshot](Different%20Explores%20in%20Looker.jpg)

Status: the screenshot demonstrates a configured merged-results view and flight records. It does not verify matched airport elevation values or the final dashboard save. No grader result was supplied.

## Scenario and approach

The course combines cancellation data from FAA Flights with airport elevation information from FAA Airports when the needed information is not available together in one Explore.

The supplied instructions recommend a single modeled Explore when suitable relationships already exist. Merged Results is an alternative for combining separately queried results using dimensions with matching values. No new database join, SQL model, or LookML definition was supplied or implemented here.

The first query is the primary query. Each added query matches against that primary query, rather than another added query. The course states a maximum of 5,000 rows from each source query; review the actual query limits and returned rows before interpreting the merged table as complete.

## Task 1 — Create the primary Flights query

1. Open **Explore → FAA → Flights**.
2. Select **Flight Details → Carrier** and **Flight Num**.
3. Select **Aircraft Origin → City**.
4. Select **Flight Details → Measures → Cancelled Count**.
5. Add **Arrival Date → Year** as a filter.
6. Set the filter to **is in the year 2000**.
7. Run and inspect the results.

This groups cancellation data by the selected attributes. A flight number can recur across dates and carriers; do not treat a row as one unique scheduled flight without inspecting model grain. The year filter uses Arrival Year as specified by the course, not Departure Year.

## Task 2 — Add the Airports source query

1. Open the primary Explore settings and choose **Merge Results**.
2. Choose **Airports**.
3. Select **City** and **Average Elevation**.
4. Run the source query independently and inspect whether it returns non-null elevations.
5. Save it into the merged results.

Both source queries need a dimension with values that match exactly. Similar-looking fields can contain different formats, capitalization, spaces, or geographic definitions. The course's date example contrasts a full date with a month label; these are not the same match grain.

## Task 3 — Review rules and run the merge

Set the rule to:

| Primary Flights dimension | Airports dimension |
|---|---|
| Aircraft Origin City | Airports City |

Run the merge, inspect the results, and sort Airports Average Elevation descending as the course requests. Explore visualization options before selecting the final table.

City is a convenient course match key, but may not uniquely identify a geographic location or airport. Multiple airports can share a city and cities can share names. An airport identifier or city plus appropriate geographic context may be a better production key if available; that is a proposed extension, not a change performed here.

A city-level average also does not establish the elevation of the specific origin airport for every flight record.

## Task 4 — Edit the primary query

1. In Source Queries, locate **Flights**, labeled **Primary**.
2. Open its settings and choose **Edit**.
3. Add **Aircraft Destination → City**.
4. Run, then save the modified primary query.
5. Recheck the merge rule after the edit.

Adding destination city changes the primary grouping. It does not mean the Airports merge should switch to destination city. Retain the origin-city rule unless intentionally answering a different question.

## Task 5 — Save the merged table

1. Select **Table** under Visualization.
2. Open the merged-results settings and choose **Save to Dashboard**.
3. Set the tile title to **Flight Cancellations & Elevation**.
4. Create dashboard **Airport Data**.
5. Save and open the dashboard link, or find it in Shared Folders.
6. Verify the tile exists and that its source queries, filters, and merge rule are retained.

These are course instructions. The screenshot is from the merged-results screen, not the saved dashboard, so successful save is not yet evidenced.

## Observed result and follow-up

The supplied JPEG shows:

- Flights marked Primary and Airports as the added source.
- Aircraft Origin City matched to Airports City.
- Arrival Year 2000 and the added Aircraft Destination City field.
- Flight 110, carrier AS, origin ANCHORAGE, destination SEATTLE, displayed Cancelled Count 88.
- Null symbols in the visible Airports Average Elevation cells.
- Sorting indicated on Cancelled Count, rather than verified descending elevation sorting.

The null elevations do not establish the cause. They could reflect unmatched city values, missing source measures, or incomplete source results. No failed-job message or confirmed root cause was supplied.

### Resolution checks for future reuse

1. Run the Airports query by itself; confirm the selected cities and whether elevation is populated.
2. Compare the exact Airports City values with primary origins such as ANCHORAGE and ATLANTA.
3. Check source query filters and limits, including possible truncation.
4. Confirm the merge uses origin city after adding destination city.
5. Test a known matching city and inspect the merged measure.
6. Only describe the elevation merge as validated after non-null matched values are reconciled against the source query.

These are proposed diagnostics, not completed fixes. Do not substitute zero for missing elevations.

## Validation

| Check | Expected | Actual evidence |
|---|---|---|
| Primary query | Flights query with year 2000 | Screenshot shows Primary label and year values |
| Merge rule | Origin city matched to Airports city | Confirmed visually |
| Destination edit | Destination city present | Confirmed visually |
| Elevation matching | Source elevations populated on valid matches | Visible cells are null; unresolved |
| Elevation sort | Descending average elevation | Not verified; screenshot indicates cancellation sort |
| Dashboard save | Tile in Airport Data | No dashboard artifact supplied |
| Lab completion | Course checks pass | No grader result supplied |

## Learning and limitations

The evidence demonstrates configuring separate Explore queries, choosing a merge key, and editing the primary grouping. It does not yet demonstrate a complete, validated elevation comparison. Keep this as course practice and distinguish screenshot evidence from expected course outcomes.

For future evidence, save both source-query results, match-key examples, unmatched-row counts, row limits, a non-null reconciliation, and the final dashboard screenshot. Never include lab passwords or temporary credentials.
