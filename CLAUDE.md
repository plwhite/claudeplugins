# Workspace guide (Claude plugins)

## Current status

**No feature currently in progress.**

`spec-design-review-agents` completed 2026-07-21 — added `feature-spec-reviewer` and `feature-design-reviewer`, run at the end of `/feature-spec` and `/feature-design` before the artefact reaches the human, so completeness, auditable delivery criteria, and blocking issues are caught first (#20). Each agent ends with a `READY FOR USER REVIEW` / `NEEDS WORK` verdict and marks findings `[rewrite]` (the skill fixes them) or `[decision]` (put to the user). Three modes: reviewed (default), skipped on explicit instruction, and unattended — where a clean verdict stands in for human sign-off, gated on `READY` with no `[decision]`, and a `## Review record` line in the plan file records what was checked. Test fixtures live under `devproc/tests/<agent>/`.

`subtask-signoff` completed 2026-06-25 — added explicit per-sub-task sign-off criteria (testing, docs, code review, user review) to the feature workflow so quality steps are a deliberate up-front choice rather than something skipped. A feature agrees a sign-off *strategy* at `/feature-spec`, `/feature-design` turns it into per-sub-task *checkbox criteria* the user agrees, and a sub-task is complete only when all boxes are `[x]` — enforced by `/feature-checkpoint` and `/feature-end`. The canonical model lives in a new `### Sign-off criteria` section of the `feature-init` CLAUDE.md template; README and `docs/` were updated to match. Categories are an open set and every criterion must be auditable (#25).

`docs-reviewer-memory-path` completed 2026-06-16 — fixed the `docs-structure-reviewer` agent so it stores memory at a `$CLAUDE_PROJECT_DIR`-anchored path (`$CLAUDE_PROJECT_DIR/.claude/agent-memory/docs-structure-reviewer/`) rather than relative to cwd, which had scattered stray memory trees when the agent was run from subdirectories (#23).

`split-features-md` completed 2026-06-11 — replaced the single `FEATURES.md` with a `features/` directory (status-split list files `CURRENT.md`/`PENDING.md`/`DEFERRED.md`/`COMPLETED.md` plus per-feature plans under `features/plans/`), so the large completed list no longer loads into context every session. `/feature-init` migrates older layouts; feature creation captures the full source-issue spec in the plan file. The lifecycle skills were also renamed `feature-create`→`feature-spec` and `feature-start`→`feature-design` (flow: spec → design → implement → end).

`dev-process-manager` completed 2026-06-03 — added a top-level Opus "Dev Process Manager" agent (`claude --agent dev-process-manager` / `claude-run --manager`) that orchestrates the feature workflow, spawning a teammate per sub-task and reviewing their work; `claude-run` gained `--manager`/`--agent`/`--model` options passed through via `CLAUDE_AGENT`/`CLAUDE_MODEL`.

`container-bugs` completed 2026-06-01 — fixed three container-mode issues from #17: corrected the credentials mount path in `claude-run` so automatic login works; added a `run-claude.sh` keep-alive loop so the tmux session survives accidental `exit`/Ctrl-D/Ctrl-C (auto-resumes via `claude --continue`, with a SIGINT trap and a crash-guard); and documented the Shift-highlight copy/paste tip.

This repository contains small "plugin" folders that package:
- skills (prompt/behavior docs)
- agents (agent definitions)

Each plugin follows the standard Claude plugin layout:
```
plugin-name/
  .claude-plugin/
    plugin.json          ← required manifest (name, description, version)
  skills/
    skill-name/
      SKILL.md           ← frontmatter: name, description, user-invocable / argument-hint / disable-model-invocation
  agents/
    agent-name.md        ← frontmatter: name, description
```

## demo plugin

Location: `demo/`

Trivial demo plugin to test plugin structure.

Contents:
- `demo/.claude-plugin/plugin.json`
- `demo/skills/demo-skill/SKILL.md`
- `demo/agents/demo-agent.md`

See `demo/README.md` for full usage documentation.

## devproc plugin

Location: `devproc/`

Skills and agents for feature lifecycle management, workflow orchestration, and code review.

Contents:
- `devproc/.claude-plugin/plugin.json`
- `devproc/skills/feature-init/SKILL.md` — one-time setup: writes feature model to CLAUDE.md, creates the `features/` directory, and migrates an older `FEATURES.md`/`plans/` layout
- `devproc/skills/feature-spec/SKILL.md` — create a new feature in `features/PENDING.md` and write its specification (full issue content) into the plan file
- `devproc/skills/feature-design/SKILL.md` — move a feature to `features/CURRENT.md` and write its design and sub-task plan
- `devproc/skills/feature-checkpoint/SKILL.md` — sync all documentation to current state
- `devproc/skills/feature-end/SKILL.md` — mark a feature complete and move it to `features/COMPLETED.md`
- `devproc/skills/review-full/SKILL.md` — full-codebase code review; auto-applies code-level findings, escalates architectural changes
- `devproc/skills/review-component/SKILL.md` — code review scoped to a described component (resolves natural-language description to files)
- `devproc/skills/review-branch/SKILL.md` — code review scoped to files changed in the current branch (uses git diff for scope and context)
- `devproc/agents/dev-process-manager.md` — top-level Opus orchestrator (`claude --agent dev-process-manager`); drives the feature workflow by spawning teammates per sub-task, reviewing their work, and checking in with the user
- `devproc/agents/feature-spec-reviewer.md` — reviews a feature spec (requirements and sign-off strategy) before a human reads it, ending with a `READY FOR USER REVIEW` / `NEEDS WORK` verdict
- `devproc/agents/feature-design-reviewer.md` — reviews a feature design and its sub-task plan (requirement coverage, recorded rationale, auditable criteria) before a human reads it, ending with the same verdict
- `devproc/agents/docs-structure-reviewer.md` — audits documentation structure and quality, producing actionable findings
- `devproc/agents/code-review-architectural.md` — architectural review agent (`claude-opus-4-6`)
- `devproc/agents/code-review-simplicity.md` — simplicity and dead-code review agent
- `devproc/agents/code-review-general.md` — correctness and robustness review agent
- `devproc/agents/code-review-nitty.md` — low-level readability and naming review agent

See `devproc/README.md` for full usage documentation.

## setup-files directory

Location: `setup-files/`

Files referenced by `docs/setup.md` that users copy into their environments rather than recreate from heredocs. Each file is paired with a setup.md section that describes where it goes and what it does.

Contents:
- `setup-files/.claudeignore` — recommended `.claudeignore` for project roots
- `setup-files/block-git-writes.sh` — `PreToolUse` hook that blocks Bash `git` write commands
- `setup-files/README.md` — destination, purpose, and back-link to setup.md per file

When adding a new file here, also add an entry to `setup-files/README.md` and a "copy from `/some/path/claudeplugins/setup-files/...`" instruction in `docs/setup.md`.

## Container mode

Location: `docker/` (image definition) and `bin/` (wrapper scripts)

Docker-based isolation mode that runs Claude with full permissions inside a container, with the project directory mounted read-write.

Contents:
- `docker/Dockerfile` — Ubuntu base with Claude Code, python3, tmux; bakes in plugins and a YOLO `~/.claude/` config
- `docker/files/home/.claude/CLAUDE.md` — global CLAUDE.md inside the container (full-permissions framing)
- `docker/files/home/.claude/settings.json` — bypass-permissions mode, devproc plugin enabled
- `docker/files/home/entrypoint.sh` — container entrypoint; starts the detached tmux session running `run-claude.sh`
- `docker/files/home/run-claude.sh` — keep-alive loop that auto-relaunches Claude (via `claude --continue`) on exit so the tmux session survives `exit`/Ctrl-D/Ctrl-C
- `bin/claude-build` — builds the `claudedev` image with host UID/GID baked in
- `bin/claude-run` — starts a detached container for a project directory; `--manager`/`--agent NAME` selects a top-level agent and `--model NAME` (default: derived from the agent's `model:` field) its session model, passed through via `CLAUDE_AGENT`/`CLAUDE_MODEL`
- `bin/claude-attach` — attaches to the tmux session in a running container
- `bin/claude-stop` — stops and removes the container

See [docs/container.md](docs/container.md) for full usage documentation.

## Feature model

Major pieces of work are organised into features. Each feature has a concise entry in one of the feature-list files under `features/` and a detailed plan file in `features/plans/`.

Use these slash commands (defined in the `devproc` plugin) to manage features
through their lifecycle — **spec → design → implement → end**:

- `/feature-spec` — create a new feature in `features/PENDING.md`, write its specification into the plan file, and agree the feature's **sign-off strategy**
- `/feature-design` — move a feature to `features/CURRENT.md`, write its design and sub-task plan, and agree the **sign-off criteria** for each sub-task
- *(implementation has no slash command — work through the sub-tasks directly; a sub-task is complete only when all its sign-off boxes are ticked)*
- `/feature-checkpoint` — during implementation, sync all feature documentation and plans to the current state (run after each sub-task and when prompted within subtasks)
- `/feature-end` — mark a feature complete and move it to `features/COMPLETED.md`

`NOTES.md` is maintained continuously. Any non-obvious technical finding — page structure quirks, API behaviour, design decisions, scope changes — goes there as it is discovered.

### Sign-off criteria

Every feature defines explicit sign-off criteria, so quality steps are a
deliberate choice rather than something quietly skipped. Four categories cover
the most likely sign-offs:

- **Testing** — manual or automated checks that the work behaves correctly.
- **Documentation** — user and architectural docs updated to reflect the change.
- **Code review** — review of the change (a light per-sub-task agent review, or a full `/review-branch`).
- **User review** — the user sees and confirms the work.

These four are the usual set, not a closed list: a feature's strategy may split
one into separate sign-offs (e.g. unit tests and manual tests confirmed at
different stages) or add a specific sign-off of another kind (e.g. "agent X has
confirmed the output"). Do not invent sign-offs for their own sake, but do
capture whatever genuinely gates the work.

Every sign-off criterion must be **auditable**: when a sub-task is finished it
must be unambiguous whether the criterion is met. "Have some tests" is not
auditable; "unit tests written to the agreed quality bar" is, and so is "enough
tests that the user confirms coverage is sufficient" — each has a clear
done/not-done point. Word every criterion so it has a definite yes/no.

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

- **`features/`** — the feature list, split across four files so the (large) completed list need not be read into context every session. Each entry is a level-3 (`###`) heading with name and slug, one paragraph max — no sub-task lists, no implementation detail, no tables; link to the plan file for detail.

    - `CURRENT.md` — feature(s) in progress (normally exactly one)
    - `PENDING.md` — features waiting for development
    - `DEFERRED.md` — features explicitly deferred, including those blocked by a dependency (not expected to happen, but may be resurrected)
    - `COMPLETED.md` — completed features; headings end with the completion date in YYYY-MM-DD format

- **`features/plans/<slug>.md`**

    Plan for a feature. Should have sections for:

    - Handoff (session state — last updated date, summary, current sub-task, first action next session, open questions, dead ends)

    - Requirements (the full relevant content from the source issue, if the feature came from one — enough to resume without re-reading the issue)

    - Sign-off strategy (the quality bar per category — testing, docs, code review, user review — agreed at `/feature-spec`)

    - Design (implementation strategy)

    - Subtask list with short descriptions, per-sub-task sign-off checkboxes, and status markers (`✓`, `▶ NEXT:`)

    - Review record (a log, appended by `/feature-spec` and `/feature-design`, of what review happened at each lifecycle stage — the reviewing agent's verdict, or `N/A` when the review was skipped. Always the last section of the file; a line is written every time, so an absent line means the stage has not run. Preserve it across edits.)

- **`NOTES.md`** — non-obvious findings only. Do not record things derivable from reading the code.

- **`CLAUDE.md`** — high-level status only. No plan detail, no implementation notes.
