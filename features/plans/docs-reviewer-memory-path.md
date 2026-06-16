# Docs reviewer stores memory in the wrong place — Feature Plan

## Handoff

**Last updated:** 2026-06-16
**Session summary:** Sub-task 1 complete — anchored the docs-structure-reviewer memory path to `$CLAUDE_PROJECT_DIR`. Implementation done; feature ready to end.
**Sub-task in progress:** None
**First action next session:** Run `/feature-end` to complete the feature.
**Open questions / decisions pending:** None
**Dead ends to avoid:** None

## Requirements

From issue #23 (verbatim):

> The docs structure reviewer was being run from various locations, and when doing so was creating memory files relative to those locations, not the base of the repo.
>
> The clean fix is in the [agent file](devproc/agents/docs-structure-reviewer.md): change line 185 to write to a project-root-anchored path (e.g. instruct it to resolve .claude/agent-memory/… against the repository root, or use $CLAUDE_PROJECT_DIR/.claude/agent-memory/…) so cwd can't move it.

(No comments on the issue.)

The relevant text in `devproc/agents/docs-structure-reviewer.md` currently
instructs the agent to "Store findings in `.claude/agent-memory/docs-structure-reviewer/`",
a relative path that resolves against the agent's cwd. It must instead resolve
against the repository root (e.g. via `$CLAUDE_PROJECT_DIR`).

## Design

The bug is purely in the agent prompt `devproc/agents/docs-structure-reviewer.md`.
The `# Memory` section (line 185) tells the agent to "Store findings in
`.claude/agent-memory/docs-structure-reviewer/`" — a path with no leading anchor,
so it resolves against whatever directory the agent happens to run in. Run from a
subdirectory, the agent creates a stray `.claude/agent-memory/…` tree there
instead of at the repo root.

**Fix:** anchor the path to the repository root using the `$CLAUDE_PROJECT_DIR`
environment variable, which Claude Code sets to the project root regardless of
cwd. Change the instruction to write to and read from
`$CLAUDE_PROJECT_DIR/.claude/agent-memory/docs-structure-reviewer/`, and make the
`MEMORY.md` index reference (line 190) use the same anchored path so the
start-of-review read and the write target match.

Notes:
- The agent already declares `memory: project` in frontmatter (line 48); the
  explicit prose path is what governs where files actually land, so the prose is
  what must change. Leave the frontmatter as-is.
- No other agent in the repo references an `agent-memory` path (confirmed via
  grep), so the fix is contained to this one file.
- This is a prompt/docs change only — there is nothing to build or test beyond
  reading the edited file back to confirm both references are anchored and
  consistent.

## Sub-tasks

1. ✓ **Anchor the memory path** (2026-06-16) — edited the `# Memory` section of `devproc/agents/docs-structure-reviewer.md` so both the storage path and the `MEMORY.md` index reference use `$CLAUDE_PROJECT_DIR/.claude/agent-memory/docs-structure-reviewer/`, with an explicit instruction to resolve against the repo root rather than cwd.

**▶ NEXT:** All sub-tasks complete — run `/feature-end`.

> Run `/feature-checkpoint` after each sub-task completes.
