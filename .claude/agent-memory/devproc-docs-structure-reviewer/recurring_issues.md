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

## New issues found in third review (2026-04-13) — claimed fixed by fourth review

All three claimed fixed, but see fifth review note on docs-structure-reviewer.md:
- docs-structure-reviewer.md: broken `<example` tag at line 45 (missing `>`) — CLAIMED fixed but NOT actually fixed as of fifth review
- Schema drift: CLAUDE.md plugin layout diagram now includes `argument-hint` and `disable-model-invocation` — confirmed fixed
- Schema drift: "Requirements" section removed from plan file schema in CLAUDE.md and feature-init SKILL.md — confirmed fixed

## New issues found in fourth review (2026-04-13) — resolved

- Stale artefact: feature-start/SKILL.md step 4 bullet mentioned Wikipedia pages specifically — confirmed resolved in fifth review (step 4 now uses generic language)

## New issues found in fifth review (2026-04-14)

- MAJOR (recurring/persistent): docs-structure-reviewer.md line 45 — third `<example>` tag open and unterminated. This was claimed fixed after the third review but the fix did not land. The issue is that the YAML frontmatter description field ends at the `---` closing delimiter, and the incomplete `<example>` on line 45 is the last item before that delimiter — the example has no content and no closing tag.
- MAJOR: FEATURES.md still shows code-review feature as "In Progress" with all sub-tasks complete in the plan file. Feature was not closed with /feature-end before this review. Not a documentation quality issue per se — a process gap.
- MINOR: plans/code-review.md has a ## Requirements section that is not part of the current prescribed plan schema (Handoff / Design / Sub-tasks). Low impact since it is a historical artifact from before the schema was normalised.

## Sixth review (2026-04-14) — fixes verified

All four targeted fixes from fifth review confirmed applied:

1. docs-structure-reviewer.md — RESOLVED. The third `<example>` tag (recurring MAJOR) is now properly terminated with `</example>` and includes content and `<commentary>` block. Lines 1–49 of the frontmatter are clean. The `---` closing delimiter is preceded by a proper `</example>` close. This recurring issue is now confirmed fixed.

2. plans/code-review.md — RESOLVED. The `## Requirements` section is gone. File structure is now Handoff → Design → Sub-tasks, matching the prescribed plan schema.

3. Cross-reference note after Step 3 — RESOLVED. All three review skills (review-full, review-component, review-branch) have the blockquote note at the correct position after "Collect all findings from all agents." (review-full line 35, review-component line 41, review-branch line 39).

4. review-branch/SKILL.md "what changed and why" — RESOLVED. Line 17 now reads "so they understand what changed, not just the current file state" — "and why" removed.

## Carryover issue (not in fix scope for sixth review)

- MAJOR (carryover): FEATURES.md still shows code-review feature as "In Progress" despite all sub-tasks being complete. /feature-end was not run. This is a process gap, not a documentation quality defect, but it leaves a stale navigational state.

## Recurring pattern alert (resolved)

The docs-structure-reviewer.md example tag issue appeared in three successive reviews (third, fourth-claimed, fifth-confirmed-not-fixed) before being correctly fixed in the sixth review. Verified by reading lines 40–49 of the frontmatter. Mark this issue closed.
