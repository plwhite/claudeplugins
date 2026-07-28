# Workspace guide (Claude plugins)

## Current status

`extract-feature-model` completed 2026-07-26 — moved the `## Feature model` boilerplate out of `CLAUDE.md` into `features/FEATUREMODEL.md`, loaded every session via a Claude Code `@import`; `feature-init` now ships that canonical file and refreshes each project's copy from it (#43). See `features/COMPLETED.md` for detail.

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
      <data file>        ← optional sibling asset a skill copies into the project at runtime (e.g. feature-init ships FEATUREMODEL.md beside its SKILL.md)
  agents/
    agent-name.md        ← frontmatter: name, description
```

## devproc plugin

Location: `devproc/`

Skills and agents for feature lifecycle management, workflow orchestration, code review, documentation review, and internal docs hygiene.

Contents:
- `devproc/.claude-plugin/plugin.json`
- `devproc/skills/feature-init/SKILL.md` — one-time setup: copies the canonical `FEATUREMODEL.md` shipped with the skill to `features/FEATUREMODEL.md`, adds its `@import` to `CLAUDE.md`, creates the `features/` directory including a git-ignored `features/tmp` scratch directory, and migrates an older `FEATURES.md`/`plans/` layout
- `devproc/skills/feature-spec/SKILL.md` — create a new feature in `features/PENDING.md` and write its specification into the plan file, from a GitHub issue, a one-line description, or requirements material staged in `features/tmp`
- `devproc/skills/feature-design/SKILL.md` — move a feature to `features/CURRENT.md` and write its design and sub-task plan
- `devproc/skills/feature-checkpoint/SKILL.md` — sync all documentation to current state
- `devproc/skills/feature-end/SKILL.md` — mark a feature complete and move it to `features/COMPLETED.md`
- `devproc/skills/review-full/SKILL.md` — full-codebase code review; auto-applies code-level findings, escalates architectural changes
- `devproc/skills/review-component/SKILL.md` — code review scoped to a described component (resolves natural-language description to files)
- `devproc/skills/review-branch/SKILL.md` — code review scoped to files changed in the current branch (uses git diff for scope and context)
- `devproc/skills/internal-docs-prune/SKILL.md` — prune internal Claude-facing docs (root and nested `CLAUDE.md` files, `NOTES.md`, `.claude/rules/*.md`): spawn `internal-docs-reviewer`, auto-apply redundant/stale findings without content loss, escalate or defer judgment findings
- `devproc/agents/dev-process-manager.md` — top-level Opus orchestrator (`claude --agent dev-process-manager`); drives the feature workflow by spawning teammates per sub-task, reviewing their work, and checking in with the user
- `devproc/agents/feature-spec-reviewer.md` — reviews a feature spec (requirements and sign-off strategy) before a human reads it, ending with a `READY FOR USER REVIEW` / `NEEDS WORK` verdict
- `devproc/agents/feature-design-reviewer.md` — reviews a feature design and its sub-task plan (requirement coverage, recorded rationale, auditable criteria) before a human reads it, ending with the same verdict
- `devproc/agents/docs-structure-reviewer.md` — audits documentation structure and quality, producing actionable findings
- `devproc/agents/internal-docs-reviewer.md` — reviews internal Claude-facing docs for redundant, stale, or judgment-call content, producing gated findings (action + class) without modifying files
- `devproc/agents/code-review-architectural.md` — architectural review agent (`opus`)
- `devproc/agents/code-review-simplicity.md` — simplicity and dead-code review agent (`sonnet`)
- `devproc/agents/code-review-general.md` — correctness and robustness review agent (`sonnet`)
- `devproc/agents/code-review-nitty.md` — low-level readability and naming review agent (`sonnet`)

See `devproc/README.md` for full usage documentation.

> **Maintainer note:** the canonical feature-model text is `devproc/skills/feature-init/FEATUREMODEL.md`, which `/feature-init` copies into every project that uses the plugin. This repo dogfoods the plugin, so it also carries its own installed copy at `features/FEATUREMODEL.md` (imported by this `CLAUDE.md`) — maintained by `/feature-init` exactly as in any other project, with no special-casing. **To change the model, edit the canonical `devproc/skills/feature-init/FEATUREMODEL.md` and re-run `/feature-init`**, which refreshes `features/FEATUREMODEL.md` to match. The two hold the same text and will only diverge if the canonical file is hand-edited without re-running `/feature-init`. (The obligation is kept out of `FEATUREMODEL.md` itself, since that file is copied verbatim into consumer projects where the twin does not exist.)

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
- `bin/claude-run` — starts a detached container for a project directory; `--manager`/`--agent NAME` selects a top-level agent and `--model NAME` (default: derived from the agent's `model:` field) its session model, passed through via `CLAUDE_AGENT`/`CLAUDE_MODEL`; also passes `GH_TOKEN` into the container (from the environment, or sourced from `~/.config/gh/env` when unset) so `gh` can read issues there
- `bin/claude-attach` — attaches to the tmux session in a running container
- `bin/claude-stop` — stops and removes the container

See [docs/container.md](docs/container.md) for full usage documentation.

## Feature model

The feature model for this project — lifecycle, sign-off criteria, and the documents that support it — is defined in @features/FEATUREMODEL.md and applies at all times.
