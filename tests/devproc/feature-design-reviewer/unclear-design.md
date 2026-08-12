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

## Spec

The reports page gains a CSV export, so support staff can hand report figures
to finance without transcribing them by hand.

A single "Export CSV" control on the reports page exports every row matching
the user's current filters — not just the current page — as a downloaded CSV
file.

The export must:

- Include exactly the on-screen columns, in the same order, with the same
  headings.
- Format dates as ISO 8601 (`YYYY-MM-DD`), not the localised display format,
  and format numbers unformatted (no thousands separators, no currency
  symbol) — finance's import step expects both.
- Name the file `report-<YYYY-MM-DD>.csv`, using the user's local date at the
  time of export.
- Never hold the whole export in memory in the browser. The largest tenant has
  around 200,000 rows, so the export must handle that scale without loading
  every row into the browser at once.

Out of scope: Excel (`.xlsx`) export, scheduled or emailed exports, and
exporting anything other than the reports page.

## Sign-off strategy

- **Testing** — Automated tests for the row-selection and formatting logic
  (filter application, ISO date formatting, unformatted numbers, column order),
  all passing, and an automated check that a 200,000-row export completes with
  flat memory use. Plus one manual export of the largest available test tenant,
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

### Formatting and serialisation

Cell formatting — ISO dates, unformatted numbers — is kept separate from CSV
serialisation (delimiters, quoting, the header row), because the formatting
rules are a contract with finance's import step and are the most likely thing
to regress; testing them directly on values, without going through a whole
export, is only possible if they are not entangled with the writer. The writer
itself also backs a future `.xlsx` exporter, though nothing is built for that
yet, and it is what the streamed rows referenced below eventually pass through
before they reach the client.

### Selection and columns

The same drift risk that applies to filters also applies to columns:
re-implementing either would create a second definition that could silently
diverge from what the screen shows, so both are read from the artefacts the
reports page itself already uses — the query-builder for rows, the
column-definition module for the column set, order and headings — and the
client sends its active column set alongside the filters and local date,
since a user may have reordered or hidden columns from the default.

### Streaming and the filename

Rather than being generated in the browser from data the page already holds,
which would mean holding the reporting lead's cited 200,000-row figure
entirely in memory — exactly what was ruled out — the rows referenced above
are written to the response as they are read from the database, and the
response's `Content-Disposition` header carries a filename built from the
client's local date, passed explicitly because the server cannot otherwise
know which timezone the user is in. Generating the file client-side from an
existing paginated API was considered and set aside for the same memory
reason, and because it would multiply request count on the largest tenants.

### Where the control lives

The "Export CSV" control sits in the reports page toolbar, to the right of the
existing filter controls, and is what starts the endpoint request described
above.

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
5. **Final sign-off criteria** — end-of-feature gates for this feature, per `## Sign-off strategy`
   - [ ] Code review (agent): /review-branch over all changed files
   - [ ] Docs review (agent): docs-structure-reviewer over the updated docs (performed at `/feature-end`)

**▶ NEXT:** Sub-task 1

> Sub-tasks 1 and 2 carry no user-review box: there is no user-visible surface
> until sub-task 3, where the user review for the feature sits.

> Run `/feature-checkpoint` after each sub-task completes.
