# Settled `judgment` decisions — `/internal-docs-prune`

Index of borderline (`judgment`) findings the user has already ruled on, so
repeat runs do not re-litigate them. Read at Step 5; a finding whose anchor
matches an entry here **and is unchanged** is suppressed. `redundant`/`stale`
findings are never recorded here — they are re-verified live every run.

Per entry: file · verbatim anchor at decision time · decision · date.

---

## 2026-07-25

### 1. CLAUDE.md — `internal-docs-prune` status entry

- **File:** `CLAUDE.md` (`## Current status`)
- **Anchor (verbatim, at decision):** ``internal-docs-prune` completed 2026-07-25 — added prevention rules and a periodic-cleanup tool for the internal, Claude-facing docs (`CLAUDE.md` root and nested, `NOTES.md`, `.claude/rules/*.md`) that grow append-only (#46). Ships a read-only `internal-docs-reviewer` agent that emits findings tagged with a gating class (`redundant`/`stale`/`judgment`) and action (`delete`/`move`/`condense`), and a `/internal-docs-prune` skill that applies them by class — auto-applying redundant/stale, escalating judgment (interactive) or deferring it (unattended), with moves done write-verify-remove so nothing is lost. Three findings-contract decisions were settled at code review: the reviewer agent is **stateless** with the *skill* owning the settled-`judgment` memory (only the caller sees a decision, so only it can remember it); `redundant`⇒`delete`; and `judgment`+`move` applies the move on plain confirmation. Prevention rules cap the `## Current status` section (enforced in `/feature-end`, stated in the `feature-init` template). Prompt-and-docs-only change.``
- **Decision:** Condensed to a one-line entry pointing to `features/COMPLETED.md` for detail.

### 2. NOTES.md — "Wording `docs/workflow.md` (Sub-task 3) must match"

- **File:** `NOTES.md`
- **Anchor (verbatim, at decision):** the `## Wording `docs/workflow.md` (Sub-task 3) must match` section — a completed Sub-task 3 planning note for `spec-requirements-input` (shipped 2026-07-24) prescribing what `docs/workflow.md` should cover, ending with the bare-one-liner→NEEDS WORK paragraph.
- **Decision:** Condensed — dropped the completed planning note, kept only the lasting finding, re-headed `## `/feature-spec` from a bare one-line description ends at NEEDS WORK`.

### 3. NOTES.md — "Container credentials mount path (#17)"

- **File:** `NOTES.md`
- **Anchor (verbatim, at decision):** the `## Container credentials mount path (#17)` section as a fixed-bug post-mortem (original wrong `.credentials` mount path, the resulting stray `nobody:nogroup` empty directory, and manual cleanup instructions).
- **Decision:** Condensed — kept the durable gotcha (`.json` suffix required; Docker's silent-empty-dir trap), dropped the fixed-bug narrative.

### 4. NOTES.md — "Consequence for this feature" (live-copy vs git-tracked)

- **File:** `NOTES.md`
- **Anchor (verbatim, at decision):** the `**Consequence for this feature:**` paragraph — a resolved status log for `spec-requirements-input` Sub-tasks 1 and 2 (who ported which SKILL.md into `/workspace/devproc/`, `diff -q` confirmation, per-sub-task policy).
- **Decision:** Condensed to the standing policy nugget (edit skill prose in the git-tracked `/workspace/devproc/`; diff the two trees before `/feature-end`).

---

## 2026-08-22

All eleven `judgment` findings from this run were condensed on the user's
instruction ("Apply all 11"), each to the reviewer's proposed replacement text.
The common pattern: an entry written as per-sub-task *evidence* for a feature
that has since closed, with a durable lesson buried in the narrative of how it
was found. The condense keeps the lesson and drops the narrative. Anchors below
are identified by their section heading at decision time.

### 5. NOTES.md — `## Agent result delivery can fail silently mid-session (#57, Sub-task 7)`
- **Decision:** Condensed — kept the failure signature, the "tabulate every spawn" diagnosis trap, the not-a-reliable-reset correction, the `claude -p --agent` workaround, and the never-tick-a-review-you-never-saw rule; dropped the superseded-investigation narrative.

### 6. NOTES.md — `## Sub-task 7 dry-run: /feature-design step 6 produces the right shape both ways (#47)`
- **Decision:** Condensed and re-headed `## /feature-design step 6: which end-of-feature gates get an annotation (#47)` — kept only the annotation-placement gotcha; the two invented scenarios were scaffolding and the rules are canonical in `FEATUREMODEL.md`.

### 7. NOTES.md — `## A bare one-line description no longer forces NEEDS WORK (superseded, #57)`
- **Decision:** Condensed and re-headed `## A one-line description is requirements (#57)` — kept the current rule and the two lessons; dropped the restatement-then-retraction of the superseded behaviour.

### 8. NOTES.md — `## Validating /internal-docs-prune's application logic without a live agent (Sub-task 2, #46)`
- **Decision:** Condensed — kept the drive-from-known-findings technique and the two fixture gotchas (the `redundant` fixture is not a clean `move` test; idempotency diffs against the `idempotent/` fixture); dropped the per-scenario pass record.

### 9. NOTES.md — `## Writing review fixtures: expect the agent to find your own bugs (#20)`
- **Decision:** Condensed — kept the "your fixture is the bug" heuristic and the two expectation errors; dropped four fixture defects and a verdict-rule bug all since fixed.

### 10. NOTES.md — `## Sub-task 1 (extract-feature-model, #43) verification method`
- **Decision:** Condensed and re-headed `## Verifying that an @import actually loads` — kept the disable-all-read-tools technique; dropped the one-off, line-number-specific migration check.

### 11. NOTES.md — `## Testing a skill end to end, and what it caught (#20)`
- **Decision:** Condensed — kept the run-it-against-a-throwaway-project practice and the reviewer-must-know-the-skill's-rules lesson; dropped four post-mortems of since-fixed bugs.

### 12. NOTES.md — `## Dogfooding: run the reviewers at spec/design time, not feature-end (#20)`
- **Decision:** Condensed — kept the no-retrospective-rewrite rule; dropped a closed feature's audit findings.

### 13. NOTES.md — container `--agent` plumbing (in `## dev-process-manager agent (#19)`)
- **Decision:** Condensed to one sentence — the plumbing is derivable from `bin/claude-run` and `run-claude.sh`, and the trailing "To verify in testing" to-do had been open since the feature closed 2026-06-03.

### 14. NOTES.md — `setup-files/` three coordinated edits (in `## setup-files/ as a checked-in resources directory`)
- **Decision:** Condensed to the ordering prerequisite alone — the three-edits rule duplicates the root `CLAUDE.md` `## setup-files directory` section.

### 15. NOTES.md — `incomplete-requirements.md` rename note
- **Decision:** Condensed to the standing rule (fixture renames use `mv`, not `git mv`); dropped the transient recovery incident.
