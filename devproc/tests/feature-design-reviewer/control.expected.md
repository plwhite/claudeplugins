# Expected findings — `control.md`

**Flaw under test:** none. This is the clean control.

## Expected result

No BLOCKING findings and no MAJOR findings.

MINOR findings and SUGGESTIONs are tolerated, but each must be a genuine
observation about this file — not an invented fault.

**Expected verdict:** `READY FOR USER REVIEW`

## Why this file should pass

- **Complete and clear** — every item in `## Spec` is covered by a sub-task: row
  selection and filters (1), ISO dates, unformatted numbers and column parity
  (2), the control and the filename (3), documentation (4). Every design
  decision carries its reasoning, and the one significant alternative
  (client-side generation) is recorded with why it lost.
- **Delivery criteria** — each sub-task's boxes derive from the agreed strategy;
  each is auditable; the strategy's feature-level `/review-branch` and
  `docs-structure-reviewer` gates are materialised as sub-task 5 ("Final
  sign-off criteria"), one box each, rather than repeated on every sub-task —
  with the docs-review box correctly carrying the "(performed at
  `/feature-end`)" annotation.
- **Blocking issues** — none: no deferred decisions, no dependency on anything
  that does not exist, and the ordering works (endpoint, then formatting, then
  the control that uses both, then docs, then the closing gates).
- **Sub-task quality** — five sub-tasks, each finishable and reviewable in one
  go, each leaving the project working; the fifth is the closing checklist of
  gates rather than a work item, which is expected for a "Final sign-off
  criteria" sub-task.

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

Six defects have been found and fixed in the baseline — four in the first
round, and the last two by the 2026-08-10 regression run. A BLOCKING or MAJOR
finding on any of them now would be a regression in the fixture, not a pass:

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
- `## Design` had **no overview**: it opened straight into "### Export happens
  on the server, streamed", leaving the reader to assemble the overall shape
  from four independent decision write-ups. This baseline predates the
  overview-first rule and violated it. A `### Overview` section now opens the
  design, stating the whole pipeline before any decision is justified.

- The `## Sign-off strategy` **Testing** criterion tested nothing about the
  200,000-row memory constraint, although `## Spec` states it as a hard
  requirement and the Documentation criterion already referenced it. A plan
  could satisfy the whole strategy while shipping an export that buffers the
  full result set. Testing now carries "an automated check that a 200,000-row
  export completes with flat memory use", which also makes sub-task 1's
  long-standing "flat server memory" box derive from the strategy instead of
  appearing from nowhere.

  Found by the 2026-08-10 regression, and the same nondeterministic signature as
  the overview defect above: on byte-identical strategy text, `control` and
  `incomplete-spec` reported nothing, `premature-design` reported it at MINOR
  (tolerated), and `deferred-requirements` reported it at MAJOR — which fails
  the "no BLOCKING or MAJOR against an untargeted section" rule and so failed a
  case whose actual flaw the agent had diagnosed correctly. The strategy text is
  shared byte-for-byte with the `feature-spec-reviewer` suite, so the fix was
  applied to both.

  The **overview defect** above shares that signature, and is worth
  understanding rather than just recording. It too was
  **nondeterministic in its effect**:
  this control passed without the overview — the reviewer accepted the first
  subsection as establishing the shape — while `weak-subtask-criteria`, whose
  `## Design` is the same text, drew a MAJOR `[rewrite]` clarity finding for the
  missing overview and so failed its "must not report against `## Design`" rule.
  A defect that fails one case and spares another on identical text makes the
  whole suite unreliable, so the fix is to the fixtures, not to the
  expectations. The overview was added to every case carrying a clean or
  incidentally-mutated `## Design`; `unclear-design` is the deliberate
  exception, since a missing overview is the flaw it exists to test.
