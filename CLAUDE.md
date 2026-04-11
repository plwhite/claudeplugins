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
