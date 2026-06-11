---
name: Project structure
description: Entry points, document hierarchy, plugin layout, and linking conventions for the claudeplugins repo
type: project
---

## Entry points

- `README.md` — primary landing page ("Claude Code setup and workflows"); Instructions list + Documentation table + Plugins table; links to docs/{setup,workflow,capabilities,container}.md, devproc/README.md, demo/README.md, setup-files/README.md, marketplace.json, CONTRIBUTING.md
- `CLAUDE.md` — agent entry point; workspace guide, plugin inventory, full feature-model section
- `docs/setup.md` — getting-started (sandbox, git hook, sensitive-file deny-list, gh, devproc install, .claudeignore) — 8 ordered steps
- `docs/workflow.md` — imperative feature lifecycle guide (spec → design → implement → end)
- `docs/capabilities.md` — dev process manager + code review + docs review reference
- `docs/container.md` — container mode procedural guide (build/run/attach/stop, manager mode, session model)
- `devproc/README.md` — plugin reference; links back to docs/workflow.md and docs/capabilities.md
- `features/` — feature index directory (replaced FEATURES.md as of split-features-md, #14). NOT linked from README.md.

## Current feature-tracking layout (post #14, split-features-md, 2026-06-11)

- `features/CURRENT.md` / `PENDING.md` / `DEFERRED.md` / `COMPLETED.md` — status-split list files (replaced single `FEATURES.md`)
- `features/plans/<slug>.md` — per-feature plans (moved from top-level `plans/`)
- Lifecycle skills renamed: `feature-create`→`feature-spec`, `feature-start`→`feature-design`. Flow = **spec → design → implement → end**. `feature-init` = one-time setup/migration; `feature-checkpoint` = during-implementation sync.
- Plan-file schema now: Handoff / Requirements / Design / Sub-tasks (Requirements is back — captures full source-issue spec).

## Conventions observed

- Plugin layout: `.claude-plugin/plugin.json` + `skills/<name>/SKILL.md` + `agents/<name>.md`
- SKILL.md frontmatter: name, description; optionally argument-hint, disable-model-invocation
- Agent frontmatter: name, description (multi-line w/ examples), tools, model, color; optionally memory
- Feature list files use `###` headings with `[slug]` tags; COMPLETED headings end with YYYY-MM-DD
- bin/ = 4 wrapper scripts (claude-build/run/attach/stop); docker/ = Dockerfile + baked config; both inventoried in CLAUDE.md ## Container mode
- Out-of-scope for audits: historical plan files under `features/plans/*.md` and `.claude/agent-memory/` snapshots retain old names/paths as point-in-time records.

## Review history (older entries: see recurring_issues.md and git log)

- 2026-06-11: Eighteenth review (split-features-md, #14 close-out). Verified all live docs migrated to features/ layout + spec/design rename with NO stale references. Live docs all consistent. Findings were minor/suggestion only (see recurring_issues.md). README Documentation table does not surface features/ directory — navigability gap (feature tracking not discoverable from landing page).
