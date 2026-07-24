---
name: internal-docs-prune
description: Prune internal Claude-facing docs (CLAUDE.md, nested CLAUDE.md files, NOTES.md, .claude/rules/*.md) — spawns internal-docs-reviewer, auto-applies redundant/stale findings without content loss, and escalates judgment findings (interactive) or defers them (unattended)
argument-hint: [unattended]
---

Prune this repository's internal, Claude-facing documentation — the working
memory Claude itself maintains across sessions, as distinct from user-facing
`docs/`. This spawns the read-only `internal-docs-reviewer` agent, then
applies its findings by gating class.

The invocation is: $ARGUMENTS

## Step 1 — Determine mode

Check $ARGUMENTS for an unattended token: `unattended` or `--unattended`
(case-insensitive, anywhere in the string). If present, run in **unattended
mode**. Otherwise run in **interactive mode** — the default.

The mode only changes how `judgment` findings are handled (Step 5). Both
modes apply `redundant` and `stale` findings identically (Step 4).

## Step 2 — Identify scope

The in-scope surface is exactly what `internal-docs-reviewer` reviews: the
root `CLAUDE.md`, any nested `CLAUDE.md` files, `NOTES.md`, and
`.claude/rules/*.md`. Do not pre-filter this list yourself beyond finding the
candidate files (e.g. `Glob **/CLAUDE.md`) — the agent decides what is
actually reviewable within it.

This skill never edits anything outside this surface, with one narrow
exception: a `move` finding's named destination, which is always one of
`features/COMPLETED.md`, a named file under `features/plans/`, or a named
file under `.claude/rules/` (the agent's own permitted destinations — see the
`move` action in its findings contract). Report-only or user-facing files
(`docs/`, `README.md`,`CONTRIBUTING.md`) are never touched, even if a finding
somehow named one - treat that as a defect in the agent's output (see Step 3)
rather than acting on it.

## Step 3 — Spawn the reviewer and collect findings

Call @internal-docs-reviewer with the repository root (or the specific
in-scope files from Step 2) to review.

Parse its output into a list of findings, each carrying: Gating class
(`redundant` | `stale` | `judgment`), file path, Anchor (exact verbatim
text), Issue, Action (`delete` | `move` → destination | `condense`), and
Replacement/Destination text where the action requires one.

A finding missing a required field (see the agent's findings contract — every
finding needs exactly one gating class and action, plus a
destination/replacement wherever the action requires one) is a defect in the
agent's output, not something to guess at: skip it, note it in the summary
(Step 6) as "could not apply — incomplete finding", and do not act on it.

A finding whose gating class and action are an **invalid combination** is
likewise a defect — do not act on it. The agent's contract constrains the
pairing: a `redundant` finding's action must be `delete` (anything else would
duplicate content already at its canonical home), and a `judgment` finding's
action must be `condense` or `move`, never `delete` (the skill never silently
deletes content a human should decide about). If a `redundant` finding carries
`move`/`condense`, or a `judgment` finding carries `delete`, skip it and note
it in the summary as "could not apply — invalid class/action combination". This
means `redundant`/`stale` reaching Step 4 and `judgment` reaching Step 5 are
already known to carry a valid action.

If the agent reports no findings, skip to Step 6 and report a clean run.

## Step 4 — Apply `redundant` and `stale` findings (both modes)

These are auto-applied in both interactive and unattended mode — no
confirmation needed. Apply them file by file, largest/most-impactful first
(the order the agent returns them in), and **re-verify each anchor is still
present, verbatim, in the file immediately before acting on it** — an earlier
finding applied to the same file can shift or remove text a later finding
also depends on. If an anchor is no longer found, skip that finding and note
it in the summary as "anchor not found — file changed since review,
re-run to confirm."

For each finding, by Action:

- **`delete`** — remove the anchor text entirely. Nothing replaces it.
- **`condense`** — replace the anchor text with the finding's exact
  Replacement text.
- **`move`** — this is the highest-consequence action (content leaving its
  only home) and the ordering below is not optional:
  1. Read the destination file (create it only if the agent's Destination
     names a file that legitimately does not exist yet — this should be rare,
     since the three permitted destinations are established files).
  2. Write the Replacement/Destination text into the destination, in a
     position consistent with that destination's own style (e.g. alongside
     other entries in `features/COMPLETED.md`, appended to the relevant
     section of a plan file).
  3. **Verify the destination now contains that text** — re-read the file
     and confirm the exact text is present — before touching the source.
  4. Only once verified present at the destination, remove the anchor text
     from the source file.

  If step 3's verification fails for any reason, stop — do not proceed to
  step 4 for that finding. Report it in the summary as blocked, with the
  source left untouched. **A `move` must never remove content from the
  source without first confirming it landed at the destination** — this is
  the one failure mode ("silent loss") this skill exists to prevent, and no
  other consideration in this skill overrides it.

## Step 5 — Handle `judgment` findings, by mode

Before handling any `judgment` finding, **load the settled-judgment memory**
(see `## Project memory` below) and filter the agent's `judgment` findings
against it: if a finding's Anchor matches a settled call recorded there **and
the anchor text is unchanged** since that decision, the user already ruled on
it — drop it silently (do not re-surface or re-defer it). This filtering
applies in **both** modes. A finding whose anchor text has changed since the
recorded decision is treated as new — the earlier ruling no longer applies to
it.

- **Unattended mode:** take no action on any surviving `judgment` finding.
  Collect them for the summary (Step 6) as deferred, with their file, Anchor,
  Issue, and proposed Action, so the calling session can review and act on
  them later. (Unattended mode records nothing to memory — it settles
  nothing.)

- **Interactive mode (default):** present each `judgment` finding to the user
  in turn — file, Anchor, Issue, and the agent's proposed Action/Replacement.
  Ask what to do with it. **The default, if the user simply confirms or gives
  no other direction, is the agent's own proposed Action — its `condense`
  text, or, for a `judgment` + `move` finding, the proposed move — but never
  `delete`.** Concretely:
  - Proposed Action `condense` → apply the finding's Replacement text.
  - Proposed Action `move` → apply the move, following Step 4's `move`
    procedure in full (see the re-verification note below). (A `judgment`
    finding may legitimately be a `move`; action and gating class vary
    independently.)

  The user may instead choose to delete it, pick a different action, edit the
  replacement or destination, or leave it as-is. Apply whatever they decide
  before moving to the next finding.

  Whatever action is applied, **re-verify the anchor is still present,
  verbatim, immediately before acting** (exactly as Step 4 requires) — an
  earlier `judgment` finding just applied to the same file can shift or remove
  text a later one depends on. For a `move`, follow Step 4's full four-step
  sequence — read the destination, write the text, verify it landed, and only
  then remove the source — including that initial read-the-destination step.

  The agent's contract forbids it from *proposing* `delete` for a `judgment`
  finding (enforced at Step 3), and this skill will not silently `delete` one
  either — a deletion here happens only because the user explicitly asks for
  it.

  **Record each resolved `judgment` finding to memory** (see `## Project
  memory`) as you settle it — whether the user kept it as-is, condensed it,
  moved it, or deleted it — so a later run does not re-ask about the same
  call. Record the anchor, the decision, and the date.

## Step 6 — Summary

Report, grouped by outcome:

- **Deleted** — file and anchor (or a short description) for each.
- **Moved** — file, anchor, and destination for each, confirming the
  write-then-remove ordering held.
- **Condensed** — file and anchor for each.
- **Retained** — `judgment` findings left untouched: in interactive mode,
  ones the user chose to keep as-is; in unattended mode, all of them, listed
  for later review with enough detail (file, Anchor, Issue) that a future
  session or `/internal-docs-prune` run can act on them without re-reviewing
  from scratch.
- **Not applied** — any finding skipped for a mechanical reason (anchor not
  found, incomplete finding, failed destination verification), separate from
  the categories above since these are not decisions, they are problems.

## Step 7 — Commit prefix

This skill does not commit on its own initiative — committing stays
user-gated, per repository convention. If the user asks to commit the
changes this run made (or asks you to prepare a commit message), use the
`docs(prune):` prefix, e.g. `docs(prune): remove duplicated status entries
and stale webhook note`, so prune commits are discoverable by prefix in
history. If multiple distinct changes happened (e.g. a mechanical
auto-applied pass and a separate user-directed judgment resolution), it's
fine to suggest they be split into more than one `docs(prune):` commit —
propose the split rather than bundling silently.

## Project memory

This skill — not the agent — owns the record of settled `judgment` calls, so
repeat runs don't re-litigate borderline entries the user has already ruled
on. The agent is stateless and re-reports every borderline call each run; this
skill is the component that holds the user dialogue and therefore the only one
that knows how each call was decided.

Keep a `MEMORY.md` index at
`$CLAUDE_PROJECT_DIR/.claude/agent-memory/devproc-internal-docs-reviewer/`
(namespaced under the reviewer agent's name with the `devproc-` plugin prefix,
so this skill's memory stays distinct from other devproc agents' and skills').
Always resolve the
path against `$CLAUDE_PROJECT_DIR` (the repository root), never the current
working directory, so memory lands in the same place regardless of where the
skill is invoked from. Create the directory and file if they do not yet exist;
the first run that settles a `judgment` call creates them.

Per settled `judgment` call, record:
- The anchor — file path plus the verbatim anchor text at the time of the
  decision (so a later run can tell whether the text has since changed).
- The decision made (kept as-is, condensed to *X*, moved to *Y*, or deleted).
- The date.

Read this index at the start of Step 5 and use it to suppress already-decided
`judgment` findings (Step 5's filter). Write to it only when a `judgment` call
is actually settled — which happens only in interactive mode, since unattended
mode defers rather than decides. Never record `redundant` or `stale` findings
here: those are re-verified against the live repository on every run
regardless of past decisions (a duplication or contradiction can newly arise
or newly resolve between runs), so memory must never suppress them.

## Idempotency

A second run over files this skill has just pruned should find no new
`redundant` or `stale` findings — those are exactly what Step 4 clears. A
residual `judgment` finding is expected and fine: those are never
auto-resolved, so one a user chose to keep as-is (interactive) or one that
was deferred (unattended) will still be *raised by the agent* — but if it was
settled in interactive mode, the Step 5 memory filter suppresses it, so it
does not re-bother the user; a deferred (unattended) one, never settled, will
re-surface, which is exactly what "escalated, not silently resolved" means. If
a second run does surface a `redundant` or `stale` finding, that is either
newly introduced since the first run (something else changed the file) or a
sign the previous apply pass didn't fully take — investigate rather than
assuming it's expected.
