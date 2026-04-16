---
name: Project structure
description: Entry points, document hierarchy, plugin layout, and linking conventions for the claudeplugins repo
type: project
---

## Entry points

- `README.md` — primary landing page; reframed as "Claude Code setup and workflows"; links to docs/setup.md, docs/workflow.md, docs/capabilities.md, devproc/README.md, demo/README.md, marketplace.json
- `CLAUDE.md` — agent entry point; workspace guide, plugin inventory with links to plugin READMEs, full feature model section
- `docs/setup.md` — getting-started guide for new users (sandbox, git hook, gh CLI, devproc install)
- `docs/workflow.md` — imperative feature lifecycle guide
- `docs/capabilities.md` — code review and documentation review reference
- `devproc/README.md` — plugin reference; links back to docs/workflow.md and docs/capabilities.md
- `FEATURES.md` — feature index (In Progress / Pending / Deferred / Completed); links to plan files

## Document hierarchy

```
README.md                        (landing page — reframed as "Claude Code setup and workflows")
CLAUDE.md                        (agent entry point — authoritative guide)
docs/setup.md                    (getting-started: sandbox, git hook, gh CLI, devproc install)
docs/workflow.md                 (imperative feature lifecycle guide)
docs/capabilities.md             (code review + docs review reference)
FEATURES.md                      (feature index)
  → plans/<slug>.md              (per-feature plan: Handoff / Design / Sub-tasks)
NOTES.md                         (non-obvious findings — exists, populated)
demo/README.md                   (plugin user docs — complete)
  demo/.claude-plugin/plugin.json
  demo/skills/demo-skill/SKILL.md
  demo/agents/demo-agent.md
devproc/README.md                (plugin reference — trimmed; links to docs/ for task-oriented view)
  devproc/.claude-plugin/plugin.json
  devproc/skills/feature-*/SKILL.md  (5 skills: feature-init, feature-create, feature-start, feature-checkpoint, feature-end)
  devproc/skills/review-*/SKILL.md   (3 skills: review-full, review-component, review-branch)
  devproc/agents/docs-structure-reviewer.md
  devproc/agents/code-review-architectural.md
  devproc/agents/code-review-simplicity.md
  devproc/agents/code-review-general.md
  devproc/agents/code-review-nitty.md
.claude-plugin/marketplace.json  (plugin registry — referenced from README.md)
CONTRIBUTING.md                  (contribution guidelines — NOT linked from README.md or any entry point)
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

- 2026-04-16: Seventh review (docs-usability-issue6 feature, all 5 sub-tasks complete). New docs/ directory with setup.md, workflow.md, capabilities.md. Key findings: (1) MAJOR: setup.md JSON block missing comma between "sandbox" and "hooks" objects — invalid JSON that would break copy-paste. (2) MAJOR: setup.md step 1 says "Check prerequisites above" but Prerequisites section is below — word "above" is wrong. (3) MINOR: setup.md says "iOS" where it means "macOS". (4) MINOR: CONTRIBUTING.md is orphaned — not linked from README.md or any entry point. (5) MINOR: devproc/README.md feature-create description mentions Requirements section in plan file but this is an optional edge-case behaviour not part of the standard plan schema — mildly confusing. (6) MINOR: setup.md typo "standboxed".
- 2026-04-16: Eighth review (re-audit after 7 fixes applied). All 7 claimed fixes verified correct. Two new issues found: (1) MINOR: docs/workflow.md line 17 has an unclosed parenthesis in the "Add a feature to the backlog" section — "(which would normally imply a small hobby project with less tracking." is never closed with ")". (2) SUGGESTION: docs/capabilities.md "### Architectural review" heading has a double blank line before its first paragraph — cosmetic.
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
