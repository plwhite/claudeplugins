# Expected findings — `nested-claude-md/`

**Flaw under test:** scope coverage. The agent must find and review the
nested `payments/CLAUDE.md`, not only the root `CLAUDE.md`. The nested file's
own text explicitly disclaims project-wide status ("do not duplicate it
here") and then does exactly that, duplicating an entry already in
`features/COMPLETED.md`.

## Required findings

Exactly one finding against `payments/CLAUDE.md`:

- **Anchor** — the `## Recent project status` section: "`csv-export`
  completed 2026-05-02 — added CSV export to the reports page (#47). See
  `features/COMPLETED.md` for detail."
- **Gating class** — `redundant` (verifiable elsewhere in
  `features/COMPLETED.md`; also a direct violation of this file's own stated
  scope, which is itself grounds to flag it even before checking duplication).
- **Action** — `delete` (the content belongs only in the root `CLAUDE.md`'s
  status line or `features/COMPLETED.md`, not in a module-scoped file at all).

## Must not report

- Any finding against the root `CLAUDE.md` — it is the clean control shape
  (single permitted completion line, no scope violation).
- Any finding against `payments/CLAUDE.md`'s `## Module notes` section — it is
  correctly in scope for that file (module-specific guidance) and violates
  neither its own stated rule nor either review criterion.
- A missed nested file: the case fails if the agent reports nothing at all,
  since that would mean it never found `payments/CLAUDE.md`.
