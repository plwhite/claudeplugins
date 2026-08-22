# Support workspaces that are not git repositories — Feature Plan

## Handoff

**Last updated:** 2026-08-22
**Session summary:** Sub-task 1 completed — `### The workspace` subsection added to the canonical `FEATUREMODEL.md`, the `features/tmp/` bullet reworded to describe git-ignoring as a tracked-workspace behaviour rather than a property of the directory, and the installed copy refreshed byte-for-byte (`diff` clean). Sub-task 2 completed — `/feature-init` step 5 gained the `git rev-parse --is-inside-work-tree` guard, its heading and embedded `features/tmp/README.md` template reworded, this repo's installed `features/tmp/README.md` matched (byte-identical, verified), and `NOTES.md`'s opening entry corrected to record that a CLI invocation runs the skill. Sub-task 3 completed — `feature-spec/SKILL.md` step 1a rewritten to state the remote is read inside the repository the issue belongs to, with the five-case resolution rule, mirrored to the plugin copy and verified live: a real `/feature-spec issue 60` run against an untracked scratch workspace resolved the sole nested repository, ran `git remote -v` there (not at the workspace root), and named the resolved repository before fetching the issue. Sub-task 4 completed — the remaining wording swept across `devproc/README.md`, `docs/workflow.md`, `CLAUDE.md`, and the `$CLAUDE_PROJECT_DIR` glosses (plus two occurrences found outside the original list); file-by-file record in sub-task 4.
Sub-task 5's consistency sweep has since been performed independently of sub-task 4's own record and is ticked; its classification of all hits across seven live files (plus `tests/`) is written under sub-task 5.
**Sub-task in progress:** None — all sub-tasks complete.
**First action next session:** None — feature closed via `/feature-end` on 2026-08-22. The user reviewed and confirmed the branch diff, and the close-out `docs-structure-reviewer` review ran and its findings were applied.
**Open questions / decisions pending:** None
**Dead ends to avoid:** Do not move the `.gitignore` `/feature-init` writes to "the workspace root". An earlier design draft did, to cover a workspace sitting in a subdirectory of a repository; the user ruled that shape out (the workspace is either the repository root or not a repository at all), so the location is deliberately unchanged. See `## Design` → "Where the `.gitignore` goes: unchanged".

## Requirements

From issue #60, "Dull gitignore issues when features not in tracked repo"
(verbatim):

> The basic problem is that the directory "features/tmp" is assumed to be in the
> repo; but in some cases it is not (as the features directory is not tracked).
>
> As a result, the skills say that `features/tmp` has a `.gitkeep` file, and is
> git ignored, none of which should be done if the features directory is not git
> controlled.
>
> The fix is almost certainly to add a few lines to skills / feature model to say
> "In some cases, the workspace is not a git repo, but a directory with a git
> repo beneath it. In that case, things like features and CLAUDE.md etc. are at
> the top of the workspace not in the git repo". That should be trivial, but
> needs a little wording care.

The issue has no comments. Nothing further was supplied, and nothing was staged
in `features/tmp` for this feature.

## Spec

### What this feature is for

Every `devproc` skill today assumes that the directory Claude is started in — the
one holding `CLAUDE.md`, `NOTES.md` and `features/` — is itself a git repository.
That assumption is baked into `/feature-init`, which writes git-specific files,
and into the prose of the feature model and the user docs, which describe
`features/tmp` as git-ignored as a plain fact.

There is a second, legitimate shape that breaks the assumption: **the workspace
is a plain directory that is not under git control, and the code being worked on
sits in one or more git repositories underneath it.** Feature tracking —
`CLAUDE.md`, `NOTES.md`, `features/` — then lives at the top of the workspace,
outside every repository. In that shape `/feature-init` produces a `.gitignore`
that no git repository will ever read, the documentation tells the user
something untrue about their own files, and `/feature-spec` tells itself to run
`git remote -v` without saying where — an instruction that only makes sense at a
workspace which is itself a repository.

The feature's purpose is to make the plugin correct in both shapes: state that
both exist, make the git-specific *actions* conditional on the workspace
actually being under git control, and hedge the git-specific *wording* so it is
accurate either way.

### Terms used below

- **Workspace** — the directory Claude is run in, and the root against which
  `CLAUDE.md`, `NOTES.md` and `features/` are located. Container mode mounts
  this directory at `/workspace` (see `docs/container.md`); the term itself is
  introduced here for the plugin's documentation.
- **Tracked workspace** — a workspace that *is* the root of a git repository.
  This is the shape everything currently assumes, and it stays the common case.
- **Untracked workspace** — a workspace that is not a git repository, holding
  one or more repositories beneath it; typically a container or scratch
  directory. This is the shape the feature adds support for.

These two are exhaustive: either the workspace is the repository root, or it is
not a repository but contains one. A workspace that is a *subdirectory* of a
repository is not a shape this project has, and nothing here is built to handle
it.

### What the feature must do

1. **State that both workspace shapes exist.** The feature model
   (`FEATUREMODEL.md`) must say, in a few lines, that a workspace is usually a
   git repository but need not be — it may be a plain directory with one or more
   git repositories beneath it — and that in either case `CLAUDE.md`, `NOTES.md`
   and `features/` live at the top of the workspace, not inside a nested
   repository. This is the "few lines to skills / feature model" the issue asks
   for, and it is the single place the rest of the change can point at.

2. **`/feature-init` must not write git files into an untracked workspace.**
   Step 5 of `feature-init/SKILL.md` currently instructs the skill to ensure
   `.gitignore` "at the repo root" carries the `features/tmp/*` and
   `!features/tmp/README.md` rules, unconditionally. After the change, those
   rules must be written when the workspace is tracked, and in an untracked
   workspace the git half of step 5 must be skipped entirely: the skill writes
   no `.gitignore`, and it does not inspect or comment on rules an earlier run
   may already have left in one. **In an untracked workspace the skill neither
   reads nor edits `.gitignore` at all** — settled with the user at spec time,
   on the grounds that a file the user maintains for their own reasons is not
   the skill's to tidy, and that a report about inert rules is noise. Everything
   else step 5 does — creating `features/tmp/` and its `README.md` — is
   unaffected, since it is not git-specific.

   How the skill decides which shape it is in is a design question, not a spec
   one; the spec fixes only the observable behaviour above.

3. **Documentation must not assert that `features/tmp` is git-ignored.** Every
   place that states this as unconditional fact must be reworded so it holds in
   both shapes — describing the ignore rules as what happens in a tracked
   workspace rather than as a property of the directory. The known occurrences
   are:

   - `devproc/skills/feature-init/FEATUREMODEL.md` (canonical) and the installed
     copy at `features/FEATUREMODEL.md` — the `features/tmp/` bullet under
     "Documents to support the model";
   - `devproc/skills/feature-init/SKILL.md` — step 5's heading ("Ensure the tmp
     scratch directory exists and is git-ignored"), which states the outcome
     unconditionally, as distinct from the `features/tmp/README.md` template the
     step embeds. The step's "`.gitignore` at the repo root" instruction needs
     no rewording: in a tracked workspace the repository root *is* the workspace
     root, so the phrase is already correct;
   - the `features/tmp/README.md` template inside `feature-init/SKILL.md`, and
     this repository's own installed `features/tmp/README.md`;
   - `devproc/README.md` — four mentions: the skill table, the `## Setup`
     paragraph, the feature-tracking table's `features/tmp/` row, and the
     `### feature-init` reference section;
   - `docs/workflow.md` — the `features/tmp` input-route section;
   - the root `CLAUDE.md` — the `feature-init` bullet;
   - the root `README.md` — the `features/` table row, if its wording implies
     tracking.

   The list is what a search found at spec time and is the starting point, not a
   closed set: the delivered change must leave no unconditional claim in any
   live skill, agent, or documentation file, whether listed above or not.
   Historical prose in `features/plans/`, `features/COMPLETED.md`, `NOTES.md`
   and `.claude/agent-memory/` records what was true when it was written and is
   not rewritten.

4. **`/feature-spec` must say where to run `git remote -v`.** Step 1a of
   `feature-spec/SKILL.md` says "Run `git remote -v` and parse the owner/repo
   from the fetch URL", without saying where. In a tracked workspace the
   omission is harmless because there is only one place it could mean. In an
   untracked workspace the workspace root has no remote to report, and the
   instruction as written points at the one directory that cannot answer.

   **This is a wording fix, not a behaviour change.** In practice Claude works
   out that the command has to run inside the repository, and the issue route
   does not actually fail today. The requirement is to make that explicit
   rather than leave it to be re-derived: state that the remote is read inside
   the repository the issue belongs to, not at the workspace root.

   *Proposed:* the instruction also covers which repository, since an untracked
   workspace may hold several — exactly one repository beneath the workspace, use
   it; more than one, ask the user rather than guess; either way, say which
   repository the remote was read from.

5. **Fix the two "repository root" glosses of `$CLAUDE_PROJECT_DIR`.**
   `devproc/agents/docs-structure-reviewer.md` and
   `devproc/skills/internal-docs-prune/SKILL.md` each gloss
   `$CLAUDE_PROJECT_DIR` as "the repository root". In an untracked workspace that
   gloss is wrong — the variable is the workspace root, which may contain
   repositories rather than be one. The behaviour these two describe (resolve
   paths against `$CLAUDE_PROJECT_DIR`, not the current directory) is already
   correct; only the parenthetical needs changing.

6. **Keep the canonical and installed feature-model copies in step.** The
   canonical model text is `devproc/skills/feature-init/FEATUREMODEL.md`; this
   repository dogfoods the plugin and so also carries an installed copy at
   `features/FEATUREMODEL.md`. Per the maintainer rule in the root `CLAUDE.md`,
   the canonical file is edited and `/feature-init` is re-run to refresh the
   installed copy — the installed copy is never hand-edited. The delivered
   change must leave the two identical.

7. **Change nothing about the tracked-workspace behaviour.** In a workspace that
   is a git repository, `/feature-init` must produce exactly what it produces
   today, including the ordering rule that `features/tmp/*` precedes
   `!features/tmp/README.md`, and the idempotency of re-running it. This
   feature adds a second path; it does not alter the existing one.

### Points settled at spec time

- **`/feature-init` leaves a stray `.gitignore` alone.** See requirement 2:
  in an untracked workspace the skill neither reads nor edits `.gitignore`,
  including one an earlier run of the current skill created. The user chose this
  over removing the rules or reporting them.

- **The issue's `.gitkeep` claim does not hold.** The issue says "the skills say
  that `features/tmp` has a `.gitkeep` file". A repository-wide search finds
  `.gitkeep` only in historical prose in
  `features/plans/spec-requirements-input.md` — the plan for the feature that
  introduced `features/tmp`, which considered a `.gitkeep` and rejected it in
  favour of the tracked `README.md`. No skill, agent, or document instructs
  anyone to create one. There is therefore nothing to remove on that count, and
  the historical plan text is a record of a past decision and stays as written.
  The `.gitignore` half of the issue's complaint is real and is requirement 2.

### Out of scope

*Proposed:* the code-review skills are left alone. `/review-branch` runs
`git diff --name-only main` and so assumes it is being run inside a repository.
The same technique requirement 4 applies to `/feature-spec` — resolve the
repository first, then run the git command there — would plausibly work for
them too, but a review scoped to a branch raises questions this feature does not
need to answer (which repository, which base branch, what happens when several
repositories have changes), and the issue asks for a wording fix. Deferred, not
dismissed.

## Sign-off strategy

- **Testing** — no automated tests; there is no test harness for skill prose and
  the existing one under `tests/devproc/` covers reviewer agents only. Manual
  verification instead, and it must be done in both shapes: run `/feature-init`
  in a scratch **untracked** workspace that contains a git repository beneath it,
  and in a scratch **tracked** workspace, confirming that the `.gitignore` rules
  appear in the tracked case and nowhere in the untracked case, that
  `features/tmp/README.md` is created in both, and that a re-run in the tracked
  case is idempotent. Requirement 4 is verified in the same untracked scratch
  workspace: `/feature-spec` resolves a real GitHub issue reference there and
  names the repository it read the remote from. (Since requirement 4 is a
  wording fix to behaviour that already works, this run confirms the instruction
  did not break it, rather than demonstrating something new.) The observed
  output of both runs is recorded in the plan file.

- **Documentation** — full user-facing and internal docs update covering
  requirements 3, 4 and 5: `devproc/README.md`, `docs/workflow.md`, the root
  `README.md` and `CLAUDE.md`, the canonical and installed `FEATUREMODEL.md`,
  the two `$CLAUDE_PROJECT_DIR` glosses, and a description of how
  `/feature-spec` resolves the repository for an issue reference.

- **Consistency sweep** (feature-specific) — a repository-wide search for
  unconditional git-tracking claims about `features/` and `features/tmp`
  (`git-ignored`, `gitignore`, `repo root`, `repository root`) returns only hits
  that are correct in both workspace shapes, or historical prose in
  `features/plans/`, `features/COMPLETED.md`, `NOTES.md`, and
  `.claude/agent-memory/`, which records what was true when it was written and is
  not rewritten. Run once by the implementing agent, after every wording change
  has landed and before `/feature-end`; every remaining hit is classified in the
  plan file. This is a separate sign-off because a scattered-wording change fails
  by omission, and no other criterion would catch a missed copy.

- **Code review** — None. The change is prose only: skill, agent, and
  documentation Markdown, with no executable code. If the design turns out to
  need a change to a shell script under `bin/` or `docker/`, this bar is raised
  to one agent `/review-branch` before `/feature-end` rather than left at none.

- **Docs review** — one `docs-structure-reviewer` pass over the updated
  documentation, at the end of the feature (performed at `/feature-end`), with
  its findings applied or explicitly declined.

- **User review** — the user reads the full branch diff and confirms the wording,
  before `/feature-end` runs. The issue asks explicitly for "a little wording
  care", so the wording itself is what the user is signing off, not merely the
  behaviour.

## Design

### Overview

The whole change is prose. Nothing executable is added, and no file is created
or deleted — the existing Markdown files listed in `### Files this touches` are
edited, plus the installed `FEATUREMODEL.md` copy, which is refreshed from the
canonical one rather than hand-edited.

It works in three moves:

1. **Define the concept once.** `FEATUREMODEL.md` gains a short `### The
   workspace` subsection naming the two shapes and stating that feature tracking
   lives at the top of the workspace either way. Because the model is imported
   into every project's `CLAUDE.md`, this text is in context for every skill run,
   so the skills that follow can refer to the distinction instead of re-arguing
   it. **Not `/feature-init` itself**, which is the skill that installs the model
   and adds the import — on a fresh project neither exists while it runs, and an
   import added mid-session does not load. Its guard must therefore be stated in
   full in step 5, never as a back-reference to the model.

2. **Make the two git-touching instructions say where they act.** Both failures
   in the spec are the same fault: an instruction that names a git operation but
   not the directory it applies to, which reads unambiguously only when the
   workspace happens to be a repository. `/feature-init` step 5 gains a guard —
   is the workspace a repository at all? — around the `.gitignore` handling it
   already has. `/feature-spec` step 1a gains a sentence saying the
   remote is read inside the repository the issue belongs to, and how to pick
   that repository when the workspace holds more than one.

3. **Sweep the wording.** Every remaining place that describes `features/tmp` as
   git-ignored, or glosses `$CLAUDE_PROJECT_DIR` as "the repository root", is
   reworded so it is true in both shapes.

The order matters only between move 1 and the rest: the model text is what the
later edits point at, so it is written first. Sub-tasks 2 and 3 are independent
of each other.

### How the skill tells the two shapes apart

`/feature-init` runs `git rev-parse --is-inside-work-tree` in the workspace root.
Exit status 0 with `true` on stdout means a **tracked** workspace; anything
else — a non-zero exit, `false`, or `git` not being installed — means an
**untracked** one. Verified in both shapes during design: `true` at a repository
root, `fatal: not a git repository` (exit 128) at a plain directory holding one.

*Why this and not the alternatives.* Testing for a `.git` directory would work
for the two shapes that exist, but misses a `.git` *file* — what git writes for
worktrees and submodules — so a legitimately tracked workspace would be read as
untracked. `git status` answers the question too, but is expensive on a large
repository and fails for reasons unrelated to it. `git rev-parse
--is-inside-work-tree` is the purpose-built query, and its failure mode is the
safe one: every way it can fail lands on "untracked", which means the skill
writes nothing. The cost of a false "untracked" is a missing `.gitignore` the
user can add in a second; the cost of a false "tracked" is a file written into a
directory the user did not expect it in.

*One caveat worth stating.* `--is-inside-work-tree` is true anywhere inside a
working tree, not only at its root, so it answers a slightly weaker question
than the spec's "is the root of a git repository". Across the two shapes the
spec declares exhaustive the two questions coincide, which is why comparing
`git rev-parse --show-toplevel` against the workspace root is not needed. In the
ruled-out nested shape the skill would write `.gitignore` at the outer
repository's root — which is what it does today, so nothing here regresses it.

### Where the `.gitignore` goes: unchanged

Nowhere. Step 5's existing "`.gitignore` at the repo root" stands as written.
Because a tracked workspace is by definition the repository root, that phrase
and "the workspace root" name the same directory, and the file the skill writes
in the tracked case is byte-identical to today's — spec requirement 7 satisfied
by not touching it.

*This was very nearly designed differently.* An earlier draft moved the
instruction to "the workspace root" to cover a workspace sitting in a
subdirectory of a repository, where the two phrases diverge and `features/tmp/*`
at the repo root would match nothing. The user ruled that shape out: the
workspace is either the repository root or not a repository at all. Designing
for the third case would have bought a behaviour change, a spec amendment and a
test case, all for a configuration this project does not have. Recorded here
because the reasoning is not obvious from the result, and a later reader might
otherwise re-derive the same wrong turn.

### Which repository `/feature-spec` reads the remote from

Spec requirement 4 is explicit that this is a wording fix — the behaviour
already happens — so the design's job is to write down the rule that is
currently re-derived each time:

- **Tracked workspace** — run `git remote -v` in the workspace, as today.
- **Untracked workspace, exactly one git repository directly beneath it** — run
  it there.
- **Untracked workspace, more than one** — ask the user which repository the
  issue belongs to. Guessing is the one outcome worth ruling out, since the
  wrong guess produces a plausible spec built from the wrong issue.
- **Untracked workspace, none found** — ask the user for the `owner/repo`
  directly. The spec's proposal did not cover this case; it falls out of the same
  principle (ask rather than guess) and costs one sentence.
- **A repository is found, but has no GitHub remote** — ask for the `owner/repo`
  directly, as in the none-found case. Not exotic: a locally-created repository,
  a clone from a local path, or a remote on a non-GitHub host all resolve to
  "exactly one repository beneath" and then yield nothing `gh` can use.

In every case the skill states which repository it read the remote from, so a
wrong resolution is visible in the transcript rather than silent.

### What is *not* being built

No detection helper, shared snippet, or script. The guard appears in exactly one
skill (`/feature-init`) and the repository-resolution rule in exactly one other
(`/feature-spec`); factoring two instructions into a shared asset would add a
file for no reader's benefit. The code-review skills keep their unqualified
`git diff` for the reasons the spec's `### Out of scope` gives.

### Files this touches

| File | What changes | Sub-task |
|---|---|---|
| `devproc/skills/feature-init/FEATUREMODEL.md` | new `### The workspace` subsection; `features/tmp/` bullet reworded | 1 |
| `features/FEATUREMODEL.md` | refreshed from the canonical copy — never hand-edited | 1 |
| `devproc/skills/feature-init/SKILL.md` | step 5: the guard, the heading, and the embedded `features/tmp/README.md` template (the `.gitignore` location is unchanged) | 2 |
| `features/tmp/README.md` | this repo's installed copy of that template | 2 |
| `devproc/skills/feature-spec/SKILL.md` | step 1a: where the remote is read from | 3 |
| `devproc/README.md` | four `git-ignored features/tmp` mentions | 4 |
| `docs/workflow.md` | the `features/tmp` input-route section, and the `git remote -v` sentence at the issue route | 4 |
| `README.md` | the `features/` table row — check only; no tracking claim found at design time | 4 |
| `CLAUDE.md` | the `feature-init` bullet | 4 |
| `devproc/agents/docs-structure-reviewer.md` | `$CLAUDE_PROJECT_DIR` gloss | 4 |
| `devproc/skills/internal-docs-prune/SKILL.md` | `$CLAUDE_PROJECT_DIR` gloss | 4 |

### Working on skill prose in this container

Two environment facts govern how this feature is built and tested. Both were
verified during design; neither is guessable from the repository.

- **The `Skill` and `Agent` tools load `devproc:*` from
  `/home/claude/claudeplugins/devproc`, not from `/workspace/devproc`.** That
  directory is a separate baked copy registered as the `local-plugins`
  marketplace — not a symlink — and it is invisible to git (recorded in
  `NOTES.md`, "`/home/claude/claudeplugins` is a live plugin copy"). The
  deliverable is `/workspace/devproc`; the plugin copy is only a runtime. So
  **before any live run of a changed skill, the edited files must be mirrored
  into the plugin copy**, or the run exercises the old prose and passes or fails
  for reasons unrelated to the change. The plugin copy is never the source of a
  refresh or a diff.

- **`/feature-init` cannot be launched by the model, but can be run from the
  command line.** Its frontmatter carries `disable-model-invocation: true`, so
  the `Skill` tool errors out (`NOTES.md` records the Skill-tool half). A CLI
  invocation is a *user* invocation and is not blocked: `claude -p
  "/feature-init"` with the working directory set to a scratch workspace runs it
  end to end. This was confirmed during design — the run is described under
  `### Verifying it` below — which is what makes sub-task 2's Testing box
  performable as a real run rather than a hand-trace.

### How the installed `FEATUREMODEL.md` is refreshed

Sub-task 1 edits the canonical `devproc/skills/feature-init/FEATUREMODEL.md` and
must then bring `features/FEATUREMODEL.md` back into step (spec requirement 6).
The refresh is done by **hand-applying `/feature-init` step 1b — a byte-for-byte
copy of the canonical file in `/workspace/devproc` over the installed one** —
which is precisely what that step instructs, and is the mechanism `NOTES.md`
already records for exercising `feature-init` template changes.

*Why not run the skill.* `claude -p "/feature-init"` would work, but at sub-task
1 it would copy from whatever the plugin copy holds, and mirroring the edit there
purely to copy a file back into `/workspace` adds a step whose only effect is to
create a second place the refresh can go wrong. A one-file copy has no such
failure mode. The user can run `/feature-init` themselves instead, but **only
after mirroring the edited `devproc/` into the plugin copy** — the skill copies
`FEATUREMODEL.md` from its own base directory, which is the installed plugin,
not the repo, so an unmirrored run silently restores the old model text
(`NOTES.md`, "`/feature-init` copies from the installed plugin, not the repo").

### Verifying it, given there is nothing to unit-test

Skill prose has no test harness — `tests/devproc/` covers reviewer agents only —
so the Testing bar is met by running the changed skills for real, in two scratch
workspaces built under `/tmp` (outside this repository, so a stray `.gitignore`
cannot pollute it):

- an **untracked** workspace: a plain directory containing a git repository
  beneath it. For sub-task 2 a bare `git init` is enough. **For sub-task 3 the
  repository beneath must have a GitHub remote** — clone this repository from
  GitHub, or `git init` plus `git remote add origin
  https://github.com/<owner>/<repo>.git` — because `git remote -v` in a bare
  `git init` repository prints nothing, leaving step 1a no fetch URL to parse;
- a **tracked** workspace: a `git init`-ed directory.

Each run is `claude -p "/feature-init"` (or `"/feature-spec …"`) executed over
Bash with the working directory set to the scratch workspace — the same
technique `tests/devproc/harness/run.sh` uses to run an agent outside the
current session. The edited `devproc/` is mirrored into
`/home/claude/claudeplugins/devproc` first, per `### Working on skill prose in
this container`; without that the runs exercise the unchanged skill.

`/feature-init` runs in both workspaces (sub-task 2) and `/feature-spec`
resolves a real issue reference in the untracked one (sub-task 3). Observed
output goes into the plan file at the following `/feature-checkpoint`.

**The baseline is already recorded.** During design, `claude -p
"/feature-init"` was run in exactly the untracked scratch workspace described
above, against the *unmodified* skill. It created `.gitignore` at the workspace
root containing `features/tmp/*` and `!features/tmp/README.md` — reproducing
issue #60's complaint exactly, in a directory git will never read. The same run
also confirmed `git rev-parse --is-inside-work-tree` returns `fatal: not a git
repository` (exit 128) at that workspace root and `true` inside the repository
beneath it, so the guard in `### How the skill tells the two shapes apart`
discriminates the two shapes as designed. Sub-task 2's test is therefore a
before/after against a known-bad baseline, not a first look.

## Sub-tasks

1. ✓ (2026-08-22) **Name the two workspace shapes in the feature model** — a `### The
   workspace` subsection *and* a reworded `features/tmp/` bullet in the canonical
   `FEATUREMODEL.md`, then step 1b hand-applied so the installed copy matches
   (spec requirements 1, 6, and `FEATUREMODEL.md`'s share of 3).
   - [x] Documentation: the canonical `FEATUREMODEL.md` carries a `### The workspace` subsection naming both shapes and stating that `CLAUDE.md`, `NOTES.md` and `features/` sit at the top of the workspace in either case, and its `features/tmp/` bullet no longer asserts git-ignoring unconditionally
   - [x] Testing: `diff devproc/skills/feature-init/FEATUREMODEL.md features/FEATUREMODEL.md` reports no differences

   **Re-verified at `/feature-end` (2026-08-22).** The close-out
   `docs-structure-reviewer` pass found the twins had since diverged: an
   "exhaustive" sentence had been hand-added to the *installed*
   `features/FEATUREMODEL.md`, which the maintainer rule forbids — the next
   `/feature-init` would have silently deleted it, and every consumer project
   would have received a model text missing the narrowing the user approved.
   Fixed at the canonical source: the `### The workspace` subsection was
   rewritten there (lead sentence plus two bullets, moved above
   `### Sign-off criteria` so the definition precedes its uses) and copied over
   the installed file. `diff` clean again.

2. ✓ (2026-08-22) **Make `/feature-init` step 5 conditional on the workspace being tracked** —
   the `git rev-parse` guard, so the existing `.gitignore` handling runs only in
   a tracked workspace and `.gitignore` is neither read nor written in an
   untracked one, plus step 5's heading, its embedded `features/tmp/README.md`
   template, and this repo's installed copy of that template (spec requirements
   2, 7, and the `feature-init` entries of 3).
   - [x] Documentation: step 5's heading, its embedded `features/tmp/README.md` template, and this repo's installed `features/tmp/README.md` all describe the ignore rules as what happens in a tracked workspace rather than as a property of the directory; and `NOTES.md`'s opening `feature-init` entry records that `claude -p "/feature-init"` runs the skill end to end, superseding its current hand-apply-only advice
   - [x] Testing: `claude -p "/feature-init"` run in both scratch workspaces against the mirrored plugin copy — the `.gitignore` rules present in the tracked case, no `.gitignore` created or modified in the untracked case (against the recorded pre-change baseline, which did create one), `features/tmp/README.md` created in both, and a second tracked run leaving the file unchanged; output recorded below

   **Test runs (2026-08-22).** Edited `devproc/skills/feature-init/SKILL.md` was
   mirrored into `/home/claude/claudeplugins/devproc/skills/feature-init/SKILL.md`
   before each run (`diff` confirmed identical after the copy). Two scratch
   workspaces were built under `/tmp`, outside this repository:
   - **untracked** — a plain directory (not itself git-init-ed) with an unrelated
     `git init`-ed `repo/` beneath it, plus a minimal `CLAUDE.md`.
   - **tracked** — a `git init`-ed directory with a minimal `CLAUDE.md`.

   Each run was `claude -p --permission-mode bypassPermissions "/feature-init"`
   with the working directory set to the scratch workspace.

   *Untracked run* — the skill's own summary: "Skipped `.gitignore` handling:
   the workspace root (.../untracked, where `CLAUDE.md` lives) is not itself a
   git repository — `git rev-parse --is-inside-work-tree` fails there — even
   though the nested `repo/` subdirectory is its own unrelated git repo." A
   filesystem check (`find . -name .gitignore -not -path "*/.git/*"`) confirmed
   no `.gitignore` was created anywhere in the workspace, and
   `features/tmp/README.md` was created with the reworded template text. This is
   the reverse of the recorded pre-change baseline, which created a `.gitignore`
   in exactly this shape.

   *Tracked run* — the skill's summary confirmed `.gitignore` was added with
   `features/tmp/*` / `!features/tmp/README.md`, and a filesystem check showed
   the file's content was exactly those two lines, in that order, plus
   `features/tmp/README.md` created with the reworded template text.

   *Tracked, second run (idempotency)* — `.gitignore`'s md5 was recorded before
   a second `/feature-init` run and re-checked after: unchanged
   (`9b2efb002125422626ead25dab60b727`). The skill's summary: "`.gitignore`
   already has the two required lines in the correct order. Nothing to change."

   Both scratch directories were removed after the runs.

3. ✓ (2026-08-22) **State where `/feature-spec` reads the git remote** — step 1a says the
   remote comes from the repository the issue belongs to, and gives the
   one/several/none resolution rule (spec requirement 4).
   - [x] Documentation: `feature-spec/SKILL.md` step 1a states that the remote is read inside the repository the issue belongs to, and gives the rule for all five cases — tracked workspace, exactly one repository beneath, more than one (ask), none found (ask), and one found with no GitHub remote (ask)
   - [x] Testing: `claude -p` runs `/feature-spec` on a real GitHub issue reference from the untracked scratch workspace — whose nested repository has a GitHub remote, per `### Verifying it` — against the mirrored plugin copy, and it names the repository it read the remote from; output recorded in the plan file

   **Test run (2026-08-22).** Edited `devproc/skills/feature-spec/SKILL.md` was
   mirrored into `/home/claude/claudeplugins/devproc/skills/feature-spec/SKILL.md`
   (`diff` confirmed identical after the copy). An **untracked** scratch workspace
   was built under `/tmp`, outside this repository: a plain directory (not
   itself git-init-ed) holding a minimal `CLAUDE.md`, with a `repo/`
   subdirectory that was `git init`-ed and given
   `git remote add origin https://github.com/plwhite/claudeplugins.git` — the
   only repository beneath the workspace, and one with a real GitHub remote.
   `claude -p --permission-mode bypassPermissions "/feature-init"` was run there
   first to install `features/FEATUREMODEL.md` and the `CLAUDE.md` import (its
   own summary confirmed `.gitignore` handling was skipped, since the workspace
   root itself is not a git repository), then
   `claude -p --permission-mode bypassPermissions "/feature-spec issue 60
   --no-review"`.

   The run succeeded: it fetched the real issue #60 content and produced a
   complete spec at `features/plans/untracked-workspace-fix.md` in the scratch
   workspace. A second run with `--verbose --output-format stream-json`
   captured the literal step 1a transcript, confirming both the resolution rule
   and the "name the repository" requirement:

   > Found exactly one repository beneath the workspace — `repo/`. Let me check its GitHub remote.
   > `[Bash] cd /tmp/untracked-fs-test2/repo && git remote -v`
   > The remote resolves to `plwhite/claudeplugins`. Fetching issue #60 from there.
   > `[Bash] gh issue view 60 --repo plwhite/claudeplugins --comments`

   `git remote -v` was run inside the nested repository, not at the workspace
   root, the owner/repo was parsed from the fetch URL, and the resolved
   repository was named before the issue was fetched — exactly the case-2
   behaviour step 1a now states. Both scratch workspaces were removed after the
   runs.

4. ✓ (2026-08-22) **Sweep the remaining wording** — the four `devproc/README.md` mentions,
   `docs/workflow.md` (both the `features/tmp` route and its `git remote -v`
   sentence), the root `README.md` and `CLAUDE.md`, and the two
   `$CLAUDE_PROJECT_DIR` glosses (spec requirements 3 and 5).
   - [x] Documentation: every occurrence named in spec requirements 3 and 5 — other than the two `FEATUREMODEL.md` copies, which sub-task 1 owns — either reworded to hold in both workspace shapes or recorded as already correct, and the docs describe how `/feature-spec` resolves the repository; the file-by-file list is recorded in the plan file

   **File-by-file record (2026-08-22).**

   *Reworded:*
   - `devproc/README.md` — all four mentions: the `feature-init` skill-table row, the `## Setup` paragraph, the feature-tracking table's `features/tmp/` row, and the `### feature-init` reference section (including its "creating or updating `.gitignore` as needed" clause, now conditional on the workspace being a repository).
   - `CLAUDE.md` — the `feature-init` bullet under `## devproc plugin` (the `## Current status` section was not touched).
   - `docs/workflow.md` — the issue-route sentence: it now says the remote is read from the repository the issue belongs to (the workspace itself when the workspace is a repository, otherwise a repository beneath it, asking the user if ambiguous) instead of unconditionally naming `git remote -v` at "your repo". This is a user-facing summary; the full five-case resolution rule lives in `feature-spec/SKILL.md` step 1a (sub-task 3).
   - `devproc/agents/docs-structure-reviewer.md` and `devproc/skills/internal-docs-prune/SKILL.md` — the `$CLAUDE_PROJECT_DIR` gloss changed from "(the repository root)" to "(the workspace root)" in both; the described behaviour (resolve against `$CLAUDE_PROJECT_DIR`, never the current directory) is unchanged.
   - `devproc/agents/internal-docs-reviewer.md` (line 14) and `devproc/skills/internal-docs-prune/SKILL.md` (line 42) — found by the requirement-3 grep, outside the named list: both instructed the caller to "pass/call ... with the repository root" when scoping the reviewer over `CLAUDE.md`/`NOTES.md`/`.claude/rules/*.md`, which live at the workspace root, not necessarily a repository root. Both reworded to "the workspace root".

   *Checked, already correct — no change:*
   - `docs/workflow.md` — the `features/tmp` input-route section (the "From material staged in `features/tmp`" paragraphs). It makes no unconditional tracking claim: it calls `features/tmp` "a hand-off channel into the spec, not a place to track requirements" and refers only to the tracked `README.md`, which holds in both workspace shapes. (The task brief expected an edit here; grepping the live file found none of the four target patterns present, and `git diff`/`git log` confirm the file has not carried that wording since before this feature.)
   - `README.md` — the `features/` table row ("a `features/tmp/` staging area for requirements input") makes no tracking claim, as recorded at design time.

   *Grepped outside the expected list, found correct as-is (not reworded):*
   - `docs/container.md` — "locating the repo root" refers to the Docker build scripts finding this plugin's own repository for the build context; unrelated to the consumer-workspace concept.
   - `tests/devproc/harness/README.md`, `tests/devproc/feature-design-reviewer/README.md`, `tests/devproc/feature-spec-reviewer/README.md`, `tests/devproc/internal-docs-reviewer/README.md`, `tests/README.md` — all "repository root" / "git-ignored" mentions describe this repository's own (genuinely tracked) test harness and its `out/`/`features/tmp/regression/` directories, not a consumer project's workspace.
   - `CLAUDE.md` (tests directory bullet) — "git-ignored `out/`" is the harness's own output directory in this tracked repo; unrelated.
   - `features/tmp/README.md` — already correctly conditional ("Where the workspace is a git repository, contents are also git-ignored"), sub-task 2's work; left untouched.

   Final targeted grep (`git-ignored|gitignore|repo root|repository root`, live files only, excluding the historical/owned paths listed in the spec) shows no remaining unconditional claim.

5. **Final sign-off criteria** — end-of-feature gates for this feature, per
   `## Sign-off strategy`.
   - [x] Consistency sweep (agent): repository-wide search, run once after every wording change has landed and before `/feature-end`, for `git-ignored`, `gitignore`, `repo root`, `repository root` returns only hits correct in both shapes or historical prose in `features/plans/`, `features/COMPLETED.md`, `NOTES.md`, `.claude/agent-memory/`, or this feature's own `features/CURRENT.md` entry (which describes the defect being fixed); every remaining hit classified in the plan file
   - [x] Docs review (agent): `docs-structure-reviewer` over the updated docs, findings applied or explicitly declined (performed at `/feature-end`)
   - [x] User review: user reads the full branch diff and confirms the wording

   **Consistency sweep performed (2026-08-22), independently of sub-task 4's
   own record above.** `grep -rniE "git-ignored|gitignore|repo root|repository
   root" --include="*.md" .`, excluding the exempt historical paths, returns
   hits in seven live files. All classified:

   - `devproc/skills/feature-init/SKILL.md` (8) — step 5's reworded heading, the
     tracked/untracked guard itself, and the tracked-only `.gitignore` rules.
     Correct: every one sits inside or describes the guarded branch.
   - `devproc/README.md` (4) — all four reworded to "git-ignored in a tracked
     workspace". Correct in both shapes. (The wording was aligned to the model's
     defined vocabulary at `/feature-end`; the sweep saw the earlier
     "git-ignored when the workspace is a repository", equivalent in meaning.)
   - `devproc/skills/feature-init/FEATUREMODEL.md` and `features/FEATUREMODEL.md`
     (2 each, identical) — the new `### The workspace` subsection and the
     reworded `features/tmp/` bullet. Correct.
   - `CLAUDE.md` (2) — line 34's reworded `feature-init` bullet (correct); line
     80's "git-ignored `out/`" for `tests/devproc/harness/`, which is this
     repository's own tracked harness directory, not a consumer workspace.
     Correct as-is.
   - `features/tmp/README.md` (1) — "Where the workspace is a git repository,
     contents are also git-ignored". Correct.
   - `docs/container.md` (1) — the build scripts "locating the repo root" means
     this plugin repository, as the Docker build context. Unrelated to the
     workspace concept. Correct as-is.

   `tests/` was checked separately: all ten hits describe this repository's own
   tracked harness ("run from the repository root") or fixture directories used
   as a stand-in repository root by `internal-docs-reviewer`. None is a claim
   about a consumer workspace. Correct as-is.

   No unconditional claim remains in any live skill, agent, or documentation
   file.

**▶ NEXT:** None — feature complete.

Notes on the criteria above:

- **No code review box anywhere.** `## Sign-off strategy` sets Code review to
  None for the whole feature, because the change is Markdown only. If any
  sub-task turns out to need a change under `bin/` or `docker/`, the strategy
  says the bar rises to one agent `/review-branch` before `/feature-end`, and
  this sub-task list gains that box at the checkpoint where it happens.
- **No user review before sub-task 5.** The strategy's user review is a single
  reading of the full branch diff, and the wording only makes sense read
  together — a per-sub-task review would show the user the same sentences
  several times in different states.
- **Sub-task 4 carries no Testing box.** Its content is prose with no behaviour
  to exercise; what would be "testing" it is the consistency sweep, which is a
  feature-level gate in sub-task 5 because it can only run once every wording
  change has landed.

> Run `/feature-checkpoint` after each sub-task completes.

## Review record

- 2026-08-22 — Spec reviewed by `feature-spec-reviewer`: VERDICT: NEEDS WORK. Four `[rewrite]` findings applied (occurrence list re-derived from a fresh grep, "no unconditional claim anywhere" bounded to live artefacts, the `workspace` term's claimed precedent softened, the consistency sweep given a timing and performer). Both `[decision]` findings were then settled by the user and folded into the spec — `/feature-spec`'s `git remote -v` is in scope as new requirement 4 (run the command inside the repository, not the workspace, per the user's correction that it needs a repo rather than the workspace); and `/feature-init` neither reads nor edits `.gitignore` in an untracked workspace, saying nothing about rules an earlier run left. Sign-off strategy agreed as proposed. Presented to the user for sign-off.
- 2026-08-22 — Design reviewed by `feature-design-reviewer`, twice (the per-run cap). First pass: VERDICT: NEEDS WORK, three BLOCKING findings — two settled by experiment rather than by the user (`/feature-init` *can* be run as `claude -p "/feature-init"`; the container's plugin copy, not `/workspace/devproc`, is what skill runs load), one `[decision]` on the `.gitignore` location that the user resolved by ruling out the third workspace shape. Second pass: VERDICT: NEEDS WORK, all findings `[rewrite]` and all applied — the untracked scratch repository needs a GitHub remote for sub-task 3's test, a fifth repository-resolution case (repo found, no GitHub remote) added, the "run `/feature-init` yourself" aside corrected against the `NOTES.md` plugin-copy trap, the overview's "the model is in context for every skill run" qualified for `/feature-init` itself, Documentation boxes added to sub-task 3 and the `NOTES.md` update to sub-task 2, and performer/timing added to the consistency-sweep box. Presented to the user for sign-off.
- 2026-08-22 — **Spec amended during design, with the user's approval.** `### Terms used below` narrowed: a **tracked workspace** is now one that *is* a repository root (was "inside a git working tree") and an **untracked workspace** one that is not a repository but holds one beneath it, with an explicit statement that the two are exhaustive. Why it changed: the original definition admitted a third shape — a workspace sitting in a subdirectory of a repository — and the design had started building for it, moving the `.gitignore` `/feature-init` writes from the repo root to the workspace root and incurring a behaviour change and a test case. The user ruled the shape out as one this project never has. Consequences: the `.gitignore` location is now unchanged, and requirement 3 no longer asks for the "repo root" phrase to be reworded, since repo root and workspace root coincide in the only tracked shape there is.
- 2026-08-22 — Feature closed by `/feature-end`. Close-out docs review by `docs-structure-reviewer`, two passes, converging (1 CRITICAL + 4 MAJOR + 8 MINOR → 0 CRITICAL + 1 MAJOR + 5 MINOR, the remaining MAJOR being this record line itself). The CRITICAL was real and caught nothing else had: the two `FEATUREMODEL.md` copies had diverged, because the "exhaustive" sentence was hand-added to the *installed* copy — which the next `/feature-init` would have silently deleted, shipping consumer projects a model text missing the narrowing the user approved. Fixed at the canonical source, and `NOTES.md` gained the never-hand-edit-the-installed-copy rule so the trap is recorded. The four MAJORs were all the same gap, which this feature's own spec had missed: the new "workspace" vocabulary was defined only in `features/FEATUREMODEL.md`, a file that does not exist until `/feature-init` has run, while `docs/setup.md` still told users to initialise "in each repo" and `devproc/README.md` used the term four times undefined. Resolved by introducing the concept once in `docs/workflow.md` (`## Where the workspace is`) and pointing `setup.md` and `devproc/README.md` at it. All MINORs applied, including one carried over from a previous feature's close-out (a completed-feature heading stating the problem rather than what was built — renamed here and in the plan H1). Two SUGGESTION-level items were considered and one declined: the root `README.md` table row is unchanged, since `workflow.md` and `setup.md` both cover the concept and both are linked from that table.
