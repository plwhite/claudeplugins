# Expected findings — `deferred-requirements.md`

**Flaw under test:** the one check `feature-spec-reviewer` retains over
`## Requirements` after the `## Spec` split — that source-issue content is
genuinely **captured**, not deferred to (see the agent's criterion 2: *"Where
the feature came from a source issue, has the issue's content been captured
rather than summarised away in `## Requirements`? ... A `## Requirements`
section that defers to the issue ('see #47 for detail') fails this test."*).
`## Requirements` here is the literal case the criterion names: a one-line
pointer to issue #47 instead of the verbatim quote, comment, and clarifying
notes `control.md` carries. `## Spec` is untouched `control.md` text — full,
clear, and internally complete — and so is `## Sign-off strategy`.

This is the **only** case in this suite whose targeted section is
`## Requirements` rather than `## Spec` — see the qualification added to this
suite's `README.md`.

## Choosing the severity: MAJOR, not BLOCKING

This is a genuine, unrecoverable gap: the test is "could a fresh session work
from this file alone, without re-reading the issue", and the answer here is
no — the exact wording of the request, the reporting lead's comment about the
200,000-row tenant, and the clarifying notes about "the rows currently
displayed" and the filename date are gone, replaced by a pointer to an issue
that may later be edited, closed, or become unreachable. A later session
resuming from this plan file cannot recover them from the file itself.

It is deliberately **not** BLOCKING, because BLOCKING means design cannot
sensibly start — and here it can: `## Spec` already states, completely and
clearly, what the feature must do (the same text `control.md` carries).
Nothing about starting design is obstructed by the missing verbatim capture.
The finding is MAJOR — "will cause rework or confusion if unaddressed, but
design could start" is exactly this case: the confusion lands later, when
someone needs the original wording and the file cannot supply it.

The fix is mechanical (restore the captured issue text), not a question
resting on the user's judgement, so the finding is marked `[rewrite]`.

## Required findings

1. A finding at **MAJOR** severity or higher against `## Requirements`, marked
   **`[rewrite]`**, reporting that the section defers to issue #47 ("See issue
   #47 ... for the full requirements and discussion") instead of capturing its
   content, and that a fresh session could not work from this file alone
   without re-reading the issue.

## Must not report

- Any **BLOCKING or MAJOR** finding against `## Spec` or `## Sign-off
  strategy`, which are the clean `control.md` baseline text. MINOR findings
  and SUGGESTIONs there are tolerated.
- A finding treating this as a `## Spec` clarity or completeness fault —
  `## Spec` is untouched and fully covers everything `control.md`'s
  `## Requirements` would have supplied; the flaw is specifically that
  `## Requirements` no longer captures the input, not that `## Spec` fails to
  state what the feature must do.
- A finding faulting the absence of a design.

**Expected verdict:** `NEEDS WORK`
