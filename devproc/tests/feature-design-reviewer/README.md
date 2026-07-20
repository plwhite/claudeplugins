# `feature-design-reviewer` test fixtures

Test cases for the `feature-design-reviewer` agent. Nothing here is a real
feature plan — each `.md` file is a deliberately constructed input, and none of
them describes work on this repository.

The layout, conventions, and pass rules are the same as for
[`../feature-spec-reviewer/`](../feature-spec-reviewer/README.md); read that
README first. The differences are below.

## What the untargeted sections are

These fixtures carry all four sections (`## Requirements`, `## Sign-off
strategy`, `## Design`, `## Sub-tasks`), because a design can only be judged
against the requirements it must satisfy and the strategy its criteria derive
from. The agent reads those two for context but does not review them, so:

- `## Requirements` and `## Sign-off strategy` are identical clean baseline text
  in every case, and must draw no BLOCKING or MAJOR finding.
- A case targeting `## Design` leaves `## Sub-tasks` at baseline, and vice
  versa — except where a single flaw genuinely spans both, which is recorded in
  that case's `.expected.md`.

## Cases

One exception to the one-flaw rule: `unexplained-design` tests both halves of
"complete and clear" at once — decisions asserted without rationale, *and* a
requirement covered by no part of the design or sub-tasks. They are distinct
defects and a design can have either without the other, so the case passes only
when **both** required findings are present. Splitting it into two fixtures
would be defensible; it is kept as one because the two failures share a root
cause in practice — a design written too quickly to record its own reasoning.

| Case | Check under test |
|------|------------------|
| `control` | None — clean design and sub-task plan, must pass |
| `unexplained-design` | Complete and clear (rationale, requirement coverage) |
| `weak-subtask-criteria` | Delivery criteria |
| `unresolved-design-question` | Blocking issues |
| `oversized-subtasks` | Sub-task quality |

## Running the tests

```
Run the feature-design-reviewer agent over
devproc/tests/feature-design-reviewer/<case>.md
```

One fresh agent invocation per case, then compare against `<case>.expected.md`.

Note that `unresolved-design-question` expects the agent to search the codebase
for a `ReportStreamService` and find nothing. An agent that reports the
dependency as unverified without having looked has reached the right answer by
the wrong route — acceptable, but worth noticing if the agent's tool access
changes.
