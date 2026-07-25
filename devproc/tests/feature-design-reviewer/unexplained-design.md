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
- **Docs review** — One agent docs review (`docs-structure-reviewer`) over the
  updated docs at `/feature-end`.
- **Code review** — One agent `/review-branch` before `/feature-end`.
- **User review** — The user opens an exported file and confirms it is what
  finance needs, before the export sub-task is marked complete.

## Design

### Server-side export

The export is a new server endpoint that streams CSV rows to the client. It will
use the streaming response writer.

### Row selection

The export endpoint builds its query with the existing query-builder, passing
the filter set from the request.

### Columns

The export takes its column set, order and headings from the page's
column-definition module. The client sends the active column set with the
request.

### Formatting

Cell formatting is a separate layer from CSV serialisation. Formatting handles
dates and numbers; serialisation handles delimiters, quoting and the header row.

### Control placement

The "Export CSV" control goes in the reports page toolbar, to the right of the
existing filter controls.

## Sub-tasks

1. **Export endpoint with streamed row selection** — the endpoint returns the correct rows for a given filter set, streamed, with flat memory use
   - [ ] Testing: automated tests for filter application (including a filter set spanning more than one page), passing; a 200,000-row export completes with flat server memory
2. **Cell formatting and CSV serialisation** — ISO dates, unformatted numbers, column order/headings matching the screen, and correctly quoted output
   - [ ] Testing: automated tests for ISO date formatting, unformatted numbers, and column order against the on-screen column set, passing
   - [ ] Testing: automated tests for serialisation of values containing commas, quotes and newlines, and for the header row, passing
3. **Reports page export control** — the control appears on the reports page and downloads the file
   - [ ] Testing: automated test that the control issues the request with the current filters, passing; one manual export of the largest available test tenant, opened in a spreadsheet with values confirmed correct
   - [ ] User review: the user opens an exported file from a filtered report and confirms it is what finance needs
4. **Help page section and implementation notes** — user-facing documentation of the export, and the memory-constraint record
   - [ ] Documentation: help page section describing the export and its column meanings; `NOTES.md` entry recording how the large-export memory constraint was met
5. **Final sign-off criteria** — end-of-feature gates for this feature, per `## Sign-off strategy`
   - [ ] Code review (agent): /review-branch over all changed files
   - [ ] Docs review (agent): docs-structure-reviewer over the updated docs (performed at `/feature-end`)

**▶ NEXT:** Sub-task 1

> Sub-tasks 1 and 2 carry no user-review box: there is no user-visible surface
> until sub-task 3, where the user review for the feature sits.

> Run `/feature-checkpoint` after each sub-task completes.
