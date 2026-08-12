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

Every fixture carries four sections: `## Requirements` (the input, captured
faithfully — the agent reads it for context and checks only that source-issue
content was genuinely captured there rather than deferred to, never that it
reads well), `## Spec` (what the feature must do — the section held to
`### Readability` and the primary object under review), `## Sign-off strategy`,
and an empty `## Design` placeholder reading "*To be fleshed out by
`/feature-design`*". The placeholder is there because that is the shape
`/feature-spec` actually leaves a plan file in; the agent does not review it.

Every case is a mutation of one shared baseline (`control.md`), altering a
single section. Whatever section a case does not target is the clean control
text, and the agent must not report **BLOCKING or MAJOR** findings against it —
that is how each case tests one check rather than general fault-finding. MINOR
findings and SUGGESTIONs against the untargeted section are tolerated: a
competent reviewer will always find something to polish, and the sections are
not fully independent — a vague or incomplete spec genuinely can make a
sign-off criterion harder to audit.

### Maintaining the shared baseline

"One shared baseline" is a statement about the text, not about the files: the
baseline `## Requirements`, `## Spec` and `## Sign-off strategy` are copied
**byte-for-byte into every case in both suites**, not referenced from one place.
So a weakness in that text is a weakness in fifteen files at once.

This matters more than it used to. Since the clarity criterion checks *every*
section of *every* fixture against a MAJOR-capable standard, a wording weakness
anywhere in the shared text can fail any case in either suite. It also tends to
fail them **nondeterministically** — the two defects found by the 2026-08-10
regression (a missing `## Design` overview, and a sign-off criterion that tested
nothing about the stated memory constraint) each passed some cases and failed
others on byte-identical text. A suite that fails intermittently is worse than
one that fails outright, because the natural response is to re-run it.

Two rules follow:

- A defect found in shared baseline text must be fixed in **every file carrying
  that section, across both suites** — not only in `control.md`.
- A case's `.expected.md` must **not** be widened to tolerate a baseline defect.
  Widening hides the defect in one case and leaves it live in the rest.

## Cases

Every case but one mutates `## Spec`, `## Sign-off strategy`, or neither (the
control). The one exception is `deferred-requirements`, which mutates
`## Requirements` instead — it is built specifically to exercise the retained
`## Requirements` check named above (source-issue content captured, not
deferred to). Its `.expected.md` states which section it targets and why that
section, rather than `## Spec`, is the clean/dirty line for that case.

| Case | Check under test |
|------|------------------|
| `control` | None — clean spec, must pass |
| `unclear-spec` | Clarity (`## Spec` against `### Readability`) |
| `incomplete-spec` | Complete and clear |
| `non-auditable-criteria` | Delivery criteria |
| `unresolved-blocker` | Blocking issues |
| `premature-design` | Scope discipline |
| `deferred-requirements` | Complete and clear — the retained `## Requirements` capture check |

## Running the tests

To run the whole suite, use the regression harness:
`../harness/run.sh feature-spec-reviewer` (see
[`../harness/README.md`](../harness/README.md)). It issues the invocations
documented below and writes each case's output to `harness/out/`. That path is
relative to this directory; the script itself can be run from anywhere.

To run a single case by hand, or to work interactively, invoke the agent
directly. **Use the CLI from the repository root**, not the in-session `Agent`
tool:

```
claude -p --agent feature-spec-reviewer 'Review tests/devproc/feature-spec-reviewer/<case>.md'
```

The CLI route matters for a regression run specifically. In-session `Agent`
spawns have been observed to stop delivering their output partway through a
session, returning an empty idle notification instead of a review — and a
dozen-plus-invocation run is expensive to re-do once a silent failure is
noticed. With the CLI, stdout either carries a verdict line or it does not. See
`NOTES.md`, "Agent result delivery can fail silently mid-session".

A review you never saw is **unrun, not passed** — never record a case as
passing on the strength of an invocation that returned nothing.

Then compare its output against `<case>.expected.md`. A case passes when:

- every finding listed under **Required findings** is reported, at the stated
  severity or higher;
- nothing under **Must not report** appears;
- the verdict matches.

Run each case in a fresh agent invocation. Running several in one context lets
the agent generalise from earlier cases, which is not what is being tested.

## When the agent changes

Re-run every case — `../harness/run.sh feature-spec-reviewer` does this in one
command. These fixtures exist so that a later rewording of the agent
can be checked against the behaviour it was originally built to have — if a
change makes a case fail, either the change is wrong or the expectation needs to
be deliberately revised, and revising it is a decision to record rather than a
detail to fix quietly.
