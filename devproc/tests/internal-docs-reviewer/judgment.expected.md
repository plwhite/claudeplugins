# Expected findings — `judgment/`

**Flaw under test:** borderline durability. The entry reads as exactly the
kind of transient, workaround-flavoured remark the durability criterion
itself flags as suspect ("a stopgap", dated, framed around one week's CI
runs) — yet it is not contradicted by anything checkable (no companion file
confirms or refutes whether the flakiness continues) and it is not stated
anywhere else, so it is neither verifiably `stale` nor verifiably
`redundant`. It also carries a real technical lead (profile the CSV writer)
that argues against outright deletion. Whether a dated, stopgap-flavoured
note like this has aged into durable value or should be pruned as a
transient remark is exactly the kind of call this agent must escalate rather
than settle itself.

## Required findings

Exactly one finding against `NOTES.md`:

- **Anchor** — the "CSV export test flaked twice this week (2026-06-02)"
  entry.
- **Gating class** — `judgment`.
- **Action** — `condense` (the appropriate action for this entry — it carries
  a real lead worth keeping but has no suitable `move` destination; `delete`
  must not be used here). A reasonable replacement keeps the actionable lead while
  dropping the dated, one-week framing — e.g. "`test_export_large_tenant` has
  intermittently timed out around 50s in CI; if it recurs, profile the CSV
  writer rather than raising the timeout further." — but exact wording is not
  required.

## Must not report

- `redundant` or `stale` as the gating class for this entry — neither is
  verifiable here, and misclassifying a judgment call as one of the
  auto-appliable classes is the specific failure mode this case guards
  against (it would cause the calling skill to delete or auto-edit content a
  human should have decided about).
- `delete` as the action for this entry.
- "No findings" — the entry's dated, stopgap framing is enough signal that a
  competent reviewer applying the durability criterion should flag it as
  borderline rather than pass it through silently.
