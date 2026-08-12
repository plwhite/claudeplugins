# Expected findings — `premature-design.md`

**Flaw under test:** scope discipline. The `## Spec` section specifies *how* —
class names, file paths, method names, a library choice, a transport mechanism
— rather than *what*, pre-empting `/feature-design`. `## Requirements` is the
clean control text (verbatim issue capture) and the sign-off strategy is the
clean one from `control.md`; neither must be faulted.

*(Relocated 2026-08-09: this flaw previously lived in `## Requirements`, which
`feature-spec-reviewer` no longer reviews as the statement of what the feature
must do. `## Requirements` now carries the clean verbatim issue text and the
implementation detail moved into `## Spec`.)*

## Required findings

At least one finding against `## Spec` at **MAJOR** severity, marked
`[rewrite]`, reporting that implementation detail has been written into the
specification and naming at least three of the specifics at fault:
`CsvExporter`, `src/reports/export/csv_exporter.py`, `stream_rows()` /
`format_cell()`, `ExporterRegistry`, the `fast-csv` library choice,
`/api/reports/export`, `Transfer-Encoding: chunked`, or `ReportFilterParser`.

The recommendation must be to move the detail to `## Design` (or drop it),
restating the underlying requirement — that the export must not hold the whole
file in memory — as a *what*.

The findings should also raise at least one of:

- **A design decision presented as a requirement** — the `fast-csv` choice comes
  with a benchmark justification, which is a design argument, and the source of
  the constraint is not attributed to the user or an issue.
- **Speculative generality** — `ReportFilterParser` exists "so it can be shared
  with the PDF path later", which is neither a requirement nor in scope.

## Must not report

- Any **BLOCKING or MAJOR** finding against `## Requirements` or `## Sign-off
  strategy`, which are the clean control text. MINOR findings and SUGGESTIONs
  there are tolerated.
- Any finding faulting the absence of a design section.

**Expected verdict:** `NEEDS WORK` — a MAJOR finding of any kind, `[rewrite]`
included, means the spec is not ready as it stands. Reporting the finding
correctly but returning `READY FOR USER REVIEW` is a failed case.
