# Expected findings — `no-spec.md`

**Flaw under test:** the missing-`## Spec` guard. This fixture is `control.md`
with the entire `## Spec` section deleted — not a mutation of one section's
content, but the removal of a whole section the reviewer depends on.

`feature-design-reviewer`'s `## What You Review` section requires it to stop
immediately when the plan file has no `## Spec`: report that as its **only**
finding, do not review `## Design` or `## Sub-tasks` at all, and do not fall
back to tracing coverage against `## Requirements`. This case exists to prove
that guard fires and that nothing else leaks through.

## Departure from the normal pass rule

Every other case in this suite is judged by "no BLOCKING or MAJOR finding
against a section the case does not target" — MINOR findings and SUGGESTIONs
against untargeted sections are tolerated. That rule does not apply here.
Because the guard means the agent must not review `## Design` or `## Sub-tasks`
**at all**, the expectation is that **nothing** about either section is
reported, at any severity, including MINOR or SUGGESTION. Any finding on
`## Design` or `## Sub-tasks` — however minor — is evidence the agent read past
the guard and reviewed a design against a standard it invented for itself,
which is the specific failure the guard exists to prevent. This is stated
explicitly so a later reader does not mistake the stricter bar for a mistake in
this file.

## Required findings

Exactly one finding:

1. **Missing `## Spec`** at **BLOCKING** severity, marked `[decision]` —
   stating that the plan file has no `## Spec` section, so there is nothing to
   trace design coverage against, and that `/feature-spec` must be run (or
   completed) for this feature before its design can be reviewed.

## Must not report

- Anything about `## Design`, at any severity — no MINOR, no SUGGESTION. The
  guard means `## Design` is not reviewed at all, not reviewed leniently.
- Anything about `## Sub-tasks`, at any severity, for the same reason.
- Any finding against `## Requirements` or `## Sign-off strategy`. The guard
  does not fall back to reviewing them either — it stops entirely.
- A second finding of any kind. The missing-`## Spec` finding is the agent's
  only output.
- A verdict other than `NEEDS WORK`.

**Expected verdict:** `NEEDS WORK`
