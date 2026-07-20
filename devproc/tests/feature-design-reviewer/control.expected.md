# Expected findings — `control.md`

**Flaw under test:** none. This is the clean control.

## Expected result

No BLOCKING findings and no MAJOR findings.

MINOR findings and SUGGESTIONs are tolerated, but each must be a genuine
observation about this file — not an invented fault.

**Expected verdict:** `READY FOR USER REVIEW`

## Why this file should pass

- **Complete and clear** — every requirement is covered by a sub-task: row
  selection and filters (1), ISO dates, unformatted numbers and column parity
  (2), the control and the filename (3), documentation (4). Every design
  decision carries its reasoning, and the one significant alternative
  (client-side generation) is recorded with why it lost.
- **Delivery criteria** — each sub-task's boxes derive from the agreed strategy;
  each is auditable; the feature-level `/review-branch` is recorded once beneath
  the list rather than repeated per sub-task, as the strategy specifies.
- **Blocking issues** — none: no deferred decisions, no dependency on anything
  that does not exist, and the ordering works (endpoint, then formatting, then
  the control that uses both, then docs).
- **Sub-task quality** — four sub-tasks, each finishable and reviewable in one
  go, each leaving the project working.

## Known soft spots

A reviewer may legitimately raise these; they are MINOR at most and do not fail
the case:

- Sub-task 1's "flat server memory" has no numeric ceiling.
- The `.xlsx` reuse remark in the design touches something explicitly out of
  scope, though it commits to building nothing.
- The design does not name the concrete modules it reuses (the query-builder,
  the column-definition module, the streaming response writer).
- Truncation of a streamed response that fails mid-export is not addressed
  (the requirements do not ask for it).

## Corrections already applied

Three defects found in the first round have been fixed in the baseline; a
BLOCKING or MAJOR finding on any of them now would be a regression in the
fixture, not a pass:

- The design said nothing about where the exported **column set** comes from,
  while taking great care over the equivalent problem for filters.
- The strategy's **manual large-tenant export** was owned by no sub-task, so
  every box could be ticked without it happening.
- Sub-task 1 carried `- [ ] User review: none — no user-visible surface yet`, a
  box that can never legitimately be ticked. Waived categories are now omitted
  and explained once in a feature-level note.
- The design named **CSV serialisation** (quoting, escaping, the header row) as
  a distinct layer that no sub-task tested — the classic way a CSV export
  corrupts a downstream import. Sub-task 2 now owns it.
