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
