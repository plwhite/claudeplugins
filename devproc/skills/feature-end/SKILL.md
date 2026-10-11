---
name: feature-end
description: Complete a feature — finalise documentation and move it to Completed
argument-hint: [feature name or slug]
---

Mark a feature as complete and bring all documentation up to date.

Before proceeding, check that `features/FEATUREMODEL.md` exists **and** that
`CLAUDE.md` loads it via a live import — an un-backticked `@features/FEATUREMODEL.md` line in ordinary prose, outside any fenced code block.
If either is missing, tell the user to run /feature-init first and stop.

The feature to end is: $ARGUMENTS (if blank, use whichever feature is currently in progress in `features/CURRENT.md`)

Steps:

1. Run a full checkpoint first (all steps from `/feature-checkpoint`): update the plan file sub-task statuses, add any outstanding NOTES.md entries, update CLAUDE.md current status.

2. Confirm all sub-tasks are complete — every sub-task marked ✓ **and every one of its sign-off boxes `[x]`** (a ticked sub-task with an unticked box is not done), including every box in the "Final sign-off criteria" sub-task. If any sub-task is incomplete, or any sign-off box remains unticked, do not close the feature: either complete the outstanding sign-off, or ask the user whether to defer or drop that sub-task, or keep the feature open.

3. Update the feature-list files:
   - Remove the feature entry from `features/CURRENT.md`.
   - Add a completion entry at the top of `features/COMPLETED.md` (below its header blurb) with the format:

```
### <Feature title> [tags] — <YYYY-MM-DD>

<Two to four sentences summarising what was built, what data was committed, and any notable decisions. No tables, no sub-task lists.>
```

   - Trim the root `CLAUDE.md` `## Current status` section to its cap: retain
     only the in-progress feature (if any is starting next) plus **at most one
     line** for this single most-recent completion; delete any older
     completion entries or status lines. Nothing is lost — that content is
     already preserved in `features/COMPLETED.md` above. (This is a
     point-in-time trim at the moment of closing a feature; periodic cleanup of
     any drift that accumulates between features is `/internal-docs-prune`'s
     job, not this step's.)

4. Stamp the `## Review record` in the plan file (`features/plans/<slug>.md`): append exactly one line, `- YYYY-MM-DD — Feature closed by /feature-end; all sign-off boxes ticked.`, with today's date. Follow the section's one-line-per-stage convention and preserve the existing lines. Without it, the record's last line still implies the close stage never ran, which contradicts the feature's completed status.

5. The rest of the plan file can be left as-is to serve as a record of how the feature unfolded.

6. Report a summary of what was completed and what feature is now next.

