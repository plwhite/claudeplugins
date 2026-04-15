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
README.md                        (landing page — proper orientation page)
CLAUDE.md                        (agent entry point — authoritative guide)
FEATURES.md                      (feature index)
  → plans/<slug>.md              (per-feature plan: Handoff / Design / Sub-tasks)
NOTES.md                         (non-obvious findings — prescribed but created on first use)
demo/README.md                   (plugin user docs — complete)
  demo/.claude-plugin/plugin.json
  demo/skills/demo-skill/SKILL.md
  demo/agents/demo-agent.md
devproc/README.md                (plugin user docs — complete)
  devproc/.claude-plugin/plugin.json
  devproc/skills/feature-*/SKILL.md  (5 skills)
  devproc/skills/review-*/SKILL.md   (3 skills: review-full, review-component, review-branch)
  devproc/agents/docs-structure-reviewer.md
  devproc/agents/code-review-architectural.md
  devproc/agents/code-review-simplicity.md
  devproc/agents/code-review-general.md
  devproc/agents/code-review-nitty.md
.claude-plugin/marketplace.json  (plugin registry — referenced from README.md)
```

## Conventions observed

- Plugin layout: `.claude-plugin/plugin.json` + `skills/<name>/SKILL.md` + `agents/<name>.md`
- SKILL.md files use YAML frontmatter (name, description; optionally user-invocable, argument-hint, disable-model-invocation)
- Plan files always have ## Handoff as first section, then ## Design, then ## Sub-tasks (no ## Requirements)
- FEATURES.md uses ### headings with [slug] tags
- NOTES.md is prescribed but not yet created (not a problem — it is created on first use)
- marketplace.json at root `.claude-plugin/` is referenced from README.md
- Agent files use YAML frontmatter: name, description (multi-line with examples), tools, model, color; optionally memory

## Review history

- 2026-04-13: First review. Key issues: README.md too sparse; marketplace.json orphaned; devproc plugin.json description weak; FEATURES.md "In Progress" guideline note absent; feature-end SKILL.md has duplicate step number 4.
- 2026-04-13: Second review (follow-up). All prior CRITICAL and MAJOR issues resolved. One new MAJOR found: feature-init SKILL.md plan-file template omits Handoff section (present in feature-start template but not feature-init template). One MINOR remaining: CLAUDE.md "Documents to support the model" plan file description omits Handoff from section list.
- 2026-04-13: Third review. Both second-review issues confirmed fixed. New findings:
  - MAJOR: docs-structure-reviewer.md has a broken `<example` tag (line 45, missing `>`) that truncates the frontmatter description prematurely.
  - MINOR: CLAUDE.md plugin layout diagram shows only `user-invocable` as a SKILL.md frontmatter field; actual fields also include `argument-hint` and `disable-model-invocation`.
  - MINOR: CLAUDE.md and feature-init SKILL.md prescribe a "Requirements" section for plan files; feature-start SKILL.md template and actual plan files do not include it — schema drift between documentation and generated artifacts.
- 2026-04-13: Fourth review. All three third-review issues confirmed fixed. One new MINOR found:
  - MINOR: feature-start/SKILL.md step 4 contained Wikipedia-specific example — resolved.
- 2026-04-14: Fifth review (post code-review feature). New findings:
  - MAJOR (persistent): docs-structure-reviewer.md line 45 — third `<example>` tag still open and unterminated; bleeds into frontmatter closing delimiter. Previously claimed fixed but was NOT fixed. This is a recurring issue.
  - MAJOR: FEATURES.md still shows code-review feature as "In Progress" with all sub-tasks complete in the plan file — feature was not closed with /feature-end.
  - MINOR: plans/code-review.md has a ## Requirements section not prescribed by current plan schema (schema was normalised to remove Requirements in an earlier review). Low impact since it is a historical artifact.
- 2026-04-14: Sixth review (targeted follow-up). All four targeted fixes confirmed applied and correct:
  1. docs-structure-reviewer.md — third `<example>` properly closed; RECURRING MAJOR now RESOLVED.
  2. plans/code-review.md — ## Requirements section removed; MINOR now RESOLVED.
  3. Cross-reference note after Step 3 in all three review skills — present and correctly placed; NEW issues RESOLVED.
  4. review-branch/SKILL.md "and why" removed — RESOLVED.
  - Carryover: FEATURES.md code-review still In Progress (process gap, not targeted by this fix pass).
  - No new findings identified.
