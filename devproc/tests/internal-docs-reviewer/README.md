# `internal-docs-reviewer` test fixtures

Test cases for the `internal-docs-reviewer` agent. Nothing here is real
project documentation — every fixture is a deliberately constructed small
"project" of internal docs, and none of them describes work on this
repository.

## Layout

This agent reviews a *set* of files together (root `CLAUDE.md`, nested
`CLAUDE.md` files, `NOTES.md`, `.claude/rules/*.md`), and some checks — a
duplication against `features/COMPLETED.md`, a contradiction against
"current code" — only make sense with more than one file present. So, unlike
a single-file-input agent, each case here is a small **fixture directory**
rather than a single `.md` file:

| Path | Contents |
|------|----------|
| `<case>/` | A miniature project directory exhibiting exactly one deliberate flaw (or none, for the control and idempotent cases), using real relative paths (`CLAUDE.md`, `NOTES.md`, `features/COMPLETED.md`, `.claude/rules/...`) so the agent's Glob/Grep patterns behave as they would on a real repository |
| `<case>.expected.md` | The findings the agent must report on it, and what it must not report |

The flaw is recorded **only** in `<case>.expected.md`. Nothing inside
`<case>/` names what is wrong with it.

## Cases

| Case | Check under test |
|------|------------------|
| `control` | None — clean docs set, must pass with no findings |
| `redundant` | An older `CLAUDE.md` status entry duplicating `features/COMPLETED.md` |
| `stale` | A `NOTES.md` entry contradicted by a companion "current state" file |
| `judgment` | A borderline-utility `NOTES.md` entry — neither verifiably stale nor redundant |
| `nested-claude-md` | Scope coverage: a nested `CLAUDE.md` violating its own stated rule |
| `claude-rules` | Scope coverage: a `.claude/rules/*.md` file with a stale claim |
| `idempotent` | An already-pruned docs set; a second pass must find no `redundant`/`stale` (a residual `judgment` call is permitted either way) |

## Running the tests

For each case, point the agent at the fixture directory as the repository
root to review:

```
Run the internal-docs-reviewer agent over
devproc/tests/internal-docs-reviewer/<case>/
as if it were the repository root — Glob it for CLAUDE.md, NOTES.md,
nested CLAUDE.md files, and .claude/rules/*.md within that directory only.
```

Then compare its output against `<case>.expected.md`. A case passes when:

- every finding listed under **Required findings** is reported, with the
  correct **Gating class** and **Action** (and, for `move`/`condense`, a
  reasonable Destination/Replacement — exact wording is not required, the
  substance is);
- nothing under **Must not report** appears;
- the anchor for each required finding is the verbatim text named in
  **Required findings** (an exact match, or a reasonable superset or subset of
  it — quoting slightly more or less surrounding context) — a paraphrase is a
  defect in the agent's output, not an acceptable near-miss.

Run each case in a fresh agent invocation. Running several in one context
lets the agent generalise from earlier cases, which is not what is being
tested.

### Testing a not-yet-restarted agent definition

A newly written or edited `devproc/agents/internal-docs-reviewer.md` is not
invocable as an agent *type* in the session that wrote it — available agent
types are resolved at session start. To validate it anyway in the same
session, spawn a general-purpose agent, have it read
`devproc/agents/internal-docs-reviewer.md`, treat the text after the
frontmatter as its system prompt, and follow it — this exercises the prompt
(the whole deliverable for a prose agent) but not the frontmatter wiring
(`tools:`, `model:`, description-based dispatch), which needs a restarted
session. When doing this, explicitly forbid the test agent from reading the
`.expected.md` files or this README before it produces its findings — they
state the flaw under test.

### Project memory during fixture runs

The agent is **stateless** — it holds no memory and reads none, so these
fixtures exercise it as a pure function of its input files: the same input
always yields the same findings, with nothing to seed or clear beforehand.

The settled-`judgment` memory lives with the `/internal-docs-prune` skill, not
the agent, under `$CLAUDE_PROJECT_DIR/.claude/agent-memory/devproc-internal-docs-reviewer/MEMORY.md`
(resolved against the real repository root). These agent fixtures do not touch
it. Testing the *skill's* suppression behaviour (that a previously-settled
`judgment` call is not re-raised on a later run) is a skill-level check: seed
or clear that directory manually around the run, since it is not part of any
agent fixture.

## When the agent changes

Re-run every case. These fixtures exist so a later rewording of the agent can
be checked against the behaviour it was originally built to have — if a
change makes a case fail, either the change is wrong or the expectation needs
to be deliberately revised, and revising it is a decision to record rather
than a detail to fix quietly.
