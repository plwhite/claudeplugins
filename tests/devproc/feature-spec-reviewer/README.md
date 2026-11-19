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

Every fixture carries four sections:

- `## Requirements` — the input, captured faithfully. The agent reads it for
  context and checks only that source-issue content was genuinely captured
  there rather than deferred to, never that it reads well.
- `## Spec` — what the feature must do: the section held to `### Readability`
  and the primary object under review.
- `## Sign-off strategy`.
- An empty `## Design` placeholder reading "*To be fleshed out by
  `/feature-design`*".

The placeholder is there because that is the shape
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

The baseline `## Requirements`, `## Spec` and `## Sign-off strategy` are
copied **byte-for-byte into every case in both suites**, not referenced from one
place. The exceptions are the cases that carry the same `## Spec` content in
another form on purpose:

- in this suite, `unheaded-requirements` (the requirements as numbered bold
  list items) and `headed-requirements-control` (the requirements as `####`
  headings under a grouping `###` heading);
- in the design suite, the cases listed in its
  [README](../feature-design-reviewer/README.md#what-the-untargeted-sections-are).

When maintaining the baseline:

- Fix a defect in shared baseline text in **every file carrying that section,
  across both suites**, not only in `control.md`. In the cases that carry
  `## Spec` in another form, apply the fix in their own form.
- Do **not** widen a case's `.expected.md` to tolerate a baseline defect:
  that hides the defect in one case and leaves it live in the rest. The design
  suite records one exception, for a defect that cannot be fixed; see its
  [README](../feature-design-reviewer/README.md#what-the-untargeted-sections-are).

The reason: the clarity criterion checks every section of every fixture, so a
wording weakness in shared text can fail any case in either suite, and tends to
fail them nondeterministically (some cases pass and others fail on identical
text). It must be fixed, not re-run.

## Cases

Every case mutates `## Spec` or `## Sign-off strategy`, with three exceptions:

- `control` changes nothing.
- `headed-requirements-control` is a second control, changing only the form of
  `## Spec`.
- `deferred-requirements` mutates `## Requirements`, to exercise the check that
  source-issue content was captured there, not deferred to. Its `.expected.md`
  says why that section, rather than `## Spec`, is the clean/dirty line for the
  case.

| Case | Check under test |
|------|------------------|
| `control` | None — clean spec, must pass |
| `unclear-spec` | Clarity (`## Spec` against `### Readability`) |
| `incomplete-spec` | Complete and clear |
| `non-auditable-criteria` | Delivery criteria |
| `unresolved-blocker` | Blocking issues |
| `premature-design` | Scope discipline |
| `deferred-requirements` | Complete and clear — the retained `## Requirements` capture check |
| `undifferentiated-docs-review` | Delivery criteria — the docs review bar must say which kinds run |
| `unheaded-requirements` | Requirement format — numbered requirements written as list items, not headings |
| `headed-requirements-control` | None — `control` with its requirements as `####` headings; must pass, with no finding about the format |

## Running the tests

To run the whole suite, use the regression harness:
`../harness/run.sh feature-spec-reviewer` (see
[`../harness/README.md`](../harness/README.md)). It issues the invocations
documented below and writes each case's output to `../harness/out/`. The
script itself can be run from anywhere.

To run a single case by hand, or to work interactively, invoke the agent
directly. **Use the CLI from the repository root**, not the in-session `Agent`
tool:

```
claude -p --agent feature-spec-reviewer 'Review tests/devproc/feature-spec-reviewer/<case>.md'
```

Then compare its output against `<case>.expected.md`. A case passes when:

- every finding listed under **Required findings** is reported, at the stated
  severity or higher;
- nothing under **Must not report** appears;
- the verdict matches.

Run each case in a fresh agent invocation. Running several in one context lets
the agent generalise from earlier cases, which is not what is being tested.

The CLI route matters for a regression run specifically. In-session `Agent`
spawns have been observed to stop delivering their output partway through a
session, returning an empty idle notification instead of a review — and a
dozen-plus-invocation run is expensive to re-do once a silent failure is
noticed. With the CLI, stdout either carries a verdict line or it does not.

A review you never saw is **unrun, not passed** — never record a case as
passing on the strength of an invocation that returned nothing.

## When the agent changes

Re-run every case — `../harness/run.sh feature-spec-reviewer` does this in one
command. These fixtures exist so that a later rewording of the agent
can be checked against the behaviour it was originally built to have — if a
change makes a case fail, either the change is wrong or the expectation needs to
be deliberately revised, and revising it is a decision to record rather than a
detail to fix quietly.
