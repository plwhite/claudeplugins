# Expected findings — `control.md`

**Flaw under test:** none. This is the clean control.

## Expected result

No BLOCKING findings and no MAJOR findings.

MINOR findings and SUGGESTIONs are tolerated (a reviewer can always find
something to polish), but each one must be a genuine observation about this
file — not an invented fault.

**Expected verdict:** `READY FOR USER REVIEW`

## Why this file should pass

- **Complete and clear** — the issue content is captured verbatim rather than
  deferred to; the ambiguous phrases "the rows currently displayed" and the
  filename date are explicitly defined; the out-of-scope list bounds the work.
- **Delivery criteria** — all four categories are present, and each is auditable
  (a clear yes/no: tests pass, help page section exists, one `/review-branch`
  run, the user has opened a file and confirmed).
- **Blocking issues** — none: no contradictions, and the one non-obvious
  constraint (export size) is stated rather than left to be discovered.
- **Scope discipline** — states *what* throughout. The memory constraint is a
  requirement from the source issue, not a design decision, so it belongs here.
