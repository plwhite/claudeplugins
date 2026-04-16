# Workspace guide (Claude plugins)

## Current status

**In progress:** `docs-usability-issue6` — all 5 sub-tasks complete. Repo repositioned with new `docs/` directory (`setup.md`, `workflow.md`, `capabilities.md`), root README reframed, `devproc/README.md` trimmed to reference doc, and issue-aware resolution added to `feature-create` and `feature-start` skills. Ready for `/feature-end`.

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

Skills and agents for feature lifecycle management and code review.

Contents:
- `devproc/.claude-plugin/plugin.json`
- `devproc/skills/feature-init/SKILL.md` — one-time setup: writes feature model to CLAUDE.md, creates FEATURES.md and plans/
- `devproc/skills/feature-create/SKILL.md` — add a new feature to FEATURES.md
- `devproc/skills/feature-start/SKILL.md` — move a feature to In Progress and create its plan file
- `devproc/skills/feature-checkpoint/SKILL.md` — sync all documentation to current state
- `devproc/skills/feature-end/SKILL.md` — mark a feature complete and move it to Completed
- `devproc/skills/review-full/SKILL.md` — full-codebase code review; auto-applies code-level findings, escalates architectural changes
- `devproc/skills/review-component/SKILL.md` — code review scoped to a described component (resolves natural-language description to files)
- `devproc/skills/review-branch/SKILL.md` — code review scoped to files changed in the current branch (uses git diff for scope and context)
- `devproc/agents/docs-structure-reviewer.md` — audits documentation structure and quality, producing actionable findings
- `devproc/agents/code-review-architectural.md` — architectural review agent (`claude-opus-4-6`)
- `devproc/agents/code-review-simplicity.md` — simplicity and dead-code review agent
- `devproc/agents/code-review-general.md` — correctness and robustness review agent
- `devproc/agents/code-review-nitty.md` — low-level readability and naming review agent

See `devproc/README.md` for full usage documentation.

## Feature model

Major pieces of work are organised into features. Each phase has a concise entry in `FEATURES.md` and a detailed plan file in `plans/`.

Use these slash commands (defined in the `devproc` plugin) to manage features:

- `/feature-create` — add a new feature to `FEATURES.md` (Pending section)
- `/feature-start` — move a feature to In Progress and create its plan file
- `/feature-checkpoint` — sync all feature documentation, plans and user documentation to the current state
- `/feature-end` — mark a feature complete and move it to Completed

`NOTES.md` is maintained continuously. Any non-obvious technical finding — page structure quirks, API behaviour, design decisions, scope changes — goes there as it is discovered.

### Resuming after a session restart

When starting a new session on a feature that is already in progress:

1. Read `FEATURES.md` to find the current in-progress feature and its plan file.
2. Open the plan file and read the `## Handoff` section first — it contains the session summary, current sub-task state, and the specific first action to take.
3. Do not begin implementation until you have read the Handoff section.

### Documents to support the model

These apply at all times, not just when completing features:

- **`FEATURES.md`**

    List of features.

    - Level 3 (`###`) heading with name and slug for the feature.

    — One entry per feature, with one paragraph max. No sub-task lists, no implementation detail, no tables. Link to the plan file for detail.

- **`plans/<slug>.md`**

    Plan for a feature. Should have sections for :

    - Handoff (session state — last updated date, summary, current sub-task, first action next session, open questions, dead ends)

    - Design (implementation strategy)

    - Subtask list with short and status markers (`✓`, `▶ NEXT:`)


- **`NOTES.md`** — non-obvious findings only. Do not record things derivable from reading the code.

- **`CLAUDE.md`** — high-level status only. No plan detail, no implementation notes.
