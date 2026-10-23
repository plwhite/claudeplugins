# Make sure requirements are in a section — Feature Plan

## Handoff

**Last updated:** 2026-10-23
**Session summary:** Feature complete and closed by `/feature-end`. All six sub-tasks are done, and every sign-off box is ticked, including the user review. The `## Review record` was accidentally truncated by a script edit during sub-task 6 and restored verbatim from the session before close.
**Sub-task in progress:** None
**First action next session:** None — feature closed. A possible follow-up is the pre-existing `unclear-design` fixture quirk noted in `NOTES.md`.
**Open questions / decisions pending:** None
**Dead ends to avoid:** None

## Requirements

From issue #75, "Make sure requirements are in a section" (verbatim):

> Sub-tasks each get their own markdown section heading, which makes them far easier to navigate with an editor (or to refer to).
>
> Currently, requirements get a line starting with "R1" or similar. These should be formatted as markdown headings at the appropriate level too, to simplify navigation, exactly analogously to sub-tasks.

The issue has no comments.

## Spec

### What this feature is for

Every feature in the `devproc` model has a plan file, `features/plans/<slug>.md`. Its `## Spec` section, written by `/feature-spec`, states what the feature must do. Most specs state that as a list of numbered requirements, though a short spec may state it as a paragraph or an unnumbered list instead. In this repository's plans, for example, they appear as numbered bold list items under a heading such as `### What must be true when it is done` (`1. **Resuming is an explicit choice…**`); the issue describes the same thing as "a line starting with R1 or similar".

A list item does not appear in an editor's document outline, so a long spec is one undifferentiated block to scroll through, and finding "requirement 5" means reading down the list. The sub-tasks in `## Sub-tasks` had the same problem until issue #67 (feature `subtask-handling`) made each sub-task its own `### N. Name` heading.

This feature does the same for requirements: wherever a spec numbers its requirements, each one becomes its own Markdown heading, so it appears in the outline and can be referred to by number. A spec short enough to state what it must do without numbering is easy to read as it is and is not referred to by number from elsewhere in the plan, so it is left as it is. The feature changes the format `/feature-spec` writes, and every place that describes that format. It does not change what a spec must contain.

Terms used below:

- A **numbered requirement** is one numbered statement in `## Spec` of something the feature must do or make true. Below, "requirement" means a numbered requirement. The other parts of a spec — its opening purpose statement, background on how things stand today, the out-of-scope list — are not requirements and are not numbered. Nor is must-do content in a short spec written as a paragraph or an unnumbered list.
- The **requirement heading** is the Markdown heading that carries one requirement's number and short name.

### What must be true when it is done

#### 1. Each numbered requirement is its own heading

In a spec written by `/feature-spec` that numbers its requirements, each requirement is a Markdown heading, so it appears in an editor's document outline. The heading carries the requirement's number and a short name. The requirement's text, including any sub-points and any `Proposed:` markers, sits beneath the heading as body text.

- *Proposed:* the heading reads `<N>. <Short name>`, numbered from 1 in the order the requirements appear — the same form as a sub-task heading (`### N. Name`). The number is kept so a requirement can still be referred to as "requirement 3".
- *Proposed:* the heading is one level below the heading that contains it. Where requirements sit directly under `## Spec`, they are `###` headings. Where the spec groups them under a sub-heading (as this spec does, under `### What must be true when it is done`), they are `####` headings. This is the "appropriate level" the issue asks for.
- *Settled by the user at `/feature-spec`:* the rule applies only where a spec numbers its requirements. A short spec that states what the feature must do as a paragraph or an unnumbered list has no requirement headings, and does not have to be rewritten into numbered requirements. Whether a spec numbers its requirements stays the writer's choice, as it is today.
- *Settled by the user during sub-task 6:* `/feature-spec` numbers the requirements unless they are only a few lines; only then is a paragraph or unnumbered list used.
- The non-requirement parts of a spec (purpose, background, out of scope) are not affected. They keep whatever form `/feature-spec` gives them today, and items in an out-of-scope list stay list items.

#### 2. Requirement numbers stay stable once agreed

Requirements are referred to by number elsewhere — in `## Design`, in sub-task descriptions, in `## Handoff`, and in `NOTES.md`. So once the spec has been agreed at `/feature-spec`, existing requirements are not renumbered.

- *Proposed:* when `/feature-design` amends `## Spec` (an existing route, which needs the user's approval), a new requirement takes the next free number at the end of the list, as its own requirement heading at the same level as the others; a reworded requirement keeps its number, and its short name may be updated; and a removed requirement keeps its heading with its text replaced by a note saying it was removed and why. This mirrors the sub-task rule in `features/FEATUREMODEL.md` under `### Changing the sub-task list`, which adds lettered sub-tasks rather than renumbering.

#### 3. Every place that shows or describes the spec format adopts it

The rule is written where `/feature-spec` and the plan-file description can apply it, and every example or description of a spec's layout matches it. Known places are:

- the `feature-spec` skill, which writes `## Spec`;
- the description of the plan file's `## Spec` section in `features/FEATUREMODEL.md` (the canonical copy is `devproc/skills/feature-init/FEATUREMODEL.md`; this repository's installed copy is refreshed by re-running `/feature-init`, as `CLAUDE.md`'s maintainer note requires);
- the `feature-design` skill, where it amends `## Spec` (requirement 2);
- the user docs: `devproc/README.md` and `docs/workflow.md`, where they describe what `## Spec` contains.

This list is illustrative. The search defined in `## Sign-off strategy` → Documentation defines the full set.

#### 4. The reviewers handle the new format

- *Proposed:* `feature-spec-reviewer` flags a spec whose numbered requirements are not each their own heading, as a `[rewrite]` finding. *Proposed:* the finding is MAJOR, so a spec in the old format cannot get `READY FOR USER REVIEW` until `/feature-spec` converts it. It does not flag a short spec whose must-do content is an unnumbered paragraph or list (requirement 1). It reviews a spec immediately after `/feature-spec` writes it, so there is no older-format spec it needs to accept.
- *Proposed:* `feature-design-reviewer` traces coverage from each requirement heading, and does **not** flag a `## Spec` written in the older list format, because a feature already in design or implementation keeps its existing spec (see Out of scope). This matches how it already accepts the older `## Sub-tasks` list format.
- *Proposed:* the `## Spec` sections of the reviewer test fixtures in `tests/devproc/feature-spec-reviewer/` and `tests/devproc/feature-design-reviewer/` are converted to the new format where they number their requirements, so the fixtures represent what `/feature-spec` now writes. Fixtures whose must-do content is unnumbered, such as `tests/devproc/feature-spec-reviewer/control.md`, are left as they are and must still not be flagged. `tests/devproc/feature-design-reviewer/old-format-control.md` keeps the older list format for its spec too, so the reviewer's acceptance of the old format stays tested. One new `feature-spec-reviewer` fixture covers a spec whose numbered requirements are list items rather than headings, which the reviewer must flag. Where conversion changes a case's expected findings, its `.expected.md` is updated to match, and the change is noted in the sub-task's notes.

### Out of scope

- Converting existing plan files. Completed plans are historical records, and a feature already in progress keeps the spec it was agreed with.
- Changing the content a spec must have, the `### Readability` standard, or `## Requirements`. `## Requirements` is the input captured faithfully and is never restructured, so a source issue's own numbering is left as it is.
- Applying headings to anything else in the plan file (sign-off strategy entries, design decisions).

## Sign-off strategy

The change is prose-only, to skill, agent, feature-model and documentation Markdown, plus reviewer test fixtures. There is no executable code. The main risks are inconsistency (one skill, agent, doc or fixture still showing the old list format) and a reviewer either missing the new check or wrongly flagging old-format specs it should accept.

- **Testing.** Skills, agents and `FEATUREMODEL.md` are loaded from the installed plugin copy at `/home/claude/claudeplugins/devproc/`, not from this repository (see `NOTES.md`). So before the regression run, the dry run, and any re-run of `/feature-init`, that copy is refreshed from the repository and confirmed byte-identical with `diff -r`. Testing then has two parts:
    - **Reviewer regression.** Both suites (`feature-spec-reviewer` and `feature-design-reviewer`) are run through `tests/devproc/harness/run.sh`, and every case, including the new fixture from requirement 4, passes its suite README's pass rule.
    - **Dry run.** `/feature-spec` is run on a small throwaway feature in a scratch workspace outside `/workspace`, which is deleted afterwards. It is run on a feature with at least five distinct must-do requirements. The check: the resulting `## Spec` numbers its requirements, every numbered requirement is its own heading at the level requirement 1 sets, and the non-requirement parts are unaffected. A spec that does not number them fails the dry run. The result is recorded in the sub-task's notes in this plan file.
- **Documentation.** Full. Every user doc and agent doc that shows or describes the layout of `## Spec` is updated, including the `FEATUREMODEL.md` pair, `devproc/README.md`, `docs/workflow.md`, and `CLAUDE.md` if any of its bullets is affected. A search across `devproc/`, `docs/`, `tests/`, and the root `CLAUDE.md`, `NOTES.md`, `README.md` and `CONTRIBUTING.md` for `## Spec` and for "requirement" is done, and every hit that describes the spec's layout is fixed or justified in the sub-task's notes.
- **Code review (agent).** One `/review-branch` over the whole change before `/feature-end`. The change is prose, so a per-sub-task agent review would cost more than it catches.
- **Docs review (agent).** One `/review-docs` over the change, all kinds (accuracy, architectural, style, agent docs), before `/feature-end`. Accuracy and style because user doc prose changes; architectural because the spec format is described in several documents that must agree; agent docs because `CLAUDE.md` describes the `feature-spec` skill and its reviewer.
- **User review.** Before `/feature-end`, the user reads the changed `feature-spec` skill text, the changed `FEATUREMODEL.md` plan-file description, and the `## Spec` produced by the dry run, and confirms the format is what they wanted.

## Design

### Overview

The rule has one canonical home and four places that apply it.

- **The rule lives in the feature model.** The plan-file description of `## Spec` in the canonical `devproc/skills/feature-init/FEATUREMODEL.md` gains the format (spec requirement 1) and the stable-numbering rule (spec requirement 2), in the same way it already states the `### N. Name` format for sub-tasks. This repository's installed copy, `features/FEATUREMODEL.md`, is refreshed from it by `/feature-init`.
- **The skills apply it.** `/feature-spec` writes numbered requirements as headings and decides when a spec is long enough to number them. `/feature-design`'s spec-amendment step (step 9) follows the stable-numbering rule. Both point at `FEATUREMODEL.md` rather than restating the rule.
- **The reviewers enforce it.** `feature-spec-reviewer` flags numbered requirements that are not headings (MAJOR, `[rewrite]`). `feature-design-reviewer` traces coverage per requirement and accepts the older list format. Both are pinned by test fixtures.
- **The user docs describe it.** `devproc/README.md` and `docs/workflow.md` say what a spec looks like, where they already describe `## Spec`.

The work is done in that order — model, skills, reviewers, user docs — so each step points at text that already exists. A dry run of `/feature-spec` then checks the whole chain, and the end-of-feature gates follow.

### Where the rule is stated

We put the format in `FEATUREMODEL.md`, not only in the `feature-spec` skill, because several components need it: `/feature-spec` writes it, `/feature-design` amends specs, and both reviewers judge it. `FEATUREMODEL.md` is where the model's shared rules already live, and the sub-task heading format set the precedent. The `feature-spec` skill carries only what is specific to writing a spec: the judgement of when to number requirements (the `Proposed:` bullet under spec requirement 1, agreed by the user), with a pointer to the model for the format itself.

The stable-numbering rule is also stated once, in `FEATUREMODEL.md`. `/feature-design` step 9a points at it, because that step is the only route by which an agreed spec changes.

### Reviewer checks

- **`feature-spec-reviewer`.** A new check: numbered requirements in `## Spec` that are not each their own heading at the level `FEATUREMODEL.md` sets are a MAJOR `[rewrite]` finding (spec requirement 4). It sits with the reviewer's other checks on how `## Spec` is written, and points at `FEATUREMODEL.md` for the format. It states plainly that unnumbered must-do content in a short spec is not a finding, since the user settled that.
- **`feature-design-reviewer`.** Its "Requirement coverage" check traces each numbered requirement (by heading, or by list item in an older spec), and it gains an instruction not to flag a `## Spec` in the older list format, next to the existing one for `## Sub-tasks`.

### Fixtures

Research showed that **no existing fixture numbers its requirements**: every fixture's `## Spec` is prose plus an unnumbered bullet list (the reports-page CSV export). So spec requirement 4's "convert fixtures where they number their requirements" converts nothing, and the existing cases are untouched. To make the new behaviour tested rather than vacuously true:

- **New `feature-spec-reviewer` case `unheaded-requirements`** — the control spec rewritten as numbered bold list items. Expected: one MAJOR `[rewrite]` finding, verdict `NEEDS WORK`. This is the fixture spec requirement 4 asks for.
- **New `feature-spec-reviewer` case `headed-requirements-control`** — the same spec with each numbered requirement as a `####` heading under a grouping `###` heading. Expected: no findings, verdict `READY FOR USER REVIEW`. This goes beyond the one fixture the spec names. Without it, nothing checks that the reviewer accepts the new format, and over-flagging is the likelier failure.
- **`feature-design-reviewer` case `old-format-control`** — its `## Spec` is rewritten as numbered list items. Spec requirement 4 says this case keeps the older list format so that acceptance of the old format stays tested. But its spec is not numbered today, so that acceptance is not actually tested. Its expected output stays "no findings". This makes `old-format-control` an exception to the suites' shared-baseline rule (both suite READMEs say `## Requirements`, `## Spec` and `## Sign-off strategy` are identical baseline text in every case). The design-suite README records the exception, and a later fix to the baseline is applied to this case in numbered-list form.
- **New `feature-design-reviewer` case `headed-requirements-control`** — the design suite's `control` case with its spec as `####` requirement headings, the same rewrite as the spec-suite control. Expected: no findings. This exercises spec requirement 4's "traces coverage from each requirement heading" against a spec in the format `/feature-spec` now writes. It too is a recorded exception to the shared baseline.
- The existing `control` case in each suite still has an unnumbered spec, so it now also confirms that a short unnumbered spec is not flagged.

Each new or changed case gets its `.expected.md`, and each suite's `README.md` case table is updated.

### Rejected alternatives

- *State the format only in the `feature-spec` skill.* Rejected: the reviewers and `/feature-design` would then each need their own copy, which is the drift `FEATUREMODEL.md` exists to prevent.
- *Lettered numbering for added requirements (`3a`), as for sub-tasks.* Rejected: the spec settles on the next free number at the end. A requirement's position carries no meaning, whereas sub-task order is execution order.
- *Making sub-tasks docs-first.* Not done. The user settled the format at `/feature-spec`, and the "code" here is itself skill and agent prose. Writing the user docs first would gain no earlier review point, so user docs come after the reviewers (sub-task 4).

## Sub-tasks

**▶ NEXT:** None — all sub-tasks complete

> Run `/feature-checkpoint` after each sub-task completes.

Sub-tasks 1–5 carry no per-sub-task code review, docs review or user review. Per `## Sign-off strategy`, those are single end-of-feature gates in sub-task 6. Refreshing the installed plugin, wherever a box calls for it, means copying `devproc/` from this repository over `/home/claude/claudeplugins/devproc/` and confirming that `diff -r devproc /home/claude/claudeplugins/devproc` prints nothing (see `NOTES.md`).

### 1. Feature-model rule ✓ (2026-10-23)

Add the requirement-heading format and the stable-numbering rule to the `## Spec` entry in the plan-file description of the canonical `FEATUREMODEL.md`, then install it here.

- [x] Documentation: the `Spec` bullet under "Documents to support the model" in `devproc/skills/feature-init/FEATUREMODEL.md` states that, where a spec numbers its requirements, each is a `N. Name` heading one level below its containing heading; that a short spec may state its must-do content unnumbered; and that agreed requirement numbers are never changed (an added requirement takes the next free number, a reworded one keeps its number (its short name may change), a removed one keeps its heading with a removal note)
- [x] Testing: installed plugin refreshed; `/feature-init` re-run in `/workspace`; `diff features/FEATUREMODEL.md devproc/skills/feature-init/FEATUREMODEL.md` prints nothing

Note: `/feature-init` is user-invocable only, so the user ran it themselves; the diff then printed nothing. The whole-tree `diff -r` later differs only because sub-task 2 edited the `feature-spec` and `feature-design` skills after sub-task 1's refresh; the installed `FEATUREMODEL.md` is identical.

### 2. Skills ✓ (2026-10-23)

Make `/feature-spec` write numbered requirements as headings, and make `/feature-design`'s spec amendments follow the stable-numbering rule.

- [x] Documentation: `devproc/skills/feature-spec/SKILL.md` step 6's `## Spec` guidance tells the skill to number the requirements when the spec is long enough to need the outline, or when other parts of the plan are likely to refer to them, and otherwise allows an unnumbered paragraph or list; where it numbers them, it writes them in the format `FEATUREMODEL.md` defines, which it points to rather than restates
- [x] Documentation: `devproc/skills/feature-design/SKILL.md` step 9a points at the stable-numbering rule in `FEATUREMODEL.md` for amendments that add, reword or remove a numbered requirement

### 3. Reviewers and fixtures ✓ (2026-10-23)

Add the new check to `feature-spec-reviewer`, update `feature-design-reviewer`'s coverage check, and pin both with fixtures (see Design → Fixtures).

- [x] Documentation: `feature-spec-reviewer.md` flags numbered requirements that are not each their own heading as MAJOR `[rewrite]`, points at `FEATUREMODEL.md` for the format, and says unnumbered must-do content in a short spec is not a finding
- [x] Documentation: `feature-design-reviewer.md`'s "Requirement coverage" check traces each numbered requirement (heading or older list item), and it says not to flag a `## Spec` in the older list format
- [x] Documentation: fixtures `feature-spec-reviewer/unheaded-requirements`, `feature-spec-reviewer/headed-requirements-control` and `feature-design-reviewer/headed-requirements-control` added with `.expected.md` files; `feature-design-reviewer/old-format-control.md`'s spec rewritten as numbered list items, its `.expected.md` updated only if its expected findings change
- [x] Documentation: both suite `README.md` case tables updated; the shared-baseline text in both suite READMEs (the spec suite's "Maintaining the shared baseline", the design suite's "What the untargeted sections are" and its old-format paragraph) records which cases carry an altered `## Spec` and in what form
- [x] Testing: installed plugin refreshed; `tests/devproc/harness/run.sh` run over both suites; every case passes its suite README's pass rule (results noted under this sub-task)

Notes:

- Harness run over both suites (22 cases) against the refreshed installed plugin. All verdicts match except `feature-design-reviewer/control` and, in the last full run, `old-format-control`: both drew the known MAJOR `[decision]` about the fictional product's unconfirmable query-builder / column-definition modules (see `NOTES.md`), which their `.expected.md` files do not tolerate. Re-run singly, `old-format-control` passed. `control` is flaky (about 3 of 5 passes with the new wording, 7 of 8 with the old); the team lead then extended the design suite README's recorded tolerance for that finding to `control`, `old-format-control` and `headed-requirements-control` (their `.expected.md` files now carry a "Tolerated finding" section). Final design-suite re-run: all 12 cases pass, the only MAJORs in the three controls being that tolerated one. The spec suite (10 cases) passed in the earlier full run and nothing in it changed afterwards except a requirement rename, after which its two new cases were re-run singly and passed.
- The three new cases and the rewritten `old-format-control` pass singly: `unheaded-requirements` NEEDS WORK with one MAJOR `[rewrite]` on the format; both `headed-requirements-control` cases and `old-format-control` READY FOR USER REVIEW with no finding about the format.
- Fix in passing: the requirement name "Dates and numbers are unformatted" drew a MINOR from the reviewer, so the fixtures use "Dates are ISO 8601 and numbers are plain".

### 4. User docs and the layout search ✓ (2026-10-23)

Describe the format in the user docs, and sweep for anything else that describes the layout of `## Spec`.

- [x] Documentation: `devproc/README.md` (the `/feature-spec` section) and `docs/workflow.md` ("Requirements and Spec are different jobs") say that numbered requirements are headings and that their numbers stay stable once agreed
- [x] Documentation: search of `devproc/`, `docs/`, `tests/`, and the root `CLAUDE.md`, `NOTES.md`, `README.md` and `CONTRIBUTING.md` for `## Spec` and for "requirement" done; every hit that describes the spec's layout fixed or justified in a note under this sub-task

Notes:

- Changes: `devproc/README.md` gained a paragraph in the `/feature-spec` section (short spec may be unnumbered; numbered requirements are `N. Name` headings; numbers stable once agreed; points at `features/FEATUREMODEL.md`), a sentence in the `/feature-design` amendment paragraph (numbers never change in an amendment), and the two reviewer descriptions now mention the heading check and acceptance of unnumbered and older-format specs. `docs/workflow.md` "Requirements and Spec are different jobs" gained the same layout and stability sentence.
- Search (`## Spec` and "requirement", over `devproc/`, `docs/`, `tests/`, root `CLAUDE.md`, `NOTES.md`, `README.md`, `CONTRIBUTING.md`) justification. Fixed: `devproc/README.md` and `docs/workflow.md` as above; the sub-task 1-3 hits (`FEATUREMODEL.md` pair, both skills, both reviewer agents, fixtures and suite READMEs) already describe the new layout. Justified, no change: `CLAUDE.md` reviewer bullets (describe what the reviewers check at summary level; do not describe spec layout); `devproc/skills/feature-init/SKILL.md`, `docs/capabilities.md`:32 and `dev-process-manager.md`, `code-review-simplicity.md`, `internal-docs-reviewer.md` (use "requirements" in the general sense, or refer to `## Spec` only as a section to amend, not its layout); `docs/capabilities.md` has no description of the two spec/design reviewers; `docs/workflow.md` lines on `## Requirements` input, the review-record example and `[rewrite]` examples (input capture or generic wording, not spec layout); `NOTES.md` hits (historical findings about `## Requirements`/`## Spec` roles, plus this feature's own flake note, none describe the layout; the "`## Spec` point 3" at line 810 refers to a past dry run, a historical record); `tests/` fixture hits outside the files changed in sub-task 3 (unnumbered specs, deliberately left per spec requirement 4); `tests/devproc/harness/out/` is git-ignored output.

### 5. Dry run ✓ (2026-10-23)

Check end to end that `/feature-spec` now writes headed requirements. The steps are short, so they are inline. Slash commands act on the session's working directory, so the dry run uses separate `claude -p` sessions started in the scratch directory, never the current session.

The throwaway description, which has nine distinct must-do behaviours so that numbering is clearly called for: *"Add a `--dry-run` flag to a backup CLI. With it the CLI must: list every file it would copy; list every file it would delete at the destination; print the total bytes it would transfer; skip all writes; skip all deletes; still validate the config file and fail on errors; still check the destination is reachable; exit 0 if it would succeed and 2 if it would fail; and print a final line saying no changes were made."*

- [x] Testing: installed plugin refreshed; `mkdir` a scratch directory under the scratchpad (outside `/workspace`), `cd` there, `git init`, `claude -p '/devproc:feature-init'`, then `claude -p '/devproc:feature-spec --no-review <the description above>'` from the same directory; the resulting `## Spec` numbers its requirements, each is its own `N. Name` heading one level below its containing heading, and the purpose, background and out-of-scope parts are unaffected; the spec is copied to `features/plans/spec-requirement-headings/dry-run-spec.md` for the user review in sub-task 6, the result is noted under this sub-task, and the scratch workspace is deleted

**Result (2026-10-23):** passed. The produced `## Spec` had `### Purpose`, then ten requirements as `### 1.`..`### 10.` headings (the nine described behaviours plus the flag itself, which the skill split out as requirement 1) (each `N. Name`, one level below `## Spec`), then `### Out of scope`; the purpose and out-of-scope parts are unnumbered and unaffected. `/feature-spec` completed in print mode (it wrote the plan and listed its questions in the reply). Spec copied (whole plan file) to `features/plans/spec-requirement-headings/dry-run-spec.md`; scratch workspace deleted.

### 6. Final sign-off criteria ✓ (2026-10-23)

End-of-feature gates for this feature, per `## Sign-off strategy`.

- [x] Code review (agent): `/review-branch` over all changed files; findings resolved or dismissed
- [x] Docs review (agent): `/review-docs` over the change, all kinds (accuracy, architectural, style, agent docs); findings resolved or dismissed
- [x] Testing: if either review changed a reviewer agent or fixture, installed plugin refreshed and `tests/devproc/harness/run.sh` re-run over both suites with every case passing; otherwise "no reviewer agent or fixture changed" noted under this sub-task
- [x] User review: user reads the changed `feature-spec` skill text, the changed `FEATUREMODEL.md` plan-file description, and `features/plans/spec-requirement-headings/dry-run-spec.md`, and confirms the format is what they wanted

Notes:

- `/review-branch` (2026-10-23): 17 files in `devproc/` and `tests/` (working tree against `HEAD`, as the change is uncommitted on `main`); the simplicity, general and nitty agents only. The agreed strategy names a plain `/review-branch`, so the optional architectural review was not run. It converged in four passes, with all findings code-level. Applied:
    - `FEATUREMODEL.md`: the `Spec` entry was split into "Numbered requirements" and "Stable numbers" sub-bullets. They define a numbered requirement, put trailing non-requirement content under an unnumbered `###` heading, replace a removed requirement's text with a note, and amend an older-format spec in its own format.
    - `feature-design-reviewer`: removed requirements, and unnumbered or grouping headings, are not traced.
    - `feature-spec-reviewer`: points at the model's definition.
    - References to the rule now use one phrasing ("the `Spec` entry under `### Documents to support the model`").
    - README de-duplication and the `NEEDS WORK` allowance stated in the design-suite README.
    - Fixtures: list items rewrapped, the lead-in dropped from the headed fixtures, `### Out of scope` added, and the tolerance copies replaced by a pointer.
- Dismissed: dropping older-format `## Spec` support (spec requirement 4 requires it), and fixing the fictional baseline instead of tolerating it (the design-suite README rejects that).
- Deferred to the user: a firmer "when to number" threshold in `feature-spec` (the user agreed the wording at `/feature-spec`).
- `features/FEATUREMODEL.md` is stale against the canonical copy after these fixes. The user must re-run `/feature-init` before the Testing re-run below.
- `/review-docs` over the change, all kinds (2026-10-23). In scope: user docs `devproc/README.md`, `docs/workflow.md`, `tests/README.md` and both suite READMEs; agent docs `CLAUDE.md` and `NOTES.md`. It converged in two passes. Minor fixes applied:
    - `tests/README.md` suite rows match the current controls.
    - `docs/workflow.md` has the spec-format text as its own paragraph, with an example.
    - The `devproc/README.md` reviewer sentences are split, and "longer spec" is defined.
    - The shared-baseline exceptions are moved to where the baseline is defined.
    - The design-suite control rule mentions the tolerated finding.
    - The format pointer names the canonical `FEATUREMODEL.md`.
- Four significant findings are escalated to the user. The Docs review box stays open until they are decided:
    1. Make `docs/workflow.md` the single owner of the user-facing spec-format explanation, with `devproc/README.md` linking to it (architectural).
    2. State the full numbering rules in the user docs rather than pointing at `features/FEATUREMODEL.md` — a boundary finding (architectural).
    3. Trim the `NOTES.md` control-flake entry to the finding, dropping the pass rates and phrasing history (agent docs).
    4. Trim the `NOTES.md` dry-run entry to the invocation, dropping the nine-to-ten sentence (agent docs).
- The user approved all four escalated findings, and they are applied. The user also tightened `feature-spec`'s "when to number" wording to "number unless the requirements are only a few lines", applied to the skill and the user docs, and recorded as a spec amendment.
- Testing re-run (2026-10-23), after the user re-ran `/feature-init` (`features/FEATUREMODEL.md` identical to canonical) and the installed plugin was refreshed (`diff -r` empty). `tests/devproc/harness/run.sh` ran over both suites, 22 cases, and every case passes its suite README's pass rule.
    - Design `headed-requirements-control` returned `NEEDS WORK`, with only the tolerated query-builder finding.
    - `unheaded-requirements` raised the expected MAJOR `[rewrite]` on the format.
    - `unclear-design` also drew MAJORs against the baseline `## Sub-tasks` (endpoint built before the formatter it streams through; no criterion for the filename or column set). Its `.expected.md` does not forbid this, but it sits uneasily with the suite README's rule that a case aimed at `## Design` leaves `## Sub-tasks` clean. Re-run three times on the new reviewer, it appeared in 2 of 4 runs. Run three times on the pre-change reviewer (`git show HEAD:`, installed temporarily, then restored), it appeared in 3 of 3. So it pre-dates this feature. Recorded in `NOTES.md`; not fixed here.
- User review (2026-10-23): the user read the changed `FEATUREMODEL.md` `Spec` entry, the `feature-spec` skill text and the dry-run spec, and signed off. They confirmed that the grouped layout (`### Requirements` with `####` requirement headings beneath other context sections) is valid under the rule, and that the `docs/workflow.md` example shows only one of the two layouts.

## Review record

- 2026-10-23 — Spec reviewed by `feature-spec-reviewer`: VERDICT: NEEDS WORK. Presented to the user for sign-off, with 1 open question (whether every spec must state its requirements as numbered requirements); the user answered: only specs that number their requirements need headings.
- 2026-10-23 — Spec re-reviewed by `feature-spec-reviewer` after the user's answer: VERDICT: READY FOR USER REVIEW. Presented to the user for sign-off.
- 2026-10-23 — Design reviewed by `feature-design-reviewer` (two passes; first NEEDS WORK, fixed): VERDICT: READY FOR USER REVIEW. Accepted unattended; no human has read this design.
- 2026-10-23 — Spec amended during implementation, with the user's approval: requirement 1's "when to number" proposal is tightened from "when long enough to need the outline or likely to be referred to" to "unless the requirements are only a few lines", at the user's request after the code review raised the vagueness.
- 2026-10-23 — Feature closed by /feature-end; all sign-off boxes ticked.
