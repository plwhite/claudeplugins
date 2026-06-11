---
name: feature-init
description: Initialises the feature model for this project. Run this once to enable feature workflows.
disable-model-invocation: true
---

Make updates to `CLAUDE.md` and the `features/` directory as required — see below
for details. This skill also **migrates** projects that still use the older
single-file layout (`FEATURES.md` plus a top-level `plans/` or `notes/`
directory). It is safe to re-run: on an already-migrated project it leaves the
existing content in place and only fills in anything missing. Do not change the
structure defined here.

## 1. Update the Feature model section of CLAUDE.md

Add the following section to `CLAUDE.md` if it is not already present. If it is
already present, update it to match the text below:

~~~markdown
## Feature model

Major pieces of work are organised into features. Each feature has a concise
entry in one of the feature-list files under `features/` and a detailed plan
file in `features/plans/`.

Use these slash commands (defined in the `devproc` plugin) to manage features:

- `/feature-create` — add a new feature to `features/PENDING.md` (and create its plan file)
- `/feature-start` — move a feature to `features/CURRENT.md` and flesh out its plan file
- `/feature-checkpoint` — sync all feature documentation, plans and user documentation to the current state
- `/feature-end` — mark a feature complete and move it to `features/COMPLETED.md`

`NOTES.md` is maintained continuously. Any non-obvious technical finding — page
structure quirks, API behaviour, design decisions, scope changes — goes there as
it is discovered.

### Resuming after a session restart

When starting a new session on a feature that is already in progress:

1. Read `features/CURRENT.md` to find the current in-progress feature and its plan file.
2. Open the plan file (`features/plans/<slug>.md`) and read the `## Handoff` section first — it contains the session summary, current sub-task state, and the specific first action to take.
3. Do not begin implementation until you have read the Handoff section.

### Documents to support the model

These apply at all times, not just when completing features:

- **`features/`** — the feature list, split across four files so the (large)
  completed list need not be read into context every session. Each entry is a
  level-3 (`###`) heading with name and slug, one paragraph max — no sub-task
  lists, no implementation detail, no tables; link to the plan file for detail.

    - `CURRENT.md` — feature(s) in progress (normally exactly one)
    - `PENDING.md` — features waiting for development
    - `DEFERRED.md` — features explicitly deferred, including those blocked by a dependency (not expected to happen, but may be resurrected)
    - `COMPLETED.md` — completed features; headings end with the completion date in YYYY-MM-DD format

- **`features/plans/<slug>.md`**

    Plan for a feature. Should have sections for:

    - Handoff (session state — last updated date, summary, current sub-task, first action next session, open questions, dead ends)

    - Requirements (the full relevant content from the source issue, if the feature came from one — enough to resume without re-reading the issue)

    - Design (implementation strategy)

    - Subtask list with short descriptions and status markers (`✓`, `▶ NEXT:`)

- **`NOTES.md`** — non-obvious findings only. Do not record things derivable from reading the code.

- **`CLAUDE.md`** — high-level status only. No plan detail, no implementation notes.
~~~

## 2. Migrate an older layout if present

Perform these migration steps before creating any fresh files, so existing
content is preserved rather than overwritten:

1. **Slug directory.** If a top-level `plans/` directory exists (or the older
   `notes/` directory), move it to `features/plans/`, preserving all its
   contents. Create the `features/` directory first if needed. If both a
   top-level `plans/` and `notes/` exist, move `plans/` to `features/plans/` and
   merge any `notes/` contents into it, then remove the empty `notes/`.

2. **FEATURES.md.** If `FEATURES.md` exists, split it into the four list files
   under `features/`, mapping its sections as follows:

   | `FEATURES.md` section   | Destination            |
   |-------------------------|------------------------|
   | `## In progress`        | `features/CURRENT.md`  |
   | `## Pending`            | `features/PENDING.md`  |
   | `## Explicitly deferred`| `features/DEFERRED.md` |
   | `## Completed`          | `features/COMPLETED.md`|

   Copy each section's `###` feature entries verbatim into the corresponding
   file under that file's standard header (see templates below). Then delete
   `FEATURES.md`. Update any links elsewhere in the repo that pointed at
   `FEATURES.md` or `plans/<slug>.md` to the new paths (see step 5 of
   `/feature-checkpoint` conventions — at minimum check `CLAUDE.md`).

If neither `FEATURES.md` nor a top-level `plans/`/`notes/` directory exists,
there is nothing to migrate; continue to step 3.

## 3. Ensure the feature-list files exist

Create the `features/` directory if it does not exist. For each of the four list
files, create it from the template below **only if it does not already exist**
(do not overwrite a file that migration or a previous run produced):

`features/CURRENT.md`:

~~~markdown
# Features in progress

Features currently being developed. Each feature has a level three (`###`)
heading with a name and slug (e.g. `[initial-development]`) so its plan file in
`features/plans/` can be found.

*There should normally be only one feature here, and it should have a plan
matching the slug in `features/plans/`. In some cases there may be no feature in
progress, or in very rare cases more than one at once.*
~~~

`features/PENDING.md`:

~~~markdown
# Pending features

Features waiting for development. Each feature has a level three (`###`) heading
with a name and slug; detail lives in `features/plans/<slug>.md`.
~~~

`features/DEFERRED.md`:

~~~markdown
# Deferred features

Features that have been explicitly deferred — including those blocked by a
dependency. These are not expected to happen but may be resurrected.
~~~

`features/COMPLETED.md`:

~~~markdown
# Completed features

Features that have been completed, described to reflect what was actually
developed. Headings must end with the date of completion in YYYY-MM-DD format.
~~~

## 4. Ensure the plans directory exists

Create the `features/plans/` directory if it does not exist.
