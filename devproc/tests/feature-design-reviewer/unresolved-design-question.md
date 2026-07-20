> **Test fixture** for the `feature-design-reviewer` agent — not a real feature
> plan, and not a feature of this repository. See [README.md](README.md).

# Add CSV export to the reports page — Feature Plan

## Requirements

From issue #47, "Users cannot get report data out of the tool" (verbatim):

> Support staff regularly need to hand report figures to finance, who work in
> spreadsheets. Today the only route is copying numbers off the reports page by
> hand, which is slow and error-prone.
>
> We want a CSV export from the reports page:
> - A single "Export CSV" control on the reports page, exporting exactly the
>   rows currently displayed, with the filters the user has applied.
> - The exported columns must match the on-screen columns, in the same order,
>   with the same headings.
> - Dates must be exported in ISO 8601 (`YYYY-MM-DD`), not the localised display
>   format, because finance's import step expects that.
> - Numbers must be exported unformatted (no thousands separators, no currency
>   symbol) for the same reason.
> - The file should be named `report-<YYYY-MM-DD>.csv` using the date of export.
>
> Out of scope for this issue: Excel (`.xlsx`) export, scheduled or emailed
> exports, and exporting anything other than the reports page.

From a comment on the issue by the reporting lead:

> Worth knowing that reports can be large — the biggest tenant has around
> 200,000 rows. Whatever we do should not hold the whole export in memory in the
> browser.

"The rows currently displayed" means every row matching the user's current
filters, not only the current page of results. The date in the filename is the
user's local date at the time of export.

## Sign-off strategy

- **Testing** — Automated tests for the row-selection and formatting logic
  (filter application, ISO date formatting, unformatted numbers, column order),
  all passing. Plus one manual export of the largest available test tenant,
  confirming the file opens in a spreadsheet with correct values.
- **Documentation** — User-facing help page section describing the export and
  its column meanings, plus a `NOTES.md` entry recording how the large-export
  memory constraint was met.
- **Code review** — One `/review-branch` before `/feature-end`.
- **User review** — The user opens an exported file and confirms it is what
  finance needs, before the export sub-task is marked complete.

## Design

### Where the file is generated

Whether the file is streamed from the server or assembled in the browser from
the existing paginated API will be settled during implementation, once we can
see how the report query performs under load. Both approaches are viable and the
choice does not affect the rest of the design.

### Row streaming

Server-side streaming, if chosen, is done through the `ReportStreamService`
provided by the platform team, which handles cursor management and back-pressure
so the export does not need its own.

### Row selection reuses the existing report query

The export builds its query with the same query-builder the reports page already
uses, passing the filter set from the request. Re-implementing filter
interpretation would create a second definition of what a filter means, which
would drift silently from the on-screen one.

### The column set comes from the page's column definition

The export takes the columns to emit — their order and their headings — from the
same column-definition module the reports page renders from, rather than from a
list maintained in the exporter. A second definition of the column set would
drift from the on-screen one silently, and the requirement is precisely that the
two match.

### Formatting is a separate layer from serialisation

Cell formatting (ISO dates, unformatted numbers) is a distinct step from CSV
serialisation (delimiters, quoting, the header row). The formatting rules are a
contract with finance's import step and are the most likely thing to regress;
keeping them separate lets them be tested directly on values.

### The filename is set by the client's local date

The response sets the filename from a local date the client supplies, since the
server cannot know the user's timezone and the two dates differ near midnight.

## Sub-tasks

1. **Reports page export control** — the control appears on the reports page, calls the export endpoint with the current filters and the client's local date, and downloads the returned file
   - [ ] Testing: automated test that the control issues the request with the current filters and the client's local date, and that the returned file downloads with the correct name, passing; one manual export of the largest available test tenant, opened in a spreadsheet with values confirmed correct
   - [ ] User review: the user opens an exported file from a filtered report and confirms it is what finance needs
2. **Cell formatting and CSV serialisation** — ISO dates, unformatted numbers, column order/headings matching the screen, and correctly quoted output
   - [ ] Testing: automated tests for ISO date formatting, unformatted numbers, and column order against the on-screen column set, passing
   - [ ] Testing: automated tests for serialisation of values containing commas, quotes and newlines, and for the header row, passing
3. **Export endpoint with streamed row selection** — the endpoint returns the correct rows for a given filter set, streamed, with flat memory use
   - [ ] Testing: automated tests for filter application (including a filter set spanning more than one page), passing; a 200,000-row export completes with flat server memory
4. **Help page section and implementation notes** — user-facing documentation of the export, and the memory-constraint record
   - [ ] Documentation: help page section describing the export and its column meanings; `NOTES.md` entry recording how the large-export memory constraint was met

**▶ NEXT:** Sub-task 1

> Feature-level sign-off: one `/review-branch` before `/feature-end`, per the
> sign-off strategy, rather than a code-review box on each sub-task.

> Run `/feature-checkpoint` after each sub-task completes.
