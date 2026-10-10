# Improve plugin subtask handling — Feature Plan

## Handoff

**Last updated:** 2026-10-10
**Session summary:** Feature complete. All seven sub-tasks are ✓; `/feature-end` ran 2026-10-10 and performed the close-out docs review.
**Sub-task in progress:** None.
**First action next session:** None. The feature is closed.
**Autonomy boundary (agreed 2026-10-10):** Sub-tasks 2–6 unattended; then the user asked to wrap up sub-task 7 and approved `/feature-end`. The user stages and commits; do not do either.
**Open questions / decisions pending:** None for this feature. A pre-existing follow-up (`/feature-end` step 2's "every sub-task ✓" versus a `/feature-end`-performed box) was raised with the user at close, to be tracked outside this plan.
**Dead ends to avoid:** Do not edit `features/FEATUREMODEL.md` by hand. Change the canonical copy, refresh the installed plugin, then re-run `/feature-init` (via `claude -p`; the Skill tool cannot invoke it).

## Requirements

From issue #67, "Improve plugin subtask handling" (verbatim):

> A few things.
>
> - The subtask list does not have each subtask as its own heading. It should. It's still good to number them, but the point is that when managing the file, the subtask list ends up being a single undifferentiated blob and it is much easier to navigate if the subtask has a header. For example, vscode will show a list of all headers in the file to navigate to, but not to line items within a heading.
>
> - When implementing a subtask, it is often better to do it docs first. This is not a hard rule, but sometimes I end up testing and reviewing a subtask, and my very first reaction is "this documents a procedure that looks wrong", obviating my testing until it is fixed. Consider (not a hard rule, just think it through) whether I should review the docs first (and if in doubt ask me when drawing up the plan).
>
> - When a subtask has sign-off criteria, they should be in the order in which they are performed. Trivial, but it can be confusing to think "wait, I am signing off on testing of the process which is listed before code review which has already happened". Some sign-off criteria may be run in parallel, which is fine, but avoid "the second sign off criteria is logically after the fourth".
>
> - Sign-offs should be clear. "Test the process to do X as documented" is fine, but if the subtask requires a load of testing, write down what the test plan is. If this is complex or is multiple steps, put it in a separate file in the slug directory. Similar things may apply in other cases; if the sign off requires many non-obvious steps then create a specific plan to work through. This is an "if required" question, requiring judgement; if in doubt ask (or say "I have chosen to put this inline and that in a separate test plan" so I can see it was an explicit decision and choose whether it is right).
>
> - The list of subtasks is not static. In practice this often works quite well now, but I want to be a bit explicit. Suppose we hit subtask 7, and my user feedback is "well this worked, but we really ought to change X". It is fine to add subtask 7a which changes X (if that is a big deal) or to just change it as a bug fix as we go (if it is not). Again, a judgement call that should be explicit.

The issue has no comments.

## Spec

### What this feature is for

Every feature in the `devproc` model has a plan file, `features/plans/<slug>.md`.
Its `## Sub-tasks` section is written by `/feature-design` and then kept up to
date during implementation by `/feature-checkpoint`, the person doing the work,
and the `dev-process-manager` agent. Each sub-task carries **sign-off criteria**:
checkboxes that must all be ticked before the sub-task counts as done. The
sign-off model is defined in `features/FEATUREMODEL.md` under
`### Sign-off criteria`.

In practice, the sub-task list has five weaknesses:

1. It is hard to navigate, because it is one long numbered list.
2. Its sign-off boxes appear in an arbitrary order.
3. Some of its sign-offs are too vague to carry out.
4. Its sub-tasks don't consider writing and checking the docs first. As a result,
   a user can spend effort testing a procedure whose documentation is plainly
   wrong.
5. When it changes during implementation, nobody records whether the change was
   a new sub-task or a fix made in passing.

This feature fixes all five, mainly in what `/feature-design` writes. Three of
the five call for judgement, not a fixed rule: docs-first ordering, whether a
test plan is needed, and how to absorb a mid-feature change. The feature does
**not** turn those three into rules. It requires the judgement to be made
**explicitly**, so the user can see that a choice was made and overturn it.

### What must change

**1. Each sub-task is its own heading.** In a plan written by `/feature-design`,
each sub-task under `## Sub-tasks` is a Markdown heading one level below
`## Sub-tasks`, so it appears in an editor's document outline. The heading
keeps the sub-task number. Its sign-off checkboxes and any notes sit beneath it.

- *Proposed:* the heading reads `### <N>. <Sub-task name>`. The one-line
  description moves to the first line of body text under the heading. On
  completion, `/feature-checkpoint` appends the existing `✓` marker and
  completion date to the heading, so status is visible in the outline.
- *Proposed:* the `▶ NEXT:` marker stays a single line in `## Sub-tasks`, but
  moves to the top of the section, before the first sub-task heading. Today it
  sits after the list. Under headings, a line after the list would read as part
  of the last sub-task.
- *Proposed:* every place that shows or describes the sub-task format adopts the
  new one. Known places are:
    - the template and examples in the `feature-design` and
      `feature-checkpoint` skills;
    - the description of the plan file in `FEATUREMODEL.md`;
    - the descriptions of the plan in the `dev-process-manager` and
      `feature-design-reviewer` agents;
    - the user docs: `devproc/README.md`, `docs/workflow.md`, and
      `docs/capabilities.md` where it applies.

  This list is illustrative. The "numbered" search in `## Sign-off strategy`
  defines the full set. Where these places say "numbered list" or "numbered
  breakdown", they are corrected.
- *Proposed:* existing plan files are not converted. Completed plans are
  historical records. A project with a plan in progress under the old format
  keeps it. The skills read a sub-task the same way whether it is a list item
  or a heading, so no compatibility wording is added for the old format.
  For the same reason, `feature-design-reviewer` does not flag a `## Sub-tasks`
  section written in the old list format.

**2. Sign-off criteria are listed in the order they are performed.** Under each
sub-task, the checkboxes appear in the order the sign-offs will actually happen.
A criterion is never listed before one that logically comes before it. Criteria
that can be carried out in parallel may appear in any order relative to each
other.

There is no fixed category order: the order comes from the sub-task, not from
the list of categories. For example, take a sub-task whose code is reviewed
before the documented procedure is tested. Its code review box is listed above
its testing box. In another sub-task the order may be reversed. What matters is
that the boxes match the order the work is actually done in.

This rule belongs to the sign-off model, so it is stated once in
`FEATUREMODEL.md` under `### Sign-off criteria`. `/feature-design` applies it,
and `feature-design-reviewer` flags violations of it.

**3. Sign-offs that need non-obvious steps say what those steps are.** A
criterion like "test the process to do X as documented" is enough when the
steps are obvious. Where a sign-off needs a substantial or non-obvious set of
steps, the plan writes those steps down. This usually means a test plan, but it
applies to any sign-off. The user reviews the steps at `/feature-design`, with
the criteria themselves.

- Short steps go **inline**, beneath the criterion they belong to.
- Complex or multi-step plans go in a **separate file** in the feature's slug
  directory, `features/plans/<slug>/`, linked from the criterion. *Proposed:*
  the file is named for what it covers, e.g. `test-plan-subtask-3.md`.
- Whether a sign-off needs written steps at all, and if so whether inline or
  separate, is a judgement made at `/feature-design`. Where the call is unclear,
  `/feature-design` asks the user. Either way, its report to the user states the
  choices it made (e.g. "sub-task 2's test steps are inline; sub-task 4 has a
  separate test plan"), so the user can see they were deliberate.
- The slug directory today holds only un-inlinable requirements artefacts
  copied in by `/feature-spec`. `FEATUREMODEL.md` widens its description to
  include sign-off plans as well.
- `feature-design-reviewer` flags a sign-off whose steps are substantial or
  non-obvious but are not written down. This is the existing auditability check,
  extended: a criterion that can't be carried out without guessing can't be
  audited either.

**4. Docs-first is considered at design time, not imposed.** Some sub-tasks
change both documentation and code. For those, `/feature-design` considers
whether the documentation should be written first and reviewed by the user
before the code is written. Reviewing docs is where a user says "no, that
procedure is not right". If that only comes after the code is written and
tested, the code, the tests and the docs all have to be redone.

- This is guidance, not a rule. Docs-first is chosen where it saves wasted
  effort, not by default.
- Where docs-first is chosen, it shows in the sign-off criteria, which are
  ordered per point 2. The docs review box comes before the boxes for the
  code written after it (or the docs work is its own sub-task, ahead of the
  code), and the sub-task description says the docs are
  written first. Where
  `## Sign-off strategy` has no per-sub-task docs review, `/feature-design` may
  add one for a docs-first sub-task. The user agrees it along with the rest of
  the criteria.
- Where it is unclear whether the user wants to review the docs before the code
  is written,
  `/feature-design` asks the user while drawing up the plan.
- *Proposed:* the design report to the user names the sub-tasks that were made
  docs-first, so the choice is visible. Sub-tasks with no documentation to write
  first need no mention.

**5. Changing the sub-task list during implementation is an explicit choice.**
The sub-task list may change after `/feature-design`. For example, finishing
sub-task 7 may produce user feedback that X should change. That change is
handled in one of two ways:

- **A new sub-task**, only for work that is both **unforeseen** (otherwise
  the plan would already have a sub-task for it) **and significant** enough to
  be a sub-task in its own right. *Settled by the user at `/feature-spec`.*
  *Proposed:* it is numbered
  with a letter suffix after the sub-task that prompted it (`7a`, then `7b`),
  not by renumbering the later sub-tasks. Renumbering would break references to
  sub-task numbers in `## Handoff`, `NOTES.md` and past conversations. It gets
  its own heading per point 1, and its own sign-off criteria derived from
  `## Sign-off strategy` and ordered per point 2.
- **A fix made in passing**, for anything smaller. It is not a sub-task: it is
  simply part of the sub-task it arose in. It is recorded as a note under that
  sub-task, so the record shows it happened.

Which of the two applies is a judgement call. Whoever makes it states the choice
when it is made, so the user can overturn it. That is the person or agent
implementing, the `dev-process-manager`, or `/feature-checkpoint` when
recording it. *Proposed:* where a new sub-task is added, its sign-off criteria
are put to the user for agreement, as criteria are at `/feature-design`. A new
sub-task is new scope, and its quality bar has not been agreed.
`/feature-checkpoint` already says to add newly discovered sub-tasks with
criteria. This point makes the choice behind that explicit, and fixes the
numbering.

**Inside an unattended autonomy boundary.** *Settled by the user at
`/feature-spec`.* This covers the case where `dev-process-manager` hits the
choice while running unattended within an agreed boundary (e.g. "do sub-tasks
1–4"). A change big enough to need a new sub-task is a replan. A replan of a
planned, specced and designed sequence always needs the user, and the manager
never starts a new sub-task the user has not agreed. What differs is when it
asks:

- **If the new work affects the flow of work in progress, the manager stops and
  asks** before going further. For example, a remaining planned sub-task
  depends on it, or would be done differently because of it.
- **If it does not, the manager may carry on** with the planned sub-tasks
  inside the boundary. It then proposes the new sub-task at the boundary report:
  "I did the planned work, but this came up, and I am asking whether we should
  do it."

**Fixes in passing.** *Settled by the user at `/feature-spec`.* A simple bug
fix is just made, and stops nothing. It is recorded under the sub-task it was
made in, and listed in the boundary report. This is a sliding scale, not a
two-way split:

- "Did X; testing turned up a couple of other minor issues, which I fixed" does
  not stop the run.
- "Did X; testing showed the approach needs major rework of another component"
  forces a halt, however the work might be labelled.

The test is the size and reach of the change, not whether it is called a fix
or a sub-task.

### Where the rules live

The ordering rule (point 2), the written-steps rule (point 3), and the rule for
changing the sub-task list (point 5) are part of the feature model, so they are
written once in the canonical `devproc/skills/feature-init/FEATUREMODEL.md`. The
skills and agents apply them without restating them, as they already do for the
rest of `### Sign-off criteria`. This repository's installed copy,
`features/FEATUREMODEL.md`, is refreshed by re-running `/feature-init`, as
`CLAUDE.md`'s maintainer note requires. The docs-first consideration (point 4) is also
stated in `FEATUREMODEL.md` `### Sign-off criteria`, with its reason, alongside
the ordering rule: it shapes the order of a sub-task's criteria, and it carries
the one allowance for a box that `## Sign-off strategy` does not call for. The
heading format (point 1) belongs to `/feature-design`, which writes the list,
and is described in `FEATUREMODEL.md` only as far as its existing description
of the plan file needs.

### Out of scope

- Converting existing plan files to the new format (see point 1).
- Making docs-first, test plans, or new-sub-task-versus-fix mandatory in either
  direction. The feature requires an explicit choice, not a particular outcome.
- Changes to `/feature-spec`, `/feature-end`, or `## Sign-off strategy`, beyond
  any wording that refers to the sub-task format.

## Sign-off strategy

The change is prose-only, to skill, agent, feature-model and documentation
Markdown. There is no executable code, apart from re-recording reviewer test
fixtures. The main risks are inconsistency (one skill still describing the old
list format, or restating a rule `FEATUREMODEL.md` now owns), and over-correction
(the judgement-call points hardening into rules the issue explicitly asked not
to make).

- **Testing.** Skills, agents and `FEATUREMODEL.md` are loaded from the
  installed plugin copy at `/home/claude/claudeplugins/devproc/`, not from this
  repository (see `NOTES.md`). So before the regression run, the dry run, and
  any re-run of `/feature-init`, that copy is refreshed from the repository and
  confirmed byte-identical with `diff -r`. Without that step, every run would
  test the old text. Testing then has two parts:
    - **Reviewer regression.** The `feature-design-reviewer` suite in
      `tests/devproc/feature-design-reviewer/` is run through
      `tests/devproc/harness/run.sh`, and every case passes its README's pass
      rule. *Proposed:* the existing fixtures are converted to the new heading
      format, so they represent what `/feature-design` now writes. New fixtures
      cover the reviewer's new checks: out-of-order criteria (point 2) and an
      unwritten non-obvious sign-off plan (point 3). The
      `feature-spec-reviewer` suite is run too, to confirm nothing regressed,
      but gains no new cases.
    - **Dry run.** `/feature-design` is run on a small throwaway feature in a
      scratch workspace outside `/workspace` (e.g. under `/tmp`), which is
      deleted afterwards. The resulting plan is checked against Spec points
      1–4. Point 5 is then exercised in that scratch workspace: a change is
      introduced mid-implementation, and the check is whether the session
      states its choice (new lettered sub-task or fix in passing) and records it
      as point 5 requires. The dry-run result goes in the sub-task's notes in
      this plan file. Anything non-obvious it turns up also goes in `NOTES.md`.
- **Documentation.** Full. Every user-facing and internal document that shows
  or describes the sub-task format or the sign-off rules is updated: the
  `FEATUREMODEL.md` pair, `devproc/README.md`, `docs/workflow.md`,
  `docs/capabilities.md` where it applies, and the workspace `CLAUDE.md` if any
  of its bullets is affected. A case-insensitive search for "numbered" across
  `devproc/` and `docs/` is done, and every remaining hit is fixed or justified.
- **Code review (agent).** One `/review-branch` over the whole change before
  `/feature-end`. The change is prose, so a per-sub-task agent review would cost
  more than it catches.
- **Docs review (agent).** One `docs-structure-reviewer` pass, performed at
  `/feature-end`.
- **User review.** The user reads the changed `FEATUREMODEL.md` sections and the
  changed `feature-design` skill steps in full before `/feature-end`. These are
  where the judgement-call points are worded, and only the user can say whether
  they read as guidance rather than rules.

## Design

### Overview

The feature is a set of prose edits across the `devproc` plugin. They are
ordered so that each rule is written once, at its owner, before anything that
applies it is changed:

1. **`FEATUREMODEL.md` first.** This is the canonical model. It gains the
   general rules: criteria in the order they are performed (point 2), written
   steps for non-obvious sign-offs and the wider role of the slug directory
   (point 3), the allowance for a docs review box the strategy does not call
   for (point 4), and how the sub-task list may change mid-feature (point 5).
   Its description of the plan file also changes to the heading format (point
   1). This repository's installed copy is then refreshed through
   `/feature-init`.
2. **The skills and agents that write or maintain the list.** They point at
   those rules and add only what is specific to them:
   - `/feature-design` writes the heading format, makes the docs-first and
     written-steps judgements, and reports its choices.
   - `/feature-checkpoint` keeps the heading format, marks completion on the
     heading, and records new lettered sub-tasks and fixes in passing.
   - `dev-process-manager` applies point 5's unattended rules.
   - `feature-design-reviewer` gains the checks for points 2 and 3, with its
     fixtures converted and extended.
3. **User docs**, then a **dry run** of the real skills in a scratch
   workspace, then the end-of-feature gates.

Nothing here is executable code. The design's decisions are about which file
owns each rule, and the order the edits land in.

### Which file owns each rule

| Spec point | Stated in | Applied by |
|---|---|---|
| 1. Heading format, `▶ NEXT:` at top | `/feature-design` template; `FEATUREMODEL.md` plan-file description (one line) | `/feature-design`, `/feature-checkpoint` |
| 2. Criteria in performed order | `FEATUREMODEL.md` `### Sign-off criteria` | `/feature-design`, `feature-design-reviewer` |
| 3. Written steps, inline or in slug directory | `FEATUREMODEL.md` `### Sign-off criteria`, plus the slug-directory description under `### Documents to support the model` | `/feature-design` (judgement and report), `feature-design-reviewer` |
| 4. Docs-first (with its reason, and the extra-box allowance) | `FEATUREMODEL.md` `### Sign-off criteria` | `/feature-design` step 6 |
| 5. Changing the list mid-feature | `FEATUREMODEL.md`, in a new short subsection after `### Sign-off criteria` | `/feature-checkpoint`; `dev-process-manager` for the unattended rules |

Point 5's unattended rules (stop if the new work affects the flow of work in
progress; otherwise carry on and propose at the boundary) go in
`dev-process-manager.md` §2, not in `FEATUREMODEL.md`. Autonomy boundaries are
a concept of the manager, not of the model, and `FEATUREMODEL.md` is copied
into consumer projects that may never use the manager. The model states only
the rule that applies to everyone: the choice is stated, and a new sub-task's
criteria are agreed with the user.

Point 5 gets its own subsection in `FEATUREMODEL.md`, not a bullet inside
`### Sign-off criteria`. It is about the shape of the sub-task list over time,
not about sign-off. Folding it in would make that section, which the skills
cite as "the sign-off model", cover two things.

### Format details

- A sub-task heading is `### <N>. <Name>`. On completion,
  `/feature-checkpoint` changes it to `### <N>. <Name> ✓ (YYYY-MM-DD)`. The
  one-line description is the first body line. Sign-off boxes follow, then any
  notes.
- Notes that apply to the whole list also go at the top, after `▶ NEXT:` and
  the reminder. An example is the note justifying an omission that recurs
  across several sub-tasks, which `/feature-design` step 6 currently places
  "beneath the sub-task list". This plan's own note is placed that way.
- A new sub-task inserted after sub-task 7 is `### 7a. <Name>`, placed directly
  after sub-task 7's section.
- `**▶ NEXT:** Sub-task N` is the first line under `## Sub-tasks`. The
  "Run `/feature-checkpoint` after each sub-task" reminder moves up beside it.
  Left after the last heading, it would read as part of the final sub-task.

### The reviewer and its fixtures

`feature-design-reviewer` gets two checks in its delivery-criteria section:

- criteria out of performed order;
- a sign-off whose steps are substantial or non-obvious but not written down.

It also gets an explicit instruction not to flag the old list format. The eight
existing design fixtures have their `## Sub-tasks` sections converted to the
heading format. Their content is unchanged, so their `.expected.md` files, which
state rules rather than recorded transcripts, need no change. Two new cases,
`misordered-criteria` and `unwritten-signoff-steps`, are added, each a mutation
of `control.md`'s `## Sub-tasks`. A third new case, `old-format-control`, is
`control.md` with `## Sub-tasks` left in the old list format. It must pass with
no finding about the format, so the "do not flag the old format" instruction is
covered. The `feature-spec-reviewer` fixtures have no `## Sub-tasks` section
and are untouched.

The existing fixtures were read against the two new checks. Their criteria are
in a sound order. The one candidate for the unwritten-steps check is the manual
large-tenant export ("one manual export of the largest available test tenant,
opened in a spreadsheet with values confirmed correct"), which is a single
stated action, not a hidden procedure. So no existing case is expected to
trigger either check. If the regression run shows otherwise, the fix goes to
the fixture, or to its README's "Known soft spots" if the finding is
defensible. It does not go to the reviewer's wording, which would weaken the
check to fit the test.

We do not add a reviewer check for whether docs-first was considered. The spec
asks for docs-first as a judgement `/feature-design` makes and reports. A
reviewer cannot tell from the plan alone whether the judgement was skipped or
made and declined, so the check would mostly produce noise.

### Applying this feature's own rules to its plan

This plan uses the format it introduces, and makes the same judgements it asks
`/feature-design` to make:

- **Docs-first.** Sub-task 1 is docs-first. Its `FEATUREMODEL.md` wording is
  the rule every later sub-task applies, so the user reviews it before anything
  else is changed. This is a per-sub-task user review that the strategy does
  not call for; the strategy's user review is a single read before
  `/feature-end`. It is added under point 4's allowance, and the user agrees it
  here. The end-of-feature read stays, because `/review-branch` may change the
  text after the early review. The other sub-tasks are not made docs-first:
  each is the docs, or applies wording already reviewed in sub-task 1.
- **Written steps.** The dry run (Sub-task 6) has a separate test plan,
  [`subtask-handling/dry-run-test-plan.md`](subtask-handling/dry-run-test-plan.md),
  because it has eleven steps across two parts. The harness run and the
  plugin-refresh check are written inline: each is one or two commands.

### Rejected alternatives

- **Renumbering later sub-tasks when one is inserted.** Rejected in the spec
  because it breaks references. The letter suffix is used instead.
- **Putting status markers only in body text.** `✓` goes in the heading so
  progress is visible in the editor outline, which is the reason for the
  heading change in the first place.
- **One combined sub-task for all skill and agent edits.** That would be too
  large to review in one go. It is split by owner, so each sub-task's diff is
  coherent.

## Sub-tasks

**▶ NEXT:** None. All sub-tasks are complete.

> Run `/feature-checkpoint` after each sub-task completes.

No sub-task before the final one carries a code review box. The strategy calls
for a single `/review-branch` over the whole change, which is in "Final sign-off
criteria". Wherever a box says "installed plugin refreshed", it means: run
`rm -rf /home/claude/claudeplugins/devproc && cp -a /workspace/devproc /home/claude/claudeplugins/devproc`,
then confirm that `diff -r /workspace/devproc /home/claude/claudeplugins/devproc`
prints nothing.

### 1. Feature-model rules ✓ (2026-10-10)

Docs-first. Add the point 2, 3, 4 and 5 rules and the heading-format plan
description to the canonical `devproc/skills/feature-init/FEATUREMODEL.md`, and
refresh `features/FEATUREMODEL.md` through `/feature-init`.

- [x] Documentation: canonical `FEATUREMODEL.md` states the ordering rule, the written-steps rule, the wider role of the slug directory, the docs-review allowance (all in `### Sign-off criteria` or the slug-directory description), a new subsection for changing the sub-task list, and the heading format in the plan-file description
- [x] User review: user reads the changed `FEATUREMODEL.md` sections and confirms the judgement-call points read as guidance, not rules
- [x] Testing: installed plugin refreshed; `/feature-init` re-run in `/workspace`; `diff features/FEATUREMODEL.md devproc/skills/feature-init/FEATUREMODEL.md` prints nothing

### 2. `/feature-design` skill ✓ (2026-10-10)

Update the template to the heading format, and step 6 to apply the ordering
and written-steps rules and the docs-first consideration. Step 8's report names
the docs-first and inline-versus-separate choices.

- [x] Documentation: `feature-design/SKILL.md` template and both examples use `### N. Name` headings with `▶ NEXT:` and list-wide notes at the top; step 6 places recurring-omission notes there too; step 6 covers ordering (pointing at `FEATUREMODEL.md`), written steps, and docs-first, and tells the skill to ask the user where the written-steps call or the docs-first call is unclear; step 8's report list includes the docs-first and written-steps choices

### 3. `/feature-checkpoint` and `dev-process-manager` ✓ (2026-10-10)

Checkpoint keeps the heading format, marks `✓` on the heading, adds lettered
sub-tasks and fix-in-passing notes, and states the choice. The manager gets
point 5's unattended rules and a corrected description of the plan.

- [x] Documentation: `feature-checkpoint/SKILL.md` example uses the heading format; its step 2 covers `✓` on the heading, `▶ NEXT:` at the top, lettered sub-tasks with criteria put to the user, and fix-in-passing notes; it states which of the two it chose when recording a change; it points at `FEATUREMODEL.md` for the rule
- [x] Documentation: `dev-process-manager.md` no longer says "numbered sub-task list"; §2 states that new work affecting the flow of work in progress stops the run, that other new sub-tasks are proposed at the boundary and not started unagreed, and that a fix in passing does not stop the run when it is small and contained, but any change whose size or reach would rework another component halts the run whatever it is called; fixes are listed in the boundary report

### 4. `feature-design-reviewer` and its fixtures ✓ (2026-10-10)

Add the two new checks and the instruction not to flag the old format. Convert
the fixtures to headings and add three cases: two for the new checks, and one
old-format control.

- [x] Documentation: `feature-design-reviewer.md` has the ordering and unwritten-steps checks, an instruction not to flag the old list format, and no "numbered breakdown" wording
- [x] Documentation: all eight existing design fixtures use the heading format with content otherwise unchanged; `misordered-criteria`, `unwritten-signoff-steps` and `old-format-control` cases and their `.expected.md` files added; suite `README.md` case table updated
- [x] Testing: installed plugin refreshed; `tests/devproc/harness/run.sh` run over both suites; every case passes its suite README's pass rule (results noted under this sub-task)
- Note — harness results (2026-10-10): installed plugin refreshed, `diff -r` clean. All 18 cases pass their suite README's pass rule: 11 design-reviewer cases, including the new `misordered-criteria` (MAJOR `[rewrite]` on both planted misorderings), `unwritten-signoff-steps` (MAJOR `[decision]`) and `old-format-control` (READY, no format finding), plus the 7 unchanged spec-reviewer cases. Eight design cases were re-run after a baseline fix.
- Note — fix in passing: after conversion, three design cases nondeterministically drew a MAJOR against the shared baseline `## Design`, which never said how the browser receives the download. The cause was a latent gap in the fixture text, not the format change. Fixed in all eight design fixtures, not in the reviewer (see `NOTES.md`). Treated as a fix in passing: it is small and contained to the fixtures.

### 5. User-facing documentation ✓ (2026-10-10)

Update `devproc/README.md`, `docs/workflow.md` (the sub-task example and
"add more sub-tasks" paragraph), `docs/capabilities.md` where it applies, and
`CLAUDE.md` bullets if affected.

- [x] Documentation: listed docs show the heading format and describe the ordering, written-steps, docs-first and mid-feature-change behaviour
- [x] Documentation: case-insensitive search for "numbered" across `devproc/` and `docs/` done; every remaining hit fixed or justified in a note under this sub-task
- Note — "numbered" sweep: `devproc/README.md` hit fixed. Remaining hits justified: `FEATUREMODEL.md` ("numbered with a letter suffix", the new `7a` rule); `feature-design-reviewer.md` (the deliberate "do not flag the older numbered-list format" instruction); `docs/workflow.md` ("renumbered", in the new mid-feature text).

### 6. Dry run ✓ (2026-10-10)

Exercise the changed skills end to end in a scratch workspace, following the
separate test plan.

- [x] Testing: every step of [`subtask-handling/dry-run-test-plan.md`](subtask-handling/dry-run-test-plan.md) carried out, with its pass or fail recorded under this sub-task; any failure fixed and its check re-run
- Note — dry-run results (2026-10-10, real CLI in `/tmp/sth-dryrun`, since torn down). The scratch feature was a backup script with a README procedure. All steps passed:
    - Steps 1–4: plugin refreshed (`diff -r` clean); `/feature-init` produced a `FEATUREMODEL.md` identical to the canonical copy.
    - Steps 5–6: `/feature-spec` and `/feature-design` ran unattended, asked nothing, and each reached READY FOR USER REVIEW on the second review pass.
    - (1a) Pass: sub-tasks are `### 1.`, `### 2.`, `### 3. Final sign-off criteria`.
    - (1b) Pass: `**▶ NEXT:** Sub-task 1` is the first line of `## Sub-tasks`.
    - (2) Pass: every sub-task's boxes are in performed order. The final sub-task's intro explains its order.
    - (3) Pass: the restore check's three steps are written inline, and the report said so explicitly.
    - (4) Pass: the README work was made docs-first as a sub-task of its own (Documentation, then Docs review (user)), ahead of the code sub-task, and named in the report. This exposed an imprecision in our own wording (see fix below); judged against the corrected check.
    - Step 8 pass: `✓ (2026-10-10)` on sub-task 1's heading, and `▶ NEXT:` moved to sub-task 2 at the top. The first two attempts were refused because the hand-ticked boxes had no README behind them, so the fixture was wrong and the checkpoint was right to refuse.
    - Step 9 pass: unforeseen checksum work became `### 2a.`, with no renumbering and ordered boxes marked "proposed and not yet agreed". The session stated its choice and asked the user to agree the criteria. It also amended its own Spec, Design and Review record, which goes beyond what point 5 requires but is not wrong.
    - Step 10 pass: the typo fix was treated as a fix in passing, stated as such, and noted under sub-task 2. No sub-task was added.
- Note — fix in passing: the dry run's step 7 (4) showed that "a docs-first sub-task's docs review box comes first among its criteria" is wrong when writing the docs is itself a box, and it ignores docs-first done as a separate sub-task. Reworded to "comes before the boxes for the code written after it" (or the docs work as its own sub-task ahead of the code) in `FEATUREMODEL.md`, `feature-design/SKILL.md`, `feature-design-reviewer.md`, the test plan, and Spec point 4. The plugin was refreshed and `/feature-init` re-run via `claude -p`; `features/FEATUREMODEL.md` matches the canonical copy again. The meaning is unchanged; only the precision is improved. It is flagged for the user's final read.

### 7. Final sign-off criteria ✓ (2026-10-10)

End-of-feature gates for this feature, per `## Sign-off strategy`.

- [x] Code review (agent): `/review-branch` over all changed files; findings resolved or dismissed
- [x] User review: user reads the final changed `FEATUREMODEL.md` sections and `feature-design/SKILL.md` steps in full
- [x] Docs review (agent): `docs-structure-reviewer` over the updated docs (performed at `/feature-end`)

- Fix in passing (from the user's read): the sub-task description in `/feature-design`'s template now states what the sub-task covers as well as what success looks like; `feature-design-reviewer`'s Descriptions check and the `oversized-subtasks` expected output were changed to match. Design suite re-run: all 11 cases match their expected verdicts.
- `/review-branch` (2026-10-10; simplicity, general and nitty agents; architectural pass not run, since the change is prose and the design was already reviewed). Two passes to converge. Applied:
  - `FEATUREMODEL.md`: the docs-first cross-reference now points "above"; "Subtask list" became "Sub-task list"; the lettered-sub-task rule now says the next free letter, placed after any existing lettered siblings; "ordered as above" became "ordered as set out under `### Sign-off criteria`". Then the installed plugin was refreshed and `/feature-init` re-run; the two copies are identical.
  - `feature-checkpoint/SKILL.md`: the list-change bullet is split into its two routes; new-sub-task criteria are marked proposed until agreed; a teammate reports a new sub-task to the manager rather than adding it; `▶ NEXT:` follows document order (`7a` before `8`).
  - `dev-process-manager.md`: defines "affects the flow of work" (a remaining planned sub-task depends on it, or would be done differently because of it); the teammate brief says not to add a new sub-task, including at checkpoint.
  - `feature-design/SKILL.md`: the docs-first example's rationale now comes before the code fence, and the example gains a Documentation box ahead of the docs review.
  - `docs/workflow.md`: Order is stated as a rule, separately from the two reported judgements. `devproc/README.md`: two sentences clarified.
  - `dry-run-test-plan.md` step 8: do real work before ticking, since `/feature-checkpoint` refuses boxes it cannot verify.
  - Dismissed: (1) restating rules across files, because the design's rule-ownership table settled where each rule lives; (2) hardening the fixtures (the "control" wording, the 3 fixtures without the download sentence, extra must-not-report lines), since all 18 cases pass and changing them would need re-baselining; (3) the reviewer's severity-label style, which is cosmetic.
  - Out of scope, pre-existing: `/feature-end` step 2 requires every sub-task ✓, but the final sub-task cannot be ✓ while its `/feature-end`-performed box is open. To raise as a separate issue.
- Fix in passing (at the user's request, after `/review-branch`): repetition reduced. In the user docs, `docs/workflow.md` is the single home for sub-task format, ordering, docs-first, written steps and list changes, and `docs/capabilities.md` is the home for the manager's unattended behaviour; `devproc/README.md` now points to them instead of restating them. In `feature-design/SKILL.md` and `dev-process-manager.md`, rules restated from `FEATUREMODEL.md` and their reasons were cut to a one-line action plus a pointer. The reviewer's explicit checks and the checkpoint/manager action lines were kept, since an agent acts on its own file.
  - The user's read (box 2) was done before this review. The changes above to `FEATUREMODEL.md` and `feature-design/SKILL.md` have been put to the user before `/feature-end`.

## Review record

- 2026-10-10 — Spec reviewed by `feature-spec-reviewer` (two passes): VERDICT: NEEDS WORK. Presented to the user for sign-off, with 1 open question (point 5 under an unattended autonomy boundary).
- 2026-10-10 — Design reviewed by `feature-design-reviewer` (two passes): VERDICT: READY FOR USER REVIEW. Presented to the user for sign-off.
- 2026-10-10 — Spec amended during implementation (Sub-task 1), at the user's direction: point 4 now says docs-first means the user reviews the docs before the *code is written*, not before testing, and gives the reason (catching a wrong procedure before code, tests and docs all need redoing). "Where the rules live" and the design table updated to match: the docs-first consideration is now stated in `FEATUREMODEL.md` with its reason.
- 2026-10-10 — Spec point 4 wording made more precise during implementation (Sub-task 6, fix in passing): "the docs review box comes first" became "comes before the boxes for the code (or the docs work is its own sub-task, ahead of the code)", after the dry run showed the first wording was wrong when writing the docs is itself a box. Meaning unchanged; flagged for the user's final read.
- 2026-10-10 — Close-out docs review by `docs-structure-reviewer` (two passes): VERDICT: SOUND. MINOR findings applied (test README counts and baseline rule, `docs/workflow.md` subsection anchors and a docs-first example, the `capabilities.md` stop-condition definition, `FEATUREMODEL.md` terminology). Feature closed by `/feature-end`.
