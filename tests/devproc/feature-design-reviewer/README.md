# `feature-design-reviewer` test fixtures

Test cases for the `feature-design-reviewer` agent. Nothing here is a real
feature plan — each `.md` file is a deliberately constructed input, and none of
them describes work on this repository.

The layout, conventions, and pass rules are the same as for
[`../feature-spec-reviewer/`](../feature-spec-reviewer/README.md); read that
README first. The differences are below.

## What the untargeted sections are

These fixtures carry all five sections (`## Requirements`, `## Spec`, `##
Sign-off strategy`, `## Design`, `## Sub-tasks`), because a design can only be
judged against what the feature must do (`## Spec`) and the strategy its
criteria derive from. The agent reads `## Requirements` and `## Spec` for
background and traces design coverage against `## Spec`, but does not review
either as an artefact in its own right, so:

- `## Requirements`, `## Spec`, and `## Sign-off strategy` are identical clean
  baseline text in every case, and must draw no BLOCKING or MAJOR finding.
- A case targeting `## Design` leaves `## Sub-tasks` at baseline, and vice
  versa — except where a single flaw genuinely spans both, which is recorded in
  that case's `.expected.md`.

## Cases

`unclear-design` and `unexplained-design` are deliberately kept distinct
rather than folded together: `unclear-design`'s rationale is present but
tangled into the main line so it cannot be followed, and its design opens
with no overview; `unexplained-design`'s rationale is simply absent. A design
can fail either without the other, so the two checks — Clarity and Complete
and clear — each get their own case.

One exception to the one-flaw rule: `unexplained-design` tests both halves of
"complete and clear" at once — decisions asserted without rationale, *and* a
requirement covered by no part of the design or sub-tasks. They are distinct
defects and a design can have either without the other, so the case passes only
when **both** required findings are present. Splitting it into two fixtures
would be defensible; it is kept as one because the two failures share a root
cause in practice — a design written too quickly to record its own reasoning.

A second, larger exception: `no-spec` deletes `## Spec` entirely rather than
mutating one section, to exercise the guard that stops the agent reviewing a
design against a nonexistent spec. Because the guard means `## Design` and
`## Sub-tasks` are not reviewed **at all**, the normal "no BLOCKING or MAJOR
against an untargeted section" rule is too weak for this case — the bar is that
**nothing** about either section is reported, at any severity. See that case's
`.expected.md` for why.

| Case | Check under test |
|------|------------------|
| `control` | None — clean design and sub-task plan, must pass |
| `unclear-design` | Clarity (`## Design` against `### Readability`) |
| `unexplained-design` | Complete and clear (rationale, requirement coverage) |
| `weak-subtask-criteria` | Delivery criteria |
| `unresolved-design-question` | Blocking issues |
| `oversized-subtasks` | Sub-task quality |
| `missing-final-signoff` | Delivery criteria — end-of-feature gates left in strategy prose instead of a "Final sign-off criteria" sub-task |
| `no-spec` | The missing-`## Spec` guard — one BLOCKING `[decision]` finding and nothing else |

## Running the tests

To run the whole suite, use the regression harness:
`../harness/run.sh feature-design-reviewer` (see
[`../harness/README.md`](../harness/README.md)). It issues the invocations
documented below and writes each case's output to `harness/out/`. That path is
relative to this directory; the script itself can be run from anywhere.

To run a single case by hand, **invoke the agent through the CLI from the
repository root**, not through the in-session `Agent` tool:

```
claude -p --agent feature-design-reviewer 'Review tests/devproc/feature-design-reviewer/<case>.md'
```

One fresh agent invocation per case, then compare against `<case>.expected.md`.

The CLI route matters for a regression run specifically. In-session `Agent`
spawns have been observed to stop delivering their output partway through a
session, returning an empty idle notification instead of a review — and a
dozen-plus-invocation run is expensive to re-do once a silent failure is
noticed. With the CLI, stdout either carries a verdict line or it does not. See
`NOTES.md`, "Agent result delivery can fail silently mid-session".

A review you never saw is **unrun, not passed** — never record a case as
passing on the strength of an invocation that returned nothing.

Note that `unresolved-design-question` expects the agent to search the codebase
for a `ReportStreamService` and find nothing. An agent that reports the
dependency as unverified without having looked has reached the right answer by
the wrong route — acceptable, but worth noticing if the agent's tool access
changes.
