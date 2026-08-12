# Move tests out of the plugin directory — Feature Plan

## Handoff

**Last updated:** 2026-08-12
**Session summary:** Feature closed — final state. `tests/devproc/harness/run.sh`, `README.md`, and `.gitignore` built, replacing the three ad-hoc `features/tmp/regression/` scripts. The one script collapses the old scripts' duplicated prompt block into a single `build_prompt` definition, derives its case list from `<name>.md`/`<name>.expected.md` pairs on disk (verified against both suites: 7 spec cases, 8 design cases, exactly matching what's on disk), resolves all paths relative to its own location (no `cd /workspace`), and writes to the git-ignored `out/`. `shellcheck` passes clean; a single case (`feature-spec-reviewer/control`) was run end to end from outside the repo, producing correct output and leaving `git status` unchanged. `/review-component` found one MAJOR (exit codes were captured per-case but never aggregated, so the script reported success even when cases failed) plus several minors; all code-level findings were applied — see Sub-task 3's "Verification performed" for the full list. The root `CLAUDE.md`'s `tests/` section now mentions the harness.
**Feature complete and closed via `/feature-end` on 2026-08-12.** The close-out `docs-structure-reviewer` pass ran and its findings were applied — chiefly a new `tests/README.md` indexing the area, back-links from the suite READMEs to the harness, and a qualification on `devproc/README.md`'s fixture-location lines, which after the move named a path that does not exist in a consumer's install.
**Sub-task in progress:** None — all sub-tasks complete.
**First action next session:** None.
**Open questions / decisions pending:** None.
**Dead ends to avoid:** Do not use `git mv`, and do not stage the move — this project's standing rule reserves repository-state-changing git commands for the user. Use a plain filesystem `mv`; git will show the result as delete+add until the user stages it, which is expected and is why losslessness is checked with `diff -r` against a pre-move copy rather than with git's rename detection.

## Requirements

From issue #50, "Tests are under devproc/tests" (verbatim):

> The issue here is that the shipped plugin should not come with tests - yet the test directory is within the devproc part of the tree.
>
> Having tests is fine, but they should be under some location that is not part of the plugin that we suggest people copy in (for example, under tests/devproc rather than devproc/tests).

The issue has no comments. The user added, when invoking `/feature-spec`: "This is expected to be a pretty trivial feature."

## Spec

### What this feature is for

This repository packages the `devproc` plugin as the directory `devproc/`. That
directory is the unit of distribution: the root `.claude-plugin/marketplace.json`
points at `./devproc` as the plugin source, `docker/Dockerfile` copies the whole
of `devproc/` into the container image, and `docs/setup.md` tells users to copy
or install that directory.

`devproc/tests/` sits inside it. It holds test fixtures for three reviewer
agents (`feature-spec-reviewer`, `feature-design-reviewer`,
`internal-docs-reviewer`) — deliberately flawed inputs paired with recorded
`.expected.md` outputs, plus a `README.md` per suite explaining how to run them.
These fixtures are development material for maintaining this repository. They
are of no use to someone installing the plugin, but they are shipped to them
anyway, because they are inside the directory that gets shipped.

The feature moves the fixtures out of the plugin directory, so that `devproc/`
contains only what a consumer of the plugin should receive.

### What the feature must do

1. **The fixtures move out of `devproc/`.** Every file currently under
   `devproc/tests/` moves to a location outside the plugin directory, with its
   internal directory structure and its content unchanged. *Proposed:* the
   destination is `tests/devproc/`, the example the issue itself gives — so
   `devproc/tests/feature-spec-reviewer/control.md` becomes
   `tests/devproc/feature-spec-reviewer/control.md`, and likewise for the
   `feature-design-reviewer` and `internal-docs-reviewer` suites. The
   `devproc/tests/` directory no longer exists when the feature is done.

   The `tests/devproc/` shape (rather than a bare `tests/`) keeps room for tests
   of things in this repository that are not the `devproc` plugin — `bin/`, the
   container scripts — without a later reorganisation.

2. **Fixture content is not rewritten.** This is a relocation, not a revision.
   The fixture inputs and their `.expected.md` counterparts keep the text they
   have now, so the suites remain valid evidence for the agent wording they were
   recorded against. The only permitted edits to moved files are to paths that
   name the fixtures' own location — for example the suite `README.md` files,
   which quote run commands such as
   `claude -p --agent feature-spec-reviewer 'Review devproc/tests/feature-spec-reviewer/<case>.md'`.

3. **Every live reference to the old path is updated, and every historical one
   is left alone.** Whether a reference is updated depends on what the sentence
   containing it does, not on which file it sits in:

   - A reference is **historical** where it forms part of a record of work
     already done — either the sentence describes a past event ("fixtures moved
     to X", a dated log entry), or it sits in a document whose job is to record
     a finished piece of work: an entry in `features/COMPLETED.md`, the plan
     file of a completed feature, or a dated agent-memory review-log entry. In
     those documents a present-tense sentence is still a record of what that
     work left behind, so it too is left exactly as it is. One such file
     (`features/plans/spec-design-review-agents.md`) exists specifically to
     record an earlier move of these same fixtures *into* `devproc/tests/`;
     rewriting it would falsify the record.
   - A reference is **live** where it makes a present-tense claim about the
     current repository in a document that describes the repository as it is
     now — `devproc/README.md`, `NOTES.md`, `CLAUDE.md`, a suite `README.md`,
     or an agent-memory file stating the current layout. Live references are
     updated.

   The two kinds can share a file, and in this repository they do:
   `.claude/agent-memory/devproc-docs-structure-reviewer/project_structure.md`
   states the current suite layout and is live, while the dated review-log
   entries in that directory's `recurring_issues.md` are historical.

   This feature's own title and plan file name the old path because they
   describe the problem being fixed: the entry in `features/PENDING.md` and
   `features/plans/move-tests-out-of-plugin.md` are excluded from the audit and
   are not rewritten.

   Known live references at the time of writing, offered as a starting point
   and not as the audit:

   - `devproc/README.md` — three lines, in the reference entries for the three
     reviewer agents, each stating where that agent's fixtures live.
   - `NOTES.md` — two lines describing the fixture layout and the rule that the
     `internal-docs-reviewer` fixtures are run against copies under `/tmp`
     rather than in place.
   - `.claude/agent-memory/devproc-docs-structure-reviewer/project_structure.md`
     — the statement of the current suite layout.

   The design stage re-derives the list rather than trusting it; the audit is a
   repository-wide search for the old path, with every remaining hit classified
   under the rule above.

4. **The repository's own structure documentation reflects the new directory.**
   *Proposed:* the root `CLAUDE.md`, which lists each top-level area of the
   repository and what it holds, gains an entry for `tests/` on the same terms
   as its existing `setup-files/` and `docker/` entries. Whether any user-facing
   document under `docs/` needs a corresponding change is a design-stage
   question — none currently mentions the fixtures.

5. **Nothing else leaves `devproc/`.** The issue is about test material
   specifically. No other file leaves the plugin directory, and no packaging
   mechanism (`marketplace.json`, `docker/Dockerfile`, `docs/setup.md`) needs to
   change, because each references `devproc/` as a whole and the move simply
   removes something from inside it. If design finds a packaging file that names
   `devproc/tests` explicitly, that is a reference under requirement 3.

6. **The regression harness is promoted into the new tests tree.** *(Added by
   amendment during implementation — see `## Review record`.)* A harness for
   running the reviewer-agent fixture suites exists as three ad-hoc scripts in
   the git-ignored `features/tmp/regression/`, left there by
   `clear-specs-and-designs` (#57) with the question of promoting it explicitly
   deferred. Now that a tests directory exists, the harness belongs in it.

   The promotion is a rewrite, not a relocation, because the scripts as they
   stand do not work outside the session that wrote them:

   - `tests/devproc/harness/` holds **one** script and a `README.md`. The three
     existing scripts (`run.sh`, `runall.sh`, `rerun.sh`) duplicate the same
     prompt block and collapse into a single entry point that can run every
     case, one suite, or one case.
   - **The case list is derived from the fixtures on disk**, not hardcoded. The
     existing lists have already drifted: the `feature-spec-reviewer` suite has
     7 fixtures, but `runall.sh` names 5 and `rerun.sh` 6, so "run everything"
     silently skips cases. Deriving the list is what stops that recurring.
   - **Paths are repository-relative.** The current `cd /workspace` works only
     inside this container.
   - **Run output goes to `tests/devproc/harness/out/`, which is git-ignored**,
     so running the harness never dirties the working tree.
   - **Only the script and its `README.md` become tracked content.** The ~30
     recorded `.txt` outputs and the `round2/` directory in
     `features/tmp/regression/` are transient artefacts of runs against August
     2026 agent wording; what they attest to is already recorded in
     `features/plans/clear-specs-and-designs.md`. They are left where they are,
     to age out with the rest of the scratch directory.

   `features/tmp/review/` — a frozen snapshot of a past `/review-branch` run —
   is **not** promoted and remains out of scope. It is disposable output, not a
   harness.

### What "done" looks like

- `devproc/` contains no test material, and the moved tree is complete —
  including hidden files and directories, which a glob-based move would silently
  drop (the `internal-docs-reviewer` fixtures contain a `.claude/` subtree, whose
  two files are the only hidden ones in the suite).
- A search of the repository for the old path returns hits only in references
  classified as historical under requirement 3, or in this feature's own
  `features/PENDING.md` entry and plan file, and the classification of each
  remaining hit is recorded.
- The fixtures are runnable at their new location by following the commands in
  their own suite `README.md` files.
- `tests/devproc/harness/` holds a single working script and a `README.md`; the
  script derives its case list from the fixtures on disk, uses no absolute
  paths, and writes to a git-ignored `out/`. Running one case end to end
  produces reviewer output in `out/` and leaves `git status` clean.

## Sign-off strategy

This is a file relocation plus reference updates, in a repository whose content
is prose and fixtures rather than executable code. The bar is set to match:
cheap, concrete checks that the move is complete and lossless, and no
disproportionate ceremony.

- **Testing** — Verification by inspection rather than by execution. Two
  checks. First, the move is lossless: a recursive comparison of the moved tree
  against its pre-move state (e.g. `diff -r` against a copy taken beforehand)
  shows an identical file set — hidden files and directories included — and no
  content difference other than the path corrections permitted by requirement 2.
  Second, the repository-wide search for the old
  path returns only hits classifiable as historical under requirement 3 or
  belonging to this feature's own entry and plan file. *No re-running of the
  reviewer-agent fixture suites:* this feature does not
  change any agent's wording or any fixture's text, so a suite re-run would test
  nothing the move puts at risk, and each run costs several agent invocations.
  Auditable: both checks have been run and their output — including the
  classification of each remaining search hit — is recorded in the plan file at
  the next `/feature-checkpoint`.

- **Documentation** — Mostly internal, plus one user-facing line. Every live
  reference to the fixture location is corrected (requirement 3), the suite
  `README.md` files' own run commands are corrected (requirement 2), and the two
  documents that map the repository's structure gain a `tests/` entry
  (requirement 4): the root `CLAUDE.md`, and the root `README.md`'s
  `## Documentation` table. *(The `README.md` row was added at design time —
  the strategy agreed at `/feature-spec` said "no user-facing documentation is
  expected to change", which design showed to be wrong: the README table lists
  top-level areas, and this feature creates one. See `## Design` → "What
  deliberately does not change".)* Auditable: each of those three is either done
  or explicitly recorded as not applicable with a reason.

- **Code review** — One agent pass over the harness script only:
  `/review-component` on `tests/devproc/harness/`. *(Raised from "None" by the
  requirement 6 amendment — the original bar was set when the feature contained
  no code, which the harness rewrite changes. The move-and-sweep work still
  carries no code-review box: it is a relocation plus Markdown path
  corrections, and the Testing search covers it more directly than a review
  agent would.)* Auditable: the review has run and its findings are applied or
  explicitly dismissed.

- **Docs review** — One agent pass: the `docs-structure-reviewer` run that
  `/feature-end` performs as its close-out review (so the box carries the
  annotation "(performed at `/feature-end`)"), covering the updated
  `devproc/README.md`, the suite `README.md` files, `NOTES.md`, the root
  `CLAUDE.md` and the root `README.md`. No additional docs-review pass beyond
  that one — the change is path corrections plus two short structure entries.
  Auditable: the close-out review has run and its findings are applied or
  explicitly dismissed.

- **User review** — One review at the end of the feature: the user sees the
  final tree layout and the complete diff, and confirms it before
  `/feature-end`. Given the size of the change, no per-sub-task user review.

## Design

### Overview

The work is a directory move followed by a reference sweep, done in that order
and split into one sub-task each, plus one addition: because the move creates a
new top-level area, the two documents that map this repository's structure — the
root `CLAUDE.md` and the root `README.md`'s `## Documentation` table — each gain
an entry for `tests/`, written on the same terms as their existing
`setup-files/` entries (spec requirement 4). That is the only new prose the
feature writes; everything else is a move or a path correction.

`devproc/tests/` — 58 files across 22 directories, all mode `100644` — moves
wholesale to `tests/devproc/`, keeping its internal structure. Nothing inside is
rewritten except the three suite `README.md` files, which quote run commands
naming their own location. Then every reference to the old path elsewhere in the
repository is visited and either updated or deliberately left, according to the
live/historical rule in requirement 3.

The reference audit has already been done, during design, and its result is the
classified table below. That is the main thing this design contributes: the
sweep in Sub-task 2 is a checklist to work and verify, not a search to invent.

Two constraints shape the mechanics:

- **The move is a plain filesystem `mv`, not `git mv`.** This project reserves
  repository-state-changing git commands for the user, and `git mv` stages its
  own rename. So git will report the result as 58 deletions plus 58 additions
  until the user stages it. That is expected, not a defect — and it is why the
  spec's losslessness check is a `diff -r` against a copy taken before the move
  rather than anything based on git's rename detection.
- **A glob-based move would silently lose files.** The
  `internal-docs-reviewer` suite contains a hidden subtree,
  `claude-rules/.claude/`, holding `hooks/block-git-push.sh` and
  `rules/no-git-push.md`. `mv devproc/tests/* ...` would leave both behind, and
  neither the path search nor a diff of the surviving files would notice, since
  neither file mentions the old path. Moving the directory itself, and diffing
  the whole tree, is what catches this.

### The reference audit

Every occurrence of `devproc/tests` in the repository, classified under
requirement 3. Historical hits are listed so the sweep can confirm they were
considered rather than missed.

Counts below are **occurrences of the string `devproc/tests`**, with the line
count given separately where the two differ.

**Live — update (6 occurrences on 6 lines, 3 files):**

| File | Lines | What it says |
|---|---|---|
| `devproc/README.md` | 187, 197, 213 | "Test fixtures … live in `devproc/tests/<agent>/`", one per reviewer agent |
| `NOTES.md` | 539, 578 | fixture-directory layout; the rule that `internal-docs-reviewer` fixtures run against `/tmp` copies |
| `.claude/agent-memory/devproc-docs-structure-reviewer/project_structure.md` | 46 | current shared-baseline layout of the two reviewer suites |

**Live — update, but inside the moved tree (3 occurrences, 3 files):** the
`README.md` of each suite, quoting a run command or a layout diagram naming its
own path (`feature-spec-reviewer/README.md:86`,
`feature-design-reviewer/README.md:68`,
`internal-docs-reviewer/README.md:44`). These belong to Sub-task 1, since they
move with the tree.

**Historical — leave untouched (20 occurrences on 18 lines, 6 files;
`clear-specs-and-designs.md` lines 132 and 142 each contain the path twice):**
`features/COMPLETED.md` (26, 38); `features/plans/spec-design-review-agents.md`
(6, 182, 248 — the record of moving these same fixtures *into* `devproc/tests/`);
`features/plans/clear-specs-and-designs.md` (17, 132, 142, 315, 361);
`features/plans/internal-docs-prune.md` (90, 245, 285);
`features/plans/final-signoff-subtask.md` (42, 132); and
`.claude/agent-memory/devproc-docs-structure-reviewer/recurring_issues.md`
(36, 218, 223 — dated review-log entries).

Two files needed the rule applied per sentence rather than per file, which is
where "which file is it in" would have given the wrong answer:

- **The agent-memory directory splits across both classes**, exactly as the
  spec predicted. `project_structure.md` describes the repository as it is now
  and is live; `recurring_issues.md`'s entries sit under dated review headings
  (`## Thirty-fourth review (2026-08-12)` and similar) and are records.
- **`NOTES.md:578` is classified live despite past-tense framing.** The
  sentence narrates how `/internal-docs-prune` was validated during #46
  ("executed by hand against copies of the fixtures under `/tmp`, never against
  `devproc/tests/`"), which reads historical. It is treated as live because the
  `/tmp`-copies rule it states is standing guidance about how this suite is run
  today, and `NOTES.md`'s job is to carry durable findings about the current
  repository — a stale path inside one misleads the next person to follow it.
  `NOTES.md:539`, a plain statement of the current fixture layout, is live
  without argument.

**Excluded from the audit:** this feature's own entry (`features/CURRENT.md`)
and plan file, which name the old path because they describe the problem.

### Why `tests/devproc/` and not `tests/`

The extra level costs nothing now and leaves room for tests of the parts of this
repository that are not the `devproc` plugin — `bin/`, the container scripts —
without a later reorganisation. It is also the shape issue #50 itself suggests.
There is no existing `tests/` directory and nothing in `.gitignore` that would
swallow one.

### What deliberately does not change

`.claude-plugin/marketplace.json` and `docker/Dockerfile` reference `devproc` as
a whole and name no test path, so removing something from inside it needs no
packaging change; `docs/setup.md` likewise refers to the plugin directory, never
the fixtures. No file under `docs/` mentions the fixtures at all. These were
checked during design; the sweep in Sub-task 2 does not need to revisit them.

Requirement 4's user-facing-documentation question is therefore **not** settled
by `docs/` alone, because the root `README.md` also documents structure: its
`## Documentation` table surfaces top-level areas, not just files under `docs/`,
carrying rows for `features/` and `setup-files/README.md`. `tests/` is a new
area of exactly that kind, so it gains a row pointing at the suite `README.md`
files. The alternative — treating the fixtures as maintainer material already
discoverable from `devproc/README.md`'s agent entries, and adding nothing — was
rejected: a top-level directory absent from the repository's own map is a
navigability gap, and `docs-structure-reviewer` has raised precisely that
finding about this table before (recorded in its memory as "README Documentation
table does not surface features/ directory"). Since a `docs-structure-reviewer`
pass is this feature's close-out gate, leaving it would invite the finding after
the user review rather than before it.

## Sub-tasks

1. ✓ **Move the fixture tree** — `devproc/tests/` becomes `tests/devproc/`, complete and unaltered but for the three suite `README.md` self-references.
   - [x] Testing: a `/tmp` reference copy is taken before the move, and `diff -r` against it afterwards reports an identical file set — hidden files and directories included — with no content difference other than the suite `README.md` path corrections; the `diff -r` output is recorded in the plan file at the next `/feature-checkpoint`
   - [x] Testing: `devproc/tests/` no longer exists and `devproc/` contains no test material
   - [x] Documentation: the three suite `README.md` files name the new location in their run commands and layout diagrams, and each quoted path resolves to a file or directory that exists at the new location

   **Verification performed:**

   Reference copy taken with `cp -a devproc/tests /tmp/fixtures-premove` before the
   move (58 files, matching the design's count). The directory itself was moved
   (`mkdir tests && mv devproc/tests tests/devproc`), not a glob, so the hidden
   `internal-docs-reviewer/claude-rules/.claude/` subtree (2 files:
   `hooks/block-git-push.sh`, `rules/no-git-push.md`) moved with it — confirmed
   present at the new location afterwards.

   `diff -r /tmp/fixtures-premove /workspace/tests/devproc` output:
   ```
   diff -r /tmp/fixtures-premove/feature-design-reviewer/README.md /workspace/tests/devproc/feature-design-reviewer/README.md
   68c68
   < claude -p --agent feature-design-reviewer 'Review devproc/tests/feature-design-reviewer/<case>.md'
   ---
   > claude -p --agent feature-design-reviewer 'Review tests/devproc/feature-design-reviewer/<case>.md'
   diff -r /tmp/fixtures-premove/feature-spec-reviewer/README.md /workspace/tests/devproc/feature-spec-reviewer/README.md
   86c86
   < claude -p --agent feature-spec-reviewer 'Review devproc/tests/feature-spec-reviewer/<case>.md'
   ---
   > claude -p --agent feature-spec-reviewer 'Review tests/devproc/feature-spec-reviewer/<case>.md'
   diff -r /tmp/fixtures-premove/internal-docs-reviewer/README.md /workspace/tests/devproc/internal-docs-reviewer/README.md
   44c44
   < devproc/tests/internal-docs-reviewer/<case>/
   ---
   > tests/devproc/internal-docs-reviewer/<case>/
   ```
   The only differences are the three suite `README.md` path corrections
   permitted by requirement 2. File count is identical (58 files each side).

   The three corrections were verified against the new tree: the
   `feature-spec-reviewer` and `feature-design-reviewer` run commands now name
   `tests/devproc/<suite>/<case>.md`, matching the fixture files present there;
   the `internal-docs-reviewer` layout instruction now names
   `tests/devproc/internal-docs-reviewer/<case>/`, and each of that suite's seven
   case directories (`control/`, `stale/`, `redundant/`, `judgment/`,
   `nested-claude-md/`, `claude-rules/`, `idempotent/`) exists at that location.

   `devproc/tests/` confirmed absent (`ls` errors "No such file or directory");
   `find /workspace/devproc -iname '*test*'` returns nothing, so `devproc/`
   carries no test material. A repository-wide `grep -rn 'devproc/tests'` over
   the moved tree itself returns no hits — all in-tree references were the three
   just corrected.

   No file in the suite carries git's executable bit — all 58 are git-tracked
   as mode `100644` (on disk this is `664`, per the local umask, which git does
   not track beyond the executable bit) — so the move had no mode-preservation
   risk to manage. Worth stating because the spec originally, and wrongly,
   claimed the suite contained an executable script (see `## Review record`).

2. ✓ **Sweep the live references** — every live reference outside the moved tree points at `tests/devproc/`, and the historical ones are left alone.
   - [x] Documentation: every live occurrence listed in the `## Design` audit table (`devproc/README.md`, `NOTES.md`, `project_structure.md`) is updated
   - [x] Documentation: the root `CLAUDE.md` gains a `tests/` section alongside its existing `setup-files/` and `docker/` sections, and the root `README.md`'s `## Documentation` table gains a `tests/` row alongside its `features/` and `setup-files/README.md` rows
   - [x] Testing: a repository-wide search for the old path returns only the historical lines listed in `## Design`, plus this feature's own `features/CURRENT.md` entry and plan file, plus two further groups classified below (git-ignored `features/tmp/` scratch, and two occurrences written by this sub-task itself); every remaining hit is classified; output recorded in the plan file at the next `/feature-checkpoint`

   **Verification performed:**

   All 6 live occurrences updated: `devproc/README.md:187,197,213`, `NOTES.md:539,578`,
   `.claude/agent-memory/devproc-docs-structure-reviewer/project_structure.md:46` —
   each `devproc/tests/<agent>/` corrected to `tests/devproc/<agent>/`. The root
   `CLAUDE.md` gained a `## tests directory` section (between `## setup-files
   directory` and `## Container mode`, same Location/purpose/Contents shape as its
   neighbours). The root `README.md`'s `## Documentation` table gained a `tests/`
   row alongside `features/` and `setup-files/README.md`.

   `grep -rn "devproc/tests" . --exclude-dir=.git` (repository root, excluding the
   moved tree itself) returned, beyond the three just-corrected files:

   - **18 lines / 20 occurrences across the 6 historical files listed in `##
     Design`**, matching that audit's file and line numbers exactly with no drift:
     `features/COMPLETED.md` (26, 38); `features/plans/spec-design-review-agents.md`
     (6, 182, 248); `features/plans/clear-specs-and-designs.md` (17, 132, 142, 315,
     361 — 132 and 142 each carry two occurrences); `features/plans/internal-docs-prune.md`
     (90, 245, 285); `features/plans/final-signoff-subtask.md` (42, 132);
     `.claude/agent-memory/devproc-docs-structure-reviewer/recurring_issues.md`
     (36, 218, 223). Left untouched, as required.
   - **This feature's own excluded files**: `features/CURRENT.md:11` and every
     occurrence in `features/plans/move-tests-out-of-plugin.md` itself. Left
     untouched, as required.
   - **7 files under `features/tmp/`, an exclusion not anticipated by `##
     Design`'s audit and resolved during this sub-task rather than by the
     original design**: `features/tmp/regression/run.sh`, `runall.sh`,
     `rerun.sh` (leftover regression-harness scripts that hardcode
     `devproc/tests/${suite}/${case}.md` in a `claude -p --agent` prompt
     string) and `features/tmp/review/arch-out.md`, `branch.diff`, `files.txt`,
     `nitty-prompt.txt` (a frozen snapshot of a past `/review-branch` run). The
     design's audit command excluded `--exclude-dir=tmp`, which is why these
     were missed rather than classified at design time. Resolution (agreed with
     the user): **excluded from this feature's scope**, left untouched — not
     edited and not deleted. Grounds: (1) `features/tmp/` is git-ignored and
     untracked (`git ls-files features/tmp/` returns only the tracked
     `README.md`), and this feature's audit governs tracked repository content,
     not scratch space; (2) the user was told at spec time that these leftovers
     existed and were being kept out of scope, and signed off on that basis;
     (3) the material was deliberately left in place when `clear-specs-and-designs`
     (#57) closed — see that feature's plan file, lines 17 and 361, which record
     the decision and note that promoting or deleting the regression harness
     "outlives this feature." Re-litigating that here would silently answer a
     question the earlier feature consciously deferred. The `arch-out.md`/
     `branch.diff`/`files.txt`/`nitty-prompt.txt` snapshot is additionally
     historical in its own right under requirement 3's rule (a frozen record of
     a past review run), independent of the git-ignored exclusion.

   - **Two occurrences created by this sub-task's own writing, after the search
     above was run**: the new `## Current status` line in the root `CLAUDE.md`,
     which names the old path in describing what the feature does (the same
     class as the `features/CURRENT.md` entry, and trimmed to a completion line
     at `/feature-end`), and the new `NOTES.md` entry recording that the
     `features/tmp/regression/` scripts hardcode `devproc/tests/${suite}/${case}.md`
     — where quoting the dead path is the entire point of the note. Both are
     correct as written and are left in place.

   No hit was found outside these four accounted-for groups.

3. ✓ **Promote the regression harness** — `tests/devproc/harness/` holds one working script plus a `README.md`, per spec requirement 6.
   - [x] Testing: `shellcheck` passes clean on the script; and a single case is run end to end, producing reviewer output in the git-ignored `out/` and leaving `git status` clean
   - [x] Testing: the script's derived case list matches the fixtures on disk for both reviewer suites (7 spec cases, 8 design cases), demonstrated by a dry-run listing rather than a full execution
   - [x] Documentation: `tests/devproc/harness/README.md` explains how to run all cases, one suite and one case, and how to read the output against the `.expected.md` files; the root `CLAUDE.md` `tests/` section mentions the harness
   - [x] Code review (agent): `/review-component` over `tests/devproc/harness/`; findings applied or dismissed

   **Verification performed:**

   Built `tests/devproc/harness/run.sh` (one script), `tests/devproc/harness/README.md`,
   and `tests/devproc/harness/.gitignore` (containing `out/`), replacing the three old
   `features/tmp/regression/` scripts (`run.sh`, `runall.sh`, `rerun.sh`), which remain
   where they are, untouched — out of scope per the amendment.

   `shellcheck tests/devproc/harness/run.sh` exits 0, clean. Ran
   `./run.sh feature-spec-reviewer control` end to end, invoked from `/tmp` (not the
   repo) to confirm no absolute-path or cwd dependency: produced
   `tests/devproc/harness/out/feature-spec-reviewer__control.txt` containing "VERDICT:
   READY FOR USER REVIEW" with no BLOCKING/MAJOR findings, matching
   `tests/devproc/feature-spec-reviewer/control.expected.md`. `git status --porcelain`
   before and after the run is identical (only `tests/devproc/harness/` itself shows
   untracked, as it did before the run); `git check-ignore -v` and
   `git status --ignored` confirm `out/` is properly git-ignored via the new
   `.gitignore`.

   `./run.sh -n feature-spec-reviewer` lists exactly 7 cases (`control`,
   `deferred-requirements`, `incomplete-spec`, `non-auditable-criteria`,
   `premature-design`, `unclear-spec`, `unresolved-blocker`); `./run.sh -n
   feature-design-reviewer` lists exactly 8 (`control`, `missing-final-signoff`,
   `no-spec`, `oversized-subtasks`, `unclear-design`, `unexplained-design`,
   `unresolved-design-question`, `weak-subtask-criteria`). Both match the fixtures on
   disk exactly, derived from `<name>.md` + `<name>.expected.md` pairs found on disk
   rather than hardcoded.

   `tests/devproc/harness/README.md` documents running all cases, one suite, one case,
   and dry-run mode; output location and format; how to read output against each
   suite's own README pass rule; and what the `DONE`/`FAILED`/`ALL CASES COMPLETE`
   lines mean. The root `CLAUDE.md`'s `## tests directory` section gained a bullet for
   `tests/devproc/harness/`.

   `/review-component` ran over `tests/devproc/harness/`. Findings: simplicity (1
   minor — inconsistent list-membership idioms), general (1 **MAJOR** — the script
   reported success even when cases failed or timed out, since exit codes were
   captured but never aggregated; plus minors: a glob-metacharacter bypass in the
   case/suite membership checks, stale `out/` files never cleaned up, a missing suite
   directory silently treated as "no cases," no upfront `claude`-on-`PATH`/`mkdir`
   failure handling), nitty (naming/comment/README-gap minors). No architectural
   findings — nothing escalated. All code-level findings were applied: a `contains()`
   helper (exact string match, not glob) now backs both suite and case membership
   checks; PID tracking plus a `reap_batch` helper aggregate exit codes, so the script
   reports `FAILED: N of M case(s)...` and exits 1 on any failure, or `ALL CASES
   COMPLETE (n case(s))` on success; a `clean_stale_out` step removes `out/` files for
   cases no longer on disk; upfront checks now catch `claude` missing from `PATH` and
   `mkdir` failure; a missing suite directory is now detected and reported; `rc`
   values and the summary lines are documented in the README; a `-h`/`--help` flag was
   added and documented. Two further convergence passes left only two SUGGESTION-level
   items, both agents rating them optional/low-priority — left as-is per
   proportionality. Re-verified after all fixes: `shellcheck` still exits 0, the
   dry-run counts are still 7/8, and the files remain untracked (not staged or
   committed, per the project's standing rule reserving git writes for the user).

4. **Final sign-off criteria** — end-of-feature gates for this feature, per `## Sign-off strategy`
   - [x] Docs review (agent): `docs-structure-reviewer` over the updated `devproc/README.md`, the suite `README.md` files, the harness `README.md`, `NOTES.md`, the root `CLAUDE.md` and the root `README.md` (performed at `/feature-end`)
   - [x] User review: user sees the final tree layout and the complete diff, and confirms it

*Only Sub-task 3 carries a code-review box, because it is the only sub-task
that produces code — Sub-tasks 1 and 2 are a relocation plus Markdown path
corrections. No sub-task before the last carries a user-review box: the
strategy places the single user review at the end, over the finished diff,
rather than after each step.*

**▶ NEXT:** Sub-task 4 (Final sign-off criteria)

> Run `/feature-checkpoint` after each sub-task completes.

## Review record

- 2026-08-12 — Spec reviewed by `feature-spec-reviewer`, two passes (the run's cap). Pass 1: VERDICT: NEEDS WORK, 1 MAJOR + 3 MINOR, all `[rewrite]`, all applied. Pass 2: VERDICT: NEEDS WORK, 1 MAJOR + 3 MINOR + 1 SUGGESTION, all `[rewrite]`, all applied after the cap was reached and so unverified by a further pass. No `[decision]` finding at either pass — nothing was left for the user to settle. Presented to the user for sign-off.
- 2026-08-12 — Spec corrected during design (factual, not a change of intent, so not put to the user as an amendment): the spec claimed the fixture tree contains "an executable shell script" whose mode must be preserved. It does not — all 58 files are mode `100644`, including `block-git-push.sh`. The false claim was removed and the hidden-file emphasis kept, since the `.claude/` subtree it guards against losing is real.
- 2026-08-12 — Design reviewed by `feature-design-reviewer`, two passes (the run's cap). Pass 1: VERDICT: NEEDS WORK, 1 MAJOR + 3 MINOR + 1 SUGGESTION, all `[rewrite]`, all applied. Pass 2: VERDICT: NEEDS WORK, 1 MAJOR + 1 MINOR, both `[rewrite]`, both applied after the cap was reached and so unverified by a further pass. No `[decision]` finding at either pass. Presented to the user for sign-off.
- 2026-08-12 — `## Sign-off strategy` (Documentation) corrected during design: the bar agreed at `/feature-spec` said no user-facing documentation was expected to change. Design established that the root `README.md`'s `## Documentation` table lists top-level areas and so needs a `tests/` row, making that false. The strategy text and Sub-task 2's criteria were widened accordingly; flagged to the user in the design report.
- 2026-08-12 — Sub-task 2's repository-wide search found 7 files under `features/tmp/` that `## Design`'s audit missed (the audit's search excluded `--exclude-dir=tmp`). Not a spec or design amendment — resolved as scope, with the user, per Sub-task 2's "Verification performed": `features/tmp/` is git-ignored/untracked and outside the audit's remit, the user was already told at spec time these leftovers existed and were out of scope, and the material's disposition was already deliberately deferred by `clear-specs-and-designs` (#57). Excluded, left untouched.
- 2026-08-12 — **Spec amended during implementation, with the user's approval**, after Sub-tasks 1–2 were complete. Added requirement 6: the regression harness in the git-ignored `features/tmp/regression/` is promoted into `tests/devproc/harness/`. Why it changed: Sub-task 2 surfaced that the harness scripts hardcode the now-dead `devproc/tests/` path, and the user judged that now a tests directory exists, the harness belongs in it — reversing, for the harness only, the "out of scope" resolution recorded earlier in this feature and the deferral inherited from `clear-specs-and-designs` (#57). Requirement 5 was narrowed from "Nothing else moves" to "Nothing else leaves `devproc/`" to accommodate it. Scope of the amendment was settled with the user on three points: promote as a rewrite rather than a relocation (the scripts' case lists have drifted from the fixtures and `cd /workspace` is hardcoded); track only the script and its `README.md`, leaving the ~30 recorded run outputs behind; and write run output to a git-ignored `out/`. `features/tmp/review/` remains out of scope.
- 2026-08-12 — `## Sign-off strategy` (Code review) raised during implementation, as a consequence of the requirement 6 amendment: from "None — the change contains no code" to one `/review-component` pass over `tests/devproc/harness/`. The original bar was set when the feature was a file move plus Markdown edits; the harness rewrite makes it a feature that ships a shell script.
- 2026-08-12 — Sub-task 3's `/review-component` pass over `tests/devproc/harness/` reviewed `run.sh`, `README.md`, and `.gitignore`. Findings: 1 MAJOR (general — exit codes captured per-case but never aggregated, so the script reported success even when cases failed or timed out), plus minors from all three agents (simplicity, general, nitty) covering a glob-metacharacter bypass in membership checks, no stale-`out/`-file cleanup, a silently-ignored missing suite directory, no upfront `claude`/`mkdir` failure handling, and naming/comment/README-gap issues. No architectural findings. All code-level findings applied across the review's convergence passes; two low-priority SUGGESTION-level items left as-is per proportionality. Full list in Sub-task 3's "Verification performed".
- 2026-08-12 — **Feature closed.** Close-out docs review by `docs-structure-reviewer`, two passes: pass 1 returned 3 MAJOR + 5 MINOR + 2 SUGGESTION, pass 2 confirmed all resolved and returned 4 MINOR + 2 SUGGESTION introduced by the fixes themselves, all applied. The MAJOR findings were a missing `tests/README.md` index (the root `README.md` link bottomed out in a bare directory listing), a one-directional harness↔suite linkage (no suite README mentioned the harness, so the reader most likely to want it would hand-run every case), and — the sharpest — `devproc/README.md` naming `tests/devproc/…` paths that do not exist in a consumer's install, the mirror image of the problem this feature set out to fix. One reviewer finding was deliberately not applied: annotating the `internal-docs-prune` entry in `features/COMPLETED.md` as superseded, which the spec's historical-record rule forbids; the reviewer accepted the reasoning on re-review and recorded the distinction (a document's frame, not a sentence's tense, decides whether an untouched reference makes a live claim). Feature complete 2026-08-12.
