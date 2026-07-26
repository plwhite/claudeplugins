# devproc plugin

Skills and agents for feature lifecycle management, workflow orchestration, code review, documentation review, and internal docs hygiene.

For task-oriented guides to using these capabilities, see [docs/workflow.md](../docs/workflow.md) and [docs/capabilities.md](../docs/capabilities.md).

## Contents

| Type | Name | Description |
|------|------|-------------|
| Skill | `feature-init` | One-time setup: adds the feature model to `CLAUDE.md`, creates the `features/` directory including a git-ignored `features/tmp` scratch directory (and migrates an older `FEATURES.md`/`plans/` layout) |
| Skill | `feature-spec` | Create a new feature in `features/PENDING.md`, write its specification into the plan file (from a GitHub issue, a one-line description, or material staged in `features/tmp`), and agree the sign-off strategy |
| Skill | `feature-design` | Move a feature to `features/CURRENT.md` and write its design and sub-task plan, with per-sub-task sign-off criteria |
| Skill | `feature-checkpoint` | Sync all documentation and tracking to the current state |
| Skill | `feature-end` | Mark a feature complete and move it to Completed |
| Skill | `review-full` | Full-codebase code review |
| Skill | `review-component` | Code review scoped to a described component or area |
| Skill | `review-branch` | Code review scoped to files changed in the current branch |
| Skill | `internal-docs-prune` | Prune internal Claude-facing docs (root and nested `CLAUDE.md` files, `NOTES.md`, `.claude/rules/*.md`) — spawns `internal-docs-reviewer`, auto-applies redundant/stale findings, escalates or defers judgment findings |
| Agent | `dev-process-manager` | Top-level orchestrator: drives the feature workflow by spawning teammates per sub-task, reviewing their work, and checking in with the user (`claude --agent dev-process-manager`) |
| Agent | `feature-spec-reviewer` | Reviews a feature spec before a human reads it: requirements clarity, auditable delivery criteria, blocking issues; ends with a verdict |
| Agent | `feature-design-reviewer` | Reviews a feature design and sub-task plan before a human reads it: requirement coverage, recorded rationale, auditable sub-task criteria, blocking issues; ends with a verdict |
| Agent | `docs-structure-reviewer` | Audits documentation structure and quality, producing actionable findings without modifying files |
| Agent | `internal-docs-reviewer` | Reviews internal Claude-facing docs for `redundant`, `stale`, or `judgment` findings, each tagged with a gating class and action, without modifying files |
| Agent | `code-review-architectural` | Architectural review: module boundaries, coupling, design fit (`opus`) |
| Agent | `code-review-simplicity` | Simplicity review: unnecessary complexity, duplication, dead code (`sonnet`) |
| Agent | `code-review-general` | General review: correctness, error handling, robustness, performance (`sonnet`) |
| Agent | `code-review-nitty` | Nitty review: naming, comments, control flow clarity, micro-robustness (`sonnet`) |

## Setup

Run `/feature-init` once per project before using any other skills. This writes the feature model section to `CLAUDE.md` and creates the `features/` directory, whose feature list is split across four files by status (`CURRENT.md` / `PENDING.md` / `DEFERRED.md` / `COMPLETED.md`) so the large completed list need not be read into context every session. It also creates a git-ignored `features/tmp/` scratch directory for staging requirements material as input to `/feature-spec`, and migrates an older single-file layout (`FEATURES.md` plus a top-level `plans/` or `notes/` directory) to the new structure. Safe to re-run — it updates existing content rather than overwriting it.

### Feature tracking files

| File | Purpose |
|------|---------|
| `features/CURRENT.md` | Feature(s) currently in progress (normally exactly one) |
| `features/PENDING.md` | Features waiting for development |
| `features/DEFERRED.md` | Features explicitly deferred, including those blocked by a dependency |
| `features/COMPLETED.md` | Completed features, dated — the large list kept out of routine context |
| `features/plans/<slug>.md` | Per-feature plan with requirements, sign-off strategy, design, sub-tasks (with sign-off checkboxes), handoff state, and a review record |
| `features/tmp/` | Git-ignored scratch space for staging requirements material as input to `/feature-spec`; only the tracked `README.md` persists — not a store for tracking requirements |
| `NOTES.md` | Non-obvious technical findings recorded continuously |
| `CLAUDE.md` | High-level project status only — no implementation detail |

---

## Skill reference

### feature-init

**Invoke with:** `/feature-init`

One-time project setup. Adds a `## Feature model` section to `CLAUDE.md`, creates the `features/` directory with its four status files (`CURRENT.md` / `PENDING.md` / `DEFERRED.md` / `COMPLETED.md`) and a `features/plans/` subdirectory, and migrates an older `FEATURES.md`/`plans/` layout if present. It also scaffolds `features/tmp/` — a git-ignored scratch directory where you can stage requirements material as input to `/feature-spec` — creating or updating `.gitignore` as needed. Safe to re-run.

---

### feature-spec

**Invoke with:** `/feature-spec <description>`

The first step of the lifecycle: create a feature and specify *what* it must do. Adds a new entry at the top of `features/PENDING.md`, deriving a lowercase-hyphenated slug from the description and appending it as a tag on the heading (e.g. `### My feature [my-feature]`). The list entry is kept to one or two sentences — the specification belongs in the plan file. It always creates the plan file `features/plans/<slug>.md`, whose `## Requirements` section captures the specification — verbatim from the source issue (entire description plus any design/requirements-relevant comments), from the one-line description, or from material staged in `features/tmp` — so a later session can resume from the plan file alone. That third route ([docs/workflow.md](../docs/workflow.md) covers the mechanics) is used when you point `/feature-spec` at `features/tmp` or it auto-detects material there, and the directory is cleared once captured (the tracked `README.md` stays).

It also agrees the feature's **sign-off strategy** — the quality bar for testing, documentation, code review, docs review, and user review across the whole feature (e.g. full test coverage vs none; production docs vs internal notes) — and records it in the plan file's `## Sign-off strategy` section, including the bar for any end-of-feature gates (e.g. one `/review-branch` before the feature closes). Review sign-offs always state whether an agent or the user performs them. Deciding *not* to do one of these is legitimate, but it is an explicit, up-front choice you can comment on here. Strategy records the bar; `/feature-design` is what turns any end-of-feature gates into an actual checklist (see below). (The canonical statement of the sign-off model lives in the `### Sign-off criteria` section that `/feature-init` writes into the project CLAUDE.md; the skills and review agents defer to it.)

Before the spec reaches you, the `feature-spec-reviewer` agent reviews it. Findings it marks `[rewrite]` are fixed for you; findings it marks `[decision]` are put to you as questions rather than guessed at. You are told what the review changed and what its verdict was. Skip it with an explicit instruction (`--no-review`, or "skip review"), in which case the report says so.

If you have asked for an unattended run, the verdict stands in for your sign-off — but only on `READY FOR USER REVIEW` with no `[decision]` finding; anything else stops and asks you regardless. A skipped review cancels unattended mode rather than compounding with it.

Every run appends a line to the plan file's `## Review record`, including one reading `N/A — skipped on the user's instruction`. That makes the section trustworthy evidence of what has been checked: an absent line means the stage has not run, not that nobody bothered to write it down.

**Example:**
```
/feature-spec "Add dark mode support to the UI"
/feature-spec "issue 12"
/feature-spec "use what's in features/tmp"
```

---

### feature-design

**Invoke with:** `/feature-design [feature name or slug]`

The second step of the lifecycle: decide *how* the feature will be built. Moves the named feature from `features/PENDING.md` to `features/CURRENT.md`, then fleshes out `features/plans/<slug>.md` — preserving the `## Requirements` section written by `/feature-spec`, filling in the Design section, and adding a numbered sub-task list. Each sub-task carries its **sign-off criteria** as checkboxes (the applicable subset of testing / documentation / code review / docs review / user review, derived from the sign-off strategy), agreed with you here — a sub-task is later complete only when all its boxes are ticked. Where the strategy defines end-of-feature gates, they are added as a final sub-task, **"Final sign-off criteria"**, one checkbox per gate — created only when such gates actually exist, so a gate is never left living only in the strategy's prose. A gate that `/feature-end` performs itself (typically the docs-review box) is annotated "(performed at `/feature-end`)" — the one box expected to stay unticked until `/feature-end` runs. Review boxes name their performer, e.g. `Code review (agent): /review-component the parser` or `Docs review (agent): docs-structure-reviewer over the updated docs` vs `Code review (user): ...`, so it is never ambiguous whether a review is yours to do. The plan file includes a `## Handoff` section kept current so any session can resume without context from the previous one. Producing the design does not begin implementation — that is a separate step with no slash command. If only one feature is pending, the argument can be omitted.

Before the design reaches you, the `feature-design-reviewer` agent reviews it — requirement coverage, recorded rationale, auditable sub-task criteria, and anything blocking implementation. Findings it marks `[rewrite]` are fixed for you; findings it marks `[decision]` are put to you as questions. Skip it with an explicit instruction (`--no-review`, or "skip review"), in which case the report says so.

If you have asked for an unattended run, the verdict stands in for your sign-off and implementation may begin without you having seen the design — but only on `READY FOR USER REVIEW` with no `[decision]` finding; anything else stops and asks you regardless. A skipped review cancels unattended mode.

As at spec time, every run appends a line to the plan file's `## Review record`, beneath the spec-stage line rather than replacing it — the section is the feature's review history. When a design is accepted unattended, the `## Handoff` summary says so too, so a resuming session sees it without going looking.

**Example:**
```
/feature-design dark-mode-support
/feature-design "issue 12"
```

---

### feature-checkpoint

**Invoke with:** `/feature-checkpoint`

Brings all project documentation up to date with the current implementation state. Updates the plan file (marks completed sub-tasks with ✓, advances the `▶ NEXT:` marker, records partial progress), refreshes the `## Handoff` section with a concrete next action, and checks `NOTES.md` and `CLAUDE.md` for drift. It never marks a sub-task complete while any of its sign-off boxes is still unticked (the one exception being a box in a "Final sign-off criteria" sub-task annotated "(performed at `/feature-end`)", which is expected to stay unticked until `/feature-end` runs) — instead it records which are done and which remain, so a mid-sub-task checkpoint still produces an accurate hand-off.

Run after each sub-task completes, and whenever you want an accurate hand-off mid-sub-task. The skill is designed to be run proactively, not just on request.

---

### feature-end

**Invoke with:** `/feature-end`

Runs a full checkpoint, verifies all sub-tasks are complete with every sign-off box ticked — with one exception: a box in the "Final sign-off criteria" sub-task annotated "(performed at `/feature-end`)" is expected to still be unticked, because this step performs and ticks it itself — moves the feature entry from `features/CURRENT.md` to `features/COMPLETED.md` (appending the completion date), and triggers a documentation review. That review *is* the performance of the annotated docs-review box, so there is exactly one close-out docs review, not a second one done separately. The plan file is kept in place as a record.

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

### internal-docs-prune

**Invoke with:** `/internal-docs-prune [unattended]`

Prunes this repository's internal, Claude-facing documentation — root and nested `CLAUDE.md` files, `NOTES.md`, and `.claude/rules/*.md` — as distinct from user-facing `docs/`, which it never touches. It spawns the read-only `internal-docs-reviewer` agent and applies its findings by gating class: `redundant` and `stale` are auto-applied, `judgment` is escalated to you (interactive, the default) or deferred (unattended). It owns the record of settled `judgment` calls (kept under `.claude/agent-memory/devproc-internal-docs-reviewer/`, since the agent is stateless) so repeat runs don't re-ask about calls you already decided. Reports a summary of what was deleted, moved, condensed, and retained. See [docs/capabilities.md](../docs/capabilities.md#internal-docs-hygiene) for the gating model, the no-content-loss move semantics, and idempotency.

**Example:**
```
/internal-docs-prune
/internal-docs-prune unattended
```

---

## Agent reference

### dev-process-manager

**Run as the session agent with:** `claude --agent dev-process-manager` (or, in container mode, `claude-run --manager` — equivalently `claude-run --agent dpm` — see [docs/container.md](../docs/container.md)).

A top-level Opus orchestrator for the feature workflow. Unlike the review agents — which are sub-agents invoked by a skill — this agent *is* the session you talk to. It establishes the feature being worked on (specifying and designing one itself if asked), agrees an autonomy boundary with you (e.g. "do sub-tasks 1–4, then check with me"), then for each sub-task spawns a teammate (normally Sonnet), briefs it to run `/feature-checkpoint` on completion, reviews the actual changes before accepting them — accepting a sub-task only once all its sign-off boxes are ticked — and shuts the teammate down. It pauses for you at requirement/design decisions and when you ask to review something. See [docs/capabilities.md](../docs/capabilities.md#dev-process-manager) for the task-oriented guide.

---

### feature-spec-reviewer

Reviews a feature specification — the `## Requirements` and `## Sign-off strategy` sections of a plan file — and reports what a human would otherwise have to catch. It checks that the spec is complete and unambiguous (in particular that source-issue content was captured rather than deferred to), that every sign-off category is present and worded auditably, that blocking issues are surfaced, and that the spec states *what* without pre-empting the design.

Findings are classified BLOCKING / MAJOR / MINOR / SUGGESTION, and each is marked `[rewrite]` (the calling skill can fix it by rewording) or `[decision]` (it needs an answer from the user). Output ends with an explicit `VERDICT: READY FOR USER REVIEW` or `VERDICT: NEEDS WORK` — ready only when there are no BLOCKING and no MAJOR findings. It never modifies files.

Invoked automatically at the end of `/feature-spec`, before the spec is presented. Test fixtures for the agent live in `devproc/tests/feature-spec-reviewer/`.

---

### feature-design-reviewer

Reviews a feature design and its sub-task plan — the `## Design` and `## Sub-tasks` sections of a plan file. It traces every requirement to the part of the design that delivers it, checks that decisions are recorded with their rationale (and that rejected alternatives are noted), that each sub-task's sign-off criteria are auditable and no weaker than the agreed strategy, that any end-of-feature gate the strategy defines is materialised as an explicit "Final sign-off criteria" sub-task rather than left only in strategy prose (and that any `/feature-end`-performed box is correctly annotated), that ticking every sub-task would actually complete the feature, and that the breakdown is sensibly sized and ordered. It reads `## Requirements` and `## Sign-off strategy` as context but does not review them — that is `feature-spec-reviewer`'s job.

Findings and verdict use the same scheme as `feature-spec-reviewer`: BLOCKING / MAJOR / MINOR / SUGGESTION, each marked `[rewrite]` or `[decision]`, ending in `VERDICT: READY FOR USER REVIEW` or `VERDICT: NEEDS WORK`. It never modifies files, and does not propose a replacement design of its own.

Invoked automatically at the end of `/feature-design`, before the design is presented. Test fixtures live in `devproc/tests/feature-design-reviewer/`.

---

### docs-structure-reviewer

Audits documentation structure and quality. Traces all documents reachable from `README.md` and `CLAUDE.md`, checks discoverability, architectural completeness, procedural rigour, and stylistic consistency. Output is a prioritised list of findings (CRITICAL / MAJOR / MINOR / SUGGESTION) — never modifies files itself. Invoked automatically after `/feature-end`.

---

### internal-docs-reviewer

Reviews a repository's internal, Claude-facing documentation — root and nested `CLAUDE.md` files, `NOTES.md`, and `.claude/rules/*.md` — for content that has gone stale, become redundant with a canonical source elsewhere, or is of borderline enough value that a human should decide. It enforces each file's own stated rules (e.g. `CLAUDE.md`'s "high-level status only", `NOTES.md`'s "non-obvious findings only") plus two fixed criteria per file type — audience relevance and duplication for `CLAUDE.md`; currency and durability for `NOTES.md` — and never touches user-facing `docs/`, `README.md`, or `CONTRIBUTING.md`.

Every finding carries an exact anchor, a gating class (`redundant` / `stale` / `judgment`), and an action (`delete` / `move` → destination / `condense`) — the contract `/internal-docs-prune` parses to decide what to apply automatically and what to escalate. `redundant` findings are always `delete` (the content already exists at its canonical source). It never modifies files itself, and it is stateless: it re-reports every borderline `judgment` call on each run, leaving the skill to suppress those already decided.

Invoked by `/internal-docs-prune`. Test fixtures live in `devproc/tests/internal-docs-reviewer/`.

---

### code-review-architectural

Reviews module boundaries, coupling between components, consistency with the established design, and public interface quality. Uses `opus`. Invoked when architectural review is requested. Produces findings classified as ARCHITECTURAL (requires confirmation), CONCERN, or SUGGESTION.

---

### code-review-simplicity

Identifies unnecessary complexity: dead code, duplication, over-engineering, redundant abstractions, and verbose logic. Uses `sonnet`. Produces findings classified as MAJOR, MINOR, or SUGGESTION.

---

### code-review-general

Checks correctness, error handling, edge cases, performance hot spots, and security at system boundaries. Uses `sonnet`. Produces findings classified as CRITICAL, MAJOR, MINOR, or SUGGESTION.

---

### code-review-nitty

Reviews low-level code quality: naming, comments (missing, wrong, or redundant), control flow clarity, and micro-robustness issues within individual functions. Uses `sonnet`. Produces findings classified as MAJOR, MINOR, or SUGGESTION.
