> **Test fixture** for the `feature-spec-reviewer` agent — not a real feature
> plan, and not a feature of this repository. See [README.md](README.md).

# Add CSV export to the reports page — Feature Plan

## Requirements

Users have asked for a way to get report data out of the tool, so we should add
an export. Finance are the main consumers and they use spreadsheets, so the
export needs to work well for them. See issue #47 for the full detail of what
they asked for, including the formatting points.

The reports page is the obvious place to put this. It should handle large
reports sensibly.

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
