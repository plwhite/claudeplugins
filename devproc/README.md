# devproc plugin

Skills and agents for feature lifecycle management, workflow orchestration, code review, and documentation review.

For task-oriented guides to using these capabilities, see [docs/workflow.md](../docs/workflow.md) and [docs/capabilities.md](../docs/capabilities.md).

## Contents

| Type | Name | Description |
|------|------|-------------|
| Skill | `feature-init` | One-time setup: adds the feature model to `CLAUDE.md`, creates the `features/` directory (and migrates an older `FEATURES.md`/`plans/` layout) |
| Skill | `feature-spec` | Create a new feature in `features/PENDING.md` and write its specification into the plan file |
| Skill | `feature-design` | Move a feature to `features/CURRENT.md` and write its design and sub-task plan |
| Skill | `feature-checkpoint` | Sync all documentation and tracking to the current state |
| Skill | `feature-end` | Mark a feature complete and move it to Completed |
| Skill | `review-full` | Full-codebase code review |
| Skill | `review-component` | Code review scoped to a described component or area |
| Skill | `review-branch` | Code review scoped to files changed in the current branch |
| Agent | `dev-process-manager` | Top-level orchestrator: drives the feature workflow by spawning teammates per sub-task, reviewing their work, and checking in with the user (`claude --agent dev-process-manager`) |
| Agent | `docs-structure-reviewer` | Audits documentation structure and quality, producing actionable findings without modifying files |
| Agent | `code-review-architectural` | Architectural review: module boundaries, coupling, design fit (`claude-opus-4-6`) |
| Agent | `code-review-simplicity` | Simplicity review: unnecessary complexity, duplication, dead code |
| Agent | `code-review-general` | General review: correctness, error handling, robustness, performance |
| Agent | `code-review-nitty` | Nitty review: naming, comments, control flow clarity, micro-robustness |

## Setup

Run `/feature-init` once per project before using any other skills. This writes the feature model section to `CLAUDE.md` and creates the `features/` directory, whose feature list is split across four files by status (`CURRENT.md` / `PENDING.md` / `DEFERRED.md` / `COMPLETED.md`) so the large completed list need not be read into context every session. It also migrates an older single-file layout (`FEATURES.md` plus a top-level `plans/` or `notes/` directory) to the new structure. Safe to re-run — it updates existing content rather than overwriting it.

### Feature tracking files

| File | Purpose |
|------|---------|
| `features/CURRENT.md` | Feature(s) currently in progress (normally exactly one) |
| `features/PENDING.md` | Features waiting for development |
| `features/DEFERRED.md` | Features explicitly deferred, including those blocked by a dependency |
| `features/COMPLETED.md` | Completed features, dated — the large list kept out of routine context |
| `features/plans/<slug>.md` | Per-feature plan with requirements, design, sub-tasks, and handoff state |
| `NOTES.md` | Non-obvious technical findings recorded continuously |
| `CLAUDE.md` | High-level project status only — no implementation detail |

---

## Skill reference

### feature-init

**Invoke with:** `/feature-init`

One-time project setup. Adds a `## Feature model` section to `CLAUDE.md`, creates the `features/` directory with its four status files (`CURRENT.md` / `PENDING.md` / `DEFERRED.md` / `COMPLETED.md`) and a `features/plans/` subdirectory, and migrates an older `FEATURES.md`/`plans/` layout if present. Safe to re-run.

---

### feature-spec

**Invoke with:** `/feature-spec <description>`

The first step of the lifecycle: create a feature and specify *what* it must do. Adds a new entry at the top of `features/PENDING.md`, deriving a lowercase-hyphenated slug from the description and appending it as a tag on the heading (e.g. `### My feature [my-feature]`). The list entry is kept to one or two sentences — the specification belongs in the plan file. It always creates the plan file `features/plans/<slug>.md`, whose `## Requirements` section captures the full source-issue content (entire description plus any design/requirements-relevant comments) so a later session can resume from the plan file alone, without re-reading the issue.

**Example:**
```
/feature-spec "Add dark mode support to the UI"
/feature-spec "issue 12"
```

---

### feature-design

**Invoke with:** `/feature-design [feature name or slug]`

The second step of the lifecycle: decide *how* the feature will be built. Moves the named feature from `features/PENDING.md` to `features/CURRENT.md`, then fleshes out `features/plans/<slug>.md` — preserving the `## Requirements` section written by `/feature-spec`, filling in the Design section, and adding a numbered sub-task list. The plan file includes a `## Handoff` section kept current so any session can resume without context from the previous one. Producing the design does not begin implementation — that is a separate step with no slash command. If only one feature is pending, the argument can be omitted.

**Example:**
```
/feature-design dark-mode-support
/feature-design "issue 12"
```

---

### feature-checkpoint

**Invoke with:** `/feature-checkpoint`

Brings all project documentation up to date with the current implementation state. Updates the plan file (marks completed sub-tasks with ✓, advances the `▶ NEXT:` marker, records partial progress), refreshes the `## Handoff` section with a concrete next action, and checks `NOTES.md` and `CLAUDE.md` for drift.

Run after each sub-task completes. The skill is designed to be run proactively, not just on request.

---

### feature-end

**Invoke with:** `/feature-end`

Runs a full checkpoint, verifies all sub-tasks are complete, moves the feature entry from `features/CURRENT.md` to `features/COMPLETED.md` (appending the completion date), and triggers a documentation review. The plan file is kept in place as a record.

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

### dev-process-manager

**Run as the session agent with:** `claude --agent dev-process-manager` (or, in container mode, `claude-run --manager` — see [docs/container.md](../docs/container.md)).

A top-level Opus orchestrator for the feature workflow. Unlike the review agents — which are sub-agents invoked by a skill — this agent *is* the session you talk to. It establishes the feature being worked on (creating and starting one itself if asked), agrees an autonomy boundary with you (e.g. "do sub-tasks 1–4, then check with me"), then for each sub-task spawns a teammate (normally Sonnet), briefs it to run `/feature-checkpoint` on completion, reviews the actual changes before accepting them, and shuts the teammate down. It pauses for you at requirement/design decisions and when you ask to review something. See [docs/capabilities.md](../docs/capabilities.md#dev-process-manager) for the task-oriented guide.

---

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
