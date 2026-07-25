# Capabilities

This document describes additional capabilities provided by `devproc` beyond the [core feature workflow](workflow.md).

---

## Dev Process Manager

The Dev Process Manager is a top-level agent that drives the feature workflow for you semi-autonomously. Instead of you asking Claude to do one sub-task at a time, you run Claude *as* the manager agent and tell it how far to go on its own — for example "work through sub-tasks 1–4 and check with me before 5", or "confirm the design with me first, then implement".

Run it as the session agent:

```
claude --agent dev-process-manager
```

In [container mode](container.md) the same agent is selected with a shorthand (`--agent dpm` is accepted as an equivalent short alias):

```
claude-run --manager
```

The manager runs as Opus automatically — `claude-run` takes the model from the agent's definition. See [container.md](container.md#session-model) for the detail and the `--model` override.

What it does:

- **Establishes the feature.** It reads the in-progress feature and its plan, or — if you ask — specs and designs a new one (e.g. "spec and design a feature from issue 19"), getting the design in front of you before any code is written. The spec and design skills review their own output first (see [workflow.md](workflow.md#review-before-you-read-it)); where your autonomy boundary covers those stages they run unattended, and a clean reviewer verdict stands in for your sign-off — but a blocking finding or an open question stops the run and comes to you regardless.
- **Agrees an autonomy boundary.** It settles with you up front how far to run unattended, then proceeds without asking at every step until it reaches that boundary.
- **Delegates each sub-task to a teammate.** For each sub-task it spawns a teammate (normally Sonnet), briefs it with the single sub-task, its sign-off criteria, and the context it needs, and requires it to run `/feature-checkpoint` when done.
- **Reviews the work.** It inspects the actual changes rather than trusting the teammate's report, running a code review where warranted, and sends corrections back if needed. It accepts a sub-task as done only once all of its sign-off boxes are ticked.
- **Closes teammates down** once their task is verified complete, and **checks in with you** at requirement/design decisions, when you asked to review something, or when it hits a blocker.

This lets you delegate a batch of work and stay in control of the high-level direction, with the manager keeping the overall context on track while teammates handle the detail. It uses more tokens than driving sub-tasks yourself, in exchange for autonomy.

---

## Code review

Code review is performed by skills described below. When run, these skills instantiate three specialist agents (simplicity, general, and nitty) which run in parallel. Code-level findings — contained within a single function or file — are applied automatically, then the agents re-run over the changed files. This iterates until no new findings appear (capped at five rounds).

If you request an architectural review, then a fourth architectural agent is run to flag architectural issues — component boundaries, public interfaces, structural design — and its results are presented for confirmation before anything is changed.

Code review should normally be run after every feature is complete, and occasionally more broadly to catch code quality drift. This uses a lot of tokens, but does greatly improve quality.

### Review options

- Review all changes in the current branch relative to `main`.

    ```
    /review-branch
    ```

- Review a specific component or area - specify the component using natural language.

    ```
    /review-component the authentication module
    /review-component src/api/
    ```

- Review the entire codebase

    ```
    /review-full
    ```

### Architectural review

If you want a deeper structural assessment (using `claude-opus-4-6` in a slow pass), you can request architectural review. If your brief is not clear, Claude will request clarification if architectural review is required. For example:

```
/review-branch including architectural review
```

---

## Documentation review

To audit the documentation structure and quality of a codebase, ask Claude to do a full docs review, which can trigger the `docs-structure-reviewer` agent. This can be asked for using natural language (`Do a full structural review of docs` or `Use the docs-structure-reviewer to review the docs`). This is automatically run by Claude at the end of each feature.

**Docs review** is also one of the five sign-off categories in the feature model, so a feature's sign-off strategy can require it — per sub-task (`Docs review (agent): ...` or `Docs review (user): ...` checkboxes), or as an end-of-feature gate, materialised at design time as a box in the "Final sign-off criteria" sub-task and marked "(performed at `/feature-end`)", since the automatic `/feature-end` run is what performs and ticks it.

The docs structure reviewer checks discoverability, architectural completeness, procedural rigour, and consistency, and produces a prioritised list of findings without modifying any files (unless you tell Claude to run it and implement its findings).

---

## Internal docs hygiene

The internal, Claude-facing documentation a project accumulates — `CLAUDE.md` (root and nested), `NOTES.md`, and `.claude/rules/*.md` — grows through append-only workflows: status sections that duplicate `features/COMPLETED.md`, post-mortems of bugs long since fixed, notes that no longer match the code. `/internal-docs-prune` finds and clears this drift. It is distinct from `docs-structure-reviewer` above, which audits user-facing documentation reachable from `README.md`; this tool never touches `docs/`, `README.md`, or `CONTRIBUTING.md`.

Run it with:

```
/internal-docs-prune
/internal-docs-prune unattended
```

What it does:

- **Spawns the read-only `internal-docs-reviewer` agent** over the in-scope files. The agent enforces each file's own stated rules (e.g. `CLAUDE.md`'s "high-level status only", `NOTES.md`'s "non-obvious findings only") plus two fixed criteria per file type — audience relevance and duplication for `CLAUDE.md`; currency and durability for `NOTES.md` — and never invents requirements beyond these. It never edits anything; it only produces findings.
- **Gates each finding by class.** Every finding carries a gating class that determines how much authority the skill has to act on it unattended:
  - `redundant` — content verifiable elsewhere (e.g. a status entry duplicating `features/COMPLETED.md`). Applied automatically, always as a plain deletion: the content already lives at its canonical source, so there is nothing to move or condense.
  - `stale` — contradicted by the current code or repository state. Applied automatically; the action varies with the finding (`delete`, `condense`, or occasionally `move`, as the agent proposes).
  - `judgment` — subjective enough that a human should decide. In interactive mode (the default), each is presented to you, and if you simply confirm, the agent's own proposed action is taken — its `condense` text, or, for a `judgment` + `move`, the proposed move — but never `delete`. In unattended mode, they are left untouched and listed in the summary for later review. Settled interactive decisions are remembered (see below), so a later run does not re-ask about the same call.
- **Moves content without loss.** A `move` finding relocates content to one of three destinations (`features/COMPLETED.md`, a named plan file, or a named `.claude/rules/` file) by writing the destination, verifying the text landed there, and only then removing it from the source — a move never drops content, even if interrupted.
- **Reports and, optionally, commits.** The run ends with a summary of what was deleted, moved, condensed, and retained. Committing stays user-gated; if you ask Claude to commit the result, it uses the `docs(prune):` prefix so prune commits are discoverable by prefix in history.
- **Idempotent.** Run it again right after and it should surface no new `redundant` or `stale` findings. `judgment` calls you settled interactively are remembered — the skill keeps a record of them under `.claude/agent-memory/devproc-internal-docs-reviewer/` (namespaced by the agent it pairs with, though the skill, not the stateless reviewer agent, owns it) and suppresses an already-decided call on later runs unless its anchor text has since changed, so repeat runs don't re-litigate them. Only genuinely unresolved calls (deferred in unattended mode, or newly arisen) resurface.

Run it periodically, or whenever `CLAUDE.md` or `NOTES.md` feels like it's carrying more than it should — see [workflow.md](workflow.md#keep-internal-docs-tidy) for when.
