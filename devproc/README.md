# devproc plugin

Skills and agents for feature lifecycle management, code review, and documentation review.

For task-oriented guides to using these capabilities, see [docs/workflow.md](../docs/workflow.md) and [docs/capabilities.md](../docs/capabilities.md).

## Contents

| Type | Name | Description |
|------|------|-------------|
| Skill | `feature-init` | One-time setup: adds the feature model to `CLAUDE.md`, creates `FEATURES.md` and `plans/` |
| Skill | `feature-create` | Add a new feature entry to the Pending section of `FEATURES.md` |
| Skill | `feature-start` | Move a feature to In Progress and create its plan file |
| Skill | `feature-checkpoint` | Sync all documentation and tracking to the current state |
| Skill | `feature-end` | Mark a feature complete and move it to Completed |
| Skill | `review-full` | Full-codebase code review |
| Skill | `review-component` | Code review scoped to a described component or area |
| Skill | `review-branch` | Code review scoped to files changed in the current branch |
| Agent | `docs-structure-reviewer` | Audits documentation structure and quality, producing actionable findings without modifying files |
| Agent | `code-review-architectural` | Architectural review: module boundaries, coupling, design fit (`claude-opus-4-6`) |
| Agent | `code-review-simplicity` | Simplicity review: unnecessary complexity, duplication, dead code |
| Agent | `code-review-general` | General review: correctness, error handling, robustness, performance |
| Agent | `code-review-nitty` | Nitty review: naming, comments, control flow clarity, micro-robustness |

## Setup

Run `/feature-init` once per project before using any other skills. This writes the feature model section to `CLAUDE.md`, creates `FEATURES.md` with the standard section structure (In Progress / Pending / Explicitly deferred / Completed), and creates the `plans/` directory. Safe to re-run — it updates existing content rather than overwriting it.

### Feature tracking files

| File | Purpose |
|------|---------|
| `FEATURES.md` | Index of all features and their status |
| `plans/<slug>.md` | Per-feature plan with design, sub-tasks, and handoff state |
| `NOTES.md` | Non-obvious technical findings recorded continuously |
| `CLAUDE.md` | High-level project status only — no implementation detail |

---

## Skill reference

### feature-init

**Invoke with:** `/feature-init`

One-time project setup. Adds a `## Feature model` section to `CLAUDE.md`, creates `FEATURES.md` with the standard section structure, and creates the `plans/` directory. Safe to re-run.

---

### feature-create

**Invoke with:** `/feature-create <description>`

Adds a new entry at the top of the `## Pending` section in `FEATURES.md`. Derives a lowercase-hyphenated slug from the description and appends it as a tag on the heading (e.g. `### My feature [my-feature]`). The description is kept to one or two sentences — implementation detail belongs in the plan file. If a longer specification is provided, it is optionally preserved in `plans/<slug>.md` under a `## Requirements` section (this is an edge case, not part of the standard plan schema; it is only created when pre-given requirements are too detailed for the FEATURES.md entry).

**Example:**
```
/feature-create "Add dark mode support to the UI"
/feature-create "issue 12"
```

---

### feature-start

**Invoke with:** `/feature-start [feature name or slug]`

Moves the named feature from `## Pending` to `## In progress` in `FEATURES.md`, then creates `plans/<slug>.md` with a Design section and a numbered sub-task list. The plan file includes a `## Handoff` section kept current so any session can resume without context from the previous one. If only one feature is pending, the argument can be omitted.

**Example:**
```
/feature-start dark-mode-support
/feature-start "issue 12"
```

---

### feature-checkpoint

**Invoke with:** `/feature-checkpoint`

Brings all project documentation up to date with the current implementation state. Updates the plan file (marks completed sub-tasks with ✓, advances the `▶ NEXT:` marker, records partial progress), refreshes the `## Handoff` section with a concrete next action, and checks `NOTES.md` and `CLAUDE.md` for drift.

Run after each sub-task completes. The skill is designed to be run proactively, not just on request.

---

### feature-end

**Invoke with:** `/feature-end`

Runs a full checkpoint, verifies all sub-tasks are complete, moves the feature entry from `## In progress` to `## Completed` in `FEATURES.md` (appending the completion date), and triggers a documentation review. The plan file is kept in place as a record.

---

### review-full

**Invoke with:** `/review-full [including architectural review]`

Runs a code review over the entire codebase. Always runs the simplicity, general, and nitty agents in parallel. Code-level findings are applied automatically and the cycle repeats until no new findings appear (capped at 5 iterations). Adds the architectural agent if requested.

---

### review-component

**Invoke with:** `/review-component <description>`

Runs a code review scoped to a specific component or area. The description is resolved to a file set using path/glob matching first, then keyword search — the resolved list is shown before any agents run.

**Example:**
```
/review-component the payments module
/review-component src/auth/ including architectural review
```

---

### review-branch

**Invoke with:** `/review-branch [including architectural review]`

Runs a code review scoped to files changed in the current feature branch, derived from `git diff` against the base branch. The full diff is passed to agents as context so they understand what changed, not just the current file state.

---

## Agent reference

### docs-structure-reviewer

Audits documentation structure and quality. Traces all documents reachable from `README.md` and `CLAUDE.md`, checks discoverability, architectural completeness, procedural rigour, and stylistic consistency. Output is a prioritised list of findings (CRITICAL / MAJOR / MINOR / SUGGESTION) — never modifies files itself. Invoked automatically after `/feature-end`.

---

### code-review-architectural

Reviews module boundaries, coupling between components, consistency with the established design, and public interface quality. Uses `claude-opus-4-6`. Invoked when architectural review is requested. Produces findings classified as ARCHITECTURAL (requires confirmation), CONCERN, or SUGGESTION.

---

### code-review-simplicity

Identifies unnecessary complexity: dead code, duplication, over-engineering, redundant abstractions, and verbose logic. Produces findings classified as MAJOR, MINOR, or SUGGESTION.

---

### code-review-general

Checks correctness, error handling, edge cases, performance hot spots, and security at system boundaries. Produces findings classified as CRITICAL, MAJOR, MINOR, or SUGGESTION.

---

### code-review-nitty

Reviews low-level code quality: naming, comments (missing, wrong, or redundant), control flow clarity, and micro-robustness issues within individual functions. Produces findings classified as MAJOR, MINOR, or SUGGESTION.
