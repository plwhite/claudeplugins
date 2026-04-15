# Code review agents and skills — Feature Plan

## Handoff

**Last updated:** 2026-04-14
**Session summary:** All seven sub-tasks complete. Feature ready to close.
**Sub-task in progress:** None
**First action next session:** N/A — feature complete
**Open questions / decisions pending:** None
**Dead ends to avoid:** None

## Design

Four code review agents (architectural, simplicity, general, nitty) operating at different levels of scrutiny, backed by three skills (/review-full, /review-component, /review-branch). All three skills auto-apply code-level findings (iterating to convergence) and escalate architectural/interface changes for user confirmation. The architectural agent uses `claude-opus-4-6`; the rest use `claude-sonnet-4-6`. The architectural agent is opt-in — invoked only when explicitly requested in the invocation text, or when the skill prompts and the user confirms.

Four agent files live in `devproc/agents/`, following the same frontmatter conventions as `docs-structure-reviewer.md`. Each specifies its `model` field explicitly (`claude-opus-4-6` for architectural, `claude-sonnet-4-6` for the rest). Each agent's prompt scopes it to its review dimension and instructs it to produce findings without modifying files.

### Applying findings

Review findings fall into two categories, and the skill handles them differently:

- **Code-level improvements** (simplicity, readability, robustness, small logic fixes — anything contained within a function or file): applied immediately and automatically. The cycle repeats — re-run the relevant agents over the changed files — until no new findings are produced.
- **Architectural / interface-level changes** (changes to module boundaries, public APIs, data contracts, or structural design): flagged to the user with a clear explanation and held until the user confirms or rejects them.

The skill must classify each finding before acting. If a finding is ambiguous, treat it as architectural (i.e., escalate rather than auto-apply).

### Scope

Three scope modes:

- **Full** (`/review-full`) — targets the entire codebase.
- **Component** (`/review-component [description]`) — user describes the component or area; the skill resolves this to a set of files (by path, glob, or keyword search) before invoking agents.
- **Branch** (`/review-branch`) — scopes to files changed in the current feature branch, derived from `git diff` against the base branch. Diff context is passed to each agent.

### Architectural review opt-in

The architectural agent is not run by default. The skill includes it when:
1. The user explicitly requests it in their invocation text (e.g. "/review-full including architectural review"), or
2. It is not clear from the invocation — the skill asks before starting.

This is natural-language inference, not a flag.

The `plugin.json` description will be updated to mention code review alongside feature lifecycle management.

## Sub-tasks

1. ✓ **Create agent files** — write `devproc/agents/code-review-architectural.md`, `code-review-simplicity.md`, `code-review-general.md`, `code-review-nitty.md` with correct frontmatter and focused review prompts (2026-04-14)
2. ✓ **Create `/review-full` skill** — `devproc/skills/review-full/SKILL.md` — full-codebase review; infers architectural inclusion from invocation text, prompts if unclear; auto-applies code-level findings and iterates to convergence; escalates architectural findings for user confirmation (2026-04-14)
3. ✓ **Create `/review-component` skill** — `devproc/skills/review-component/SKILL.md` — resolves the component description to files, then same review logic as `/review-full` (2026-04-14)
4. ✓ **Create `/review-branch` skill** — `devproc/skills/review-branch/SKILL.md` — diff-scoped review using `git diff` to identify changed files; same auto-apply/escalate and architectural opt-in logic (2026-04-14)
5. ✓ **Update `plugin.json`** — extend description to cover code review skills and agents (2026-04-14)
6. ✓ **Update `devproc/README.md`** — add agents to Contents table and Agents section; add skills to Contents table and Skills section (2026-04-14)
7. ✓ **Update `CLAUDE.md`** — add new agents and skills to the devproc plugin contents list (2026-04-14)

**✓ All sub-tasks complete.**

> Run `/feature-checkpoint` after each sub-task completes.
