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

## New issue found in second review

- feature-init SKILL.md plan-file template (lines 49–53) omits Handoff from the section list, while feature-start SKILL.md correctly includes Handoff as the first section. This creates a discrepancy between the two templates that could confuse a reader comparing them — and means /feature-init gives an incomplete picture of what a plan file contains.
- CLAUDE.md "Documents to support the model" plan file bullet also omits Handoff from the listed sections (lists Requirements, Design, Subtask list — no Handoff).
