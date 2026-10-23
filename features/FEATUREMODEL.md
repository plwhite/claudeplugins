<!-- This is the feature-model text, imported into CLAUDE.md's `## Feature model` section (which is why it has no top-level heading of its own). It is an installed copy: `/feature-init` refreshes it from the canonical FEATUREMODEL.md shipped with the devproc plugin on every run, so edit that shipped copy, not this one — local edits here are overwritten. -->

Major pieces of work are organised into features. Each feature has a concise entry in one of the feature-list files under `features/` and a detailed plan file in `features/plans/`.

Use these slash commands (defined in the `devproc` plugin) to manage features
through their lifecycle — **spec → design → implement → end**:

- `/feature-spec` — create a new feature in `features/PENDING.md`, write its specification into the plan file, and agree the feature's **sign-off strategy**
- `/feature-design` — move a feature to `features/CURRENT.md`, write its design and sub-task plan, and agree the **sign-off criteria** for each sub-task
- *(implementation has no slash command — work through the sub-tasks directly; a sub-task is complete only when all its sign-off boxes are ticked)*
- `/feature-checkpoint` — during implementation, sync all feature documentation and plans to the current state (run after each sub-task and when prompted within sub-tasks)
- `/feature-end` — mark a feature complete and move it to `features/COMPLETED.md`

`NOTES.md` is maintained continuously. Any non-obvious technical finding — page structure quirks, API behaviour, design decisions, scope changes — goes there as it is discovered.

### The workspace

The **workspace** is the directory Claude is run in, and the one holding `CLAUDE.md`, `NOTES.md` and `features/`. Every path in this document is relative to it. It takes one of two shapes:

- **Tracked workspace** — the workspace is itself the root of a git repository. This is the common case.
- **Untracked workspace** — the workspace is not under git control; the code being worked on sits in one or more git repositories beneath it.

These two are exhaustive: the workspace is either the repository root, or it is not a repository at all but contains one. Either way, `CLAUDE.md`, `NOTES.md` and `features/` live at the top of the workspace, never inside a nested repository — so in an untracked workspace they are not part of any repository, and anything git-specific (ignore rules, branches, diffs) applies to the repositories beneath, not to the tracking files.

### Sign-off criteria

This section is the **canonical statement of the sign-off model**. The
`devproc` skills and review agents apply the rules written here rather than
carrying their own copies — when the model changes, it changes here.

Every feature defines explicit sign-off criteria, so quality steps are a
deliberate choice rather than something quietly skipped. Five categories cover
the most likely sign-offs:

- **Testing** — manual or automated checks that the work behaves correctly.
- **Documentation** — user and architectural docs updated to reflect the change.
- **Code review** — review of the code, by an agent (e.g. a light per-sub-task agent review, or a full `/review-branch`) or by the user.
- **Docs review** — review of the documentation, by an agent (`/review-docs`) or by the user. This is a review activity like code review — checking what was done, not writing it — and it has its own category because it is the sign-off most routinely missed. It has four kinds, and the strategy sets a bar for each kind or skips it explicitly. The first three review the **user docs** (`README.md` and every document reachable from it, which people use to work with what the project delivers); the fourth reviews the **agent docs** (`CLAUDE.md`, `NOTES.md`, `.claude/rules/*.md`, which are for Claude only). Feature records (everything under `features/`, including this model) are never docs-reviewed:
    - **Accuracy** — the docs still match the code and its behaviour. Warranted whenever any doc changes, or might need to.
    - **Architectural** — the documentation set still hangs together: its structure, its links, and any docs in non-obvious places that the change should have touched. Warranted whenever there is any risk that the structure should change, a link might break, or a doc has been missed.
    - **Style** — the docs read clearly and consistently. Warranted whenever any doc prose is added or changed, other than a trivial edit that manifestly cannot affect how it reads.
    - **Agent docs** — the agent docs still match the repository, hold nothing a person needs that the user docs lack, and link to the user docs rather than repeat them. Warranted whenever an agent doc changes, or the change touches anything an agent doc describes (a file it lists, a path, a command, a component).

    Skip a kind only for a trivial change that manifestly cannot need it. When in doubt, run it: a review that finds nothing costs a few tokens, and a missed one can leave errors in. Docs review is normally run once, in the final sub-task, like any other sign-off, and may also appear in other sub-tasks. A box names the skill and the kinds, e.g. `- [ ] Docs review (agent): /review-docs over the change, all kinds`.
- **User review** — the user sees and confirms the work.

These five are the usual set, not a closed list: a feature's strategy may split
one into separate sign-offs (e.g. unit tests and manual tests confirmed at
different stages) or add a specific sign-off of another kind (e.g. "agent X has
confirmed the output"). Do not invent sign-offs for their own sake, but do
capture whatever genuinely gates the work.

Every sign-off criterion must be **auditable**: when a sub-task is finished it
must be unambiguous whether the criterion is met. "Have some tests" is not
auditable; "unit tests written to the agreed quality bar" is, and so is "enough
tests that the user confirms coverage is sufficient" — each has a clear
done/not-done point. Word every criterion so it has a definite yes/no.

Part of being auditable is that any review sign-off — code review, docs
review, or otherwise — says **who performs it**: an agent (naming the skill or
agent, e.g. `/review-branch`, `/review-docs`) or the user. A bare
"code review" box is ambiguous. In checkbox labels, write the performer in
parentheses — e.g. `- [ ] Code review (agent): /review-component the parser`,
`- [ ] Docs review (agent): /review-docs over the updated docs, all kinds`, or
`- [ ] Code review (user): user reads the parser diff`. (A **User review**
box needs no parenthetical — the user is the performer by definition.)

Under each sub-task the boxes are listed **in the order they are performed**: a
criterion is never listed before one that logically comes before it, and
criteria that can be carried out in parallel may appear in any order relative to
each other. There is no fixed category order; the order comes from the
sub-task, not from the list of categories.

**Docs-first sub-tasks.** Where a sub-task changes both documentation and code,
it is often worth writing the documentation first and having the user review it
before the code is written. Reviewing docs is where a user says "no, that is not
the right procedure" — and if that comes after the code is written and tested,
the code, the tests and the docs all have to be redone. This is a judgement,
not a rule: `/feature-design` considers it for each sub-task that changes both,
and asks the user when it is unclear. A docs-first sub-task's docs review box
comes before the boxes for the code written after it; the docs-first work may
also be a sub-task of its own, ahead of the one that writes the code.
`/feature-design` may add that box even where the strategy has no
per-sub-task docs review; the user agrees it with the rest of the criteria.

Auditability also means a criterion can be carried out without guessing. Where
a sign-off needs a substantial or non-obvious set of steps, write them down —
inline beneath the criterion when they are short, or in a separate file in
`features/plans/<slug>/`, linked from the criterion, when they are complex or
multi-step. Whether a sign-off needs written steps, and which form, is a
judgement made at `/feature-design`, which asks the user when it is unclear and
states the choices it made.

For each category it is legitimate to decide *not* to do it — but that decision
is made explicitly and up front, where the user can comment on it:

- **Strategy (at `/feature-spec`).** The plan file's `## Sign-off strategy` section records the quality bar per category for the whole feature (e.g. "100% test coverage" vs "basic tests" vs "none"; "full production docs" vs "internal notes only"), including the bar for any end-of-feature gates (e.g. "one `/review-branch` before end", "one `/review-docs` over the change, all kinds", "final user review"). The user agrees it.
- **Criteria (at `/feature-design`).** Each sub-task in `## Sub-tasks` carries the applicable sign-off categories as checkboxes, derived from the strategy. Where the strategy defines end-of-feature gates, `/feature-design` also materialises them as an explicit final sub-task named **"Final sign-off criteria"**, one checkbox per gate — added only when such gates actually exist, never as an empty placeholder. The user agrees them. Criteria may go beyond the strategy in one case: the docs review box of a docs-first sub-task (see **Docs-first sub-tasks** above).
- **Completion (at implement time).** A sub-task may be marked complete (✓) only when every one of its sign-off boxes is ticked.

Checkbox convention:

- `- [ ]` is pending; `- [x]` is satisfied.
- A sub-task is complete only when all its boxes are `[x]`; an unchecked box means it is not done.
- Only the categories that apply to a sub-task are listed. When a category does not apply, omit it — never write a placeholder such as `- [ ] User review: none`, which can never be ticked and so blocks the sub-task from ever completing. A category skipped for the whole feature is justified once in `## Sign-off strategy`. But a sign-off that gates completion of the feature must not live only in that strategy prose: where the strategy defines end-of-feature gates, they are materialised as the "Final sign-off criteria" sub-task described above, one checkbox per gate, rather than recorded once and left unchecked against anything.
- Every box in every sub-task, including "Final sign-off criteria", must be `[x]` before `/feature-end` starts. `/feature-end` performs no sign-off itself.

`/feature-checkpoint` may be run at any time, including mid-sub-task: it records
which boxes are ticked and which remain so the hand-off is accurate, and never
marks a sub-task complete while a box is still outstanding.

### Changing the sub-task list

The sub-task list may change after `/feature-design`. A change is handled in one
of two ways:

- **A new sub-task**, only for work that is both unforeseen and significant
  enough to be a sub-task in its own right. It is numbered with the next free
  letter suffix on the sub-task that prompted it (`7a`, then `7b`) rather than
  by renumbering later sub-tasks, and placed after that sub-task and any
  lettered sub-tasks already following it. It has its own heading and its own
  sign-off criteria, derived from the strategy and ordered as set out under
  `### Sign-off criteria`. Those criteria are put to the user for agreement,
  since the new scope's quality bar has not been agreed.
- **A fix in passing**, for anything smaller. It is not a sub-task: it is part
  of the sub-task it arose in, and is recorded as a note under it.

Which applies is a judgement on a sliding scale, set by the size and reach of
the change rather than by what it is called. Whoever makes the choice states it
when it is made, so the user can overturn it.

### Readability

This section is the **canonical statement of what a readable spec or design
looks like**. The `devproc` skills and review agents apply the standard
written here rather than carrying their own copies — when the standard
changes, it changes here.

The standard is two outcomes:

- A **spec** must be followable by a reader with no background on the feature
  — someone who knows the project, but has read neither the source issue nor
  the `/feature-spec` conversation that produced the spec.
- A **design** must be followable by a reader who knows only the requirements
  and spec — someone who did not sit through the design conversation.

Both outcomes assume a reader who is competent and familiar with the project.
The artefact does not explain the project to them; it explains the feature.

Six structural tests exist to make those outcomes checkable, not to replace
them:

- **Point first.** The artefact states what it is for before it states how.
  A reader who stops after the opening section can say what the feature is
  for and why it exists. For a `## Design` specifically, this means an
  explicit overview of how the design works as a whole, placed before any
  detailed section — a reader must be able to see the shape of what is
  proposed before meeting the decisions that make it up.
- **Nothing assumed.** Any term, file, component or convention a reader
  outside the authoring conversation would not know is defined or linked at
  first use.
- **Unambiguous.** Two competent readers come away with the same
  understanding. A sentence open to more than one reading is rewritten rather
  than left for context to settle, and a term that carries weight is defined
  rather than assumed to be obvious.
- **Detail subordinated.** Supporting material sits under headings that mark
  it as supporting, so the reader can see the shape of the argument before
  deciding how deep to go.
- **Rationale without detour.** Where a decision had a plausible alternative,
  the artefact records what was chosen and why the alternative lost — placed
  so it does not interrupt the main line. Either a brief "we do A, not B,
  because…" at the point of decision, or a separate rejected-options section
  the main flow can point at. A reader must be able to recover the reasoning
  behind a decision without having to wade through it to follow the argument.
- **Proportionate.** The central point is not outweighed by minor detail —
  the test that catches a "grab bag" of true statements assembled without
  structure.

Where a test and an outcome disagree, the outcome wins. The tests exist to
make a failure concrete enough to point at and fix; they are not the bar
itself, and passing all six while still failing the outcome is still a
failure — so nobody games the checklist in place of writing something a
human can read.

### Resuming after a session restart

When starting a new session on a feature that is already in progress:

1. Read `features/CURRENT.md` to find the current in-progress feature and its plan file.
2. Open the plan file (`features/plans/<slug>.md`) and read the `## Handoff` section first — it contains the session summary, current sub-task state, and the specific first action to take.
3. Do not begin implementation until you have read the Handoff section.

### Documents to support the model

These apply at all times, not just when completing features:

- **`features/`** — the feature list, split across four files so the (large) completed list need not be read into context every session. Each entry is a level-3 (`###`) heading with name and slug, one paragraph max — no sub-task lists, no implementation detail, no tables; link to the plan file for detail.

    - `CURRENT.md` — feature(s) in progress (normally exactly one)
    - `PENDING.md` — features waiting for development
    - `DEFERRED.md` — features explicitly deferred, including those blocked by a dependency (not expected to happen, but may be resurrected)
    - `COMPLETED.md` — completed features; headings end with the completion date in YYYY-MM-DD format

- **`features/plans/<slug>.md`**

    Plan for a feature. Should have sections for:

    - Handoff (session state — last updated date, summary, current sub-task, first action next session, open questions, dead ends)

    - Requirements (the input, captured faithfully — the full relevant content from the source issue, if the feature came from one — enough to resume without re-reading the issue. Not required to meet the `### Readability` standard: reorganising the user's own words to read better is how their meaning gets lost.)

    - Spec (what the feature must do, written to stand alone against `### Readability` — clarifying ambiguities in the Requirements input and filling gaps with explicitly-marked proposals; agreed at `/feature-spec`). Its layout:

        - **Numbered requirements.** A numbered requirement is a numbered statement of something the feature must do or make true. Where a spec numbers its requirements, each is a `N. Name` heading one level below its containing heading (`###` directly under `## Spec`, `####` under a grouping sub-heading), with its text beneath. A short spec may instead state its must-do content as an unnumbered paragraph or list. Purpose, background and out-of-scope content are not numbered requirements, and nor are lists inside a requirement's text; where such content follows the numbered requirements, it goes under its own unnumbered `###` heading (e.g. `### Out of scope`), after the last requirement — at the level of the requirements when they sit directly under `## Spec`, or of the grouping headings when they are grouped — so it is not read as part of the last requirement.
        - **Stable numbers.** Once the spec is agreed, requirement numbers never change. An added requirement takes the next free number; a reworded one keeps its number (its short name may change); a removed one keeps its heading, with its text replaced by a note saying it was removed and why. A spec agreed in the older list format is amended in that format, by the same rules, with list items in place of headings.

    - Sign-off strategy (the quality bar per sign-off category — see `### Sign-off criteria` — agreed at `/feature-spec`)

    - Design (implementation strategy)

    - Sub-tasks: each sub-task is a `### N. Name` heading one level below `## Sub-tasks`, with a short description, then its sign-off checkboxes. `✓ (date)` is appended to the heading on completion. The `▶ NEXT:` line and any notes that apply to the whole list sit at the top of the section.

    - Review record (a log, appended by `/feature-spec`, `/feature-design`, and `/feature-end`, of what review happened at each lifecycle stage — the reviewing agent's verdict, or `N/A` when the review was skipped, for `/feature-spec` and `/feature-design`; the closure date and that all sign-off boxes were ticked, for `/feature-end` — and of any amendment `/feature-design` makes to `## Spec`, recording the user's approval and why it changed. Always the last section of the file; a line is written every time a stage runs or a spec amendment is made, so an absent line means neither has happened. Preserve it across edits.)

    Optionally, a sibling `features/plans/<slug>/` directory holds un-inlinable requirements artefacts (screenshots, Word docs, other binaries) that `/feature-spec` copied in and linked from `## Requirements`, and sign-off plans (e.g. test plans) that `/feature-design` wrote and linked from the criteria they serve.

- **`features/tmp/`** — scratch space for staging requirements material as input to `/feature-spec`, git-ignored in a tracked workspace; a hand-off channel, not a store — its contents (other than the tracked `README.md`) are captured into the plan and then removed.

- **`NOTES.md`** — non-obvious findings only. Do not record things derivable from reading the code.

- **`CLAUDE.md`** — high-level status only. No plan detail, no implementation
  notes. Its `## Current status` section is capped: it holds **only** the
  in-progress feature (if any) plus **at most one line** for the single most
  recent completion. Older completion entries live in `features/COMPLETED.md`
  only and are deleted from `CLAUDE.md` — `/feature-end` performs this trim
  when it closes a feature. `/internal-docs-prune` is the periodic-cleanup
  tool for any drift beyond that (here or elsewhere in the internal docs).
