> **Test fixture** for the `feature-spec-reviewer` agent — not a real feature
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

Numbers in the exported file are unformatted (no thousands separators, no
currency symbol) and dates are ISO 8601 (`YYYY-MM-DD`) rather than the
localised display format — matching the shape finance's import step already
expects from every other feed in the reporting pipeline.

The exported columns match the on-screen columns, in the same order, with the
same headings, following the column-parity convention the other export types
in the system already use. The file itself is named `report-<YYYY-MM-DD>.csv`,
using the user's local date at the time of export, the same naming pattern
those other exports follow.

Because the largest tenant runs to around 200,000 rows, nothing in this flow
may hold the full result set in memory in the browser at any point — the same
memory discipline already applied to the dashboard's bulk operations. Out of
scope: Excel (`.xlsx`) export, scheduled or emailed exports, and exporting
anything other than the reports page. This is delivered as a single "Export
CSV" control on the reports page, exporting every row matching the user's
current filters rather than only the current page, for support staff who
currently have to copy report figures to finance by hand.

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

*To be fleshed out by `/feature-design`.*
