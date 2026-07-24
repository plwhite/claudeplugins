# Expected findings — `redundant/`

**Flaw under test:** duplication. `CLAUDE.md`'s `## Current status` carries a
second, older completion entry beyond the one line its own `## Feature model`
section says it may — and that entry is a full, verbatim (or near-verbatim)
duplicate of an entry already in `features/COMPLETED.md`.

## Required findings

Exactly one finding against `CLAUDE.md`:

- **Anchor** — the `bulk-tagging` paragraph: "`bulk-tagging` completed
  2026-03-11 — added the ability to apply a tag to multiple selected inventory
  items at once (#39), with an undo action available for 30 seconds after
  applying."
- **Gating class** — `redundant` (verifiable elsewhere: the identical content
  is already in `features/COMPLETED.md`'s `### Bulk tagging` entry).
- **Action** — `delete`, and `delete` only. The content already exists at the
  canonical destination (`features/COMPLETED.md`), so there is nothing to move
  there — a `move` would write a second copy — and nothing to preserve in
  condensed form. A `redundant` finding carrying any action other than
  `delete` is itself a defect (see the agent's gating-class contract).

## Must not report

- Any finding against the `csv-export` line — it is the single permitted
  most-recent-completion line under `CLAUDE.md`'s own stated rule, not a
  second violation.
- Any finding against `features/COMPLETED.md` — out of scope for findings.
- Any `stale` or `judgment` finding — this fixture only plants a duplication.
