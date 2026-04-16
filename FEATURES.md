# Project features

Features being developed for this project. Each feature has a level three (`###`) heading and a short, normally one-paragraph description that explains what the feature is. The feature heading should have a slug (such as `initial-development` or `code-coverage-00` so the plan can be found when created.

---

## In progress

### Docs and usability improvements [docs-usability-issue6]

Reposition the repo from "a collection of Claude plugins" to "Claude best practice and recommendations, supported by plugins." A new user following the docs ends up with a well-configured Claude setup (sandbox, git write protection, `gh` integration) and a working devproc workflow. Covers sandbox network config research, a new getting-started guide, devproc setup documentation, and issue-aware skills. Sub-task detail in [plans/docs-usability-issue6.md](plans/docs-usability-issue6.md).

---

## Pending

*No features pending.*

---

## Explicitly deferred

*Features that are explicitly deferred; these are not expected to happen but may be resurrected.*

---

## Completed

### Code review agents and skills [code-review] — 2026-04-14

Four specialist code review agents (architectural using `claude-opus-4-6`, plus simplicity, general, and nitty using `claude-sonnet-4-6`) and three review skills (`/review-full`, `/review-component`, `/review-branch`). All skills auto-apply code-level findings iterating to convergence, and escalate architectural or interface-level changes for user confirmation. The architectural agent is opt-in via natural language. `devproc/README.md`, `CLAUDE.md`, and `plugin.json` updated to cover the new capabilities.

### Plugin documentation [plugin-documentation] — 2026-04-13

Added `README.md` to both plugins (`demo/` and `devproc/`) with full user-facing documentation covering what each plugin provides and how to use it. The `devproc/README.md` documents the full feature lifecycle workflow and all five skills with invocation examples. A docs-structure review was also run, surfacing and resolving issues in `README.md`, `CLAUDE.md`, `FEATURES.md`, `devproc/plugin.json`, and `feature-init/SKILL.md`.
