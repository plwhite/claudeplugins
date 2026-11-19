# devproc plugin

Skills and agents for feature lifecycle management, workflow orchestration, code review, documentation review, and internal docs hygiene.

This is the reference for the plugin's skills and agents, for people using the plugin. It covers setup and the files the plugin creates, then one entry per skill and agent. For task-oriented guides to using these capabilities, see [docs/workflow.md](../docs/workflow.md) and [docs/capabilities.md](../docs/capabilities.md).

## Contents

| Type | Name | Description |
|------|------|-------------|
| Skill | `feature-init` | One-time setup: installs the feature model, imports it from `CLAUDE.md`, and creates the `features/` directory |
| Skill | `feature-spec` | Create a new feature in `features/PENDING.md`, capture its input and write its spec, and agree the sign-off strategy |
| Skill | `feature-design` | Move a feature to `features/CURRENT.md` and write its design and sub-task plan, with per-sub-task sign-off criteria |
| Skill | `feature-checkpoint` | Sync all documentation and tracking to the current state |
| Skill | `feature-end` | Mark a feature complete and move it to Completed |
| Skill | `review-full` | Full-codebase code review |
| Skill | `review-component` | Code review scoped to a described component or area |
| Skill | `review-branch` | Code review scoped to files changed in the current branch |
| Skill | `review-docs` | Docs review scoped to the whole documentation set, the current change, or a described area; runs the four docs review agents, auto-applies minor in-doc fixes, escalates significant findings |
| Skill | `internal-docs-prune` | Prune internal Claude-facing docs (`CLAUDE.md`, `NOTES.md`, `.claude/rules/*.md`) of redundant, stale and borderline content |
| Agent | `dev-process-manager` | Top-level orchestrator: drives the feature workflow by spawning teammates per sub-task, reviewing their work, and checking in with the user (`claude --agent dev-process-manager`) |
| Agent | `feature-spec-reviewer` | Reviews a feature spec before a human reads it: `## Spec` clarity against the readability standard, auditable delivery criteria, blocking issues; ends with a verdict |
| Agent | `feature-design-reviewer` | Reviews a feature design and sub-task plan before a human reads it: `## Spec` coverage, design clarity against the readability standard, recorded rationale, auditable sub-task criteria, blocking issues; ends with a verdict |
| Agent | `docs-review-architectural` | Structure and concision of the user docs (`opus`) |
| Agent | `docs-review-accuracy` | User docs still match the code (`sonnet`) |
| Agent | `docs-review-style` | How the user docs read (`sonnet`) |
| Agent | `docs-review-agent-docs` | Agent docs (`CLAUDE.md`, `NOTES.md`, `.claude/rules/*.md`) review (`sonnet`) |
| Agent | `internal-docs-reviewer` | Finds stale, redundant or borderline content in internal Claude-facing docs |
| Agent | `code-review-architectural` | Architectural review: module boundaries, coupling, design fit (`opus`) |
| Agent | `code-review-simplicity` | Simplicity review: unnecessary complexity, duplication, dead code (`sonnet`) |
| Agent | `code-review-general` | General review: correctness, error handling, robustness, performance (`sonnet`) |
| Agent | `code-review-nitty` | Nitty review: naming, comments, control flow clarity, micro-robustness (`sonnet`) |

## How the skills and agents fit together

Most agents are not run directly: a skill runs them as sub-agents. The `dev-process-manager` agent is the exception, being run as the session itself.

| Skill or agent | Runs |
|----------------|------|
| `/feature-spec` | `feature-spec-reviewer` |
| `/feature-design` | `feature-design-reviewer` |
| `/review-full`, `/review-component`, `/review-branch` | `code-review-simplicity`, `code-review-general` and `code-review-nitty`, plus `code-review-architectural` when requested |
| `/review-docs` | `docs-review-architectural`, `docs-review-accuracy`, `docs-review-style` and `docs-review-agent-docs` |
| `/internal-docs-prune` | `internal-docs-reviewer` |
| `dev-process-manager` (session agent) | A teammate per sub-task, plus the `/feature-*` and review skills, which run the agents above |

`/feature-init`, `/feature-checkpoint` and `/feature-end` run no agents.

## Setup

Run these skills from the **workspace**, the directory holding `CLAUDE.md`, `NOTES.md` and `features/`; see [Where the workspace is](../docs/workflow.md#where-the-workspace-is).

Run `/feature-init` once per workspace before any other skill; see [feature-init](#feature-init).

### Feature tracking files

| File | Purpose |
|------|---------|
| `features/FEATUREMODEL.md` | The project's installed copy of the feature-model text (lifecycle, sign-off criteria, readability and user docs standards, supporting documents), refreshed from the plugin's canonical copy by `/feature-init` and imported by `CLAUDE.md`, so it loads every session |
| `features/CURRENT.md` | Feature(s) currently in progress (normally exactly one) |
| `features/PENDING.md` | Features waiting for development |
| `features/DEFERRED.md` | Features explicitly deferred, including those blocked by a dependency |
| `features/COMPLETED.md` | Completed features, dated — the large list kept out of routine context |
| `features/plans/<slug>.md` | Per-feature plan with requirements, spec, sign-off strategy, design, sub-tasks (with sign-off checkboxes), handoff state, and a review record |
| `features/tmp/` | Scratch space for staging requirements material as input to `/feature-spec`, not a store for tracking requirements. Git-ignored in a tracked workspace. Contents are removed once captured; only the tracked `README.md` stays |
| `NOTES.md` | Non-obvious technical findings recorded continuously |
| `CLAUDE.md` | High-level project status only — no implementation detail |

---

## Skill reference

### feature-init

**Invoke with:** `/feature-init`

One-time project setup. It copies the canonical `FEATUREMODEL.md` shipped with the skill into the project as `features/FEATUREMODEL.md`, ensures `CLAUDE.md`'s `## Feature model` section contains the `@features/FEATUREMODEL.md` import line, and creates `features/` with its four status files (`CURRENT.md` / `PENDING.md` / `DEFERRED.md` / `COMPLETED.md`), a `plans/` subdirectory and a `tmp/` scratch directory for staging requirements material as input to `/feature-spec`.

In a tracked workspace it also creates or updates `.gitignore` to ignore `features/tmp/`. In an untracked workspace it neither writes nor inspects a `.gitignore`, and reports that it skipped the step, and why.

Safe to re-run: it refreshes `features/FEATUREMODEL.md` from the canonical copy, so the model always matches the plugin version, and preserves your feature-list files and plans.

---

### feature-spec

**Invoke with:** `/feature-spec <description>`

The first step of the lifecycle: create a feature and specify *what* it must do. Adds a new entry at the top of `features/PENDING.md`, deriving a lowercase-hyphenated slug from the description and appending it as a tag on the heading (e.g. `### My feature [my-feature]`). The list entry is kept to one or two sentences — the specification belongs in the plan file. It always creates the plan file `features/plans/<slug>.md`: its `## Requirements` section captures the input (a GitHub issue, your description, or material staged in `features/tmp`) and its `## Spec` section states what the feature must do. See [Specify a feature](../docs/workflow.md#specify-a-feature) and [Requirements and Spec are different jobs](../docs/workflow.md#requirements-and-spec-are-different-jobs).

It also agrees the feature's **sign-off strategy**, recorded in the plan file's `## Sign-off strategy` section; see [The sign-off strategy](../docs/workflow.md#the-sign-off-strategy).

Before the spec reaches you, the `feature-spec-reviewer` agent reviews it, and every run is logged in the plan file's `## Review record`; see [Review before you read it](../docs/workflow.md#review-before-you-read-it).

**Example:**
```
/feature-spec "Add dark mode support to the UI"
/feature-spec "issue 12"
/feature-spec "use what's in features/tmp"
```

---

### feature-design

**Invoke with:** `/feature-design [feature name or slug]`

The second step of the lifecycle: decide *how* the feature will be built. Moves the named feature from `features/PENDING.md` to `features/CURRENT.md`, then fleshes out `features/plans/<slug>.md` — preserving the `## Requirements` and `## Spec` sections written by `/feature-spec`, writing the Design section, and adding the sub-task list, each sub-task its own `### N. Name` heading so it shows in an editor's outline. Each sub-task carries sign-off checkboxes derived from the sign-off strategy and agreed with you here; see [Sub-tasks and their sign-off criteria](../docs/workflow.md#sub-tasks-and-their-sign-off-criteria). A missing plan file, `## Requirements`, or `## Spec` stops the skill with a pointer to `/feature-spec`. `## Design` must open with an overview of how the design works as a whole, before any detailed section — followable by a reader who knows only `## Requirements` and `## Spec` — per the same `### Readability` standard.

Design work can turn up problems with the spec. `/feature-design` may then amend `## Spec`, but only with your approval; see [Design a feature](../docs/workflow.md#design-a-feature).

A sub-task is later complete only when all its boxes are ticked. The plan file includes a `## Handoff` section kept current so any session can resume without context from the previous one. Producing the design does not begin implementation — that is a separate step with no slash command. If only one feature is pending, the argument can be omitted.

Before the design reaches you, the `feature-design-reviewer` agent reviews it, and the run is logged in `## Review record` beneath the spec-stage line. See [Review before you read it](../docs/workflow.md#review-before-you-read-it).

**Example:**
```
/feature-design dark-mode-support
/feature-design "issue 12"
```

---

### feature-checkpoint

**Invoke with:** `/feature-checkpoint`

Brings all project documentation up to date with the current implementation state. Updates the plan file (marks completed sub-tasks by appending ✓ and the date to the sub-task's heading, advances the `▶ NEXT:` marker, records partial progress), refreshes the `## Handoff` section with a concrete next action, and checks `NOTES.md` and `CLAUDE.md` for drift. It never marks a sub-task complete while any of its sign-off boxes is still unticked — instead it records which are done and which remain, so a mid-sub-task checkpoint still produces an accurate hand-off. It also records changes to the sub-task list found mid-feature; see [When the sub-task list changes](../docs/workflow.md#when-the-sub-task-list-changes).

Run after each sub-task completes, and whenever you want an accurate hand-off mid-sub-task. The skill is designed to be run proactively, not just on request.

---

### feature-end

**Invoke with:** `/feature-end`

Runs a full checkpoint, verifies all sub-tasks are complete with every sign-off box ticked, and moves the feature entry from `features/CURRENT.md` to `features/COMPLETED.md` (appending the completion date). It runs no docs review of its own: docs review is an ordinary sign-off, normally a box in the "Final sign-off criteria" sub-task, ticked before `/feature-end` starts. The plan file is kept in place as a record.

---

### review-full

**Invoke with:** `/review-full [including architectural review]`

Runs a code review over the entire codebase, adding architectural review if requested. See [docs/capabilities.md](../docs/capabilities.md#code-review) for how findings are applied.

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

### review-docs

**Invoke with:** `/review-docs [full | change | an area] [kinds]`

Runs a docs review over the whole documentation set (`full`), the docs touched by or describing the current change (`change`, the default), or a described area (e.g. "the container docs"), as free text. It runs four agents: architectural, accuracy and style over the user docs, and agent docs over `CLAUDE.md`, `NOTES.md` and `.claude/rules/*.md`. You can name a subset (e.g. "accuracy only"). Minor fixes inside a single doc are applied automatically; significant findings are escalated to you. See [docs/capabilities.md](../docs/capabilities.md#documentation-review) for the classes of document, what each kind checks, and what is applied and what escalated.

**Example:**
```
/review-docs
/review-docs full
/review-docs the container docs, accuracy only
```

---

### internal-docs-prune

**Invoke with:** `/internal-docs-prune [unattended]`

Prunes the internal, Claude-facing docs (root and nested `CLAUDE.md` files, `NOTES.md`, `.claude/rules/*.md`) using the `internal-docs-reviewer` agent, and reports what was deleted, moved, condensed and retained. See [docs/capabilities.md](../docs/capabilities.md#internal-docs-hygiene) for what it applies and what it asks about.

**Example:**
```
/internal-docs-prune
/internal-docs-prune unattended
```

---

## Agent reference

### dev-process-manager

**Run as the session agent with:** `claude --agent dev-process-manager` (or, in container mode, `claude-run --manager` — equivalently `claude-run --agent dpm` — see [docs/container.md](../docs/container.md)).

A top-level Opus orchestrator for the feature workflow. Unlike the review agents, which are sub-agents invoked by a skill, it *is* the session you talk to: it spawns a teammate per sub-task, reviews its work, and checks in with you at the boundary you set. See [docs/capabilities.md](../docs/capabilities.md#dev-process-manager).

---

### feature-spec-reviewer

Reviews a feature specification (the `## Spec` and `## Sign-off strategy` sections of a plan file) for completeness against `## Requirements`, clarity against the `### Readability` standard, auditable sign-off criteria and blocking issues. Each finding is marked `[rewrite]` (fixable by rewording) or `[decision]` (it needs your answer), and the output ends with `VERDICT: READY FOR USER REVIEW` or `VERDICT: NEEDS WORK`. It never modifies files. See [Review before you read it](../docs/workflow.md#review-before-you-read-it).

Invoked automatically at the end of `/feature-spec`, before the spec is presented.

---

### feature-design-reviewer

Reviews a feature design and its sub-task plan (the `## Design` and `## Sub-tasks` sections of a plan file): that the design delivers every `## Spec` requirement, opens with an overview, is clear and records its rationale, and that each sub-task's sign-off criteria are auditable and no weaker than the agreed strategy. Findings and verdict use the same scheme as `feature-spec-reviewer`. It never modifies files and does not propose a replacement design. See [Review before you read it](../docs/workflow.md#review-before-you-read-it).

Invoked automatically at the end of `/feature-design`, before the design is presented.

---

### docs-review-architectural

Reviews the structure and concision of the user docs (`opus`). See [The four kinds](../docs/capabilities.md#the-four-kinds) and [Concision checks](../docs/capabilities.md#concision-checks). Invoked by `/review-docs`.

---

### docs-review-accuracy

Checks that the user docs still match the code and its behaviour (`sonnet`). See [The four kinds](../docs/capabilities.md#the-four-kinds). Invoked by `/review-docs`.

---

### docs-review-style

Reviews how the user docs read (`sonnet`): clarity, procedural form and consistency. Clarity includes wordiness. See [The four kinds](../docs/capabilities.md#the-four-kinds) and [Concision checks](../docs/capabilities.md#concision-checks). Invoked by `/review-docs`.

---

### docs-review-agent-docs

Reviews the agent docs (`sonnet`): `CLAUDE.md` at any depth, `NOTES.md` and `.claude/rules/*.md`. See [The four kinds](../docs/capabilities.md#the-four-kinds). Invoked by `/review-docs`.

---

### internal-docs-reviewer

Reviews internal, Claude-facing docs for stale, redundant or borderline content. Every finding carries an exact anchor, a gating class (`redundant` / `stale` / `judgment`) and an action (`delete` / `move` / `condense`), which `/internal-docs-prune` parses to decide what to apply. It never modifies files and is stateless. Invoked by `/internal-docs-prune`; see [Internal docs hygiene](../docs/capabilities.md#internal-docs-hygiene).

---

### code-review-architectural

Reviews module boundaries, coupling between components, consistency with the established design, and public interface quality. Uses `opus`. Invoked when architectural review is requested. Produces findings classified as ARCHITECTURAL (requires confirmation), CONCERN, or SUGGESTION. See [Code review](../docs/capabilities.md#code-review).

---

### code-review-simplicity

Identifies unnecessary complexity: dead code, duplication, over-engineering, redundant abstractions, and verbose logic. Uses `sonnet`. Produces findings classified as MAJOR, MINOR, or SUGGESTION. See [Code review](../docs/capabilities.md#code-review).

---

### code-review-general

Checks correctness, error handling, edge cases, performance hot spots, and security at system boundaries. Uses `sonnet`. Produces findings classified as CRITICAL, MAJOR, MINOR, or SUGGESTION. See [Code review](../docs/capabilities.md#code-review).

---

### code-review-nitty

Reviews low-level code quality: naming, comments (missing, wrong, or redundant), control flow clarity, and micro-robustness issues within individual functions. Uses `sonnet`. Produces findings classified as MAJOR, MINOR, or SUGGESTION. See [Code review](../docs/capabilities.md#code-review).
