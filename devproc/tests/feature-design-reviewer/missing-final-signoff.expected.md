# Expected findings — `missing-final-signoff.md`

**Flaw under test:** delivery criteria — specifically the "end-of-feature gates
are materialised, not left in strategy prose" check. `## Requirements`, `##
Sign-off strategy`, `## Design`, and sub-tasks 1–4 of `## Sub-tasks` are all
clean baseline text and must not be faulted. The flaw is that the sub-task list
stops at 4: the strategy's `/review-branch` code review and
`docs-structure-reviewer` docs review are named only in the trailing prose note
("Feature-level sign-off: …"), with no "Final sign-off criteria" (or
equivalently named) sub-task materialising them as checkboxes.

## Required findings

One finding, at **BLOCKING or MAJOR** severity, identifying that the strategy's
end-of-feature gates have no corresponding sub-task:

1. Both the feature-wide **`/review-branch` code review** and the
   **`docs-structure-reviewer` docs review** are left in the prose note rather
   than materialised as checkboxes in a final sub-task. The finding must name
   both gates, or name the missing sub-task generically in a way that makes
   clear both gates are affected — a finding that catches only one of the two
   is incomplete.
2. The recommendation should be to add a final sub-task — e.g. "Final sign-off
   criteria" — with one checkbox per gate (something like `Code review
   (agent): /review-branch over all changed files` and `Docs review (agent):
   docs-structure-reviewer over the updated docs (performed at
   `/feature-end`)`), replacing the prose note.

## Also acceptable

- A finding that also notes the "(performed at `/feature-end`)" annotation
  convention for whichever box `/feature-end` would perform, as part of
  describing what the recommended sub-task should look like.
- Two separate findings, one per gate, that together identify both missing
  checkboxes and recommend the "Final sign-off criteria" sub-task — provided
  neither on its own is so narrow that it implies the other gate is already
  handled correctly.

## Must not report

- Any **BLOCKING or MAJOR** finding against `## Requirements`, `## Sign-off
  strategy`, `## Design`, or sub-tasks 1–4 of `## Sub-tasks`, which are the
  clean baseline. MINOR findings and SUGGESTIONs there are tolerated.
- A finding that the plan needs *per-sub-task* code-review or docs-review
  boxes on sub-tasks 1–4. The strategy correctly puts these two gates at
  feature level; the defect is that the feature-level gates are not
  materialised as an explicit sub-task, not that they are missing from every
  ordinary sub-task.

**Expected verdict:** `NEEDS WORK`
