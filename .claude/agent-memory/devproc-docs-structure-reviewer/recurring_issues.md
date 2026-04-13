---
name: Recurring issues
description: Structural and style problems observed across reviews of this repo
type: project
---

## First review (2026-04-13)

- README.md is persistently sparse — used as a landing page but gives no orientation beyond a list
- Orphaned infrastructure files (marketplace.json) not referenced from any navigable document
- plugin.json descriptions inconsistent in quality: demo plugin's is good, devproc's is weak
- Step numbering errors in SKILL.md procedural documents (feature-end has duplicate step 4)
- FEATURES.md in the repo is missing the "In Progress" explanatory note that feature-init injects — structural drift between template and live file

## Second review (2026-04-13) — fixes applied and verified

All first-review findings confirmed resolved:
- README.md is now a proper landing page with orientation, plugin table, registry explanation, and links
- marketplace.json is now referenced from README.md
- devproc plugin.json description is now substantive
- feature-end SKILL.md step numbering is now correct (steps 1–6, no duplicate)
- FEATURES.md "In Progress" explanatory note is now present
- CLAUDE.md links to plugin READMEs added
- devproc/README.md Setup section includes "safe to re-run" note
- Workflow block in devproc/README.md uses /feature-checkpoint consistently

## Issues found in second review — resolved by third review

Both confirmed fixed:
- feature-init SKILL.md plan-file template now includes Handoff as first listed section (line 49)
- CLAUDE.md "Documents to support the model" plan file bullet now lists Handoff first

## New issues found in third review (2026-04-13) — all resolved by fourth review

All three confirmed fixed:
- docs-structure-reviewer.md: broken `<example` tag at line 45 (missing `>`) — now properly closed
- Schema drift: CLAUDE.md plugin layout diagram now includes `argument-hint` and `disable-model-invocation`
- Schema drift: "Requirements" section removed from plan file schema in CLAUDE.md and feature-init SKILL.md

## New issues found in fourth review (2026-04-13)

- Stale artefact: feature-start/SKILL.md step 4 bullet mentions Wikipedia pages specifically — a project-specific example from a prior codebase that should be replaced with a generic example. Recurring pattern risk: SKILL.md files imported from other projects may carry context-specific examples that are misleading when the plugin is used generally.
