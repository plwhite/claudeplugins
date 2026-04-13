# Workspace guide (Claude plugins)

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
      SKILL.md           ← frontmatter: name, description, user-invocable
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

Dev process skills for managing features through their lifecycle.

Contents:
- `devproc/.claude-plugin/plugin.json`
- `devproc/skills/feature-init/SKILL.md` — one-time setup: writes feature model to CLAUDE.md, creates FEATURES.md and plans/
- `devproc/skills/feature-create/SKILL.md` — add a new feature to FEATURES.md
- `devproc/skills/feature-start/SKILL.md` — move a feature to In Progress and create its plan file
- `devproc/skills/feature-checkpoint/SKILL.md` — sync all documentation to current state
- `devproc/skills/feature-end/SKILL.md` — mark a feature complete and move it to Completed

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

    - Requirements (potentially more detail than in `FEATURES.md`)

    - Design (implementation strategy)

    - Subtask list with short and status markers (`✓`, `▶ NEXT:`)


- **`NOTES.md`** — non-obvious findings only. Do not record things derivable from reading the code.

- **`CLAUDE.md`** — high-level status only. No plan detail, no implementation notes.
