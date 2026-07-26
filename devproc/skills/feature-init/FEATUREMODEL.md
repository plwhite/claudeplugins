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

    - Requirements (the full relevant content from the source issue, if the feature came from one — enough to resume without re-reading the issue)

    - Sign-off strategy (the quality bar per sign-off category — see `### Sign-off criteria` — agreed at `/feature-spec`)

    - Design (implementation strategy)

    - Subtask list with short descriptions, per-sub-task sign-off checkboxes, and status markers (`✓`, `▶ NEXT:`)

    - Review record (a log, appended by `/feature-spec`, `/feature-design`, and `/feature-end`, of what review happened at each lifecycle stage — the reviewing agent's verdict, or `N/A` when the review was skipped. Always the last section of the file; a line is written every time, so an absent line means the stage has not run. Preserve it across edits.)

    Optionally, a sibling `features/plans/<slug>/` directory holds un-inlinable requirements artefacts (screenshots, Word docs, other binaries) that `/feature-spec` copied in and linked from `## Requirements`.

- **`features/tmp/`** — git-ignored scratch space for staging requirements material as input to `/feature-spec`; a hand-off channel, not a store — its contents (other than the tracked `README.md`) are captured into the plan and then removed.

- **`NOTES.md`** — non-obvious findings only. Do not record things derivable from reading the code.

- **`CLAUDE.md`** — high-level status only. No plan detail, no implementation
  notes. Its `## Current status` section is capped: it holds **only** the
  in-progress feature (if any) plus **at most one line** for the single most
  recent completion. Older completion entries live in `features/COMPLETED.md`
  only and are deleted from `CLAUDE.md` — `/feature-end` performs this trim
  when it closes a feature. `/internal-docs-prune` is the periodic-cleanup
  tool for any drift beyond that (here or elsewhere in the internal docs).
