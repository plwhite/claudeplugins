---
name: feature-checkpoint
description: Sync all documentation and feature tracking to reflect the current state of the in-progress feature
argument-hint: [feature name or slug]
---

Bring all project documentation up to date with the current state of the feature.

Before proceeding, check that CLAUDE.md contains a Feature Model section.
If it doesn't, tell the user to run /feature-init first and stop.

The feature to checkpoint is: $ARGUMENTS (if blank, use whichever feature is currently In Progress in `FEATURES.md`)

Steps:

1. Read `FEATURES.md` to identify the in-progress feature and its plan file reference.

2. Read the plan file (`plans/<slug>.md`). Update it to reflect the actual current state:
   - Mark completed sub-tasks with ✓ and a completion date.
   - Move the **▶ NEXT:** marker to the next incomplete sub-task if applicable.
   - Add any new sub-tasks discovered during implementation.
   - Keep descriptions concise (one line each).

3. Check the documentation for all user and architectural documentation in the various docs directories; they should be kept up to date continuously.

   1. Fix any drift.

   2. Check `NOTES.md`. For each non-obvious technical finding made since the last checkpoint (page structure quirks, API behaviour, design decisions, scope changes), add a note.

   3. Check `CLAUDE.md` current status section. Update it to accurately reflect what is done and what is next. Keep it high-level — one paragraph per component.

   4. Verify `FEATURES.md` In Progress entry is still accurate (description has not drifted from what the feature is actually doing).

   5. Call @docs-structure-reviewer to perform a full review that the structure of the documentation is still valid. Apply its feedback, then call it again to confirm. If each call does not have fewer issues than the previous one (i.e. you are converging) ask for user input.

4. Report a brief summary of what was updated.

**Rule**: do not wait to be asked. This skill exists because documentation and tracking information drifts silently. Run it proactively when a sub-task completes.
