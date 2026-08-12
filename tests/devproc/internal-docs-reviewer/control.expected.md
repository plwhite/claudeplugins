# Expected findings — `control/`

**Flaw under test:** none. This is the clean control.

## Expected result

No findings at all.

## Why this fixture should pass

- **`CLAUDE.md`** — `## Current status` carries only the in-progress line
  (none) and a single, short, most-recent-completion line, exactly as its own
  `## Feature model` section says it may. It is not a paragraph-length
  duplication of `features/COMPLETED.md`.
- **`NOTES.md`** — the one entry is durable (a lasting environmental fact about
  webhook retry behaviour) and current: `webhooks/config.yaml` sets
  `max_attempts: 3`, matching the note exactly. Nothing here is derivable from
  a glance at the code without the "why" the note supplies (the queue's
  90-second timeout).
- **`features/COMPLETED.md`** — out of the agent's scope-in list for findings,
  but consulted to confirm `CLAUDE.md`'s one line does not exceed what the rule
  permits.
