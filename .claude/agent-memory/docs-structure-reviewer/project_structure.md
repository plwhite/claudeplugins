---
name: Project structure
description: Entry points, document hierarchy, plugin layout, and linking conventions for the claudeplugins repo
type: project
---

## Entry points

- `README.md` — primary landing page; describes what plugins are, lists both plugins with links to their READMEs, references marketplace.json, links to CLAUDE.md and FEATURES.md
- `CLAUDE.md` — agent entry point; workspace guide, plugin inventory with links to plugin READMEs, full feature model section
- `FEATURES.md` — feature index (In Progress / Pending / Deferred / Completed); links to plan files

## Document hierarchy

```
README.md                        (landing page — now a proper orientation page)
CLAUDE.md                        (agent entry point — authoritative guide)
FEATURES.md                      (feature index)
  → plans/<slug>.md              (per-feature plan: Handoff / Design / Sub-tasks)
NOTES.md                         (non-obvious findings — prescribed but created on first use)
demo/README.md                   (plugin user docs — now exists and is complete)
  demo/.claude-plugin/plugin.json
  demo/skills/demo-skill/SKILL.md
  demo/agents/demo-agent.md
devproc/README.md                (plugin user docs — now exists and is complete)
  devproc/.claude-plugin/plugin.json
  devproc/skills/feature-*/SKILL.md  (5 skills)
.claude-plugin/marketplace.json  (plugin registry — now referenced from README.md)
```

## Conventions observed

- Plugin layout: `.claude-plugin/plugin.json` + `skills/<name>/SKILL.md` + `agents/<name>.md`
- SKILL.md files use YAML frontmatter (name, description, user-invocable or argument-hint)
- Plan files always have ## Handoff as first section, then ## Design, then ## Sub-tasks
- FEATURES.md uses ### headings with [slug] tags
- NOTES.md is prescribed but not yet created (not a problem — it is created on first use)
- marketplace.json at root `.claude-plugin/` is now referenced from README.md

## Review history

- 2026-04-13: First review. Key issues: README.md too sparse; marketplace.json orphaned; devproc plugin.json description weak; FEATURES.md "In Progress" guideline note absent; feature-end SKILL.md has duplicate step number 4.
- 2026-04-13: Second review (follow-up). All prior CRITICAL and MAJOR issues resolved. One new MAJOR found: feature-init SKILL.md plan-file template omits Handoff section (present in feature-start template but not feature-init template). One MINOR remaining: CLAUDE.md "Documents to support the model" plan file description omits Handoff from section list.
