# Expected findings — `unresolved-design-question.md`

**Flaw under test:** blocking issues. The design defers its central decision,
depends on a component whose existence is not established, and orders the
sub-tasks so that the first depends on the third. The sub-task sign-off criteria
are the clean baseline and must not be faulted.

## Required findings

All three of the following. The first must be **BLOCKING**; the other two must
be **BLOCKING or MAJOR** — their substance is what matters, and reasonable
reviewers rank them differently.

1. **Deferred central decision** (BLOCKING) — "Whether the file is streamed from
   the server or assembled in the browser will be settled during
   implementation". The finding must note that this cannot wait: the client-side
   option is the one the 200,000-row constraint rules out, so the claim that
   "both approaches are viable" contradicts the requirements, and the claim that
   "the choice does not affect the rest of the design" is false — the endpoint,
   the sub-tasks, and the filename mechanism all depend on it. Should be marked
   `[decision]`.
2. **Unestablished dependency** (BLOCKING or MAJOR) — the `ReportStreamService`
   "provided by the platform team" is assumed to exist, with no evidence it
   does, and the design leans on it for both cursor management and
   back-pressure. Note that the reviewer *cannot* settle this by searching: the
   fixture describes a different product from the repository the agent is run
   in, so absence of the component here is not evidence. The correct answer is
   to flag it as unconfirmed and ask, not to assert it is missing.
3. **Impossible ordering** (BLOCKING or MAJOR) — sub-task 1 builds the control
   that "calls the export endpoint", but the endpoint is not built until
   sub-task 3. Sub-task 1 cannot be completed, let alone signed off by a user
   opening an exported file, before sub-task 3 exists.

## Also acceptable

- A finding that sub-task 1's user-review box cannot be satisfied at the point
  the sub-task is meant to finish (a consequence of the ordering flaw, and a
  legitimate way to report it).
- A finding that the deferred decision makes sub-task 3's "flat server memory"
  test meaningless if the browser option is later chosen.

## Must not report

- Any **BLOCKING or MAJOR** finding against the sub-task sign-off criteria as
  such — they are the clean baseline wording. Reporting that a criterion cannot
  be *met* because of the ordering flaw is fine; faulting how it is *worded* is
  not.
- Any finding faulting `## Requirements` or `## Sign-off strategy`.

**Expected verdict:** `NEEDS WORK`
