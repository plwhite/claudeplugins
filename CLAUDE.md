# Workspace guide (Claude plugins)

## Current status

No feature in progress.

`remove-migration-code` completed 2026-08-28 — removed `/feature-init`'s legacy-layout migration (the workspace-root `FEATURES.md`, `plans/` and `notes/` checks), leaving it a setup-only skill with nothing added in place of what was removed; the `CLAUDE.md` normalisation in step 1c was deliberately kept, as correcting state rather than migrating a layout (#64). See `features/COMPLETED.md` for detail.

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
- `devproc/skills/feature-init/SKILL.md` — one-time setup: copies the canonical `FEATUREMODEL.md` shipped with the skill to `features/FEATUREMODEL.md`, ensures `CLAUDE.md`'s `## Feature model` section holds the `@features/FEATUREMODEL.md` import, and creates the `features/` directory including a `features/tmp` scratch directory (git-ignored in a tracked workspace)
- `devproc/skills/feature-spec/SKILL.md` — create a new feature in `features/PENDING.md`, capture the input as `## Requirements` and write `## Spec` (what the feature must do) into the plan file, from a GitHub issue, a one-line description, or requirements material staged in `features/tmp`
- `devproc/skills/feature-design/SKILL.md` — move a feature to `features/CURRENT.md` and write its design (overview first) and sub-task plan; may amend `## Spec` with the user's approval
- `devproc/skills/feature-checkpoint/SKILL.md` — sync all documentation to current state
- `devproc/skills/feature-end/SKILL.md` — mark a feature complete and move it to `features/COMPLETED.md`
- `devproc/skills/review-full/SKILL.md` — full-codebase code review; auto-applies code-level findings, escalates architectural changes
- `devproc/skills/review-component/SKILL.md` — code review scoped to a described component (resolves natural-language description to files)
- `devproc/skills/review-branch/SKILL.md` — code review scoped to files changed in the current branch (uses git diff for scope and context)
- `devproc/skills/internal-docs-prune/SKILL.md` — prune internal Claude-facing docs (root and nested `CLAUDE.md` files, `NOTES.md`, `.claude/rules/*.md`): spawn `internal-docs-reviewer`, auto-apply redundant/stale findings without content loss, escalate or defer judgment findings
- `devproc/agents/dev-process-manager.md` — top-level Opus orchestrator (`claude --agent dev-process-manager`); drives the feature workflow by spawning teammates per sub-task, reviewing their work, and checking in with the user
- `devproc/agents/feature-spec-reviewer.md` — reviews a feature spec (`## Spec` and sign-off strategy, including clarity against the `### Readability` standard) before a human reads it, ending with a `READY FOR USER REVIEW` / `NEEDS WORK` verdict
- `devproc/agents/feature-design-reviewer.md` — reviews a feature design (`## Design`) and its sub-task plan (`## Spec` coverage, design clarity, recorded rationale, auditable criteria) before a human reads it, ending with the same verdict
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

## tests directory

Location: `tests/`

Test fixtures for the `devproc` plugin's reviewer agents, deliberately kept outside the shipped `devproc/` directory so the plugin a consumer installs carries no test material. Maintainer-only; a consumer of the plugin has no use for it. Tests are namespaced by what they test — `tests/devproc/` holds the `devproc` plugin's, leaving room for other areas.

Contents:
- `tests/devproc/feature-spec-reviewer/` — fixtures for `feature-spec-reviewer`
- `tests/devproc/feature-design-reviewer/` — fixtures for `feature-design-reviewer`
- `tests/devproc/internal-docs-reviewer/` — fixtures for `internal-docs-reviewer`
- `tests/devproc/harness/` — `run.sh`, a regression harness that runs the `feature-spec-reviewer` and `feature-design-reviewer` suites (not `internal-docs-reviewer`, which needs a different invocation shape) and writes output to its git-ignored `out/`

Each suite pairs deliberately flawed inputs with recorded `.expected.md` outputs, and carries its own `README.md` explaining how to run it. `tests/README.md` indexes the area.

When adding a suite here, give it a `README.md`, add a bullet above, add a row to `tests/README.md`, and check whether `tests/devproc/harness/run.sh` can cover it.

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
- `bin/claude-creds-refresh` — refreshes OAuth credentials in a running container mid-session (they are copied in at start, not bind-mounted, so a long session can outlive them)
- `bin/claude-stop` — stops and removes the container

See [docs/container.md](docs/container.md) for full usage documentation.

## Feature model

The feature model for this project — lifecycle, sign-off criteria, and the documents that support it — is defined in @features/FEATUREMODEL.md and applies at all times.
