# Code review agents and skills — Feature Plan

## Handoff

**Last updated:** 2026-04-14
**Session summary:** Sub-task 5 completed: `plugin.json` updated with a description covering both feature lifecycle and code review capabilities.
**Sub-task in progress:** None
**First action next session:** Begin Sub-task 6 — update `devproc/README.md`: add four agents to Contents table and Agents section; add three review skills to Contents table and Skills section
**Open questions / decisions pending:** None
**Dead ends to avoid:** None

## Requirements

Four code review agents, each focused on a distinct level of scrutiny:

- **architectural** — checks that the architecture is valid, consistent with the design, and is the best approach. Uses `claude-opus-4-6`.
- **simplicity** — identifies where complex code could be simplified or unused code removed. Uses `claude-sonnet-4-6`.
- **general** — checks that the code does the right thing, is robust, and is suitably performant. Uses `claude-sonnet-4-6`.
- **nitty** — digs into low-level code quality: readability, comments, robustness. Uses `claude-sonnet-4-6`.

Skills that invoke these agents, incorporate their feedback, and apply it:

- `/review-full` — reviews the full codebase
- `/review-component [component description]` — reviews the described component or part of the codebase
- `/review-branch` — reviews only files changed in the current feature branch (diff-scoped).
- All three auto-apply code-level findings (iterating to convergence) and escalate architectural/interface changes for user confirmation.
- The architectural agent is expensive; it runs only when the user explicitly requests it (e.g. "including architectural review") or when the skill prompts and the user confirms.

## Design

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
6. **Update `devproc/README.md`** — add agents to Contents table and Agents section; add skills to Contents table and Skills section
7. **Update `CLAUDE.md`** — add new agents and skills to the devproc plugin contents list

**▶ NEXT:** Sub-task 6

> Run `/feature-checkpoint` after each sub-task completes.
