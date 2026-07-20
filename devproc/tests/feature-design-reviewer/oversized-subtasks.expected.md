# Expected findings — `oversized-subtasks.md`

**Flaw under test:** sub-task quality. Sub-task 1 is the entire feature in one
box with a description that restates its name, and sub-tasks 2–4 are unrelated
trivia. The `## Design` section is the clean baseline and must not be faulted.

## Required findings

**Both** of, at **BLOCKING** or **MAJOR** severity:

1. **Sub-task 1 is the whole feature** — endpoint, streaming, formatting, and
   the page control are one sub-task, so it cannot be finished, reviewed, or
   signed off in one go, and its single testing box bundles four unrelated
   checks. The recommendation must be to split it, and should propose roughly
   the split the design already implies (endpoint / formatting layer / page
   control).
2. **Sub-tasks 2–4 do not belong to this feature** — the `ReportView` prop
   rename, the `TODO` comment on the legacy PDF exporter, and the `csv-writer`
   version bump deliver none of the requirements. At least two of the three must
   be named. Note that the dependency bump may be a genuine prerequisite; a
   finding that asks whether it is required by sub-task 1 (and if so, that it be
   stated as such and ordered first) is a correct answer rather than a miss.

The findings should also raise at least one of:

3. **Sub-task 1's description is empty** — "build the export" restates the name
   and states nothing about what success looks like.
4. **Ordering leaves work stranded** — the `TODO` comment in sub-task 3 refers to
   the formatting layer, which is buried inside sub-task 1 with no independent
   existence; and the trivia sub-tasks sit between the feature work and its
   documentation for no reason.
5. **Granularity is inconsistent** — one sub-task spanning the whole feature
   alongside three that are single-line edits means the sign-off model gives the
   same weight to each.

## Must not report

- Any **BLOCKING or MAJOR** finding faulting `## Design` **on its own terms** —
  it is the clean baseline. MINOR findings and SUGGESTIONs there are tolerated.

  A design finding that arises *from* this case's planted sub-tasks is not a
  violation, because the flaw genuinely creates it. The known instance: sub-task
  4 bumps `csv-writer` "for the quoting fix", which implies a serialiser choice
  the design never records — the reviewer is right that the decision is
  load-bearing (the writer must support incremental writes to a stream) and
  reviewable nowhere. The control does not raise this, which is the evidence
  that the sub-tasks, not the design, are its source.
- Any finding faulting the absence of per-sub-task code-review boxes: the
  strategy puts code review at feature level and the plan records it beneath the
  sub-task list.

**Expected verdict:** `NEEDS WORK`
