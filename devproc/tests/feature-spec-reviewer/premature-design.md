> **Test fixture** for the `feature-spec-reviewer` agent — not a real feature
> plan, and not a feature of this repository. See [README.md](README.md).

# Add CSV export to the reports page — Feature Plan

## Requirements

Support staff need to hand report figures to finance, who work in spreadsheets.
Today the only route is copying numbers off the reports page by hand.

The work is as follows. Add a `CsvExporter` class in
`src/reports/export/csv_exporter.py`, with a `stream_rows()` generator and a
`format_cell()` static method, and register it in the `ExporterRegistry`
alongside the existing `PdfExporter`. Use the `fast-csv` library rather than the
standard library writer, since benchmarks put it about 40% faster on wide rows.
The reports page gains a button wired to a new `/api/reports/export` endpoint,
which streams the response with `Transfer-Encoding: chunked` so the browser
never holds the whole file. Put the filter-parsing logic in a
`ReportFilterParser` helper so it can be shared with the PDF path later.

The exported columns must match the on-screen columns, in the same order, with
the same headings. Dates must be exported in ISO 8601 (`YYYY-MM-DD`) and numbers
unformatted, because finance's import step expects that.

Out of scope: Excel (`.xlsx`) export, scheduled or emailed exports, and
exporting anything other than the reports page.

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

*To be fleshed out by `/feature-design`.*
