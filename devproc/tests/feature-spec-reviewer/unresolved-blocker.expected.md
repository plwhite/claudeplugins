# Expected findings — `unresolved-blocker.md`

**Flaw under test:** blocking issues. `## Spec` contains a flat contradiction
and a dependency on a feature that does not exist. `## Requirements` is the
clean, faithfully-captured input for this scenario (it is not `control.md`'s
text — this fixture tells a different, extended version of the issue — but it
is captured verbatim and deferred to nowhere, so it must not be faulted). The
sign-off strategy is the clean one from `control.md` and must not be faulted.

*(`## Spec` carries this flaw rather than `## Requirements` because
`feature-spec-reviewer` now reviews `## Spec` as the statement of what the
feature must do; a faithful `## Spec` derived from this `## Requirements`
necessarily restates both halves of the contradiction, which is exactly what
should trip the "Blocking issues" check.)*

*(Fixture corrected 2026-08-10, by the regression run. The relocation above was
recorded at the time as having moved this case's flaw "for free" — true of the
contradiction, which the agent still catches at BLOCKING, but **not** of the
dependency. In `## Requirements` the `multi-currency` dependency is a standalone
closing paragraph; the relocated `## Spec` had demoted it to a trailing
subordinate clause inside the currency bullet ("...converted using the rates
table delivered by the `multi-currency` feature"), and the agent read past it,
missing required finding 2 entirely. `## Spec` now states it as its own
paragraph, mirroring how `## Requirements` states it. The lesson generalises:
when a planted flaw is moved between sections, check that it kept its
**salience**, not just its words — a fact demoted to a subordinate clause is
still present and no longer tests anything.)*

*(Fixture corrected again 2026-08-10, by the next regression run, for the same
required finding 2. The salience fix above had held — the dependency was a
standalone closing paragraph in both sections — but the agent still reported it
at **MINOR `[rewrite]`**, as a `### Readability` "nothing assumed" linking nit
recommending a pointer be added, rather than as a blocker. The cause was
**wording, not placement**: the sentence read "the rates table **delivered by**
the `multi-currency` feature", asserting the dependency as already shipped, so
there was nothing for a reviewer to escalate — a dependency that is stated as
met is not a blocker. It now reads "Currency conversion depends on a rates
table. The `multi-currency` feature is expected to provide one," which leaves
existence and timing open without naming the flaw. Both `## Requirements` and
`## Spec` were changed together: they carry this paragraph byte-identically,
and a `## Spec` that alone called the feature pending would diverge from its
own captured input. The lesson extends the 2026-08-09 one: a relocated flaw
must keep its salience **and** its wording must still leave the fault
available to be found — confident phrasing can defuse a planted blocker as
effectively as burying it. Note the agent is not generally blind to this: on
the design suite's `unresolved-design-question`, where the text leaves the
dependency open, it correctly flagged `ReportStreamService` as unconfirmed and
asked rather than asserting it missing.)*

## Required findings

**Both** of these, at **BLOCKING** severity, marked `[decision]`:

1. **Contradiction** — the export "must work while the user is offline", yet
   every row must carry account status "fetched live from the billing service at
   export time". Both cannot hold. The recommendation must put the choice to the
   user (e.g. cached status offline, or offline export excluded) rather than
   silently picking one.
2. **Unstated dependency** — currency conversion "depends on a rates table"
   which "the `multi-currency` feature is expected to provide", whose existence
   and timing are not established. The finding must call out that this blocks
   the work if that feature is not delivered first.

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

- A finding that `## Sign-off strategy` has no testing criterion covering the
  offline requirement. This is a finding against an untargeted section, but it
  arises **from** the planted flaw rather than faulting the strategy on its own
  terms: no auditable offline criterion can be written until the user resolves
  the offline/live-fetch contradiction, so a reviewer that catches the
  contradiction has good reason to notice the gap it leaves downstream. Same
  principle as the `csv-writer` design finding tolerated in the design suite's
  `oversized-subtasks` — see that case's `.expected.md`. The evidence that the
  flaw is its source is that `control.md`, whose spec has no offline
  requirement, does not exhibit it.

## Must not report

- Any **BLOCKING or MAJOR** finding faulting `## Requirements` or `## Sign-off
  strategy` **on its own terms** — they are the clean baseline text for this
  scenario. MINOR findings and SUGGESTIONs there are tolerated, as is the
  offline-coverage finding described above, which the planted contradiction
  genuinely creates.

  Note this does **not** cover the `multi-currency` dependency: since the
  2026-08-10 correction that paragraph lives in `## Requirements` and
  `## Spec` alike, so a reviewer attributing required finding 2 to both
  sections jointly (e.g. heading it "Spec / Requirements") is reporting the
  planted flaw where it actually sits, not faulting the clean input. Only a
  finding about how `## Requirements` *captures* its source — the check
  `deferred-requirements` owns — would be faulting it on its own terms.
- Any finding that resolves the contradiction by assumption instead of putting
  it to the user.

**Expected verdict:** `NEEDS WORK`
