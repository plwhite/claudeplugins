# Workspace guide (Claude plugins)

## Current status

**No feature currently in progress.**

`split-features-md` completed 2026-06-11 — replaced the single `FEATURES.md` with a `features/` directory (status-split list files `CURRENT.md`/`PENDING.md`/`DEFERRED.md`/`COMPLETED.md` plus per-feature plans under `features/plans/`), so the large completed list no longer loads into context every session. `/feature-init` migrates older layouts; feature creation captures the full source-issue spec in the plan file. The lifecycle skills were also renamed `feature-create`→`feature-spec` and `feature-start`→`feature-design` (flow: spec → design → implement → end).

`dev-process-manager` completed 2026-06-03 — added a top-level Opus "dev process manager" agent (`claude --agent dev-process-manager` / `claude-run --manager`) that orchestrates the feature workflow, spawning a teammate per sub-task and reviewing their work; `claude-run` gained `--manager`/`--agent`/`--model` options passed through via `CLAUDE_AGENT`/`CLAUDE_MODEL`.

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

- `/feature-spec` — create a new feature in `features/PENDING.md` and write its specification into the plan file
- `/feature-design` — move a feature to `features/CURRENT.md` and write its design and sub-task plan
- *(implementation has no slash command — work through the sub-tasks directly)*
- `/feature-checkpoint` — during implementation, sync all feature documentation and plans to the current state (run after each sub-task)
- `/feature-end` — mark a feature complete and move it to `features/COMPLETED.md`

`NOTES.md` is maintained continuously. Any non-obvious technical finding — page structure quirks, API behaviour, design decisions, scope changes — goes there as it is discovered.

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
    - `DEFERRED.md` — features explicitly deferred, including those blocked by a dependency
    - `COMPLETED.md` — completed features; headings end with the completion date in YYYY-MM-DD format

- **`features/plans/<slug>.md`**

    Plan for a feature. Should have sections for:

    - Handoff (session state — last updated date, summary, current sub-task, first action next session, open questions, dead ends)

    - Requirements (the full relevant content from the source issue, if any)

    - Design (implementation strategy)

    - Subtask list with short and status markers (`✓`, `▶ NEXT:`)


- **`NOTES.md`** — non-obvious findings only. Do not record things derivable from reading the code.

- **`CLAUDE.md`** — high-level status only. No plan detail, no implementation notes.
