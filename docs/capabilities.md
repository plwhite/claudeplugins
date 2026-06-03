# Capabilities

This document describes additional capabilities provided by `devproc` beyond the [core feature workflow](workflow.md).

---

## Dev process manager

The dev process manager is a top-level agent that drives the feature workflow for you semi-autonomously. Instead of you asking Claude to do one sub-task at a time, you run Claude *as* the manager agent and tell it how far to go on its own — for example "work through sub-tasks 1–4 and check with me before 5", or "confirm the design with me first, then implement".

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

- **Establishes the feature.** It reads the in-progress feature and its plan, or — if you ask — creates and starts a new one (e.g. "create and start a feature from issue 19"), getting the design in front of you before any code is written.
- **Agrees an autonomy boundary.** It settles with you up front how far to run unattended, then proceeds without asking at every step until it reaches that boundary.
- **Delegates each sub-task to a teammate.** For each sub-task it spawns a teammate (normally Sonnet), briefs it with the single sub-task and the context it needs, and requires it to run `/feature-checkpoint` when done.
- **Reviews the work.** It inspects the actual changes rather than trusting the teammate's report, running a code review where warranted, and sends corrections back if needed.
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

The docs structure reviewer checks discoverability, architectural completeness, procedural rigour, and consistency, and produces a prioritised list of findings without modifying any files (unless you tell Claude to run it and implement its findings).
