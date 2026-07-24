# Requirements input for /feature-spec — Feature Plan

## Handoff

**Last updated:** 2026-07-24
**Session summary:** Feature complete and closed. All five sub-tasks done; both
feature-level sign-offs passed (`/review-branch` converged over two passes,
fixing two edge-case gaps in `feature-spec` step 2; `docs-structure-reviewer`
found no major issues). Feature moved to `features/COMPLETED.md` and
`/workspace/CLAUDE.md` status flipped to no feature in progress via
`/feature-end` on 2026-07-24. All deliverable edits are under `/workspace/`
(the live plugin copy at `/home/claude/claudeplugins/devproc/` may have
drifted — see NOTES.md).
**Sub-task in progress:** None
**First action next session:** None — feature completed and moved to
`features/COMPLETED.md` on 2026-07-24.
**Open questions / decisions pending:** None
**Dead ends to avoid:** None

**Important — read before any commit:** Sub-tasks 1–2's skill-prose edits were
originally made only in `/home/claude/claudeplugins/devproc/` (the live plugin
copy) and had to be ported into the git-tracked `/workspace/devproc/`; this was
resolved during Sub-task 2 (`diff -q` confirmed the two trees back in sync for
both files — see NOTES.md "`/home/claude/claudeplugins` is a live plugin
copy"). Sub-tasks 3 and 4 were made directly under `/workspace/`, so no porting
is owed for them. The two trees may still drift going forward (that's
accepted); diffing them remains the pre-`/feature-end` check.

## Requirements

**The problem.** The actual flow is *requirements → spec → design*, but the
requirements step is not flexible enough. `/feature-spec` currently assumes the
feature is specified either in a GitHub issue or as a single line on the command
line. Often the requirements are neither: the user has a chunk of information —
more than one line, not in an issue — that they want to give to `/feature-spec`
as input.

**What the feature must deliver.** A simple, clean way for a user to supply a
body of requirements material to `/feature-spec`, and documentation that makes
this discoverable and explains it.

**Proposed approach** (the user's plan; explicitly open to being simplified or
improved at design time):

1. Add a new directory under `features`, called `features/tmp`. Git-ignore it
   (create or update `.gitignore` so its contents are not stored). *(No
   `.gitignore` exists in the repo yet.)*
2. User docs (`workflow.md`) explain that complex requirements can be placed
   there as input to `/feature-spec`.
3. The `feature-spec` skill is updated to say something to the effect of "you
   may be asked to look at documents in `features/tmp`", with suitable wording.

**Constraints and intent** (these shape the design, so must be honoured):

- **This is scratch input, not requirements tracking.** The directory is "how
  the user provides ~200 lines of context when a feature is being created", *not*
  "how the user tracks requirements". Requirements docs must **not** be bundled
  into the `features` directory indefinitely. This is precisely why the directory
  is deliberately named `tmp` (and git-ignored) rather than `reqts` or similar —
  the naming signals it is transient.
- **The flow should be as simple as possible.** The three-step approach above is
  the simplest and cleanest the user could come up with; simplifications are
  welcome but simplicity is the priority.
- **Requirements material may not be in tidy form.** It might be a Word document,
  multiple documents, a document containing links, or similar — not necessarily a
  clean markdown file. In that case it may be necessary to move or copy some
  requirements artefacts into a subdirectory under `plans` and link to them from
  the main plan (slug) doc — **but only if the material is genuinely unsuitable
  to copy inline**. The rule of thumb:
  - Screenshots, Word documents, and other binary/non-text artefacts probably
    have to be copied (kept) and linked.
  - A ~200-line markdown file should just be copied inline into the plan's
    `## Requirements` section, as `/feature-spec` already does for issue content.
- **The plan (spec) is the durable home of "what we are implementing"; `tmp` is
  not.** Once `/feature-spec` has captured the requirements material into the
  plan — inline for text, or copied into `features/plans/<slug>/` for genuinely
  un-inlinable binary artefacts (Word docs, screenshots) — the transient copy in
  `features/tmp` has served its purpose and should not persist as a second copy.
  Keeping two copies (one in `tmp`, one inline/under the plan) causes confusion:
  **avoiding that duplication is a key requirement.** The permanent artefact under
  `features/plans/<slug>/` is the deliberate, confirmed exception to "nothing
  requirements-y lives in `features/` indefinitely" — the spec must record what is
  being implemented, and an un-inlinable artefact has to live somewhere.
- **Requirements do not belong in code directories.** Requirements material lives
  in issues, or in spec docs (reviewed by the PM org or equivalent), or — once
  captured — in the plan. The `features/tmp` scratch mechanism is a hand-off
  channel into the spec, not a store; it must not become a place where
  requirements accumulate alongside the code.

*(Source: the user's `workflownotes.md`, captured here so it need not be
re-read. Note: `workflownotes.md` describes this as providing context "at
implementation time" in one place; in context it means at feature-creation /
spec time, since the material is input to `/feature-spec`.)*

## Sign-off strategy

This is a prose-and-configuration change: it edits the `feature-spec` skill
(`SKILL.md`) prose, updates user documentation (`workflow.md`, and the project
`CLAUDE.md` feature model where it describes requirements capture), adds a
`features/tmp` directory, and adds/updates `.gitignore`. There is no application
code.

- **Testing** — No automated tests (there is no code to unit-test). Manual
  verification instead: confirm that `.gitignore` actually causes `features/tmp`
  contents to be untracked (e.g. a test file in `features/tmp` shows as ignored
  under `git status --ignored`), and that the directory itself is preserved in
  the repo (e.g. via a tracked `.gitkeep`/README) if the design calls for it.
- **Documentation** — Full update. `docs/workflow.md` gains a clear description
  of the new requirements-input path; the project `CLAUDE.md` feature model and
  the `feature-spec` skill are updated to match. Done when all three artefacts
  reflect the new requirements-input path.
- **Code review (agent)** — A single `/review-branch` pass over the changed
  files before `/feature-end`, treating the skill prose as the "logic" to check
  for consistency and correctness (recorded once at feature level rather than per
  sub-task).
- **Docs review (agent)** — `docs-structure-reviewer` over the updated
  documentation before `/feature-end`, to confirm the new flow is discoverable
  and well-placed. This is the most load-bearing sign-off for this feature, since
  its central purpose is documentation quality.
- **User review** — A single end-of-feature pass: the user reads and confirms
  the whole feature (skill behaviour, scaffolding, and docs wording) reads well
  and matches their intent, in one review of the complete diff rather than per
  sub-task. Expected to need only minor wording tweaks, so the risk of batching
  it is minimal and it is quicker.

## Design

### Where each change lives

The feature touches three artefact clusters. The design keeps them separate
because they have different owners and different sign-offs:

1. **Scaffolding** — the `features/tmp` directory and the `.gitignore` rule.
   These belong in **`feature-init`** (`devproc/skills/feature-init/SKILL.md`),
   the one-time setup skill that already builds the `features/` layout and is
   explicitly **re-runnable** to retrofit existing projects ("safe to re-run …
   only fills in anything missing"). Putting the scaffolding there means every
   project — new or existing — gets `features/tmp` and the ignore rule by
   running/re-running `/feature-init`, and this repo gets it the same way.
2. **Behaviour** — `/feature-spec` learning to ingest requirements material from
   `features/tmp`. This is prose in **`devproc/skills/feature-spec/SKILL.md`**.
3. **Documentation** — the user-facing narrative in **`docs/workflow.md`**, plus
   the mirrored feature-model reference that appears in three places kept in
   sync: the `feature-init` CLAUDE.md **template**, this repo's own
   **`/workspace/CLAUDE.md`**, and **`devproc/README.md`**.

### Key design decisions

- **Keep `features/tmp` present and self-documenting via a tracked README.**
  Rather than leave the directory to be created ad hoc, `feature-init` creates
  `features/tmp/README.md` (a short note: "scratch space — drop requirements
  material here as input to `/feature-spec`; contents are git-ignored and
  transient; do not use this to *track* requirements"). The `.gitignore` rule
  ignores everything in the directory **except** that README:

  ```gitignore
  features/tmp/*
  !features/tmp/README.md
  ```

  Rationale: the README both keeps the directory in the repo (so it always
  exists) and documents its purpose *in place*, which directly serves the
  feature's discoverability goal. A bare `.gitkeep` would keep the directory but
  explain nothing. *(This is the concrete choice behind the strategy's "directory
  preserved … if the design calls for it" — it does.)*

- **`feature-init` creates `.gitignore` if absent, and appends to it if present.**
  No `.gitignore` exists in this repo yet, so it will be created. On a project
  that already has one, `feature-init` adds the two lines only if they are not
  already present (idempotent, matching the rest of the skill).

- **`/feature-spec` ingests from `features/tmp` when directed to it, and captures
  into the plan, then clears `tmp`.** The skill's requirements-gathering gains a
  third input route alongside "GitHub issue" and "one-line description": *material
  in `features/tmp`*. The skill is told it may be pointed at `features/tmp` (and
  should look there when the user references it, or when the command-line
  description is thin and the directory holds material — but where it *auto-detects*
  material it was not explicitly pointed at, it confirms with the user before
  ingesting, so stale content left by an aborted earlier run cannot leak into an
  unrelated feature's spec). When it uses that material it:
  - **inlines** text/markdown content into the plan's `## Requirements` section
    (as it already does for issue content); but
  - for genuinely un-inlinable artefacts (Word documents, screenshots, binaries)
    **copies them into `features/plans/<slug>/`** and links to them from
    `## Requirements`; then
  - **removes the ingested material from `features/tmp`** once captured, so no
    duplicate copy survives. This enforces the requirements' "avoid two copies /
    duplication is a key requirement" and "`tmp` is a hand-off channel, not a
    store" constraints. (The README is not ingested and stays.)

- **Documentation mirrors the mechanism in the right register.**
  `docs/workflow.md` "Specify a feature" gains a short description of the third
  input route (what it is, that it is transient/git-ignored, and that the content
  ends up in the spec). The feature-model reference — `feature-init`'s CLAUDE.md
  template "Documents to support the model", this repo's `/workspace/CLAUDE.md`,
  and `devproc/README.md` — gains a one-line mention of `features/tmp` so the
  directory is explained wherever the layout is listed.

### Sign-off placement

Per the strategy, **code review (`/review-branch`)** and **docs review
(`docs-structure-reviewer`)** are single feature-level passes before
`/feature-end`, not per-sub-task — recorded here, not repeated on each sub-task.
**Testing** applies only to Sub-task 1 (it is the only sub-task with runnable,
git-observable behaviour); the prose/doc sub-tasks carry no Testing box because
there is nothing to execute — they are covered by the feature-level code/docs
review plus per-sub-task user review. **Documentation** boxes sit on the
sub-tasks that actually change docs (2, 3 and 4). **User review** is a single
end-of-feature pass over the complete diff (Sub-task 5), not per sub-task — the
user preferred one full review of the finished feature, which is quicker and
carries minimal risk since only minor wording tweaks are expected.

## Sub-tasks

1. ✓ **Scaffold `features/tmp` and git-ignore it** (2026-07-24) — Updated `feature-init` SKILL.md to create `features/tmp/README.md` (purpose note) and to create-or-append the `features/tmp/*` + `!features/tmp/README.md` rules in `.gitignore` idempotently; applied that logic to this repo so `.gitignore` and `features/tmp/README.md` exist here.
   - [x] Testing: a file dropped in `features/tmp/` shows as ignored under `git status --ignored`; `features/tmp/README.md` is tracked; the `.gitignore` rules are present and the described feature-init logic is idempotent on re-run.
2. ✓ **Teach `/feature-spec` to ingest requirements from `features/tmp`** (2026-07-24) — Added step 2 (later steps renumbered) to `feature-spec` SKILL.md: explicit pointer or auto-detect-with-confirmation, inline text into `## Requirements`, copy genuinely un-inlinable artefacts into `features/plans/<slug>/` and link them, then remove the ingested material from `features/tmp` to avoid a duplicate copy.
   - [x] Documentation: `feature-spec` SKILL.md describes the `tmp` ingest route accurately and consistently with `docs/workflow.md` (workflow.md itself not yet written — Sub-task 3; NOTES.md records what it must say to match).
3. ✓ **Document the input path in `docs/workflow.md`** (2026-07-24) — Added a third bullet ("From material staged in `features/tmp`") to the "Specify a feature" section, mirroring the existing GitHub-issue bullets' format: what to drop there, the explicit-pointer vs. auto-detect-with-confirmation routes, inline-vs-copy handling, and that the material is cleared from `features/tmp` (`README.md` stays) once captured.
   - [x] Documentation: `docs/workflow.md` describes the new route accurately and consistently with the skill behaviour.
4. ✓ **Sync the feature-model reference docs** (2026-07-24) — Added a `features/tmp/` bullet to the "Documents to support the model" list in both the `feature-init` CLAUDE.md template and this repo's `/workspace/CLAUDE.md` (verified identical after collapsing line-wrapping); updated `devproc/README.md`'s `feature-init`/`feature-spec` table rows and detail sections, and this repo's CLAUDE.md devproc-plugin bullets for the same two skills, to note the scaffolding and the third ingest route.
   - [x] Documentation: the feature-init template, `/workspace/CLAUDE.md` (both its Feature model list and its devproc plugin bullets), and `devproc/README.md` all mention `features/tmp` and the ingest mechanism, consistently.
5. ✓ **Full user review of the feature** (2026-07-24) — User reviewed the entire feature diff in one pass (skill behaviour, scaffolding, and all doc changes) and confirmed it reads well and matches intent, with no changes requested.
   - [x] User review: user has reviewed the complete feature diff and is content (any tweaks applied).

**▶ NEXT:** All sub-tasks and feature-level sign-offs complete. Ready for `/feature-end`.

**Feature-level sign-offs** (per `## Sign-off strategy`, done once before `/feature-end`, not repeated above):
- [x] Code review (agent): `/review-branch` over the whole diff — converged over two passes; all findings code-level (two MAJOR gaps in `feature-spec` step 2 fixed: explicitly-referenced-but-empty `tmp`, and ambiguous auto-detect trigger; plus terminology and robustness fixes). No architectural findings.
- [x] Docs review (agent): `docs-structure-reviewer` over the updated documentation — no CRITICAL/MAJOR findings; one MINOR (workflow.md sentence split) and three SUGGESTIONs all applied. Mirror invariant (CLAUDE.md ↔ feature-init template) re-verified.

> Run `/feature-checkpoint` after each sub-task completes.

## Review record

- 2026-07-24 — Spec reviewed by `feature-spec-reviewer`: VERDICT: READY FOR USER REVIEW. Presented to the user for sign-off; the reviewer's 1 open question (permanence of un-inlinable binary artefacts under `plans/`) was resolved with the user and folded into the Requirements constraints. Sign-off strategy agreed as written.
- 2026-07-24 — Design reviewed by `feature-design-reviewer`: VERDICT: READY FOR USER REVIEW. Two SUGGESTION `[rewrite]` findings applied (Documentation box added to Sub-task 2; auto-detect confirmation folded into the design); no open questions. Presented to the user for sign-off.
- 2026-07-24 — Implementation reviewed by `/review-branch` (code-review-simplicity/general/nitty): converged over two passes. All findings code-level (auto-applied); no architectural findings. Fixed two MAJOR gaps in `feature-spec` step 2 and a grammatical ambiguity, plus terminology/robustness polish.
- 2026-07-24 — Documentation reviewed by `docs-structure-reviewer`: no CRITICAL/MAJOR findings; 1 MINOR + 3 SUGGESTIONs applied. Feature documented consistently across all surfaces; mirror invariant re-verified.
