# Expected findings — `unwritten-signoff-steps.md`

**Flaw under test:** delivery criteria — a sign-off whose steps are substantial
and non-obvious but written down nowhere. Sub-task 2 gains the box "manual
verification against the finance team's month-end reconciliation procedure
passes", with no steps in the plan and no link to a file that holds them.
Everything else, including `## Design`, is the clean baseline.

## Required findings

A **MAJOR** (or BLOCKING) finding against Sub-tasks → 2 that the
reconciliation-procedure box depends on a procedure whose steps are not written
down anywhere the implementer can find them. Marked `[rewrite]` or `[decision]`
(the second is reasonable: only the user may know the procedure).

## Also acceptable

- A finding that the box is not auditable as worded, provided it also says the
  procedure is unwritten.
- A finding that the box is not derived from the sign-off strategy or belongs
  in a different sub-task (it is a manual check on the whole export).

## Must not report

- Any **BLOCKING or MAJOR** finding against `## Design`, `## Requirements`,
  `## Spec` or `## Sign-off strategy`.
- Any finding about the heading format of `## Sub-tasks`.
- A written-steps finding against any other box: the automated-test boxes are
  self-evident, and the other manual checks are described in the box.

**Expected verdict:** `NEEDS WORK`
