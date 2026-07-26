---
name: Project structure
description: Entry points, document hierarchy, plugin layout, and linking conventions for the claudeplugins repo
type: project
---

## Entry points

- `README.md` — primary landing page ("Claude Code setup and workflows"); Instructions list + Documentation table + Plugins table; links to docs/{setup,workflow,capabilities,container}.md, devproc/README.md, setup-files/README.md, marketplace.json, CONTRIBUTING.md. (demo/README.md link REMOVED by delete-demo-plugin, #42, 2026-07-24 — demo plugin deleted; devproc is now the only plugin.)
- `CLAUDE.md` — agent entry point; workspace guide, plugin inventory, full feature-model section
- `docs/setup.md` — getting-started (sandbox, git hook, sensitive-file deny-list, gh, devproc install, .claudeignore) — 8 ordered steps
- `docs/workflow.md` — imperative feature lifecycle guide (spec → design → implement → end)
- `docs/capabilities.md` — dev process manager + code review + docs review reference
- `docs/container.md` — container mode procedural guide (build/run/attach/stop, manager mode, session model)
- `devproc/README.md` — plugin reference; links back to docs/workflow.md and docs/capabilities.md
- `features/` — feature index directory (replaced FEATURES.md as of split-features-md, #14). NOT linked from README.md.
- `features/FEATUREMODEL.md` (post extract-feature-model, #43, 2026-07-26) — the whole feature-model boilerplate (lifecycle + `### Sign-off criteria` + `### Resuming` + `### Documents to support the model`), moved OUT of CLAUDE.md. Loaded via an un-backticked `@features/FEATUREMODEL.md` import in CLAUDE.md `## Feature model` (now a 1-line pointer, CLAUDE.md ~90 lines). Byte-identical twin shipped at `devproc/skills/feature-init/FEATUREMODEL.md` (canonical master); `/feature-init` REFRESHES (overwrites) the project copy from it on EVERY run — it is the one file feature-init overwrites, not preserves. File deliberately has NO top-level heading (CLAUDE.md `## Feature model` supplies H2); read standalone it opens on body text, first heading is H3 `### Sign-off criteria`. All ~10 live refs + 4 feature-skill precondition checks + both reviewer agents + dev-process-manager now point at `features/FEATUREMODEL.md` — migration complete, no stale "CLAUDE.md ### Sign-off criteria" refs in live docs. NOT surfaced from README.md features/ row.

## Current feature-tracking layout (post #14, split-features-md, 2026-06-11)

- `features/CURRENT.md` / `PENDING.md` / `DEFERRED.md` / `COMPLETED.md` — status-split list files (replaced single `FEATURES.md`)
- `features/plans/<slug>.md` — per-feature plans (moved from top-level `plans/`)
- Lifecycle skills renamed: `feature-create`→`feature-spec`, `feature-start`→`feature-design`. Flow = **spec → design → implement → end**. `feature-init` = one-time setup/migration; `feature-checkpoint` = during-implementation sync.
- Plan-file schema now: Handoff / Requirements / Sign-off strategy / Design / Sub-tasks / Review record.
- `features/tmp/` (post spec-requirements-input, 2026-07-24): git-ignored `/feature-spec` staging scratch dir; only tracked file is `features/tmp/README.md`. `.gitignore` = `features/tmp/*` then `!features/tmp/README.md`. Third `/feature-spec` input route (alongside description + GitHub issue). Documented in workflow.md, devproc/README.md, CLAUDE.md "Documents to support the model", both feature-init/feature-spec SKILLs. feature-init template README + CLAUDE.md tmp bullet are byte-identical-invariant copies.

## Conventions observed

- Plugin layout: `.claude-plugin/plugin.json` + `skills/<name>/SKILL.md` + `agents/<name>.md`
- SKILL.md frontmatter: name, description; optionally argument-hint, disable-model-invocation
- Agent frontmatter: name, description (multi-line w/ examples), tools, model, color; optionally memory
- Feature list files use `###` headings with `[slug]` tags; COMPLETED headings end with YYYY-MM-DD
- bin/ = 4 wrapper scripts (claude-build/run/attach/stop); docker/ = Dockerfile + baked config; both inventoried in CLAUDE.md ## Container mode
- Out-of-scope for audits: historical plan files under `features/plans/*.md` and `.claude/agent-memory/` snapshots retain old names/paths as point-in-time records.

## Agent memory path (post #23, docs-reviewer-memory-path, 2026-06-16)

- RESOLVED (twentieth review re-audit, 2026-06-16): the prompt prose now points to `$CLAUDE_PROJECT_DIR/.claude/agent-memory/devproc-docs-structure-reviewer/` (both refs, lines 185/195) with a parenthetical explaining the `devproc-` plugin-namespace prefix. NOTES.md and COMPLETED.md updated to match. The LIVE tree is `devproc-docs-structure-reviewer/` (full review history). The stale unprefixed `docs-structure-reviewer/` tree remains on disk — flagged to user for manual deletion (agent does not delete files); not a doc defect.

## Review history (older entries: see recurring_issues.md and git log)

- 2026-07-26: Thirty-first review (unpin-agent-model-versions, #48 close-out). Four `devproc/agents/code-review-*.md` moved from pinned dated `model:` ids to unpinned family aliases (`opus`/`sonnet`); CLAUDE.md/devproc/README.md/docs/capabilities.md synced with symmetric tier annotations. Fully converged, 0 CRITICAL/MAJOR. One new MINOR class identified: a feature can render NOTES.md entries stale even when the feature's own spec deliberately scopes NOTES.md out of its edits (NOTES.md L97-99/151-154 now cite a defunct pinned id as if current) — flag this pattern in future reviews when a feature explicitly "leaves NOTES.md untouched as historical record" but NOTES.md's untouched text makes a present-tense factual claim about the very thing being changed. Also confirmed the 30th-review canonical-sync divergence (CLAUDE.md vs feature-init template `**CLAUDE.md**` bullet, short vs long form) is now RESOLVED — both byte-identical with the cap prose.
- 2026-06-16: Twentieth review (docs-reviewer-memory-path, #23 close-out). Feature-tracking files (CURRENT/COMPLETED/PENDING/DEFERRED.md, CLAUDE.md status, NOTES.md, plan) all internally consistent and well-formed; no close-out status drift. Agent prompt memory path correctly anchored to $CLAUDE_PROJECT_DIR. Findings: orphaned duplicate memory tree (docs-structure-reviewer/ vs devproc-docs-structure-reviewer/); prompt path string does not match the runtime-namespaced live dir; features/ still not in README Documentation table (carryover, now MINOR/recurring).
- 2026-06-11: Eighteenth review (split-features-md, #14 close-out). Verified all live docs migrated to features/ layout + spec/design rename with NO stale references. Live docs all consistent. Findings were minor/suggestion only (see recurring_issues.md). README Documentation table does not surface features/ directory — navigability gap (feature tracking not discoverable from landing page).
