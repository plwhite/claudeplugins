# Split FEATURES.md into separate files to save tokens [split-features-md]

## Requirements

From issue #14 (verbatim):

> `FEATURES.md` is a single file, which means that it needs to be read in its entirety.
>
> Better to have a directory `features/` with four files in it: CURRENT.md, PENDING.md, BLOCKED.md and COMPLETED.md. Over time, COMPLETED.md may get large, but that will not have to be read into the context window all the time.
>
> Full set of changes for this fix involves changing the skills relating to features as follows
> - The `notes` directory is a bad name. Rename to `features`
> - Move the `FEATURES.md` file into the `features` directory, and split it into `CURRENT.md`, `PENDING.md`, `BLOCKED.md` and `COMPLETED.md`
> - Tweak `/feature-create` such that it always creates a slug file and copies the relevant content from the issue into that slug file.
> - Tweak `/feature-init` for all of the above, including the change that if there is a `notes` directory it should be renamed; if there is a `FEATURES.md` file, it should be split up; `CLAUDE.md` should be updated etc.

Additional requirement from the feature request: `/feature-create` must copy the **whole content** of the issue description into the slug file (not just a summary), together with any relevant information from the comments on the issue.

## Handoff

**Last updated:** 2026-06-11
**Session summary:** All five sub-tasks complete. The `devproc` plugin (skills, agents, docs, plugin.json) now defines the `features/` model, and this repo has been migrated to it (`FEATURES.md` split into `features/{CURRENT,PENDING,DEFERRED,COMPLETED}.md`; `plans/` moved to `features/plans/`; root `CLAUDE.md` rewritten). No stale references remain in live docs.
**Sub-task in progress:** None — feature implementation complete.
**First action next session:** Run `/feature-end` (it will trigger a docs-structure review that also refreshes the agent-memory snapshots still describing the old layout).
**Open questions / decisions pending:** None — all resolved (see "Open decisions").
**Dead ends to avoid:** None

## Design

### Goal

**Primary deliverable: the plugin.** The objective is not merely to change this
repo, but to update the `devproc` plugin (skills, agents, documentation) so that
*every* project using the plugin adopts the new `features/` model — both via
`/feature-init` migration of existing projects and as the default for new ones.
Migrating this repo (Sub-task 5) is dog-fooding that validates the change.

Split the single, ever-growing `FEATURES.md` into a `features/` directory of
smaller files so that the large Completed list no longer has to be read into
context every session, and consolidate the per-feature slug/plan files into the
same directory. Update all five feature skills, the dev-process-manager agent,
and the supporting documentation to match, and provide a migration path in
`/feature-init` for existing projects (including this repo).

### Target layout

```
features/
  CURRENT.md       ← the In-progress feature(s)        (was FEATURES.md "## In progress")
  PENDING.md       ← features waiting for development   (was "## Pending")
  DEFERRED.md      ← deferred work (incl. blocked)       (was "## Explicitly deferred")
  COMPLETED.md     ← completed features, dated          (was "## Completed")
  plans/
    <slug>.md      ← per-feature plan/slug files        (were in plans/)
```

The four list files replace `FEATURES.md`. The per-feature plan files (currently
`plans/<slug>.md`) move into a `plans/` **subdirectory** of `features/` and
become `features/plans/<slug>.md`. Keeping them in their own subdirectory cleanly
separates the small, frequently-read list files from the slug files and removes
any possibility of a slug colliding with a list-file name. The top-level `plans/`
directory (a confusing sibling of `FEATURES.md`) is thereby eliminated, satisfying
the issue's "the notes directory is a bad name" intent without overloading the
`features/` root.

`NOTES.md` (the continuously-maintained findings file) is unaffected and stays
at the project root — it is a different thing from the slug directory the issue
calls "notes".

### Section → file mapping & headings

Each list file is self-contained with its own top-of-file explanatory blurb and
the level-3 (`###`) feature entries that were previously under the corresponding
heading. `CURRENT.md` keeps the "normally only one feature" guidance;
`COMPLETED.md` keeps the "headings end with YYYY-MM-DD" rule. The old "Explicitly
deferred" section becomes `DEFERRED.md`: there is no separate "blocked" file —
being blocked is simply one reason a feature is deferred, so `DEFERRED.md` covers
both.

### `/feature-create` change

Currently `/feature-create` only *optionally* creates a plan file (when
pre-given requirements are too long for the FEATURES.md entry). New behaviour:
it **always** creates `features/plans/<slug>.md`, and when the feature came from a
GitHub issue it copies everything relevant into a `## Requirements` section of
that slug file — not just the one-or-two-sentence summary that goes into
`PENDING.md`. Specifically: the **entire** issue description verbatim (nothing in
it is assumed irrelevant), plus any comment that bears on design or requirements
(e.g. "we should use tool X", "we must ensure Y holds"). Comments that are mere
reactions or scheduling chatter ("great idea", "let's wait until next month") are
omitted. The objective is that a later session can pick up the feature from the
slug file alone, without re-reading the GitHub issue. The PENDING.md entry stays
short and links to the slug file.

### `/feature-init` migration

`/feature-init` becomes idempotent and migration-aware. On a project that still
has the old layout it must:
1. If a top-level slug directory exists (`plans/` or the older `notes/`), move it
   to `features/plans/` (preserving its contents).
2. If `FEATURES.md` exists, split its four sections into
   `features/{CURRENT,PENDING,DEFERRED,COMPLETED}.md` (mapping "Explicitly
   deferred" → DEFERRED), then remove `FEATURES.md`.
3. Update the `## Feature model` section of `CLAUDE.md` to describe the new
   layout.
It must be safe to re-run after migration (detect the new layout and do
nothing destructive).

### Documentation touch-points

`devproc/README.md`, `docs/workflow.md`, `devproc/.claude-plugin/plugin.json`,
`devproc/agents/dev-process-manager.md`, `devproc/agents/docs-structure-reviewer.md`,
`devproc/agents/code-review-architectural.md` (the `plans/` mention), and the
workspace `CLAUDE.md` all reference `FEATURES.md` / `plans/` and must be updated.

### Dog-fooding this repo

The final sub-task migrates this repository itself using the new scheme: create
`features/`, split the current `FEATURES.md`, move `plans/*.md` into
`features/plans/`, delete the top-level `FEATURES.md` and `plans/`, and update the
root `CLAUDE.md`. This both
completes the feature and validates the migration logic end-to-end.

### Open decisions (all resolved)

1. **Directory layout.** RESOLVED — the four list files live at the `features/`
   root; per-feature slug files live in a `features/plans/` subdirectory.
2. **Deferred vs blocked.** RESOLVED — use `DEFERRED.md`, not `BLOCKED.md`; being
   blocked is just one reason a feature is deferred, so a single file covers both.
3. **Issue content in the slug file.** RESOLVED — copy the entire description
   verbatim plus every comment bearing on design/requirements; omit reactions and
   scheduling chatter. Goal: resume from the slug file without re-reading the issue.

## Sub-tasks

1. ✓ (2026-06-11) **Update `feature-init`** — new CLAUDE.md template and FEATURES structure describing the `features/` layout, plus idempotent migration logic (move top-level `plans`/`notes` → `features/plans`, split `FEATURES.md` into the four list files, update CLAUDE.md).
2. ✓ (2026-06-11) **Update `feature-create`** — always create `features/plans/<slug>.md`; copy the full issue body and relevant comments into its `## Requirements` section; write the short entry to `features/PENDING.md`.
3. ✓ (2026-06-11) **Update `feature-start`, `feature-checkpoint`, `feature-end`** — operate on `features/{CURRENT,PENDING,DEFERRED,COMPLETED}.md` and `features/plans/<slug>.md` instead of `FEATURES.md` and `plans/<slug>.md`. Also fixed the `plans/` reference in the `review-branch`/`review-component` skills.
4. ✓ (2026-06-11) **Update supporting docs** — `devproc/README.md`, `docs/workflow.md`, `plugin.json`, `dev-process-manager.md`, `docs-structure-reviewer.md`, `code-review-architectural.md`. (The workspace `CLAUDE.md` is deferred to Sub-task 5, where the repo migration updates its `## Feature model` section as part of dog-fooding.)
5. ✓ (2026-06-11) **Migrate this repo** — applied the new scheme here: created `features/` with the four list files, `git mv plans → features/plans`, split `FEATURES.md` (In progress → CURRENT, Completed → COMPLETED, others empty), deleted `FEATURES.md`, and rewrote root `CLAUDE.md` (feature-model section, plugin skill descriptions, current status). Verified no stale references remain in live docs.

**▶ NEXT:** All sub-tasks complete — ready for `/feature-end`.

> Run `/feature-checkpoint` after each sub-task completes.
