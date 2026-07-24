# Expected findings — `stale/`

**Flaw under test:** currency. The `NOTES.md` entry claims the service
overrides the provider's default of 5 down to 3 (`max_attempts: 3`), but the
companion `webhooks/config.yaml` sets `max_attempts: 5` — the override
described no longer exists, so the entry's entire premise is false.

## Required findings

Exactly one finding against `NOTES.md`:

- **Anchor** — the whole "Webhook retries are capped at 3 attempts" entry (at
  minimum the sentence containing "gives up after 3 delivery attempts
  (`webhooks/config.yaml`, `max_attempts: 3`)").
- **Gating class** — `stale` (contradicted by `webhooks/config.yaml`, which
  this agent reads to check the claim).
- **Action** — `delete` (the note's entire reason for existing — a surprising
  override — is false; there is no correct value to condense it to, since the
  actual state is now simply the provider's unremarkable default). A `condense`
  that rewrites the note to state the current, unremarkable default is also
  acceptable, provided the finding is still gated `stale` and the "3 attempts"
  claim does not survive into the replacement text.

## Must not report

- Any `redundant` or `judgment` finding — this fixture only plants a
  contradiction.
- Any finding against `webhooks/config.yaml` — out of scope for findings; it
  exists only to be checked against.
