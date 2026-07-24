# Tidy up internal files that grow without limit — Feature Plan

## Handoff

**Last updated:** 2026-07-25
**Status:** ✅ **COMPLETE — closed 2026-07-25 via `/feature-end`.** Moved to `features/COMPLETED.md`.
**Session summary:** All four sub-tasks complete. The three MAJOR design-level code-review findings were resolved with the user (2026-07-25) and applied across agent, skill, fixtures, plan, and docs — see resolutions below. All sign-offs satisfied: **code review** (`/review-branch` re-converged over two passes, no MAJOR on the second), **user review** (user confirmed the final post-decision wording), and **docs review** (`docs-structure-reviewer` via `/feature-end`, converged after applying its findings). No further action.
**Sub-task in progress:** None. All sub-tasks ✓; feature closed.
**First action next session:** N/A — feature complete. Pick up the next feature from `features/PENDING.md`.
**Resolved decisions (2026-07-25):**
1. **Project memory — caller owns it (was: non-functional).** The agent is now **stateless** (removed `memory: project` and its Project Memory section): it re-reports every borderline `judgment` call each run. The **skill** owns the settled-decision record (`.claude/agent-memory/devproc-internal-docs-reviewer/MEMORY.md`) — reads it at Step 5 to suppress already-decided calls (unless the anchor changed), writes it only when an interactive decision settles a call. Rationale: only the caller sees the outcome, since the agent finishes before the user decides; and memory is a convenience, not a correctness gate.
2. **`redundant` ⇒ `delete` only.** The agent contract now forbids `move`/`condense` for `redundant` (content already at its canonical home). `redundant.expected.md` updated to require `delete`.
3. **`judgment` + `move` ⇒ apply the move on plain confirmation.** Skill Step 5's plain-confirmation default is now the agent's *proposed* action (`condense`, or `move` via write-verify-remove), never `delete`.
(Docs split across `workflow.md`/`capabilities.md` remains the agreed soft default, revisitable at docs review.)
**Dead ends to avoid:** A `judgment` fixture must exhibit the actual symptom a review criterion calls out as suspect (e.g. a dated, stopgap-flavoured remark), not just be a plausible edge case in the fixture author's head — a first draft that was merely "true and durable" was correctly passed with no finding. See `NOTES.md`. Similarly, a "move without loss" validation is not meaningful against the `redundant` fixture's own `features/COMPLETED.md` (the destination already holds the content, since that's why it's redundant) — a real test needs a destination that genuinely lacks the content first.

## Requirements

From issue #46 (verbatim):

> **internal-docs-prune: pruning of internal Claude docs**
>
> ### Problem
>
> The internal docs Claude maintains accumulate cruft through append-only workflows:
>
> - **CLAUDE.md** loads fully each session, increasing token costs. Long files reduce instruction adherence; Anthropic targets under ~200 lines. The `## Current status` section duplicates `features/COMPLETED.md` and plan files, violating its own rules.
>
> - **NOTES.md** accumulates post-mortems of fixed bugs, transient remarks, and stale entries that contradict current code, diluting genuinely valuable environmental gotchas.
>
> This feature adds prevention rules and periodic cleanup to both files across all repos using the devproc plugin.
>
> ### Scope: memory surfaces and their treatment
>
> Coverage includes `CLAUDE.md`, `NOTES.md`, `.claude/rules/*.md`, and nested `CLAUDE.md` files—all Claude-facing internal documentation. Excludes user-facing `docs/`, `README.md`, and `CONTRIBUTING.md`.
>
> ### Deliverables
>
> **1. A read-only review agent (`internal-docs-reviewer`):**
> - Produces findings with exact anchors and replacement text, never edits directly
> - Proposes: delete, move (to `features/COMPLETED.md`, plan files, or `.claude/rules/`), or condense
> - Uses project-scoped agent memory to avoid re-litigating borderline entries
> - Reviews CLAUDE.md for audience relevance; reviews NOTES.md for currency and durability
>
> **2. A skill (`/internal-docs-prune`):**
> - Spawns the reviewer agent and applies findings via gating model
> - Moves content to destinations in the same change (no silent loss)
> - Includes summary of deletions, moves, condensations, and retentions
> - Uses consistent commit prefix (e.g., `docs(prune):`) for discoverability
> - Supports interactive (default) and unattended modes
>
> **3. Prevention rules (changes to existing skills):**
> - **`/feature-end`**: Feature summary goes to `COMPLETED.md` (one paragraph max); CLAUDE.md status retains only in-progress feature or single recent-completion line; older status deleted
> - **`feature-init` template**: Explicitly state status-section cap and reference `/internal-docs-prune`
>
> ### Gating Model
>
> Findings gated by class, not blanket approval:
>
> - **Redundant** (content verifiable elsewhere): Apply automatically
> - **Stale** (contradicted by code/repo): Apply automatically
> - **Judgment** (subjective utility): Escalate to calling session; default action is condense, not delete
>
> Unattended mode applies redundant and stale findings only; judgment findings listed for later review.
>
> ### Requirements
>
> - Must be idempotent; second run should find little
> - Agent enforces files' stated rules plus review criteria; must not invent additional requirements
> - Never expands files or edits report-only surfaces
>
> ### Documentation
>
> - Update `devproc/README.md` with new skill and agent details
> - Add section to `docs/capabilities.md` or `docs/workflow.md` covering hygiene prevention rules, gating model, and usage timing

*(No comments on the issue.)*

## Sign-off strategy

This is a prompt-and-docs feature: new prompt artefacts (a skill and an agent),
prevention-rule edits to existing skills/templates, and documentation. There is
no executable code, so "testing" means exercising the prompts against crafted
inputs rather than running a unit suite. The quality bar per category:

- **Testing** — Fixture-based validation, covering both the reviewer agent and
  the skill's application layer:
  - *Reviewer agent.* Crafted sample `CLAUDE.md` / `NOTES.md` (and a
    `.claude/rules/*.md` and nested `CLAUDE.md`) inputs are placed under
    `devproc/tests/internal-docs-reviewer/`, the reviewer is run over them, and
    its findings are confirmed to match a documented expectation file per
    fixture — including the correct gating class (redundant / stale / judgment).
  - *Idempotency.* A second pass over already-pruned input produces no redundant
    or stale findings (judgment findings permitted), matching the documented
    expectation file — a definite done/not-done rather than "finds little".
  - *Skill application.* The `/internal-docs-prune` skill's application of those
    findings is confirmed to move content to its destination without loss (the
    highest-consequence failure mode), and to gate correctly by class in both
    interactive and unattended modes (unattended applies redundant/stale only and
    defers judgment).

  Signed off when the reviewer produces the expected findings on every fixture
  and the skill applies them correctly, without content loss, in both modes.
- **Documentation** — Full user-facing docs. `devproc/README.md` gains the new
  skill and agent. The docs split across two homes (a soft default, revisitable
  at docs implementation/review if it looks wrong there):
  - `docs/workflow.md` — the *workflow* view: a short line that
    `/internal-docs-prune` should be run routinely as part of the workflow, plus
    when, linking to `docs/capabilities.md` for the detail.
  - `docs/capabilities.md` — the *what-it-is* view: the actual description of the
    `internal-docs-reviewer` agent and `/internal-docs-prune` skill, the gating
    model, and behaviour.

  The `feature-init` CLAUDE.md template states the status-section cap and
  references the new skill. Signed off when all named docs reflect the shipped
  behaviour.
- **Code review** — Agent review. A single `/review-branch` over the whole diff
  before `/feature-end`, run as a feature-level sign-off (not per sub-task), since
  the artefacts are prompt/markdown files best assessed together for consistency.
- **Docs review** — Agent review. The `docs-structure-reviewer` pass that
  `/feature-end` already runs by default serves as this feature's docs-review
  sign-off (not a separate extra pass), which is apt since the feature is
  documentation-heavy and the surfaces it touches (README, workflow docs,
  template) are exactly what that agent audits.
- **User review** — The user reads and confirms the new skill and agent prompts
  and the prevention-rule edits before `/feature-end`, since these change the
  devproc workflow's behaviour across every repo that uses the plugin.

## Design

The feature ships four coordinated artefacts — a review agent, a skill that acts
on it, prevention-rule edits to two existing artefacts, and documentation —
built and validated in that order so each is testable before the next depends on
it. Everything is prompt/markdown; there is no executable code.

### The findings contract (the spine of the feature)

The agent and the skill are coupled by a **findings contract**, exactly as
`feature-spec-reviewer`'s `[rewrite]`/`[decision]` markers couple it to
`/feature-spec`. Each finding the agent emits carries two orthogonal tags:

- **Action** — what to do with the content: `delete`, `move` (to one of the
  permitted destinations — `features/COMPLETED.md`, a plan file under
  `features/plans/`, or `.claude/rules/`), or `condense` (with replacement text).
- **Gating class** — how much authority the skill has to apply it unattended:
  - `redundant` — content verifiable elsewhere (e.g. a `## Current status` entry
    that duplicates `features/COMPLETED.md`). Auto-applied. Action is always
    `delete` — the content already exists at its canonical home, so a `move`
    would duplicate it and there is nothing to condense (resolved code-review
    decision, 2026-07-25).
  - `stale` — contradicted by the current code or repo. Auto-applied.
  - `judgment` — subjective utility. Escalated to the calling session; the
    default on plain confirmation is the agent's *proposed* action (`condense`,
    or `move` for a `judgment`+`move`), never `delete` (resolved code-review
    decision, 2026-07-25).

Every finding also carries an **exact anchor** (the file plus the verbatim text
to act on) and, for `move`/`condense`, the **replacement/destination text**, so
the skill applies it mechanically without re-deciding. The class strings are
parsed verbatim by the skill and are the contract to keep in step between the two
artefacts — a divergence here is the analogue of the unattended-gate divergence
the spec/design skills warn about.

### 1. `internal-docs-reviewer` agent (read-only)

Modelled on `feature-spec-reviewer` (tools `Glob, Grep, Read`; `model: inherit`).
The agent is **stateless** — it holds no memory of its own. It runs and exits
before the calling session decides anything, so it cannot observe or record
outcomes; suppressing re-litigation of already-settled `judgment` calls is the
*skill's* job (see below), not the agent's (resolved code-review decision,
2026-07-25 — earlier drafts gave the agent `memory: project`, which was
non-functional because a read-only agent that finishes before the decision has
nothing to record).

- **Scope in:** root `CLAUDE.md`, nested `CLAUDE.md` files, `NOTES.md`,
  `.claude/rules/*.md`. **Scope out (never edits, never flags):** user-facing
  `docs/`, `README.md`, `CONTRIBUTING.md`.
- **What it enforces:** each file's *own stated rules* (e.g. CLAUDE.md's "high-level
  status only", NOTES.md's "non-obvious findings only") plus the review criteria —
  CLAUDE.md for audience relevance and duplication, NOTES.md for currency and
  durability. It must **not invent additional requirements** beyond what the files
  state and these criteria.
- **Output:** findings only, in the contract above, most-impactful first; it never
  edits and never expands a file. It re-reports every borderline `judgment` call
  on each run; deduplication against already-settled calls happens in the skill.

### 2. `/internal-docs-prune` skill

- Spawns `internal-docs-reviewer`, parses findings by gating class, and **applies
  them in the same change** — a `move` writes the destination *and* removes the
  source in one edit, so content is never lost (the highest-consequence failure
  mode).
- **Interactive mode (default):** auto-applies `redundant` and `stale`; presents
  each `judgment` finding to the user (default action `condense`, not `delete`).
- **Unattended mode (token in the invocation):** applies `redundant`/`stale` only;
  lists `judgment` findings for later review without acting.
- **Output:** a summary of deletions, moves, condensations, and retentions.
- Any commit it makes or proposes uses the `docs(prune):` prefix for
  discoverability. (Actual committing stays user-gated per repo convention; the
  skill supplies the prefix rather than committing unbidden.)
- **Owns the settled-`judgment` memory:** the skill (not the agent) keeps the
  record of resolved `judgment` calls under
  `.claude/agent-memory/devproc-internal-docs-reviewer/MEMORY.md`, since it is
  the component that holds the user dialogue and therefore knows each outcome.
  It reads that record at Step 5 to suppress an already-decided call (unless the
  anchor text has changed), and writes to it only when a call is actually
  settled — which happens only in interactive mode. `redundant`/`stale` are
  never recorded there; they are re-verified live every run.
- **Idempotent:** a second run over already-pruned files yields no `redundant` or
  `stale` findings.

### 3. Prevention rules (edits to existing artefacts)

- **`/feature-end`:** add an explicit step — the feature summary goes to
  `features/COMPLETED.md` (one paragraph max, already the format there); the
  CLAUDE.md status retains only the in-progress feature or a single
  recent-completion line, and older status lines are deleted. This stops the
  `## Current status` section growing without bound at the point new entries are
  added.
- **`feature-init` CLAUDE.md template:** state the status-section cap explicitly in
  the `- **CLAUDE.md** — high-level status only` guidance, and reference
  `/internal-docs-prune` as the periodic-cleanup tool. Because this template is the
  canonical text copied into every repo, the rule the reviewer enforces, the rule
  `/feature-end` applies, and the rule the template states must all agree — a
  contradiction across the three would make the tooling fight itself.

### 4. Documentation

- **`devproc/README.md`:** a `### internal-docs-prune` entry under Skill reference
  and an `### internal-docs-reviewer` entry under Agent reference.
- **`docs/capabilities.md`:** the *what-it-is* view — a section describing the
  agent, the skill, the gating model, and behaviour.
- **`docs/workflow.md`:** the *workflow* view — a short line that
  `/internal-docs-prune` should be run routinely, and when, linking to
  `docs/capabilities.md` for detail. (Split agreed with the user; soft default,
  revisitable at docs review.)
- **`devproc/.claude-plugin/plugin.json`:** extend the `description` to mention the
  new hygiene skill/agent, consistent with how it enumerates the others.
- **Root `CLAUDE.md` `## devproc plugin` contents list:** add the new skill and
  agent to the enumerated file list (kept in sync at checkpoint/end time, but
  named here so it is not missed — apt given this feature's own theme).

### Testing approach

Fixtures live under `devproc/tests/internal-docs-reviewer/`, following the
existing `feature-spec-reviewer` convention: each case is a small fixture
*directory* (`<case>/`, holding real relative paths such as `CLAUDE.md`,
`NOTES.md`, `features/COMPLETED.md`, `.claude/rules/...`) paired with a top-level
`<case>.expected.md` stating the required findings, their gating class, and the
expected outcome; the flaw is named only in the `.expected.md`. (A directory per
case, rather than the single `.md` file `feature-spec-reviewer` uses, because
some checks — a duplication against `COMPLETED.md`, a contradiction against a
config file — only make sense with several files present.) Cases cover a clean control (no findings), a `redundant`
CLAUDE.md status duplication, a `stale` NOTES.md entry, a `judgment` borderline
entry, and coverage of a nested `CLAUDE.md` and a `.claude/rules/*.md` file, plus
an already-pruned input for the idempotency check. Skill application (moves
without loss, gating in both modes) is validated by a worked run over these
fixtures, since it cannot be checked by inspecting the agent's output alone.

### Key decisions

- **Two-tag findings (action × gating class)** rather than one combined marker:
  the action tells the skill *what* to do, the gating class tells it *how much
  authority* it has — they vary independently (a `judgment` finding can still be a
  `move`), so collapsing them would lose information. The one constraint on the
  cross-product is that `redundant` implies `delete` — the class *means* the
  content is already at its canonical home, so there is nothing to move or
  condense (resolved code-review decision, 2026-07-25).
- **Memory lives with the skill, not the agent** (resolved code-review decision,
  2026-07-25). The requirement to "avoid re-litigating borderline entries" needs
  the *outcome* of each `judgment` call, which only the calling session sees — the
  agent finishes before the decision exists. So the agent is stateless and the
  skill owns the settled-decision record. This is a convenience (it suppresses
  re-asking), never a correctness gate: nothing is lost or wrongly applied if the
  record is absent; only `redundant`/`stale` gate real changes, and those are
  re-verified live every run and never remembered.
- **Agent before skill** in sequence: the skill's application layer can only be
  tested once the agent emits real findings to apply.
- **Prevention rules kept consistent with the reviewer** by treating the
  status-cap as one rule stated in three places, checked for agreement — rather
  than three independently worded rules.

## Sub-tasks

1. ✓ (2026-07-24) **`internal-docs-reviewer` agent + fixtures** — Write the read-only agent (scope, enforced rules, two-tag findings contract, project memory) and its test fixtures under `devproc/tests/internal-docs-reviewer/`, then validate it.
   - [x] Testing: the agent produces the expected findings — correct action and gating class — on every fixture (control, redundant, stale, judgment, nested-CLAUDE.md, `.claude/rules`), and a second pass over already-pruned input yields no redundant/stale findings, each matching its `.expected.md`.

2. ✓ (2026-07-24) **`/internal-docs-prune` skill** — Write the skill: spawn the reviewer, apply findings by gating class, perform moves without loss, support interactive (default) and unattended modes, emit the deletions/moves/condensations/retentions summary, and use the `docs(prune):` commit prefix.
   - [x] Testing: a worked run confirms the skill applies findings without content loss, gates correctly by class (unattended applies redundant/stale only and defers judgment; interactive escalates judgment with a condense default), and a second run is idempotent. Validated by hand over throwaway copies of Sub-task 1's fixtures under `/tmp` (real agent invocation not yet possible in this session — see `NOTES.md`): unattended auto-applied the `redundant` and `stale` fixtures' findings while leaving the `judgment` fixture untouched; interactive applied the `judgment` fixture's finding via the `condense` default (never `delete`); a derived copy with the move destination pre-emptied proved the write-destination→verify→remove-source ordering holds and blocks cleanly if verification fails; the auto-pruned `redundant` fixture's `CLAUDE.md` came out byte-identical to the `idempotent` fixture's `CLAUDE.md`, confirming the steady state a second pass expects. Full account in `NOTES.md`.

3. ✓ (2026-07-24) **Prevention rules** — Edit `/feature-end` (cap the CLAUDE.md status section and route summaries to `COMPLETED.md`) and the `feature-init` CLAUDE.md template (state the status-section cap, reference `/internal-docs-prune`).
   - [x] Testing: confirm the status-cap rule is stated consistently across the `feature-init` template, `/feature-end`, and what `internal-docs-reviewer` enforces — no contradiction across the three. Verified: all three describe the same cap (in-progress feature, if any, plus at most one most-recent-completion line; older entries deleted from `CLAUDE.md`, preserved only in `features/COMPLETED.md`). No edit to the agent was needed. Full comparison in `NOTES.md`.

4. ✓ (2026-07-24) **Documentation** — Add the skill and agent to `devproc/README.md`; add the *what-it-is* section to `docs/capabilities.md` and the *workflow* line to `docs/workflow.md`; extend `plugin.json`'s description.
   - [x] Documentation: `devproc/README.md`, `docs/capabilities.md`, `docs/workflow.md`, `plugin.json`, the `feature-init` CLAUDE.md template (status-section cap + `/internal-docs-prune` reference), and the root `CLAUDE.md` `## devproc plugin` contents list all reflect the shipped agent, skill, gating model, and prevention rules. `devproc/README.md` gained Contents-table rows plus a `### internal-docs-prune` skill-reference entry and `### internal-docs-reviewer` agent-reference entry; `docs/capabilities.md` gained a new `## Internal docs hygiene` section (agent, skill, gating model, move-without-loss, idempotency); `docs/workflow.md` gained a short `## Keep internal docs tidy` section linking to it; `plugin.json`'s `description` now mentions the hygiene skill/agent (validated as JSON); the root `CLAUDE.md` contents list gained both entries; the `feature-init` template was checked and already covered the cap/reference correctly (no edit needed).

**Feature-level sign-offs** (recorded in `## Sign-off strategy`, not repeated per
sub-task, and covering all four sub-tasks including the prose-only prevention-rule
edits): **Code review (agent)** — one `/review-branch` over the whole diff before
`/feature-end`; **Docs review (agent)** — the `docs-structure-reviewer` pass
`/feature-end` runs by default; **User review** — the user reads and confirms the
new agent and skill prompts and the prevention-rule edits before `/feature-end`.

**▶ NEXT:** All sub-tasks complete. Code-review sign-off **satisfied** (`/review-branch` re-converged 2026-07-25, no MAJOR on the second pass). User review **confirmed for the final post-decision wording** (2026-07-25). Only remaining sign-off is docs review via `docs-structure-reviewer`, run by `/feature-end`. Ready to run `/feature-end`.

> Run `/feature-checkpoint` after each sub-task completes.

## Review record

<!-- One line per lifecycle stage; preserve across edits. -->

- 2026-07-24 — Spec reviewed by `feature-spec-reviewer`: VERDICT: READY FOR USER REVIEW. Presented to the user for sign-off, with 1 open question (docs destination).
- 2026-07-24 — Design reviewed by `feature-design-reviewer`: VERDICT: READY FOR USER REVIEW. Presented to the user for sign-off.
- 2026-07-24 — Code review by `/review-branch` (simplicity + general + nitty; no architectural pass, per instruction). Code-level findings (prose/terminology/scope-consistency) applied. **3 MAJOR design-level findings remain open** (project-memory wiring; `redundant`+`move` duplication; `judgment`+`move` default) — escalated to the user as decisions; code-review sign-off NOT yet satisfied. Details in `## Handoff`.
- 2026-07-25 — Three MAJOR decisions resolved with the user and fixes applied (agent stateless + skill-owned memory; `redundant`⇒`delete`; `judgment`+`move` applies-on-confirm). Re-ran `/review-branch` over the changed files (simplicity + general + nitty; no architectural pass) to converge: pass 1 found follow-on code-level findings (all applied — chiefly making `judgment`+`move` reachable in the agent contract, and centralising invalid class/action rejection in the skill's Step 3); pass 2 found **no MAJOR findings and no contract contradictions**, only prose-clarity nits, which were applied. **Code-review sign-off now satisfied.** User review confirmed 2026-07-25 for the earlier state; final applied wording to be re-confirmed before `/feature-end`. Remaining: docs-review sign-off via the `docs-structure-reviewer` pass `/feature-end` runs.
- 2026-07-25 — User review confirmed for the final post-decision wording. Docs review by `docs-structure-reviewer` (feature-level sign-off, run by `/feature-end`): first pass found 1 MAJOR (feature-tracking surfaces disagreeing on lifecycle state) + 2 MINOR + 1 SUGGESTION, all applied; re-audit **CONVERGED — CLEAN**, no new inconsistencies. All sign-offs satisfied. **Feature closed via `/feature-end` and moved to `features/COMPLETED.md`.** (Record line added retroactively when the `/feature-end` Review-record stamping step was introduced — see that skill's step 5.)
