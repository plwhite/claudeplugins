---
name: feature-checkpoint
description: Sync all documentation and feature tracking to reflect the current state of the in-progress feature
argument-hint: [feature name or slug]
---

**Run this skill after every sub-task completes — do not wait to be asked.**

Bring all project documentation up to date with the current state of the feature.

Before proceeding, check that CLAUDE.md contains a Feature Model section.
If it doesn't, tell the user to run /feature-init first and stop.

The feature to checkpoint is: $ARGUMENTS (if blank, use whichever feature is currently in progress in `features/CURRENT.md`)

Steps:

1. Read `features/CURRENT.md` to identify the in-progress feature and its plan file reference.

2. Read the plan file (`features/plans/<slug>.md`). Update it to reflect the actual current state:
   - Mark a sub-task complete (✓) with a completion date **only when all of its sign-off boxes are `[x]`** — the completion rule defined in the project CLAUDE.md under `### Sign-off criteria`. If any sign-off box is still `[ ]`, the sub-task is *not* complete — leave it unmarked and record its state (see partial progress below). Tick a sign-off box only when the work it names is genuinely done; never tick one — especially a *user review* box — on the user's behalf. This skill records state; it does not grant sign-off.
   - Move the **▶ NEXT:** marker to the next incomplete sub-task if applicable.
   - For any sub-task that is *partially* complete, record what has been done and what remains. Its sign-off boxes already carry most of this — ticked ones are done, unticked ones outstanding — so make sure they are accurate, and add indented notes for any progress a box does not capture. Example:
     ```
     3. **Refactor auth module** — extract session handling to its own class
        - [x] Testing: SessionManager unit tests passing
        - [ ] Code review (agent): /review-component the auth module
        - [ ] User review: user confirms the new interface
        - Remaining: token-refresh path still to extract
     ```
   - Add any new sub-tasks discovered during implementation, giving each its sign-off criteria.
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

   4. Verify the `features/CURRENT.md` entry is still accurate (description has not drifted from what the feature is actually doing).

5. Report a brief summary of what was updated.

**Rule**: do not wait to be asked. This skill exists because documentation and tracking information drifts silently. Run it proactively when a sub-task completes, and whenever requested.
