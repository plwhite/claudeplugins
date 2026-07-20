# Expected findings — `weak-subtask-criteria.md`

**Flaw under test:** delivery criteria. The sub-task sign-off boxes are vague,
missing, or weaker than the agreed strategy. The `## Design` section is the
clean baseline and must not be faulted; `## Requirements` and `## Sign-off
strategy` are context and are not reviewed.

## Required findings

Findings at **BLOCKING** or **MAJOR** severity covering **all four** of:

1. **Sub-task 1 testing is not auditable** — "tests added for the endpoint" has
   no yes/no point, and drops the strategy's specifics (filter application, the
   200,000-row memory check).
2. **Sub-task 2 has no sign-off criteria at all** — no boxes, so nothing gates
   it, even though the strategy requires automated tests of exactly the
   formatting rules this sub-task implements.
3. **Sub-task 3 erodes the agreed user review** — the strategy requires the user
   to open an exported file and confirm it; the sub-task records "User review:
   none" with no justification, and this is the only sub-task producing a
   user-visible export. Its testing box ("the control works") is also not
   auditable.
4. **Sub-task 4 documentation is not auditable** — "docs updated" names neither
   the help page section nor the `NOTES.md` entry the strategy requires.

A single finding may cover more than one of these only if it names each
explicitly.

## Also acceptable

- A finding that, taken together, the criteria are systematically weaker than
  the strategy agreed at `/feature-spec` — i.e. the strategy is being eroded
  rather than applied.
- A finding that the manual large-tenant export from the strategy is owned by no
  sub-task.

## Must not report

- Any **BLOCKING or MAJOR** finding against `## Design`, which is the clean
  baseline. MINOR findings and SUGGESTIONs there are tolerated.
- Any finding faulting the absence of per-sub-task code-review boxes: the
  strategy puts code review at feature level and the plan records it beneath the
  sub-task list.

**Expected verdict:** `NEEDS WORK`
