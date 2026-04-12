---
name: feature-init
description: Initialises the feature model for this project. Run this once to enable feature workflows.
disable-model-invocation: true
---

Make updates to CLAUDE.md, FEATURES.md, and plans directory as required - see below for details. Do not change the structure defined here.

Add the following section to CLAUDE.md if it is not already present. If it is already present, update it to match the text below.:

~~~markdown
## Feature model

Major pieces of work are organised into features. Each phase has a concise entry in `FEATURES.md` and a detailed plan file in `plans/`.

Use these slash commands (defined in the `devproc` plugin) to manage features:

- `/feature-create` — add a new feature to `FEATURES.md` (Pending section)
- `/feature-start` — move a feature to In Progress and create its plan file
- `/feature-checkpoint` — sync all feature documentation, plans and user documentation to the current state
- `/feature-end` — mark a feature complete and move it to Completed

`NOTES.md` is maintained continuously. Any non-obvious technical finding — page structure quirks, API behaviour, design decisions, scope changes — goes there as it is discovered.

### Resuming after a session restart

When starting a new session on a feature that is already in progress:

1. Read `FEATURES.md` to find the current in-progress feature and its plan file.
2. Open the plan file and read the `## Handoff` section first — it contains the session summary, current sub-task state, and the specific first action to take.
3. Do not begin implementation until you have read the Handoff section.

### Documents to support the model

These apply at all times, not just when completing features:

- **`FEATURES.md`**

    List of features.

    - Level 3 (`###`) heading with name and slug for the feature.

    — One entry per feature, with one paragraph max. No sub-task lists, no implementation detail, no tables. Link to the plan file for detail.

- **`plans/<slug>.md`**

    Plan for a feature. Should have sections for :

    - Requirements (potentially more detail than in `FEATURES.md`)

    - Design (implementation strategy)

    - Subtask list with short and status markers (`✓`, `▶ NEXT:`)


- **`NOTES.md`** — non-obvious findings only. Do not record things derivable from reading the code.

- **`CLAUDE.md`** — high-level status only. No plan detail, no implementation notes.
~~~

If the file `FEATURES.md` does not exist, create it with the following content. If it does exist, update it to match the headings and structure below, though without deleting or modifying existing feature entries.

~~~markdown
# Project features

Features being developed for this project. Each feature has a level three (`###`) heading and a short, normally one-paragraph description that explains what the feature is. The feature heading should have a slug (such as `initial-development` or `code-coverage-00` so the plan can be found when created.

---

## In progress

*There should normally be only one feature here, and it should have a plan matching the slug in the plans directory. In some cases there may be no feature in progress, or in very rare cases more than one at once.*

---

## Pending

*Features that are waiting for development.*

---

## Explicitly deferred

*Features that are explicitly deferred; these are not expected to happen but may be resurrected.*

---

## Completed

*Features that have been completed, updated to reflect what was developed. Headings must end with the date of completion in YYYY-MM-DD format.*

~~~

Finally, create the `plans/` directory if it does not exist.