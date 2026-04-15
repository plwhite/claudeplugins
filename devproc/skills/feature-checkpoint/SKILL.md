---
name: feature-checkpoint
description: Sync all documentation and feature tracking to reflect the current state of the in-progress feature
argument-hint: [feature name or slug]
---

**Run this skill after every sub-task completes — do not wait to be asked.**

Bring all project documentation up to date with the current state of the feature.

Before proceeding, check that CLAUDE.md contains a Feature Model section.
If it doesn't, tell the user to run /feature-init first and stop.

The feature to checkpoint is: $ARGUMENTS (if blank, use whichever feature is currently In Progress in `FEATURES.md`)

Steps:

1. Read `FEATURES.md` to identify the in-progress feature and its plan file reference.

2. Read the plan file (`plans/<slug>.md`). Update it to reflect the actual current state:
   - Mark completed sub-tasks with ✓ and a completion date.
   - Move the **▶ NEXT:** marker to the next incomplete sub-task if applicable.
   - For any sub-task that is *partially* complete, add indented bullet points beneath it recording what has been done and what remains. Example:
     ```
     3. **Refactor auth module** — extract session handling to its own class
        - ✓ Extracted SessionManager class
        - ✓ Moved token refresh logic
        - ▶ TODO: Update tests to use new interface
     ```
   - Add any new sub-tasks discovered during implementation.
   - Keep sub-task headline descriptions concise (one line each).

3. Update the `## Handoff` section at the top of the plan file. Create it if it does not exist. This section is the single source of truth for resuming work in a new session:

   ```markdown
   ## Handoff

   **Last updated:** YYYY-MM-DD
   **Session summary:** [1–2 sentences on what this session accomplished]
   **Sub-task in progress:** Sub-task N — [what has been done within it so far, if partially complete]
   **First action next session:** [specific, concrete first step — not "continue sub-task N" but the actual action]
   **Open questions / decisions pending:** [anything unresolved that needs a decision]
   **Dead ends to avoid:** [approaches tried and abandoned this session, with reasons — omit if none]
   ```

   Be specific and concrete. Vague entries like "continue working on the feature" are useless to a cold session.

4. Check the documentation for all user and architectural documentation in the various docs directories; they should be kept up to date continuously.

   1. Fix any drift.

   2. Check `NOTES.md`. For each non-obvious technical finding made since the last checkpoint (page structure quirks, API behaviour, design decisions, scope changes), add a note.

   3. Check `CLAUDE.md` current status section. Update it to accurately reflect what is done and what is next. Keep it high-level — one paragraph per component.

   4. Verify `FEATURES.md` In Progress entry is still accurate (description has not drifted from what the feature is actually doing).

5. Report a brief summary of what was updated.

**Rule**: do not wait to be asked. This skill exists because documentation and tracking information drifts silently. Run it proactively when a sub-task completes, and whenever requested.
