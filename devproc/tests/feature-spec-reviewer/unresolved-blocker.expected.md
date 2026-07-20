# Expected findings — `unresolved-blocker.md`

**Flaw under test:** blocking issues. The requirements contain a flat
contradiction and a dependency on a feature that does not exist. The sign-off
strategy is the clean one from `control.md` and must not be faulted.

## Required findings

**Both** of these, at **BLOCKING** severity, marked `[decision]`:

1. **Contradiction** — the export "must work while the user is offline", yet
   every row must carry account status "fetched live from the billing service at
   export time". Both cannot hold. The recommendation must put the choice to the
   user (e.g. cached status offline, or offline export excluded) rather than
   silently picking one.
2. **Unstated dependency** — currency conversion depends on "the rates table
   delivered by the `multi-currency` feature", whose existence and timing are
   not established. The finding must call out that this blocks the work if that
   feature is not delivered first.

## Also acceptable

- A finding that "the customer's billing currency" is undefined for multi-entity
  customers.
- A finding noting the reviewer could not locate a `multi-currency` feature when
  checking the repository.
- Further BLOCKING contradictions against the column-parity rule, which this
  fixture's added requirements also collide with: the account-status column has
  no on-screen equivalent, and exporting in the billing currency may differ from
  the displayed currency. These were not deliberately planted but are genuine,
  and finding them is a pass rather than a false positive.

## Must not report

- Any **BLOCKING or MAJOR** finding against `## Sign-off strategy`, which is the
  clean control text. MINOR findings and SUGGESTIONs there are tolerated.
- Any finding that resolves the contradiction by assumption instead of putting
  it to the user.

**Expected verdict:** `NEEDS WORK`
