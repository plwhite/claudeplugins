<!-- This is the feature-model text, imported into CLAUDE.md's `## Feature model` section (which is why it has no top-level heading of its own). It is an installed copy: `/feature-init` refreshes it from the canonical FEATUREMODEL.md shipped with the devproc plugin on every run, so edit that shipped copy, not this one — local edits here are overwritten. -->

Major pieces of work are organised into features. Each feature has a concise entry in one of the feature-list files under `features/` and a detailed plan file in `features/plans/`.

Use these slash commands (defined in the `devproc` plugin) to manage features
through their lifecycle — **spec → design → implement → end**:

- `/feature-spec` — create a new feature in `features/PENDING.md`, write its specification into the plan file, and agree the feature's **sign-off strategy**
- `/feature-design` — move a feature to `features/CURRENT.md`, write its design and sub-task plan, and agree the **sign-off criteria** for each sub-task
- *(implementation has no slash command — work through the sub-tasks directly; a sub-task is complete only when all its sign-off boxes are ticked)*
- `/feature-checkpoint` — during implementation, sync all feature documentation and plans to the current state (run after each sub-task and when prompted within subtasks)
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
- **Docs review** — review of the updated documentation, by an agent (e.g. `docs-structure-reviewer`) or by the user. This is a review activity like code review — checking what was done, not writing it — and it has its own category because it is the sign-off most routinely missed.
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
agent, e.g. `/review-branch`, `docs-structure-reviewer`) or the user. A bare
"code review" box is ambiguous. In checkbox labels, write the performer in
parentheses — e.g. `- [ ] Code review (agent): /review-component the parser`,
`- [ ] Docs review (agent): docs-structure-reviewer over the updated docs`, or
`- [ ] Code review (user): user reads the parser diff`. (A **User review**
box needs no parenthetical — the user is the performer by definition.)

For each category it is legitimate to decide *not* to do it — but that decision
is made explicitly and up front, where the user can comment on it:

- **Strategy (at `/feature-spec`).** The plan file's `## Sign-off strategy` section records the quality bar per category for the whole feature (e.g. "100% test coverage" vs "basic tests" vs "none"; "full production docs" vs "internal notes only"), including the bar for any end-of-feature gates (e.g. "one `/review-branch` before end", "one `docs-structure-reviewer` review", "final user review"). The user agrees it.
- **Criteria (at `/feature-design`).** Each sub-task in `## Sub-tasks` carries the applicable sign-off categories as checkboxes, derived from the strategy. Where the strategy defines end-of-feature gates, `/feature-design` also materialises them as an explicit final sub-task named **"Final sign-off criteria"**, one checkbox per gate — added only when such gates actually exist, never as an empty placeholder. The user agrees them.
- **Completion (at implement time).** A sub-task may be marked complete (✓) only when every one of its sign-off boxes is ticked.

Checkbox convention:

- `- [ ]` is pending; `- [x]` is satisfied.
- A sub-task is complete only when all its boxes are `[x]`; an unchecked box means it is not done.
- Only the categories that apply to a sub-task are listed. When a category does not apply, omit it — never write a placeholder such as `- [ ] User review: none`, which can never be ticked and so blocks the sub-task from ever completing. A category skipped for the whole feature is justified once in `## Sign-off strategy`. But a sign-off that gates completion of the feature must not live only in that strategy prose: where the strategy defines end-of-feature gates, they are materialised as the "Final sign-off criteria" sub-task described above, one checkbox per gate, rather than recorded once and left unchecked against anything.
- A box that is **performed by `/feature-end` itself** (e.g. the close-out docs review, since `/feature-end` runs it as part of closing the feature) carries the annotation "(performed at `/feature-end`)". This is the one box in the final sub-task legitimately left unticked before `/feature-end` runs — `/feature-checkpoint` and a resuming session must treat that as expected, not as an incomplete feature. Every other box, in the final sub-task and in all other sub-tasks, must be ticked before `/feature-end` starts.

`/feature-checkpoint` may be run at any time, including mid-sub-task: it records
which boxes are ticked and which remain so the hand-off is accurate, and never
marks a sub-task complete while a box is still outstanding — except the one
`/feature-end`-performed box noted above, whose unticked state before `/feature-end`
runs is the model's expected state, not a sign of incompleteness.

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

    - Spec (what the feature must do, written to stand alone against `### Readability` — clarifying ambiguities in the Requirements input and filling gaps with explicitly-marked proposals; agreed at `/feature-spec`)

    - Sign-off strategy (the quality bar per sign-off category — see `### Sign-off criteria` — agreed at `/feature-spec`)

    - Design (implementation strategy)

    - Subtask list with short descriptions, per-sub-task sign-off checkboxes, and status markers (`✓`, `▶ NEXT:`)

    - Review record (a log, appended by `/feature-spec`, `/feature-design`, and `/feature-end`, of what review happened at each lifecycle stage — the reviewing agent's verdict, or `N/A` when the review was skipped — and of any amendment `/feature-design` makes to `## Spec`, recording the user's approval and why it changed. Always the last section of the file; a line is written every time a stage runs or a spec amendment is made, so an absent line means neither has happened. Preserve it across edits.)

    Optionally, a sibling `features/plans/<slug>/` directory holds un-inlinable requirements artefacts (screenshots, Word docs, other binaries) that `/feature-spec` copied in and linked from `## Requirements`.

- **`features/tmp/`** — scratch space for staging requirements material as input to `/feature-spec`, git-ignored in a tracked workspace; a hand-off channel, not a store — its contents (other than the tracked `README.md`) are captured into the plan and then removed.

- **`NOTES.md`** — non-obvious findings only. Do not record things derivable from reading the code.

- **`CLAUDE.md`** — high-level status only. No plan detail, no implementation
  notes. Its `## Current status` section is capped: it holds **only** the
  in-progress feature (if any) plus **at most one line** for the single most
  recent completion. Older completion entries live in `features/COMPLETED.md`
  only and are deleted from `CLAUDE.md` — `/feature-end` performs this trim
  when it closes a feature. `/internal-docs-prune` is the periodic-cleanup
  tool for any drift beyond that (here or elsewhere in the internal docs).
