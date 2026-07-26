# Un-pin agent model versions — Feature Plan

## Handoff

**Last updated:** 2026-07-26
**Session summary:** Design agreed by user. Sub-tasks 1 (agent frontmatter)
and 2 (doc prose) implemented and verified. Sub-task 3's code-review gate
(`/review-branch`) complete — converged clean after 5 iterations, all
code-level, no architectural findings. Remaining for Sub-task 3: docs review
(`docs-structure-reviewer`, performed at `/feature-end`) and user review.
**Sub-task in progress:** Sub-task 3 (Final sign-off criteria)
**First action next session:** Present the `/review-branch` outcome to the
user and get their sign-off on the per-agent model choices and final diff
(Sub-task 3's user-review gate); the docs-review gate then runs at
`/feature-end`.
**Open questions / decisions pending:** None
**Dead ends to avoid:** None

## Requirements

From issue #48 (verbatim):

> It should just use the default version of opus. The default now seems to be
> opus 5, and opus 4.6 is still being run. (I haven't grepped for sonnet, but
> similar things apply there if it pins to a version.)

The issue has no comments.

### Confirmed scope (found while preparing this spec)

A repo grep for `model:` frontmatter across `devproc/agents/*.md` found four
agent definitions pinning a dated model id, matching the issue exactly:

- `devproc/agents/code-review-architectural.md` — `model: claude-opus-4-6`
- `devproc/agents/code-review-general.md` — `model: claude-sonnet-4-6`
- `devproc/agents/code-review-nitty.md` — `model: claude-sonnet-4-6`
- `devproc/agents/code-review-simplicity.md` — `model: claude-sonnet-4-6`

The remaining agent definitions already avoid this: `dev-process-manager.md`
uses the unpinned alias `model: opus`, and `docs-structure-reviewer.md`,
`feature-spec-reviewer.md`, `feature-design-reviewer.md`, and
`internal-docs-reviewer.md` all use `model: inherit`. `NOTES.md` (under the
`dev-process-manager` write-up) already documents why the alias form is
preferred: "the aliases resolve to the latest model in each family at
runtime, so the agent never goes stale" — which is precisely the property the
four pinned agents lack. `bin/claude-run`'s `derive_model()` is documented as
already handling both forms ("the derivation handles both the alias (`opus`)
and pinned ids (`claude-opus-4-6`)"), so switching the four agents to the
alias form is not expected to require any change there.

Several files also *mention* the pinned ids in prose, without being the
source of truth themselves (the frontmatter is): `CLAUDE.md`'s devproc
contents bullet, `devproc/README.md` (two mentions), and
`docs/capabilities.md`. **In scope:** these three are current-state
documentation and must be updated to match whatever `/feature-design` settles
on for the frontmatter values, so they no longer state a pinned id as current
fact. Historical files that record a past-tense design decision —
`features/plans/code-review.md`, `features/plans/dev-process-manager.md`,
`features/COMPLETED.md`, and `NOTES.md`'s existing entries — describe what was
decided *at the time*, not the current recommendation; whether to touch these
is a design question, not a requirement (resolved in `## Sign-off strategy`
below: left untouched as historical record).

### Done when

- No file under `devproc/agents/*.md` pins a `model:` frontmatter value to a
  dated id (e.g. `claude-opus-4-6`, `claude-sonnet-4-6`); each uses an
  unpinned family alias or `inherit` instead.
- `CLAUDE.md`, `devproc/README.md`, and `docs/capabilities.md` no longer
  state a dated pinned id as the current model for any agent.

### Open question

- Should each of the four agents move to the bare alias (`opus` / `sonnet`,
  matching `dev-process-manager.md`) or to `inherit` (matching the other four
  non-review agents)? The user has confirmed this is a per-agent design
  decision, not a single blanket choice — `/feature-design` must propose a
  specific value for each of the four agents individually (e.g. the
  architectural agent might deliberately stay on a stronger tier than
  whatever `inherit` would resolve to, if `inherit` and the family alias
  could ever diverge), and the user will review the per-agent proposal at
  that stage. The user's intent — "just use the default version" — is
  captured here as the guiding requirement either way.

## Sign-off strategy

This is a small, self-contained fix confined to `devproc` agent frontmatter
plus a few lines of prose in docs that describe it — no executable code and
no automated test harness covers agent Markdown files in this repo.

- **Testing** — Manual. After the edit, grep confirms no `devproc/agents/*.md`
  file pins a dated model id anymore, and the replacement value in each case
  is a form already proven to work elsewhere in the repo (the `opus`/`sonnet`
  aliases are already used by `dev-process-manager.md` and by the `Agent` tool
  call in its prompt; `inherit` is already used by four other review-family
  agents). Auditable: the grep is re-run and shown clean, and each changed
  file's new `model:` value is one already in use elsewhere.
- **Documentation** — Update the prose that currently states the pinned ids as
  current fact — `CLAUDE.md`'s devproc contents bullet, `devproc/README.md`,
  and `docs/capabilities.md` — to match whatever the design settles on.
  Historical records of a past decision (`features/plans/code-review.md`,
  `features/plans/dev-process-manager.md`, `features/COMPLETED.md`,
  `NOTES.md`) are left untouched as historical record, not corrected in
  place. Auditable: grep for the old pinned ids across `CLAUDE.md`,
  `devproc/README.md`, and `docs/` returns no hits.
- **Code review** — Agent: `/review-branch` over the changed files before
  `/feature-end`.
- **Docs review** — Agent: `docs-structure-reviewer` over the updated docs
  before `/feature-end`, given `CLAUDE.md`, `devproc/README.md`, and
  `docs/capabilities.md` are all touched.
- **User review** — The user confirms the final diff, since this changes
  which model cost/capability tier the review agents actually run on.

## Design

### Per-agent model value

The spec left open whether each of the four pinned agents should move to the
bare family alias (`opus` / `sonnet`) or to `inherit`. Resolved per agent,
based on what each agent is *for* and how it is invoked:

- **`code-review-architectural.md`: `model: opus`** (not `inherit`). This
  agent is deliberately the strongest tier in the review-agent family —
  `docs/capabilities.md` describes it as a "deeper structural
  assessment... in a slow pass", i.e. its whole reason to exist is to run at a
  higher capability tier than the other three review agents, regardless of
  what invoked it. It is always spawned as a *sub-agent* (via the `Agent`
  tool, from `/review-branch`, `/review-component`, `/review-full`, or
  `dev-process-manager`), never as a top-level session, so `inherit` would
  tie its tier to whatever model the calling session happens to be running
  as — which could be Sonnet (e.g. an ordinary user session running
  `/review-branch`) or Opus (`dev-process-manager`), making its quality
  inconsistent and defeating the deliberate "always the strong tier" design.
  The bare alias `opus` preserves the deliberate choice while tracking
  whichever model is currently the Opus-family default.
- **`code-review-general.md`, `code-review-nitty.md`,
  `code-review-simplicity.md`: `model: sonnet`** (not `inherit`), for the
  mirror-image reason: these three were deliberately pinned at the Sonnet
  tier before this change — their own frontmatter fixed them at
  `claude-sonnet-4-6` (`devproc/agents/code-review-general.md`, `-nitty.md`,
  `-simplicity.md`), distinct from the architectural agent's stronger
  `claude-opus-4-6` tier, and they run repeatedly (iterating to convergence)
  over every diff, so a consistent, cheaper tier is the intended trade-off.
  `inherit` would make their tier drift with the caller instead (e.g.
  running at Opus cost when invoked from `dev-process-manager`, or dropping
  to a weaker tier if a caller ever runs cheap), which was not the existing
  behaviour and not something this feature should introduce as a side
  effect. The bare alias `sonnet` keeps them consistently at the Sonnet
  family's current default.

`inherit` remains correct, and unchanged, for the other four agents
(`docs-structure-reviewer.md`, `feature-spec-reviewer.md`,
`feature-design-reviewer.md`, `internal-docs-reviewer.md`) — those are
lightweight review passes with no stated tier requirement of their own, so
matching the caller is the existing and appropriate behaviour. This feature
does not touch them.

`bin/claude-run`'s `derive_model()` forces a top-level session's `--model`
from the invoked agent's `model:` field, and `inherit` would not be a valid
top-level `--model` value. This is not a concern for the four agents this
feature changes: all four are only ever invoked as sub-agents (via the
`Agent`/`Task` tool from within a review skill), never as a top-level
`claude-run --agent`/`--manager` session, so `derive_model()` never runs
against them regardless of which value they carry.

### Doc-prose updates

`CLAUDE.md`'s devproc contents bullet, `devproc/README.md` (two mentions),
and `docs/capabilities.md` currently state the old pinned ids as fact. Each
is updated to describe the new alias values instead (e.g. "architectural
agent uses `opus`" / "the rest use `sonnet`"), preserving whatever
surrounding sentence structure already exists — this is a value substitution
in existing sentences, not a rewrite of the surrounding prose. If the
substitution leaves an annotation asymmetry (the architectural agent's tier
named but the three sonnet agents' tier left unstated, once its id shrinks from a
pinned id to the terse `opus`), matching `(sonnet)` annotations are added to
the previously-unannotated agents rather than treating that as out of scope
— see the Sub-task 2 completion note for where this applied in practice.

## Sub-tasks

1. ✓ **Un-pin the four agent frontmatter values** (2026-07-26) — changed each
   agent's `model:` field per the per-agent decision above (architectural →
   `opus`; general, nitty, simplicity → `sonnet`); no other frontmatter or
   prompt content changed.
   - [x] Testing (manual): `grep -n "^model:" devproc/agents/*.md` and
     `grep -rniE 'claude-(opus|sonnet|haiku)-[0-9]+-[0-9]+' devproc/agents/*.md`
     — confirmed the four files now read `opus` / `sonnet` / `sonnet` /
     `sonnet` respectively, and no dated id remains anywhere under
     `devproc/agents/*.md` (multi-digit minor versions included, not just
     the single-digit `-4-6` ids that were actually present).
2. ✓ **Sync doc prose to the new values** (2026-07-26) — updated
   `CLAUDE.md`, `devproc/README.md` (two mentions), and
   `docs/capabilities.md`; only `claude-opus-4-6` mentions existed in these
   three files (no `claude-sonnet-4-6` mentions were present to update), each
   replaced with `opus` in place, no surrounding prose rewritten. (During
   Sub-task 3's `/review-branch` convergence, `code-review-nitty`/`-general`/
   `-simplicity` findings noted that this left `code-review-architectural`'s
   tier annotated in `CLAUDE.md` and `devproc/README.md` while the three
   `sonnet`-tier agents carried none — an asymmetry that predated this
   feature but became more conspicuous once the architectural id changed
   from a pinned id to the terse `opus`. Fixed by adding `(sonnet)`
   parentheticals to the three bullets in `CLAUDE.md` and "Uses `sonnet`."
   sentences to the three agent descriptions in `devproc/README.md` — new
   content in each case, not a further substitution of existing text.)
   - [x] Testing (manual):
     `grep -rniE "claude-(opus|sonnet|haiku)-[0-9]+-[0-9]+" CLAUDE.md devproc/README.md docs/`
     — re-run after the edits, returns no hits.
3. ✓ **Final sign-off criteria** (2026-07-26) — end-of-feature gates for this
   feature, per `## Sign-off strategy`:
   - [x] Code review (agent): `/review-branch` over all changed files (no
     architectural review requested). Ran simplicity/general/nitty over the
     full diff, then iterated to convergence over the files touched by
     fixes — 5 rounds total (the iteration cap), converging to a clean pass
     on round 5. All findings were code-level wording/consistency fixes in
     `CLAUDE.md`, `devproc/README.md`, and the plan file itself (mostly the
     plan's own review-record prose catching up with itself as annotation
     symmetry was added); none were architectural. No findings dismissed —
     everything raised was applied.
   - [x] Docs review (agent): `docs-structure-reviewer` over the updated docs
     (performed at `/feature-end`). No CRITICAL/MAJOR findings; the feature's
     doc changes (agent frontmatter, `CLAUDE.md`/`devproc/README.md`/
     `docs/capabilities.md` prose, the `CLAUDE.md` status trim, and the
     `features/CURRENT.md`↔`COMPLETED.md` move) are fully and consistently
     propagated with no broken links or orphans. One MINOR, pre-existing and
     out of this feature's scope (two `NOTES.md` entries now cite the
     superseded `claude-opus-4-6` id as a live example), explicitly
     recommended by the reviewer for deferral to a future
     `/internal-docs-prune` run rather than a hand-fix here; not applied.
   - [x] User review: user confirmed the per-agent model choices and the
     resulting diff match intent (2026-07-26).

**▶ NEXT:** None — all sub-tasks complete; feature closed 2026-07-26.

> Run `/feature-checkpoint` after each sub-task completes.

## Review record

- 2026-07-26 — Spec reviewed by `feature-spec-reviewer` (two passes): first pass VERDICT: NEEDS WORK (one MAJOR `[rewrite]` — doc-prose files' in-scope status was only implied, not stated; one SUGGESTION `[rewrite]` — add a "Done when" outcome summary). Both fixed; second pass VERDICT: READY FOR USER REVIEW. Presented to the user for sign-off.
- 2026-07-26 — Design reviewed by `feature-design-reviewer`: VERDICT: READY FOR USER REVIEW. One MINOR `[rewrite]` (two supporting quotes in the per-agent rationale were misattributed to `devproc/README.md`; corrected to their actual sources) fixed without a second review pass, as it was a citation correction, not a restructuring. Presented to the user for sign-off.
- 2026-07-26 — Close-out docs review by `docs-structure-reviewer` (performed at `/feature-end`): no CRITICAL/MAJOR findings; doc changes fully and consistently propagated, no broken links or orphans. One MINOR (pre-existing, out of scope: two `NOTES.md` entries cite the now-superseded `claude-opus-4-6` id) deliberately deferred to a future `/internal-docs-prune` run per the reviewer's own recommendation. Feature closed 2026-07-26.
