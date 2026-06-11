# Plugin documentation — Feature Plan

## Handoff

**Last updated:** 2026-04-13
**Session summary:** Both READMEs written and approved by user. Feature complete.
**Sub-task in progress:** None — all complete
**First action next session:** N/A — feature ended
**Open questions / decisions pending:** None
**Dead ends to avoid:** None

## Design

Each plugin directory gets a `README.md` aimed at a user who has just discovered the plugin and wants to understand what it does and how to use it. Content is derived from the `plugin.json` manifest, the skill and agent `*.md` files, and the SKILL.md frontmatter.

**demo plugin** — one skill (`demo-skill`) and one agent (`demo-agent`), both intentionally trivial. The README should explain the plugin's purpose (verifying plugin wiring), list the skill and agent, and document their contracts.

**devproc plugin** — five lifecycle skills (`feature-init`, `feature-create`, `feature-start`, `feature-checkpoint`, `feature-end`). The README should describe the feature workflow, explain when each skill is used, and show the slash-command invocations.

Both READMEs live at the plugin root (e.g. `demo/README.md`) so they are discoverable alongside the plugin manifest.

## Sub-tasks

1. ✓ **demo README** — write `demo/README.md` documenting the plugin purpose, `demo-skill`, and `demo-agent` (2026-04-13)
2. ✓ **devproc README** — write `devproc/README.md` documenting the feature lifecycle workflow and all five skills (2026-04-13)

**All sub-tasks complete.**
