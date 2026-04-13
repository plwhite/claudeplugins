# devproc plugin

This plugin provides skills to support a systematic development process based on features. It enforces rules to track features in files, moving through the lifecycle Pending → In Progress → Completed, with a plan file tracking sub-tasks and a handoff section that lets a new session resume exactly where the last one left off. By using skills to step through the various stages, it helps ensure that the good practice is systematically followed and the user can track and control how development happens.

## Contents

| Type | Name | Description |
|------|------|-------------|
| Skill | `feature-init` | One-time setup: adds the feature model to `CLAUDE.md`, creates `FEATURES.md` and `plans/` |
| Skill | `feature-create` | Add a new feature entry to the Pending section of `FEATURES.md` |
| Skill | `feature-start` | Move a feature to In Progress and create its plan file |
| Skill | `feature-checkpoint` | Sync all documentation and tracking to the current state |
| Skill | `feature-end` | Mark a feature complete and move it to Completed |

## Setup

Run `/feature-init` once per project before using any other skills. This writes the feature model section to `CLAUDE.md`, creates `FEATURES.md`, and creates the `plans/` directory. Safe to re-run — it updates existing content rather than overwriting it.

## Workflow

```
/feature-create "My new feature"
    → adds entry to FEATURES.md (Pending)

/feature-start my-new-feature
    → moves entry to In Progress, creates plans/

Invoke implementation of each subtask in turn, checkpointing as required.

/feature-checkpoint
    → updates plan file, refreshes Handoff, checks NOTES.md and CLAUDE.md for drift

/feature-end
    → moves entry to Completed, updates all documentation
```

## Skills

### feature-init

**Invoke with:** `/feature-init`

One-time project setup. Adds a `## Feature model` section to `CLAUDE.md`, creates `FEATURES.md` with the standard section structure (In Progress / Pending / Explicitly deferred / Completed), and creates the `plans/` directory. Safe to re-run — it updates existing content rather than overwriting it.

---

### feature-create

**Invoke with:** `/feature-create <description>`

Adds a new entry at the top of the `## Pending` section in `FEATURES.md`. Derives a lowercase-hyphenated slug from the description and appends it as a tag on the heading (e.g. `### My feature [my-feature]`). The description is kept to one or two sentences — implementation detail belongs in the plan file, which is created when the feature starts.

**Example:**
```
/feature-create "Add dark mode support to the UI"
```

---

### feature-start

**Invoke with:** `/feature-start [feature name or slug]`

Moves the named feature from `## Pending` to `## In progress` in `FEATURES.md`, then creates `plans/<slug>.md` with a Design section and a numbered sub-task list. The plan file includes a `## Handoff` section that is kept current so any session can resume without context from the previous one.

If only one feature is pending, the argument can be omitted.

**Example:**
```
/feature-start dark-mode-support
```

---

### feature-checkpoint

**Invoke with:** `/feature-checkpoint`

Brings all project documentation up to date with the current implementation state. Updates the plan file (marks completed sub-tasks with ✓, advances the `▶ NEXT:` marker, records partial progress), refreshes the `## Handoff` section with a concrete next action, and checks `NOTES.md` and `CLAUDE.md` for drift.

Run this after each sub-task completes. The skill is designed to be run proactively, not just on request.

---

### feature-end

**Invoke with:** `/feature-end`

Runs a full checkpoint, verifies all sub-tasks are complete, moves the feature entry from `## In progress` to `## Completed` in `FEATURES.md` (appending the completion date to the heading), and leaves the plan file in place as a record. Reports what was completed and what feature is next.

## Key files

| File | Purpose |
|------|---------|
| `FEATURES.md` | Index of all features and their status |
| `plans/<slug>.md` | Per-feature plan with design, sub-tasks, and handoff state |
| `NOTES.md` | Non-obvious technical findings recorded continuously |
| `CLAUDE.md` | High-level project status only — no implementation detail |
