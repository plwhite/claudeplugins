# Improve feature subtask flow — Feature Plan

## Handoff

**Last updated:** 2026-06-25
**Session summary:** Sub-task 5 complete and signed off — the completion rule is enforced in `feature-checkpoint` (records partial box state, never marks ✓ while a box is unticked, never ticks on the user's behalf) and `feature-end` (won't close while any box is unticked). All five sub-tasks now complete.
**Sub-task in progress:** None — all sub-tasks ✓.
**First action next session:** Run `/feature-end` (with the `@docs-structure-reviewer` pass). Feature-level code review is not required — the strategy used per-sub-task light reviews.
**Open questions / decisions pending:** None.
**Dead ends to avoid:** None

## Requirements

From issue #25 (verbatim):

> General objective is to stop Claude cutting corners - skipping testing / docs / signoff.
>
> Each subtask in a feature should have explicit signoff criteria. These should include:
> - testing (manual or automated)
> - documentation (as necessary, but any new tooling or change should be reflected in docs - docs as we go unless there is a good reason not to, though it is fine to have a "now do a full docs run through" thing at the end)
> - User feedback / review / confirmation
> - Code review
>
> In each of these cases, it is reasonable to not have them, but that is an explicit up-front choice that the user can comment on at feature-design time. When moving from one subtask to another, the process must involve checking all of the "sign off" boxes that exist for that subtask, as well as running feature-checkpoint.
>
> My implementation straw man is that these should be added at the feature-design stage, where the design and plan are created, and added to the subtask list as checkboxes. Part of the spec (i.e. feature-spec) should be the test / docs / code review strategy (it might be required to have 100% test coverage, or acceptable to only have basic coverage or no formal tests; docs may be just internal notes or full production quality). The flow is then "spec => user agrees strategy for what sign-off criteria should look like", then "design => user agrees actual sign off criteria for each subtask", then "implement => completion of a subtask only when all done".
>
> The section in CLAUDE.md about features then needs some updating to reflect.

## Sign-off strategy

The quality bar agreed for this feature. Each sub-task's sign-off criteria (see
Sub-tasks) are derived from this. *(This section is itself the new artefact the
feature introduces — recorded here both to drive the work and to demonstrate the
target format.)*

- **Testing:** None — every change is to prompt/markdown documents (`SKILL.md`,
  `CLAUDE.md`, docs); there is nothing to test automatically. Correctness is
  covered by the per-sub-task code review and user review below.
- **Documentation:** Docs-first. The feature-model and user-facing docs are
  written up front (sub-tasks 1–2) to define the intended behaviour; the skill
  edits (sub-tasks 3–5) implement it; any doc found inaccurate during
  implementation is corrected in the same sub-task. Nothing is deferred to a
  final docs pass beyond the `@docs-structure-reviewer` review that `/feature-end`
  always runs.
- **Code review:** Per sub-task, for the skill edits (sub-tasks 3–5) — a
  code-review agent reviews that sub-task's diff against a short brief and gives
  feedback. This is a light review, not a full `/review-branch`.
- **User review:** Per sub-task. The user reviews and approves the wording of
  each skill/doc change before it is considered complete. (This is itself an
  instance of the "user review" sign-off the feature introduces.)

## Design

### Overview

The whole feature is changes to the `devproc` lifecycle skills and the
documentation that describes them. No code. The mechanism has four moving parts:

1. **Strategy at spec time** — `feature-spec` records a feature-wide *sign-off
   strategy* (the quality bar for testing, docs, code review, user review) and
   the user agrees it.
2. **Criteria at design time** — `feature-design` turns that strategy into
   concrete, per-sub-task sign-off checkboxes, and the user agrees them.
3. **Completion rule at implement time** — a sub-task may be marked complete (✓)
   only when all of its sign-off boxes are ticked. This is a rule about *marking
   a sub-task done*, not about `feature-checkpoint`: checkpoint can be run at any
   time, including mid-sub-task, to record accurate state and enable handover —
   when it runs with boxes still unticked it simply records partial progress
   rather than marking the sub-task complete.
4. **Documentation** — the feature model (in the `feature-init` template, the
   project `CLAUDE.md`, the README and the `docs/`) describes all of the above.

### Plan-file format changes

**New `## Sign-off strategy` section.** Added to the plan-file template, placed
after `## Requirements` and before `## Design`. `feature-spec` seeds it with a
proposed strategy across the four categories; the user agrees or adjusts it.
Format: one bullet per category (Testing / Documentation / Code review / User
review), each stating the quality bar or "None — <reason>" if deliberately
skipped. A blanket omission is recorded here so the up-front choice is visible.

**Sub-task sign-off checkboxes.** `feature-design` extends each sub-task in the
`## Sub-tasks` section with indented markdown checkboxes, one per *applicable*
category, derived from the strategy:

```markdown
1. **Update feature-spec** — add the sign-off strategy step
   - [ ] Testing: re-read the edited skill end-to-end for consistency
   - [ ] User review: user approves the wording
```

**Checkbox convention** (defined once, in the feature-model docs):

- `- [ ]` — pending.
- `- [x]` — satisfied.
- A sub-task may be marked complete (✓) **only when every one of its sign-off
  boxes is `[x]`.** An unchecked box means the sub-task is not done.
- Only categories that *apply* to a sub-task are listed. A category omitted for
  the whole feature is justified once in `## Sign-off strategy`; a category
  dropped for one specific sub-task that the strategy generally requires is
  noted inline on that sub-task so the deviation stays explicit.
- Feature-level sign-offs (e.g. a single end-of-feature docs review, or a full
  `/review-branch` if that is the chosen code-review approach) are recorded in
  `## Sign-off strategy` rather than duplicated onto every sub-task.

The **code-review** category can be satisfied at either granularity, chosen in
the strategy: *per sub-task* (a code-review agent reviews that sub-task's diff
against a short brief — light, fast feedback as you go) or *feature-level* (a
single full `/review-branch` over the whole diff before `/feature-end`). This
feature uses the per-sub-task form.

**Refinement (decided during Sub-task 3).** Two clarifications were added to the
model: (1) the four categories are the *usual set, not a closed list* — a
strategy may split one (e.g. separate unit-test and manual-test sign-offs) or
add a specific sign-off of another kind (e.g. "agent X has confirmed the
output"); (2) every criterion must be *auditable* — worded so there is a clear
yes/no at the point a sub-task finishes ("have some tests" is not auditable;
"unit tests to the agreed quality bar" is). Both are recorded canonically in the
`### Sign-off criteria` section of the feature-init template / `CLAUDE.md`, and
echoed in `feature-spec` step 6 and `docs/workflow.md`.

### Interaction changes

Both `feature-spec` and `feature-design` gain an explicit user-agreement step
(the issue's "user agrees strategy" / "user agrees actual sign off criteria").
The skills propose a sensible default and invite the user to adjust — they do
not silently choose. `feature-spec` already ends by confirming the spec;
`feature-design` already ends by presenting the design for confirmation, so the
agreement folds into those existing confirmation points.

### Enforcement changes

The completion rule lives at the point a sub-task is *marked done*, not inside
`feature-checkpoint` as a gate. `feature-checkpoint` step 2 (which records
sub-task status) gains the rule: never mark a sub-task ✓ while any of its
sign-off boxes is unchecked — instead record the ticked boxes and the
outstanding ones as partial progress, so a mid-sub-task checkpoint produces an
accurate handover. A sub-task becomes complete only once the last box is ticked.
`feature-end` step 2 (verify all sub-tasks complete) likewise checks that no
sign-off boxes remain unticked before the feature can close.

### Documents to update

- `devproc/skills/feature-spec/SKILL.md` — plan-file template + strategy step.
- `devproc/skills/feature-design/SKILL.md` — sub-task template + checkbox
  convention + agreement step.
- `devproc/skills/feature-checkpoint/SKILL.md` — completion/transition rule.
- `devproc/skills/feature-end/SKILL.md` — verify boxes at completion.
- `devproc/skills/feature-init/SKILL.md` — the `## Feature model` template
  written to `CLAUDE.md` (lifecycle bullets + plan-file structure).
- `CLAUDE.md` (this project's own copy of the feature model) — kept in step with
  the template above.
- `devproc/README.md`, `docs/workflow.md`, `docs/capabilities.md` — user-facing
  flow descriptions.
- `devproc/agents/dev-process-manager.md` — the manager accepts a sub-task only
  when its sign-off boxes are ticked.

## Sub-tasks

Ordered docs-first: the model is documented up front (1–2), then the skills are
edited to implement it (3–5), correcting any doc that proves inaccurate.

1. ✓ **Feature-model docs (feature-init template + project CLAUDE.md)** — write the
   sign-off model into the `## Feature model` template that `feature-init` writes
   to `CLAUDE.md`: the sign-off strategy
   section, per-sub-task checkboxes, the checkbox convention, and the completion
   rule, in both the lifecycle bullets and the plan-file structure. *(completed 2026-06-24)*
   - [x] User review: user approves the wording
   - [x] Test: ran feature-init's step 1 against the project `CLAUDE.md`; its Feature model section now matches the updated template (verified by diff, identical bar line-wrapping)

2. ✓ **User-facing docs (README, workflow.md, capabilities.md, dev-process-manager)**
   — describe the sign-off flow in the flow narratives, and the manager's rule of
   accepting a sub-task only once its sign-off boxes are ticked. *(completed 2026-06-24)*
   - [x] User review: user approves the wording

3. ✓ **feature-spec: capture sign-off strategy** — add the `## Sign-off strategy`
   section to the plan-file template and a step where the skill proposes a
   strategy (testing/docs/code review/user review) and the user agrees it. Fix
   the sub-task 1–2 docs if implementation shows them inaccurate. *(completed 2026-06-24; also added the sign-off-model refinement — categories are an open set, criteria must be auditable — to feature-spec, the feature-init template, CLAUDE.md, and workflow.md)*
   - [x] Code review: `code-review-general` reviewed the diff (short brief) twice — first the base change (addressed its minor point: a note that `## Handoff` is added later by `/feature-design`), then again after the flexibility/auditability refinement, confirming all four docs consistent and no critical/major issues
   - [x] User review: user approves the wording

4. ✓ **feature-design: per-sub-task sign-off checkboxes** — update the `## Sub-tasks`
   template to include sign-off checkboxes, reference the checkbox convention, and
   add the user-agreement step for the per-sub-task criteria. Fix docs if needed. *(completed 2026-06-24)*
   - [x] Code review: `code-review-general` reviewed the diff (short brief); no issues, confirmed consistency with `CLAUDE.md` and the feature-spec skill (preserved section, open category set, auditability, checkbox convention, step numbering)
   - [x] User review: user approves the wording

5. ✓ **feature-checkpoint + feature-end: completion rule** — checkpoint records
   partial sign-off state mid-sub-task and never marks a sub-task ✓ while a box
   is unticked; end verifies none remain. Fix docs if needed. *(completed 2026-06-25)*
   - [x] Code review: `code-review-general` reviewed the diff (short brief); confirmed both skills consistent with each other and the model; addressed its one minor point (replaced the undefined `▶ TODO:` marker in the example with a plain "Remaining:" note)
   - [x] User review: user approves the wording

**Feature-level sign-off** (from the strategy): the `@docs-structure-reviewer`
pass that `/feature-end` already triggers. Code review is per sub-task (above),
so there is no separate full `/review-branch` at the end.

**▶ NEXT:** All sub-tasks complete — ready for `/feature-end`.

> Run `/feature-checkpoint` after each sub-task completes.
