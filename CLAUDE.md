# Workspace guide (Claude plugins)

This repository contains small “plugin” folders that package:
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

Contents:
- `demo/.claude-plugin/plugin.json`
- `demo/skills/demo-skill/SKILL.md`
- `demo/agents/demo-agent.md`
- `demo/test.sh`

### Smoke test

From the repo root:

```bash
bash demo/test.sh
```

This test only checks that the files exist and contain the expected minimal frontmatter markers.
