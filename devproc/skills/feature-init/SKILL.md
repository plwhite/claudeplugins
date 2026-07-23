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

Use these slash commands (defined in the `devproc` plugin) to manage features
through their lifecycle — **spec → design → implement → end**:

- `/feature-spec` — create a new feature in `features/PENDING.md`, write its specification into the plan file, and agree the feature's **sign-off strategy**
- `/feature-design` — move a feature to `features/CURRENT.md`, write its design and sub-task plan, and agree the **sign-off criteria** for each sub-task
- *(implementation has no slash command — work through the sub-tasks directly; a sub-task is complete only when all its sign-off boxes are ticked)*
- `/feature-checkpoint` — during implementation, sync all feature documentation and plans to the current state (run after each sub-task and when prompted within subtasks)
- `/feature-end` — mark a feature complete and move it to `features/COMPLETED.md`

`NOTES.md` is maintained continuously. Any non-obvious technical finding — page
structure quirks, API behaviour, design decisions, scope changes — goes there as
it is discovered.

### Sign-off criteria

This section is the **canonical statement of the sign-off model**. The
`devproc` skills and review agents apply the rules written here rather than
carrying their own copies — when the model changes, it changes here.

Every feature defines explicit sign-off criteria, so quality steps are a
deliberate choice rather than something quietly skipped. Five categories cover
the most likely sign-offs:

- **Testing** — manual or automated checks that the work behaves correctly.
- **Documentation** — user and architectural docs updated to reflect the change.
- **Code review** — review of the code, by an agent (e.g. a light per-sub-task agent review, or a full `/review-branch`) or by the user.
- **Docs review** — review of the updated documentation, by an agent (e.g. `docs-structure-reviewer`) or by the user. This is a review activity like code review — checking what was done, not writing it — and it has its own category because it is the sign-off most routinely missed.
- **User review** — the user sees and confirms the work.

These five are the usual set, not a closed list: a feature's strategy may split
one into separate sign-offs (e.g. unit tests and manual tests confirmed at
different stages) or add a specific sign-off of another kind (e.g. "agent X has
confirmed the output"). Do not invent sign-offs for their own sake, but do
capture whatever genuinely gates the work.

Every sign-off criterion must be **auditable**: when a sub-task is finished it
must be unambiguous whether the criterion is met. "Have some tests" is not
auditable; "unit tests written to the agreed quality bar" is, and so is "enough
tests that the user confirms coverage is sufficient" — each has a clear
done/not-done point. Word every criterion so it has a definite yes/no.

Part of being auditable is that any review sign-off — code review, docs
review, or otherwise — says **who performs it**: an agent (naming the skill or
agent, e.g. `/review-branch`, `docs-structure-reviewer`) or the user. A bare
"code review" box is ambiguous. In checkbox labels, write the performer in
parentheses — e.g. `- [ ] Code review (agent): /review-component the parser`,
`- [ ] Docs review (agent): docs-structure-reviewer over the updated docs`, or
`- [ ] Code review (user): user reads the parser diff`. (A **User review**
box needs no parenthetical — the user is the performer by definition.)

For each category it is legitimate to decide *not* to do it — but that decision
is made explicitly and up front, where the user can comment on it:

- **Strategy (at `/feature-spec`).** The plan file's `## Sign-off strategy` section records the quality bar per category for the whole feature (e.g. "100% test coverage" vs "basic tests" vs "none"; "full production docs" vs "internal notes only"). The user agrees it.
- **Criteria (at `/feature-design`).** Each sub-task in `## Sub-tasks` carries the applicable sign-off categories as checkboxes, derived from the strategy. The user agrees them.
- **Completion (at implement time).** A sub-task may be marked complete (✓) only when every one of its sign-off boxes is ticked.

Checkbox convention:

- `- [ ]` is pending; `- [x]` is satisfied.
- A sub-task is complete only when all its boxes are `[x]`; an unchecked box means it is not done.
- Only the categories that apply to a sub-task are listed. When a category does not apply, omit it — never write a placeholder such as `- [ ] User review: none`, which can never be ticked and so blocks the sub-task from ever completing. A category skipped for the whole feature is justified once in `## Sign-off strategy`; a feature-level sign-off (e.g. one end-of-feature docs review or `/review-branch`) is recorded there too, rather than repeated on every sub-task.

`/feature-checkpoint` may be run at any time, including mid-sub-task: it records
which boxes are ticked and which remain so the hand-off is accurate, and never
marks a sub-task complete while a box is still outstanding.

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

    - Sign-off strategy (the quality bar per sign-off category — see `### Sign-off criteria` — agreed at `/feature-spec`)

    - Design (implementation strategy)

    - Subtask list with short descriptions, per-sub-task sign-off checkboxes, and status markers (`✓`, `▶ NEXT:`)

    - Review record (a log, appended by `/feature-spec` and `/feature-design`, of what review happened at each lifecycle stage — the reviewing agent's verdict, or `N/A` when the review was skipped. Always the last section of the file; a line is written every time, so an absent line means the stage has not run. Preserve it across edits.)

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
   `FEATURES.md` or `plans/<slug>.md` to the new paths — at minimum check
   `CLAUDE.md` and any project README.

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
