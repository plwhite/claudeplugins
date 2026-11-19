# Capabilities

This document describes the capabilities `devproc` provides beyond the [core feature workflow](workflow.md), for people using the plugin: the [Dev Process Manager](#dev-process-manager), [code review](#code-review), [documentation review](#documentation-review) and [internal docs hygiene](#internal-docs-hygiene).

---

## Dev Process Manager

The Dev Process Manager is a top-level agent that drives the feature workflow for you semi-autonomously. Instead of you asking Claude to do one sub-task at a time, you run Claude *as* the manager agent and tell it how far to go on its own — for example "work through sub-tasks 1–4 and check with me before 5", or "confirm the design with me first, then implement".

Run it as the session agent:

```
claude --agent dev-process-manager
```

In [container mode](container.md) use `--manager` (or `--agent dpm`, an alias for `--agent dev-process-manager`):

```
claude-run --manager
```

The manager runs as Opus automatically — `claude-run` takes the model from the agent's definition. See [container.md](container.md#session-model) for the detail and the `--model` override.

What it does:

- **Establishes the feature.** It reads the in-progress feature and its plan, or — if you ask — specs and designs a new one (e.g. "spec and design a feature from issue 19"), getting the design in front of you before any code is written. The spec and design skills review their own output first (see [workflow.md](workflow.md#review-before-you-read-it)); where your autonomy boundary covers those stages they run unattended, and a clean reviewer verdict stands in for your sign-off — but a blocking finding or an open question stops the run and comes to you regardless.
- **Agrees an autonomy boundary.** It settles with you up front how far to run unattended, then proceeds without asking at every step until it reaches that boundary.
- **Delegates each sub-task to a teammate.** For each sub-task it spawns a teammate (normally Sonnet), briefs it with the single sub-task, its sign-off criteria, and the context it needs, and requires it to run `/feature-checkpoint` when done.
- **Reviews the work.** It inspects the actual changes rather than trusting the teammate's report, running a code review where warranted, and sends corrections back if needed. It accepts a sub-task as done only once all of its sign-off boxes are ticked.
- **Handles new work found mid-run.** It never starts a new sub-task you have not agreed. See [workflow.md](workflow.md#when-the-sub-task-list-changes).
  - New work that affects the flow of work in progress (a remaining planned sub-task depends on it, or would be done differently because of it) stops the run and asks you.
  - Other new sub-tasks are proposed in the report at the boundary.
  - Small contained fixes are made and listed in that report without stopping.
  - Anything that would rework another component halts the run, whatever it is called.
- **Closes teammates down** once their task is verified complete, and **checks in with you** at requirement/design decisions, when you asked to review something, or when it hits a blocker.

This lets you delegate a batch of work and stay in control of the high-level direction, with the manager keeping the overall context on track while teammates handle the detail. It uses more tokens than driving sub-tasks yourself, in exchange for autonomy.

---

## Code review

Code review is performed by skills described below. When run, these skills instantiate three specialist agents (simplicity, general, and nitty) which run in parallel. Code-level findings — contained within a single function or file — are applied automatically, then the agents re-run over the changed files. This iterates until no new findings appear (capped at five rounds).

If you request an architectural review, then a fourth architectural agent is run to flag architectural issues — component boundaries, public interfaces, structural design — and its results are presented for confirmation before anything is changed.

Code review should normally be run after every feature is complete, and occasionally more broadly to catch code quality drift. This uses a lot of tokens, but does greatly improve quality.

### Review options

- Review all changes in the current branch relative to the base branch (`main`, else `master`).

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

For a deeper structural assessment, ask for architectural review. It uses `opus` and is slower. If your request does not make clear whether you want it, Claude asks. For example:

```
/review-branch including architectural review
```

---

## Documentation review

To review the documentation, run `/review-docs`. It takes a scope and, optionally, the kinds of review to run:

```
/review-docs
/review-docs full
/review-docs the container docs, accuracy only
```

### Scope

The scope is `full` (the whole documentation set), `change` (the docs touched by, or describing, the current change; the default), or an area described in plain language.

### Classes of document

A project has three classes of document, and docs review treats them differently:

- **User docs** — `README.md` and every document reachable from it. They are for people using what the project delivers, so they must be correct, complete and self-sufficient. They must never rely on agent docs or feature records for information.
- **Agent docs** — `CLAUDE.md` (at any depth), `NOTES.md` and `.claude/rules/*.md`. They are for Claude only; no person should need to read them. They may rely on the user docs.
- **Feature records** — everything under `features/`, including `FEATUREMODEL.md` (which `/feature-init` overwrites). They are working records and history, and docs review never reviews or edits them.

A user doc that only describes agent docs or feature records as something the project creates (as the plugin guide describes the `features/` layout) is not relying on them.

**Code** — source, prompts, templates and data files, even when written in Markdown — is not documentation: docs review never reviews or edits it, though the accuracy and architectural agents read it as the thing the docs describe.

### The four kinds

Four kinds of review exist, each run by its own stateless, findings-only agent. All four run unless you name a subset. In `change` scope the agent docs kind is also skipped, and reported as skipped, when no agent doc is in the change and nothing the change touches is described by one. The first three kinds review the user docs; the fourth reviews the agent docs:

- **Architectural** (`docs-review-architectural`, `opus`) — the user docs still hang together: entry points, orphaned documents, broken links, hierarchy, one source of truth per fact, and docs in non-obvious places that a change should have touched. It also checks that the user docs are fit for purpose (everything a user would expect is documented, to the standard of comparable features, and nothing unneeded is there) and flags a user doc that relies on an agent doc or feature record.
- **Accuracy** (`docs-review-accuracy`, `sonnet`) — the user docs still match the code and its behaviour.
- **Style** (`docs-review-style`, `sonnet`) — the user docs read clearly and consistently, and procedures are written as procedures.
- **Agent docs** (`docs-review-agent-docs`, `sonnet`) — the agent docs still match the repository (file lists, paths, commands, descriptions of components), nothing a person needs is held only in them, and they link to the user docs rather than repeating them. It also asks whether they are fit for purpose: an agent finds everything it needs, and nothing it does not, such as history of completed work. A feature listed as in progress is expected, since the review runs before the feature closes. Style and bloat in agent docs are not its concern; they are left to [`/internal-docs-prune`](#internal-docs-hygiene).

### Concision checks

`/review-docs` checks that user docs are concise, against the `### User docs` section of the [feature model](../devproc/skills/feature-init/FEATUREMODEL.md). Claude follows the same standard when writing user docs. Two agents each check part of it:

- **Style** flags prose that could say the same in fewer words.
- **Architectural** flags content beyond a doc's purpose, code-derivable detail, and duplication. It searches for duplicates actively (changed docs against the whole set, or every doc in `full` scope). How findings are handled is under [Applied and escalated](#applied-and-escalated).

### Applied and escalated

**Applied automatically:** minor fixes inside a single existing doc:

- a wording fix, a corrected command or path, a repointed or added link, or wording tightened without losing information;
- a duplicate whose owner is clear and holds all of the copy: the copy becomes a short statement and a link to the owner.

The agents then re-run over the changed docs, up to five passes in all. From the second pass on, only CRITICAL or MAJOR findings and corrections to an earlier fix are applied, so prose review does not churn; anything else is listed in the report as not applied.

**Escalated to you for confirmation:** significant findings:

- creating, deleting, moving or splitting a doc, or changing how information is divided between docs;
- rewriting a section;
- any other removal of content, including a duplicate whose owner is unclear or lacks part of the copy;
- a mismatch where the code may be what is wrong.

Two kinds are always escalated: every boundary finding (a user doc relying on an agent doc or feature record, information a person needs held only in an agent doc, or agent doc content repeating the user docs), because each changes which class of document holds the information; and removing content from an agent doc, unless it exactly duplicates what is kept.

### As a sign-off

**Docs review** is one of the five sign-off categories; a feature's sign-off strategy sets a bar for each kind or skips it explicitly. See [The sign-off strategy](workflow.md#the-sign-off-strategy) for the strategy, and the feature model's `### Sign-off criteria` section in [FEATUREMODEL.md](../devproc/skills/feature-init/FEATUREMODEL.md) for when each kind is warranted.

---

## Internal docs hygiene

The internal, Claude-facing documentation a project accumulates — `CLAUDE.md` (root and nested), `NOTES.md`, and `.claude/rules/*.md` — grows through append-only workflows: status sections that duplicate `features/COMPLETED.md`, post-mortems of bugs long since fixed, notes that no longer match the code. Run `/internal-docs-prune` periodically to clear this drift. It complements `/review-docs`: the agent docs kind of `/review-docs` checks that the agent docs are correct and respect the user-docs boundary, usually as a feature sign-off, while `/internal-docs-prune` removes accumulated bloat and history. This tool never touches `docs/`, `README.md`, or `CONTRIBUTING.md`.

Run it with:

```
/internal-docs-prune
/internal-docs-prune unattended
```

What it does:

- **Spawns the read-only `internal-docs-reviewer` agent** over the in-scope files. The agent enforces each file's own stated rules (e.g. `CLAUDE.md`'s "high-level status only", `NOTES.md`'s "non-obvious findings only") and only produces findings.
- **Gates each finding by class:**
  - `redundant` — content that already lives at its canonical source (e.g. a status entry duplicating `features/COMPLETED.md`). Deleted automatically.
  - `stale` — contradicted by the current code or repository state. Applied automatically with the action the agent proposes: `delete`, `condense` or, occasionally, `move`.
  - `judgment` — subjective enough that a human should decide. In interactive mode (the default), each is put to you; if you confirm, the agent's proposed `condense` or `move` is taken, but never `delete`. In unattended mode they are left untouched and listed in the summary.
- **Moves content without loss.** A `move` relocates content to `features/COMPLETED.md`, a named plan file, or a named `.claude/rules/` file, and never drops it, even if interrupted.
- **Reports and, optionally, commits.** The run ends with a summary of what was deleted, moved, condensed, and retained. Committing stays user-gated; if you ask Claude to commit the result, it uses the `docs(prune):` prefix.
- **Idempotent.** Run it again right after and it should surface no new `redundant` or `stale` findings. `judgment` calls you settled are remembered, in `.claude/agent-memory/devproc-internal-docs-reviewer/`, and are not re-asked unless their anchor text changes; only unresolved calls resurface.

See [workflow.md](workflow.md#keep-internal-docs-tidy) for when to run it.
