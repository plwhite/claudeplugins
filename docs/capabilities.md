# Capabilities

This document describes additional capabilities provided by `devproc` beyond the [core feature workflow](workflow.md).

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
