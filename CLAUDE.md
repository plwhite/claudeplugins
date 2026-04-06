# Workspace guide (Claude plugins)

This repository contains small “plugin” folders that package:
- skills (prompt/behavior docs)
- agents (agent definitions that reference skills)

## demo plugin

Location: `demo/`

Contents:
- `demo/skills/demo-skill.md`
- `demo/agents/demo-agent.md`
- `demo/test.sh`

### Smoke test

From the repo root:

```bash
bash demo/test.sh
```

This test only checks that the files exist and contain the expected minimal frontmatter markers.
