---
name: feature-end
description: Complete a feature — finalise documentation and move it to Completed
argument-hint: [feature name or slug]
---

Mark a feature as complete and bring all documentation up to date.

Before proceeding, check that CLAUDE.md contains a Feature Model section.
If it doesn't, tell the user to run /feature-init first and stop.

The feature to end is: $ARGUMENTS (if blank, use whichever feature is currently In Progress in `FEATURES.md`)

Steps:

1. Run a full checkpoint first (all steps from `/feature-checkpoint`): update the plan file sub-task statuses, add any outstanding NOTES.md entries, update CLAUDE.md current status.

2. Confirm all sub-tasks are complete. If any are not, ask the user whether to defer them, drop them, or keep the feature open.

3. Call @docs-structure-reviewer to perform a full review that the structure of the documentation is still valid. Apply its feedback, then call it again to confirm. If each call does not have fewer issues than the previous one (i.e. you are converging) ask for user input.

4. Update `FEATURES.md`:
   - Remove the feature entry from `## In progress`.
   - Add a completion entry at the top of `## Completed` with the format:

```
### <Feature title> [tags] — <YYYY-MM-DD>

<Two to four sentences summarising what was built, what data was committed, and any notable decisions. No tables, no sub-task lists.>
```

4. The plan file (`plans/<slug>.md`) can be left as-is to serve as a record of how the feature unfolded.

5. Report a summary of what was completed and what feature is now next.

