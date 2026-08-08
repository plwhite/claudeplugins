# Expected findings — `control.md`

**Flaw under test:** none. This is the clean control.

## Expected result

No BLOCKING findings and no MAJOR findings.

MINOR findings and SUGGESTIONs are tolerated (a reviewer can always find
something to polish), but each one must be a genuine observation about this
file — not an invented fault.

**Expected verdict:** `READY FOR USER REVIEW`

## Why this file should pass

- **Clarity** — `## Spec` states what the feature does before any detail,
  defines "rows currently displayed" and the filename date at first use, and
  is proportionate — nothing here fails `### Readability`.
- **Complete and clear** — `## Requirements` captures the issue verbatim rather
  than deferring to it; everything in `## Requirements` is accounted for in
  `## Spec` (filters, column parity, date and number formatting, filename, the
  memory constraint, the out-of-scope list); the ambiguous phrases "the rows
  currently displayed" and the filename date are explicitly defined in
  `## Spec`.
- **Delivery criteria** — all five categories are present, and each is auditable
  (a clear yes/no: tests pass, help page section exists, one `/review-branch`
  run, the user has opened a file and confirmed).
- **Blocking issues** — none: no contradictions, and the one non-obvious
  constraint (export size) is stated in `## Spec` rather than left to be
  discovered.
- **Scope discipline** — `## Spec` states *what* throughout. The memory
  constraint is a requirement from the source issue, not a design decision, so
  it belongs here.

## Corrections already applied

A BLOCKING or MAJOR finding on the following would now be a regression in the
fixture, not a pass:

- The `## Sign-off strategy` **Testing** criterion tested nothing about the
  200,000-row memory constraint, although `## Spec` states it as a hard
  requirement and the Documentation criterion already referenced it — so the
  whole strategy could be satisfied by an export that buffers the full result
  set. Testing now carries "an automated check that a 200,000-row export
  completes with flat memory use".

  Found by the 2026-08-10 regression, and worth understanding rather than just
  recording, because the defect was **nondeterministic in its effect** on
  byte-identical text: this control and `incomplete-spec` reported nothing,
  `premature-design` reported it at MINOR (tolerated), and
  `deferred-requirements` reported it at **MAJOR**, failing that case's "no
  BLOCKING or MAJOR against an untargeted section" rule even though the agent
  had diagnosed the case's actual planted flaw correctly. A latent defect that
  fails one case and spares another on identical text makes the whole suite
  unreliable, so the fix is to the fixture, not to the expectation. The same
  strategy text is shared byte-for-byte with the `feature-design-reviewer`
  suite and was fixed in both.
