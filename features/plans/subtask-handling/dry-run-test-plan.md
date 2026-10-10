# Dry-run test plan — `subtask-handling`, sub-task 6

This is the test plan behind sub-task 6's testing box in
[`../subtask-handling.md`](../subtask-handling.md). It checks that the changed
skills actually produce what `## Spec` points 1–5 require when they run, and not
only that the prose reads correctly. It is a separate file because it has too
many steps to fit under a checkbox (Spec point 3).

All runs use the real CLI against a throwaway workspace **outside `/workspace`**,
so nothing is written into this repository's `features/`. Record each step's
outcome as a note under sub-task 6 in the plan file. Anything non-obvious also
goes in `NOTES.md`.

## Preconditions

1. All earlier sub-tasks are complete.
2. Refresh the installed plugin from the repo:
   `rm -rf /home/claude/claudeplugins/devproc && cp -a /workspace/devproc /home/claude/claudeplugins/devproc`.
   Then confirm `diff -r /workspace/devproc /home/claude/claudeplugins/devproc`
   prints nothing. Without this step the runs test the old text (`NOTES.md`,
   "`/home/claude/claudeplugins` is a live plugin copy").

## Setup

3. Create the scratch workspace: `mkdir /tmp/sth-dryrun && cd /tmp/sth-dryrun && git init`.
4. Run `/feature-init` there:
   `claude -p --permission-mode bypassPermissions "/devproc:feature-init"`.

## Part A — what `/feature-design` writes (Spec points 1–4)

5. Specify a small feature whose sub-tasks will need all three judgement
   calls. Use a feature that documents a multi-step procedure and then tests
   it, e.g. "Add a backup script `backup.sh` with a README section describing
   how to run and restore from it". Run `/feature-spec` with that description
   and the instruction to run unattended. Accept whatever sign-off strategy it
   proposes. If it stops to ask a question, answer it in a follow-up
   `claude -p --continue` and record that it asked.
6. Run `/feature-design` on that feature, unattended through design only (say
   "do not begin implementation"), saving stdout to
   `/tmp/sth-dryrun/design-report.txt` (append the output of any follow-ups).
   If it stops to ask a question, answer it in a follow-up
   `claude -p --continue` and record that it asked. Checks (3) and (4) below
   are judged against this saved report.
7. Check the resulting plan file against each of the following, recording pass
   or fail for each:
   - **(1a)** Every sub-task under `## Sub-tasks` is a `### N. Name` heading,
     including "Final sign-off criteria" if present.
   - **(1b)** `▶ NEXT:` is a single line at the top of `## Sub-tasks`, before
     the first sub-task heading.
   - **(2)** In every sub-task, the boxes are in the order the work would be
     done. No box depends on one listed after it.
   - **(3)** Any sign-off with non-obvious steps has them written down, inline
     or in a linked file under `features/plans/<slug>/`. The run's final report
     states which it chose for each.
   - **(4)** Pass if the README sub-task is docs-first, with its docs review
     box ahead of the boxes for the code (or the docs work split into its own
     sub-task ahead of the code), and named in the report. Also pass if it is
     not docs-first and the session either asked the user or gave a reason.
     Fail if it is not docs-first and the session neither asked nor gave a
     reason.

## Part B — changing the sub-task list (Spec point 5)

8. Do work that genuinely meets sub-task 1's criteria (`/feature-checkpoint`
   refuses ticked boxes it cannot verify; see `NOTES.md`), tick its boxes, and
   run `/feature-checkpoint`, so the plan is in a realistic mid-feature state. Check that sub-task 1's heading now
   ends `✓ (YYYY-MM-DD)`, and that `▶ NEXT:` is still the first line of
   `## Sub-tasks`, now naming sub-task 2.
9. **Significant, unforeseen work.** In a `--continue` session, tell it:
   "While doing sub-task 2, we found the restore path also needs a
   checksum-verification step. Record this." Do not say how to classify it.
   Record what the session chose. The expected choice is a new sub-task. Then
   check:
   - it is added as a new lettered sub-task (`### 2a. …`), and later
     sub-tasks are not renumbered;
   - it has its own sign-off boxes, derived from the strategy and ordered;
   - the session states that it chose a new sub-task, and puts the new boxes
     to the user for agreement instead of treating them as agreed.
10. **Minor fix.** In a `--continue` session, tell it: "While doing sub-task
    2, I also fixed a typo in an unrelated usage message. Record this." Do not
    say how to classify it. Record what the session chose. The expected choice
    is a fix in passing. Then check:
    - no new sub-task is created;
    - a note is added under sub-task 2 recording the fix;
    - the session states that it treated this as a fix in passing.

## Teardown

11. `rm -rf /tmp/sth-dryrun`.

## Not covered here

The `dev-process-manager`'s unattended behaviour (stopping or carrying on when
a new sub-task arises inside a boundary) is not dry-run. Simulating an
autonomy boundary with teammates is out of proportion to a prose change. The
manager's wording is covered by the `/review-branch` gate and by the user's
read of the changed text.
