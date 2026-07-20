# `feature-spec-reviewer` test fixtures

Test cases for the `feature-spec-reviewer` agent. Nothing here is a real feature
plan — each `.md` file is a deliberately constructed input, and none of them
describes work on this repository.

## Layout

Each case is a pair:

| File | Contents |
|------|----------|
| `<case>.md` | A plan file exhibiting exactly one deliberate flaw (or none, for the control) |
| `<case>.expected.md` | The findings the agent must report on it, and the expected verdict |

The flaw is recorded **only** in the `.expected.md` file. The fixture itself
never names what is wrong with it, so the agent cannot read the answer off the
input.

Every case is a mutation of one shared baseline (`control.md`), altering a
single section. Whatever section a case does not target is the clean control
text, and the agent must not report **BLOCKING or MAJOR** findings against it —
that is how each case tests one check rather than general fault-finding. MINOR
findings and SUGGESTIONs against the untargeted section are tolerated: a
competent reviewer will always find something to polish, and the sections are
not fully independent — vague requirements genuinely do make a sign-off
criterion harder to audit.

## Cases

| Case | Check under test |
|------|------------------|
| `control` | None — clean spec, must pass |
| `incomplete-requirements` | Complete and clear |
| `non-auditable-criteria` | Delivery criteria |
| `unresolved-blocker` | Blocking issues |
| `premature-design` | Scope discipline |

## Running the tests

For each case, run the agent over the fixture:

```
Run the feature-spec-reviewer agent over
devproc/tests/feature-spec-reviewer/<case>.md
```

Then compare its output against `<case>.expected.md`. A case passes when:

- every finding listed under **Required findings** is reported, at the stated
  severity or higher;
- nothing under **Must not report** appears;
- the verdict matches.

Run each case in a fresh agent invocation. Running several in one context lets
the agent generalise from earlier cases, which is not what is being tested.

## When the agent changes

Re-run every case. These fixtures exist so that a later rewording of the agent
can be checked against the behaviour it was originally built to have — if a
change makes a case fail, either the change is wrong or the expectation needs to
be deliberately revised, and revising it is a decision to record rather than a
detail to fix quietly.
