# Expected findings — `unexplained-design.md`

**Flaw under test:** completeness and clarity of the design. Every decision is
asserted without reasoning, no rejected alternative is recorded, and the
filename requirement is covered nowhere. The `## Requirements` and `## Sign-off
strategy` sections are the clean baseline and must not be reviewed.

Sub-task 3 differs from the control only by the removal of the filename and
local-date wording — that removal is part of this case's single flaw (the
uncovered requirement), not a second one.

## Required findings

**Both** of:

1. **Uncovered requirement** at **BLOCKING** severity: the requirement that the
   file be named `report-<YYYY-MM-DD>.csv` using the user's local date is
   addressed by no part of the design and by no sub-task. The finding must
   identify the filename requirement specifically.
2. **Missing rationale** at **MAJOR** or higher: the design states decisions
   without saying why — "It will use the streaming response writer", the reuse
   of the existing query-builder, the formatting/serialisation split, and the
   toolbar placement are all bare assertions. A single finding covering the
   section as a whole is acceptable, provided it names at least two examples.

The findings should also raise at least one of:

3. **No rejected alternatives** — client-side generation is the obvious
   alternative for an export feature and is not mentioned, so the user cannot
   tell whether it was considered.
4. **The memory constraint is not traced** — the design never connects "streams
   CSV rows" to the 200,000-row constraint that motivates it, so an implementer
   cannot tell that flat memory use is a requirement rather than an incidental
   property.
5. **Control placement is unexplained** — "to the right of the existing filter
   controls" is a decision presented with neither reasoning nor an alternative.

## Must not report

- Any **BLOCKING or MAJOR** finding against `## Requirements` or `## Sign-off
  strategy`, which are the clean baseline. MINOR findings and SUGGESTIONs there
  are tolerated.
- Any finding that supplies a replacement design of the reviewer's own rather
  than naming what is missing.

**Expected verdict:** `NEEDS WORK`
