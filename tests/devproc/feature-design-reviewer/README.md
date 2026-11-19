# `feature-design-reviewer` test fixtures

Test cases for the `feature-design-reviewer` agent. Nothing here is a real
feature plan — each `.md` file is a deliberately constructed input, and none of
them describes work on this repository.

The layout, conventions, and pass rules are the same as for
[`../feature-spec-reviewer/`](../feature-spec-reviewer/README.md); read that
README first. The differences are below.

## What the untargeted sections are

These fixtures carry all five sections (`## Requirements`, `## Spec`,
`## Sign-off strategy`, `## Design`, `## Sub-tasks`), because a design can only be
judged against what the feature must do (`## Spec`) and the strategy its
criteria derive from. The agent reads `## Requirements` and `## Spec` for
background and traces design coverage against `## Spec`, but does not review
either as an artefact in its own right, so:

- `## Requirements`, `## Spec` and `## Sign-off strategy` are identical clean
  baseline text in every case, and draw no BLOCKING or MAJOR finding (apart
  from the tolerated finding below). The exceptions are
  `headed-requirements-control` and `old-format-control`, which carry `## Spec`
  in another form (see [Cases](#cases)); apply a baseline `## Spec` fix to them
  in their own form.
- A case targeting `## Design` leaves `## Sub-tasks` at baseline, and vice
  versa — except where a single flaw genuinely spans both, which is recorded in
  that case's `.expected.md`.

The baseline `## Design` and `## Sub-tasks` text is shared across the design
cases in the same way, and follows the same rules as the spec suite's
[Maintaining the shared baseline](../feature-spec-reviewer/README.md#maintaining-the-shared-baseline):
a weakness found in it is fixed in every case that carries it. The
three cases whose `## Design` is the deliberate target (`unclear-design`,
`unexplained-design`, `unresolved-design-question`) carry their own altered
design text instead; likewise, the cases targeting `## Sub-tasks`, and
`old-format-control`, carry their own sub-task text.

There is one recorded exception to fixing baseline weaknesses. The baseline
design reuses a query-builder module and column definitions the reviewer cannot
confirm exist, because the product is fictional. A MAJOR `[decision]` finding
about them, and the `NEEDS WORK` verdict it forces, may be tolerated in any case
using the shared baseline, including the controls; nothing else is widened this
way. It is the one departure from the spec suite's rule against widening an
`.expected.md`, made because no wording can make fictional modules confirmable,
and the reviewer rule behind the finding is right for real plans.

## Cases

| Case | Check under test |
|------|------------------|
| `control` | None — clean design and sub-task plan, must pass |
| `unclear-design` | Clarity (`## Design` against `### Readability`) |
| `unexplained-design` | Complete and clear (rationale, requirement coverage) |
| `weak-subtask-criteria` | Delivery criteria |
| `unresolved-design-question` | Blocking issues |
| `oversized-subtasks` | Sub-task quality |
| `missing-final-signoff` | Delivery criteria — end-of-feature gates left in strategy prose instead of a "Final sign-off criteria" sub-task |
| `misordered-criteria` | Delivery criteria — a sub-task's boxes listed out of performed order |
| `unwritten-signoff-steps` | Delivery criteria — a substantial sign-off whose steps are written down nowhere |
| `old-format-control` | None — `control` with `## Sub-tasks` and `## Spec` in the old numbered-list format; must pass, with no finding about the format of either |
| `headed-requirements-control` | None — `control` with `## Spec` requirements as `####` headings; must pass, with coverage traced from them and no finding about the format |
| `no-spec` | The missing-`## Spec` guard — one BLOCKING `[decision]` finding and nothing else |

Notes on particular cases:

- `unclear-design` and `unexplained-design` are deliberately kept distinct
  rather than folded together: `unclear-design`'s rationale is present but
  tangled into the main line so it cannot be followed, and its design opens
  with no overview; `unexplained-design`'s rationale is simply absent. A design
  can fail either without the other, so the two checks — Clarity and Complete
  and clear — each get their own case.
- **Exception to the one-flaw rule:** `unexplained-design` tests both halves of
  "complete and clear" at once — decisions asserted without rationale, *and* a
  requirement covered by no part of the design or sub-tasks — and passes only
  when **both** required findings are present. It is kept as one case because
  the two failures share a root cause in practice: a design written too quickly
  to record its own reasoning.
- **A larger exception:** `no-spec` deletes `## Spec` entirely, to exercise the
  guard that stops the agent reviewing a design against a nonexistent spec.
  Because the guard means `## Design` and `## Sub-tasks` are not reviewed **at
  all**, the bar is that **nothing** about either section is reported, at any
  severity. See that case's `.expected.md` for why.
- `unresolved-design-question` expects the agent to search the codebase for a
  `ReportStreamService` and find nothing. An agent that reports the dependency
  as unverified without having looked has reached the right answer by the wrong
  route — acceptable, but worth noticing if the agent's tool access changes.

Spec and sub-task formats:

- `old-format-control` — `## Sub-tasks` in the older numbered-list format, and
  `## Spec` requirements as numbered bold list items (`1. **Name.** text`), so
  that the reviewer's acceptance of both older formats stays tested.
- `headed-requirements-control` — `## Spec` requirements as `#### N. Name`
  headings under a grouping `###` heading, the format the `Spec` entry in
  [`FEATUREMODEL.md`](../../../devproc/skills/feature-init/FEATUREMODEL.md)
  sets.
- All other cases — `## Sub-tasks` in the heading format (`### N. Name`,
  description first, boxes beneath), and the baseline's unnumbered bullet list
  of requirements, which also confirms a short unnumbered spec is not flagged.

## Running the tests

To run the whole suite, use the regression harness:
`../harness/run.sh feature-design-reviewer` (see
[`../harness/README.md`](../harness/README.md)). It issues the invocations
documented below and writes each case's output to `../harness/out/`. The
script itself can be run from anywhere.

To run a single case by hand, **invoke the agent through the CLI from the
repository root**, not through the in-session `Agent` tool:

```
claude -p --agent feature-design-reviewer 'Review tests/devproc/feature-design-reviewer/<case>.md'
```

One fresh agent invocation per case, then compare against `<case>.expected.md`.

For why to use the CLI rather than the in-session `Agent` tool, and why a
review you never saw is unrun rather than passed, see
[Running the tests](../feature-spec-reviewer/README.md#running-the-tests) in
the `feature-spec-reviewer` README.
