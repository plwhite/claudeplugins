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

### Export happens on the server, streamed

The export is a new server endpoint that streams CSV rows to the client, rather
than being generated in the browser from data the page already holds.

The reporting lead's 200,000-row figure rules out the browser route: the reports
page paginates, so the browser holds only the current page, and fetching all
rows to serialise them client-side would mean holding the entire result set in
memory — exactly what the requirement forbids. Streaming from the server keeps
memory flat on both sides, since rows are written to the response as they are
read from the database.

Rejected alternative: generating the file client-side from an existing paginated
API by fetching every page. This was rejected on the memory constraint above,
and because it would multiply request count on the largest tenants.

### Row selection reuses the existing report query

The export endpoint builds its query with the same query-builder the reports
page already uses, passing the filter set from the request.

The requirement is that the export contains exactly the rows the filters select.
Re-implementing filter interpretation for the export would create a second
definition of what a filter means, which would drift from the on-screen one —
and the drift would be silent, since both would look plausible. Reusing the
builder makes the two definitions the same by construction.

### The column set comes from the page's column definition

The export takes the columns to emit — their order and their headings — from the
same column-definition module the reports page renders from, rather than from a
list maintained in the exporter.

This is the same argument as for filters: a second definition of the column set
would drift from the on-screen one silently, and the requirement is precisely
that the two match. Where the user has reordered or hidden columns, the client
sends the active column set with the request, alongside the filters and the
local date.

### Formatting is a separate layer from serialisation

Cell formatting (ISO dates, unformatted numbers) is a distinct step from CSV
serialisation (delimiters, quoting, the header row).

The formatting rules are a contract with finance's import step and are the most
likely thing to regress; keeping them separate lets them be tested directly on
values, without going through a whole export. It also keeps the CSV writer
generic, so the out-of-scope `.xlsx` exporter can reuse the same formatting if
it is ever built — though nothing is built for that now.

### The filename is set by the client's local date

The response sets `Content-Disposition` with the filename, and the client passes
its local date as a request parameter for that purpose.

The requirement names the user's local date, which the server cannot know: the
server's date and the user's may differ near midnight. Passing it explicitly is
the only way to satisfy the requirement without guessing at a timezone.

## Sub-tasks

1. **Export endpoint with streamed row selection** — the endpoint returns the correct rows for a given filter set, streamed, with flat memory use
   - [ ] Testing: automated tests for filter application (including a filter set spanning more than one page), passing; a 200,000-row export completes with flat server memory
2. **Cell formatting and CSV serialisation** — ISO dates, unformatted numbers, column order/headings matching the screen, and correctly quoted output
   - [ ] Testing: automated tests for ISO date formatting, unformatted numbers, and column order against the on-screen column set, passing
   - [ ] Testing: automated tests for serialisation of values containing commas, quotes and newlines, and for the header row, passing
3. **Reports page export control** — the control appears on the reports page and downloads the file with the correct name
   - [ ] Testing: automated test that the control issues the request with the current filters and the client's local date, passing; one manual export of the largest available test tenant, opened in a spreadsheet with values confirmed correct
   - [ ] User review: the user opens an exported file from a filtered report and confirms it is what finance needs
4. **Help page section and implementation notes** — user-facing documentation of the export, and the memory-constraint record
   - [ ] Documentation: help page section describing the export and its column meanings; `NOTES.md` entry recording how the large-export memory constraint was met

**▶ NEXT:** Sub-task 1

> Feature-level sign-off: one `/review-branch` before `/feature-end`, per the
> sign-off strategy, rather than a code-review box on each sub-task.

> Sub-tasks 1 and 2 carry no user-review box: there is no user-visible surface
> until sub-task 3, where the user review for the feature sits.

> Run `/feature-checkpoint` after each sub-task completes.
