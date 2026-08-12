# Expected findings — `idempotent/`

**Flaw under test:** none — this represents the *output* of a previous prune
pass: `CLAUDE.md` already has only its one permitted completion line, and the
`webhooks/config.yaml` figure now matches the `NOTES.md` claim exactly (a
prior `stale` finding has already been applied). This is the second-pass /
idempotency check: applying `redundant` and `stale` findings must not create
new work for the next run.

## Required findings

None required.

## Must not report

- Any `redundant` finding — `CLAUDE.md`'s status section is at its permitted
  cap; there is nothing left to remove.
- Any `stale` finding — the `webhooks/config.yaml` figure and the `NOTES.md`
  claim agree.

## Permitted but not required

- A `judgment` finding against "Local dev database seed can take under a
  minute" is acceptable either way. `judgment` findings are escalated to a
  human each run rather than silently resolved by a prior pass, so their
  presence or absence here does not indicate a defect — only a `redundant` or
  `stale` finding surviving a second pass would.
