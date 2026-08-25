# Remove old migration code — Feature Plan

## Handoff

**Last updated:** 2026-08-28
**Session summary:** Sub-task 4 taken to the edge of completion. The user read the final `feature-init/SKILL.md` and signed it off (LGTM), ticking the user-review box. `/review-branch` was then run over the six changed files — simplicity, general and nitty, with the architectural pass skipped by the user's decision as the change is prose-only and touches no module boundary, interface or data contract. Three findings were applied. (1) An unrelated pre-existing `NOTES.md` paragraph — the macOS MITM-proxy / `enableWeakerNetworkIsolation` note — had been silently clobbered by commit `5c47868` while the new `gh issue view` entry was appended; found independently by the team lead and by `simplicity-rb`, and restored byte-identical to `main`'s line 55 in its original position, so `NOTES.md` is now purely additive against `main`. (2) `SKILL.md`'s opening "safe to re-run" sentence had been over-generalised when its old "on an already-migrated project" scoping clause was removed, leaving it claiming nothing is ever overwritten while step 1b overwrites `features/FEATUREMODEL.md` every run; reworded to mirror `devproc/README.md`'s already-correct phrasing. (3) `devproc/README.md:58`'s merged step-1c clause branched only two ways where the skill branches three, reading as though the skill rewrites the `## Feature model` section on every run; reworded to cover the already-correct case. A targeted convergence pass over both rewrites returned clean. Sub-task 1's grep test, the step numbering (a continuous 1–4), and the live-document `migrat` sweep were all re-verified after the edits and still hold.

**Sub-task in progress:** Sub-task 4 — two of its three boxes are ticked (code review, user review). The third, the `docs-structure-reviewer` docs review, is annotated "(performed at `/feature-end`)" and is the one box the model expects to be unticked at this point; it is not a sign of incompleteness. Sub-tasks 1, 2 and 3 are complete (✓).

**First action next session:** Run `/feature-end`. Everything it gates on is in place: all boxes across all sub-tasks are ticked except the `docs-structure-reviewer` box it performs itself. If that review raises findings, fix them and re-run it before closing. `/feature-end` should also trim `CLAUDE.md`'s `## Current status` to a single completed-feature line — and that line must not describe the Sub-task 3 validation as an unqualified five-run pass, since run (c) failed the criterion's literal wording and was accepted as out of scope.

**Open questions / decisions pending:** None. The run (c) finding was settled by the user on 2026-08-26 — accepted as out of scope, with Sub-task 3 complete; the reasoning is recorded under Sub-task 3 and in `NOTES.md`. One non-blocking observation from the review is deliberately not actioned: commit `5c47868` carries the message "blah", which would make a future `git blame` for exactly the kind of regression found above harder. Rewriting history is the user's call, and nothing in this feature depends on it.

**Autonomy boundary (agreed 2026-08-26):** the manager drives Sub-tasks 1–3 unattended — a teammate per sub-task, reviewed and checkpointed — then stops and reports before Sub-task 4's review gates.

**Dead ends to avoid:** Do not add a detection-and-warn path for the old layout — considered and explicitly ruled out (see `## Spec`). Do not run validation (Sub-task 3) inside this repository: `/feature-init` takes no target directory, so a run under `features/tmp` would write ignore rules into this repo's own `.gitignore` — use throwaway directories under `/tmp`. Per `NOTES.md` § "`/home/claude/claudeplugins` is a live plugin copy, separate from this repo", skill-prose edits must land in the git-tracked `/workspace/devproc/` (done in Sub-task 1) — Sub-task 3's CLI validation runs will need the installed plugin copy refreshed from this tree first, or they will silently validate the unmodified skill.

## Requirements

From issue #64, "Remove old migration code" (verbatim):

> The old migration code says to nuke the contents of `notes`, move old stuff etc.
>
> That migration is no longer required and can be harmful if there is an existing notes directory. We should retire it completely.
>
> /feature-init must continue to get everything into the right state on a clean repo, but it should no longer:
> - Check for the old FEATURES.md and other files in the root of the workspace
> - Check for the notes directory at the root of the workspace
>
> No workspace in this old format still exists, and if it does, the user is responsible for migrating it. *We must not add a lot of verbiage telling the user this; the point is to remove old unused code in skills, not to add loads of instructions to tell the user to do a thing that is not supported.*

The issue has no comments.

## Spec

### What this feature is for

`/feature-init` is the `devproc` skill that prepares a workspace for the feature
model: it installs `features/FEATUREMODEL.md`, wires the import into
`CLAUDE.md`, and scaffolds the `features/` directory. It also still carries
instructions for **migrating a workspace from a layout that no longer exists**
— the pre-`features/` arrangement in which the feature list lived in a
workspace-root `FEATURES.md` and plan files in a workspace-root `plans/` or
`notes/` directory.

That migration is dead weight, and worse than dead weight: a workspace that
happens to have an unrelated root `notes/` directory will have it moved and
emptied by a skill the user ran only to set up feature tracking. This feature
removes the migration entirely, leaving `/feature-init` a pure setup skill.

The deletion is the deliverable. No detection, no warning, and no migration
instructions replace what is removed — a workspace in the old layout is the
user's own problem, and the feature must not trade removed logic for added
prose.

### What must change

**1. `/feature-init` no longer inspects the workspace root for legacy files.**
The skill must not look for, read, move, rewrite, or delete a workspace-root
`FEATURES.md`, `plans/` directory, or `notes/` directory. In the skill as it
stands this is the whole of its `## 2. Migrate an older layout if present`
section, plus the framing sentences elsewhere in the document that advertise
migration as something the skill does. The remaining steps are renumbered so
the document reads as a continuous sequence.

The consequence for a workspace still in the old layout is accepted, not
mitigated: the skill treats it exactly as it treats a clean one, creating the
fresh `features/` layout beside whatever root `FEATURES.md`, `plans/` or
`notes/` is already there and leaving those untouched and unmentioned. The old
feature list simply stops being visible to the model. That is the outcome issue
#64 asks for, not a defect to be worked around.

**2. Nothing is added in its place.** Specifically: no check that reports "an
old layout was detected", no warning, and no paragraph explaining how the user
should migrate. Where a sentence currently promises migration, it is deleted
rather than reworded into a disclaimer. This plan file and the eventual
`features/COMPLETED.md` entry are the whole record of the removal; the shipped
skill says nothing.

**3. Behaviour on a workspace that is not in the old layout is unchanged.**
Every workspace `/feature-init` is expected to meet today — a clean workspace
with no feature tracking at all, and a workspace already on the current
`features/` layout — must end in exactly the state it ends in now:

- `features/FEATUREMODEL.md` installed, and **refreshed** (overwritten) from the
  canonical copy shipped beside the skill on every run;
- `CLAUDE.md` carrying the live un-backticked `@features/FEATUREMODEL.md`
  import, in a `## Feature model` section created if absent and **corrected
  whatever it previously held** (see "Normalising `CLAUDE.md`" below);
- the four list files `features/{CURRENT,PENDING,DEFERRED,COMPLETED}.md`
  created from their templates **only where absent**, never overwritten;
- `features/plans/` present;
- `features/tmp/` present with its `README.md`, and — in a tracked workspace
  only — the two `.gitignore` lines that ignore its contents but keep the
  README;
- the skill safe to re-run, preserving all existing feature data.

**4. Documentation stops advertising migration.** Every live document that
describes `/feature-init` as migrating an older layout is updated to describe
only what the skill then does. The known places are `devproc/README.md` (the
skill table row, the "run this first" paragraph, and the per-skill description)
and the workspace `CLAUDE.md` bullet for `feature-init/SKILL.md`; the feature
must sweep for any others rather than trusting that list. As with the skill
itself, the sentences are shortened, not replaced with an explanation of what
was withdrawn.

**5. History is not rewritten.** `features/COMPLETED.md` and
`features/plans/split-features-md.md` record what was true when they were
written. They are historical records, not live documentation, and are left
alone.

**6. Agent memory is out of scope.** The files under `.claude/agent-memory/`
are agent-maintained internal material, and some of it — such as
`devproc-docs-structure-reviewer/project_structure.md` — still describes
`/feature-init` as a setup-and-migration skill. That is not history, and it
will be read live during this feature's own docs review, but correcting it
belongs to `/internal-docs-prune`, not here. Leave it for the next hygiene
pass.

### Normalising `CLAUDE.md` is kept — it is not migration

*Settled by the user at `/feature-spec`.* `/feature-init` step 1c handles a
`CLAUDE.md` whose `## Feature model` section holds something other than the live
import — the full model text embedded inline, or an inert backticked or
Markdown-link mention of the path — and replaces whichever it finds with the
import line. **This stays.**

The distinction that decides it is the difference between *correcting state* and
*migrating a layout*. After a run, `CLAUDE.md`'s `## Feature model` section must
be correct and up to date, whatever state it was in beforehand; that obligation
is part of what `/feature-init` is for and is unaffected by this feature. What
#64 removes is something else: hunting around the workspace root for files
belonging to models that are no longer supported. Step 1c does no hunting — it
looks only at the one file the skill owns, moves nothing, and deletes nothing.

Two consequences follow for the work:

- Step 1c's behaviour is unchanged, including the branch that replaces embedded
  model text.
- The `devproc/README.md` sentence at line 58 covers the workspace-root
  migration and the `CLAUDE.md` normalisation in one breath. The migration half
  is removed; the normalisation half is **kept, and reworded** so it no longer
  reads as a legacy-project special case but as what the skill always does —
  bringing the `## Feature model` section to the current import whatever it
  contained.

### Out of scope

- Any change to what `/feature-init` produces on a clean workspace (point 3
  above states this as a constraint, not an opportunity to improve the output).
- Any change to the other lifecycle skills, the feature model text, or
  `features/FEATUREMODEL.md`.
- Any change to `/feature-init` step 1c's behaviour, per "Normalising
  `CLAUDE.md`" above — only the wording of the documentation describing it
  changes.
- Providing a migration path by any other route — a separate skill, a script,
  or documentation. The issue is explicit that unsupported is the answer.

## Sign-off strategy

The change is prose-only, confined to skill and documentation Markdown, with no
executable code involved. The risk is not subtle breakage but omission: leaving
a dangling reference to removed steps, breaking the step numbering, or
accidentally weakening the clean-workspace behaviour the skill must retain.
The bar below is set accordingly — light on testing machinery, firm on review
and on exercising the revised skill end to end across the workspace shapes it
must handle.

- **Testing** — Manual, no automated tests. The repository has no automated test
  for `/feature-init` (`tests/` covers reviewer agents only) and this feature
  does not add one; adding a harness for a prose skill is a larger piece of work
  than the change itself. Instead the revised skill's steps are executed by hand
  against throwaway workspaces created **outside this repository** (e.g. under
  `/tmp`), since `/feature-init` takes no target directory and acts on the
  workspace it is run in — running it under `features/tmp` would put the ignore
  rules in this repo's own `.gitignore`. Four runs:

    - **(a) empty directory** — must produce the end state in Spec point 3;
    - **(b) re-run over the result of (a)** — must produce the same end state,
      with existing list files and plans preserved;
    - **(c) a directory holding a root `FEATURES.md` and a root `notes/`** —
      must produce the same end state as (a), leaving `FEATURES.md` and
      `notes/` byte-identical;
    - **(d) an untracked variant of (a)** (a directory that is not a git
      repository) — must write no `.gitignore`.

  No run may mention migration in its output. The result of each run is recorded
  in `NOTES.md` so the box is auditable against something written down.

- **Documentation** — Full. `devproc/README.md` and the workspace `CLAUDE.md`
  are updated so no live document claims `/feature-init` migrates anything. The
  sweep in Spec point 4 is carried out as a case-insensitive search for
  `migrat` across the workspace, excluding `features/plans/`,
  `features/COMPLETED.md`, `.claude/` and `tests/`, with every remaining hit
  either fixed or justified in the sub-task. No new user-facing documentation is
  written, per Spec point 2.

- **Code review (agent)** — One `/review-branch` over the whole change before
  `/feature-end`. Per-sub-task agent review is not warranted for a change this
  size; a single branch-wide pass is.

- **Docs review (agent)** — One `docs-structure-reviewer` pass over the updated
  documentation before `/feature-end`, checking that the removals left no
  dangling reference and that the `/feature-init` description still reads as a
  complete account of the skill.

- **User review** — The user reads the final `/feature-init` `SKILL.md` in full
  before `/feature-end`. This is the artefact the feature exists to change, it
  is short enough to read whole, and "nothing was added in its place" is a
  judgement only the user can make.

## Design

### Overview

The work is a deletion and a wording pass in
`devproc/skills/feature-init/SKILL.md`, four passages reworded across
`devproc/README.md` and the workspace `CLAUDE.md`, and a validation run. There
is no new mechanism to design — the design question is
only *what exactly comes out*, *what must demonstrably still work*, and *how we
prove it*, since the artefact being changed is a prose skill that no test
harness executes.

`devproc/skills/feature-init/SKILL.md` today has five numbered steps. Step 2,
"Migrate an older layout if present", is the whole of the legacy handling and is
deleted; steps 3–5 shift up to become 2–4. Four further passages in the same
file are trimmed or reworded, listed as a closed set below. Nothing is added:
the skill ends up shorter and silent about the old layout, which is the point
of #64.

The deletion has a knock-on inside the file — the surviving steps cross-refer to
each other by number, and one of them mentions migration in passing — so the
sub-task that does the deletion also owns the consistency sweep of the file. A
second sub-task updates the four places outside the skill that describe it. A
third runs the revised skill by hand against five throwaway workspaces — the
four shapes agreed in `## Sign-off strategy`, plus one covering the step 1c
rewording — because that is the only evidence available that the surviving steps
still produce a correct workspace.

The three implementation sub-tasks are strictly ordered: the docs pass must describe the skill
as it finally reads, and the validation runs must exercise the final text.

### What comes out of `SKILL.md`

One section deletion, four prose edits, and a renumbering. The four prose edits
are a **closed list** — Sub-task 1 points at this list rather than repeating a
count:

**The deletion.** The whole of `## 2. Migrate an older layout if present`
(currently lines 67–98) — the top-level `plans/`/`notes/` move, the
`FEATURES.md` split table, and the "nothing to migrate, continue to step 3"
tail. This is the code #64 names.

**The four prose edits.**

1. The opening paragraph's migration sentence (currently lines 8–10) — "This
   skill also **migrates** projects that still use the older single-file layout
   (`FEATURES.md` plus a top-level `plans/` or `notes/` directory)." — deleted.
2. The adjacent "safe to re-run" sentence — kept, but reworded so it no longer
   says "on an already-migrated project".
3. The parenthetical in what is currently step 3 — "(do not overwrite a file
   that migration or a previous run produced)" becomes "(do not overwrite a file
   a previous run produced)".
4. Step 1c's framing of the embedded-model case — see "What deliberately stays"
   below, which is where its rationale and its test live.

**The renumbering.** Steps 3, 4 and 5 become 2, 3 and 4, and any internal
cross-reference pointing at them is corrected. All three live step-number
cross-references in the file today (lines 70, 71 and 98) sit *inside* the
deleted section, so they go with it; the consistency check in Sub-task 1 exists
to catch anything the deletion leaves dangling rather than because a specific
breakage is known.

### What deliberately stays

**Step 1c, the `CLAUDE.md` normalisation.** Settled with the user at
`/feature-spec` and recorded in `## Spec` under "Normalising `CLAUDE.md` is kept
— it is not migration": the skill must leave `CLAUDE.md`'s `## Feature model`
section correct whatever state it was in, and that obligation is not what #64
retires. The branch logic is untouched.

Its *wording* is trimmed, though, and this is the one judgement call in the
sub-task. The step currently identifies the embedded-model case as "an older
initialised project, recognisable because it is more than the one-line import",
which frames a live normalisation rule as legacy-project handling. The
parenthetical is reworded to describe the *state* rather than the era — the
section holds the model text inline rather than the import — so the rule reads
as what it is. Rationale: leaving the legacy framing in place would leave the
file half-arguing that it still does migration, which invites a future reader to
delete the step as more dead code; rewriting the framing costs one sentence and
removes that trap. The alternative — touch nothing in step 1c at all — was
rejected for that reason, and because `## Spec` explicitly admits wording
changes to the documentation describing the step.

**This rewording is the one edit in the feature that could change behaviour, so
it is the one edit that gets its own test.** The parenthetical is not decoration
— it is the cue by which a model running the skill *recognises* an embedded
`## Feature model` body or an inert backticked mention. Reword it carelessly and
step 1c silently stops firing, leaving a real project with the model text
duplicated and no live import; nothing else in this feature's validation would
notice, since the other runs all start from a workspace with no `CLAUDE.md` or
with a correct one. Sub-task 3 therefore carries a fifth walkthrough covering
both branches. The alternative — leave the parenthetical exactly as it stands,
which `## Spec` permits since it requires no rewording — was rejected as the
worse trade: it keeps the trap described above to avoid a run that costs
minutes.

### What the old layout gets

Nothing, by design. A workspace with a root `FEATURES.md` and a root `notes/`
now gets the same treatment as an empty one: a fresh `features/` layout created
beside them, with both left byte-identical and unmentioned. Sub-task 3 tests
exactly this, because "does nothing" is a behaviour that can regress into
"warns" or "helpfully moves" without anyone noticing.

### Documents outside the skill

Four passages describe `/feature-init` as migrating, and a `migrat` sweep
confirms they are the only live ones that do. The sweep does return other hits,
and they are expected residue, not defects: everything under `features/plans/`,
`features/COMPLETED.md` and `.claude/` (out of scope per `## Spec` points 5 and
6), plus this feature's own `features/CURRENT.md` entry, the generic use of the
word in `devproc/agents/feature-design-reviewer.md:85`, and — after Sub-task 3 —
`NOTES.md`. None of those claims `/feature-init` migrates anything; all are left
alone.

| Location | Change |
|---|---|
| `devproc/README.md:11` (skill table) | Drop the trailing migration clause |
| `devproc/README.md:34` (setup paragraph) | Drop the migration sentence; keep the re-run sentence |
| `devproc/README.md:58` (skill reference) | Drop the migration half; **keep and reword** the `CLAUDE.md` half as normalisation, per `## Spec` |
| `CLAUDE.md:34` (skill bullet) | Drop the trailing migration clause |

The workspace root `README.md` (line 34, the `features/` directory row — a
different file from the `devproc/README.md:34` row in the table above, sharing a
line number by coincidence) and `docs/setup.md` / `docs/workflow.md` mention
`/feature-init` but never its migration behaviour, so they need no change —
noted here so the sub-task does not go looking for a problem that is not there.

### How this is validated

`/feature-init` takes no target directory: every path in it is relative to the
workspace it runs in, and its tracked/untracked branch turns on
`git rev-parse` in that directory. So each run happens in a throwaway directory
under `/tmp` — outside this repository, so the `.gitignore` step cannot write
here.

The runs are **real invocations, not hand re-enactments**. `feature-init` is
marked `disable-model-invocation: true`, which blocks the Skill tool but not the
CLI: `claude -p --permission-mode bypassPermissions "/feature-init"` with the
working directory set to the scratch workspace runs the skill end to end, and
`--verbose --output-format stream-json` yields the tool-call transcript needed
to confirm *which* steps ran rather than only the end state. Both facts are
already established in `NOTES.md` ("`feature-init` can be run from the CLI
despite `disable-model-invocation`" and "Verifying a skill's internal steps
needs the verbose transcript"). This matters more than usual here: the feature's
whole risk is that a surviving step silently stops firing, and an end-state
check alone cannot distinguish "step ran and had nothing to do" from "step never
ran". The transcript is also what evidences "no run mentions migration".

Each run's outcome goes in
`NOTES.md`, so each box is auditable against something written down rather than
a recollection.

The four runs agreed in `## Sign-off strategy`, plus a fifth:

- **(a) Empty directory** — must produce the end state in `## Spec` point 3.
- **(b) Re-run over (a)'s result** — proves existing data is preserved. Run (a)
  leaves list files identical to their templates, so a re-run that wrongly
  overwrote them would be indistinguishable from one that preserved them. The
  run therefore begins by seeding distinguishing content: a
  `### Test feature [test-feature]` entry appended to `features/PENDING.md` and
  a stub `features/plans/test-feature.md`. Both must survive byte-identical,
  while `features/FEATUREMODEL.md` must be byte-identical to the shipped
  canonical copy (it is the one file the skill overwrites every run).
- **(c) Old layout** — a directory holding a root `FEATURES.md` and a root
  `notes/`. Same end state as (a), with both left byte-identical.
- **(d) Untracked** — a non-repository directory. No `.gitignore` written.
- **(e) Pre-existing `CLAUDE.md`** — the test for the step 1c rewording, in two
  variants: a `## Feature model` section holding the full model text inline, and
  one holding only an inert backticked `` `features/FEATUREMODEL.md` ``
  mention. Both must end with the live un-backticked import, with any
  hand-added non-model prose in the section left intact. This run is one more
  than `## Sign-off strategy` agreed; it is added because the design touches
  step 1c's recognition cue, and the reasoning is in "What deliberately stays"
  above.

No run may mention migration in its output.

This is the same validation technique the `extract-feature-model` feature used
on this same skill (see that plan's Sub-task 3), so it is a known-workable
approach rather than an invention here. Building an automated harness for a
prose skill was rejected at `/feature-spec` as larger than the change itself.

One caution carried over from `NOTES.md` ("`/feature-init` copies from the
installed plugin, not the repo"): a CLI run executes the **installed** copy of
the skill at `/home/claude/claudeplugins`, not this repository's working tree.
The revised `SKILL.md` must be in place there before a run means anything, or
every run will validate the unmodified skill and pass for the wrong reason.

## Sub-tasks

1. ✓ (2026-08-26) **Strip migration from `feature-init/SKILL.md`** — delete step 2, renumber the survivors, and make the four prose edits listed in `## Design` § "What comes out of `SKILL.md`"; the file must read as a continuous setup-only sequence.
   - [x] Testing: `grep -in 'migrat\|FEATURES\.md\|notes/' devproc/skills/feature-init/SKILL.md` returns nothing, and every internal step cross-reference in the file resolves to an existing step number
2. ✓ (2026-08-26) **Update the documents that describe the skill** — the three `devproc/README.md` passages and the `CLAUDE.md` bullet, per the table in `## Design`.
   - [x] Documentation: the four passages match the revised skill, with `devproc/README.md:58`'s `CLAUDE.md` clause kept and reworded as normalisation rather than deleted
   - [x] Testing: a case-insensitive `migrat` sweep across the workspace, excluding `features/plans/`, `features/COMPLETED.md`, `.claude/` and `tests/`, leaves no hit that claims `/feature-init` migrates anything
3. ✓ (2026-08-26) **Validate the revised skill** — five real CLI runs against throwaway `/tmp` workspaces, per `## Design` § "How this is validated"; each run's outcome recorded in `NOTES.md`, and no run mentioning migration in its output.
   - [x] Testing (a) empty directory: produces the end state in `## Spec` point 3
   - [x] Testing (b) re-run over (a) with seeded content: the seeded `features/PENDING.md` entry and stub plan file survive byte-identical, and `features/FEATUREMODEL.md` is byte-identical to the shipped canonical copy
   - [x] Testing (c) old layout: produces the same end state as (a), leaving the root `FEATURES.md` and `notes/` byte-identical
   - [x] Testing (d) untracked directory: no `.gitignore` is written
   - [x] Testing (e) pre-existing `CLAUDE.md`: both variants (embedded model text, inert backticked mention) end with the live un-backticked import, with hand-added non-model prose in the section left intact
   - **Resolved by the user (2026-08-26): the run (c) "migration" mentions are accepted as out of scope, and the sub-task is complete.** The headline condition "no run mentioning migration in its output" failed on run (c) on its literal wording, reproducibly (the fixture was run twice independently, same result both times). What the condition was written to detect — the skill advertising or performing migration — is provably absent: the tool-call transcript shows no skill step reads, moves or reasons about the leftover files, and `FEATURES.md` and both `notes/` files came out byte-identical (re-checksummed by the team lead, with only `Read`/`cat` against them in the transcript). Every "migrate"/"migrating" hit is in the general assistant's own closing summary, after it did a routine `ls -la`, noticed the unfamiliar root files and volunteered "flagging, not touching — I can help migrate…" on its own initiative. That is general-assistant orientation behaviour that no skill prose reliably suppresses, and prose naming the old layout in order to suppress it would violate `## Spec` point 2 ("nothing is added in its place"). Recorded as a known limitation of the criterion's wording rather than a defect. Full evidence in `NOTES.md` § "Sub-task 3 validation runs for `remove-migration-code` (#64)".
4. **Final sign-off criteria** — end-of-feature gates for this feature, per `## Sign-off strategy`.
   - [x] Code review (agent): `/review-branch` over all changed files; findings resolved or dismissed
   - [x] Docs review (agent): `docs-structure-reviewer` over the updated documentation, confirming no dangling reference and that the `/feature-init` description still reads as a complete account of the skill (performed at `/feature-end`)
   - [x] User review: user reads the final `feature-init/SKILL.md` in full and confirms nothing was added in place of what was removed
   - Code review detail (2026-08-28): `/review-branch` over the six changed files, architectural pass skipped by the user's decision (prose-only change, no module boundary, interface or data contract touched). `general-rb` found nothing. `simplicity-rb` found the clobbered `NOTES.md` paragraph; `nitty-rb` found the over-generalised "safe to re-run" sentence and the two-way/three-way mismatch in `devproc/README.md:58`. All three applied, convergence pass clean. Detail in `## Handoff`.
   - Remaining: only the `docs-structure-reviewer` box above, which `/feature-end` performs.

Sub-tasks 1–3 carry no code-review, docs-review or user-review boxes: the agreed
`## Sign-off strategy` buys one feature-wide `/review-branch`, one
`docs-structure-reviewer` pass and one final user read rather than per-sub-task
review, and those three gates are Sub-task 4.

**▶ NEXT:** Sub-task 4 (final sign-off criteria)

> Run `/feature-checkpoint` after each sub-task completes.

## Review record

- 2026-08-25 — Spec reviewed by `feature-spec-reviewer` (two passes): VERDICT: NEEDS WORK, held solely by one `[decision]` finding. All `[rewrite]` findings applied. The user then settled that finding (step 1c is kept — normalising `CLAUDE.md` is state correction, not migration) and agreed the sign-off strategy as proposed, closing the last open point.
- 2026-08-25 — Design reviewed by `feature-design-reviewer` (two passes): VERDICT: READY FOR USER REVIEW. All findings were `[rewrite]` and all were applied; none was `[decision]`. Presented to the user for sign-off, with one flagged deviation from the agreed sign-off strategy (a fifth validation run covering the step 1c rewording).
- 2026-08-28 — Feature closed. Docs reviewed by `docs-structure-reviewer` (two passes) at `/feature-end`: first pass PASS on criterion (a) no dangling reference, FAIL on criterion (b) complete and accurate account, on one MAJOR — `SKILL.md`'s opening "safe to re-run" sentence denied an overwrite that step 1c performs, a contradiction introduced during the earlier `/review-branch` fix to the same sentence. Fixed, along with one MINOR (three summary sites said the skill "adds" the import when it also repairs an existing wrong one). Second pass: **both criteria PASS**, docs-review box ticked. Two further MINORs (`docs/workflow.md:12`'s link target, a typo at `docs/setup.md:207`) were pre-existing and unrelated, and were deliberately left as follow-up candidates rather than closed inside this feature. Preceding code-review gate: `/review-branch` on 2026-08-28, architectural pass skipped by the user's decision, three findings applied — including an unrelated `NOTES.md` paragraph clobbered by commit `5c47868` and restored.
