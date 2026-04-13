# Project features

Features being developed for this project. Each feature has a level three (`###`) heading and a short, normally one-paragraph description that explains what the feature is. The feature heading should have a slug (such as `initial-development` or `code-coverage-00` so the plan can be found when created.

---

## In progress

*There should normally be only one feature here, and it should have a plan matching the slug in the plans directory. In some cases there may be no feature in progress, or in very rare cases more than one at once.*

---

## Pending

### Code review agents and skills [code-review]

A set of code review agents (architectural, simplicity, general, nitty) operating at different levels of scrutiny and using appropriate models, plus skills that invoke them and apply their feedback — supporting both full-codebase and feature-diff review modes. Requirements detail in [plans/code-review.md](plans/code-review.md).

*Features that are waiting for development.*

---

## Explicitly deferred

*Features that are explicitly deferred; these are not expected to happen but may be resurrected.*

---

## Completed

### Plugin documentation [plugin-documentation] — 2026-04-13

Added `README.md` to both plugins (`demo/` and `devproc/`) with full user-facing documentation covering what each plugin provides and how to use it. The `devproc/README.md` documents the full feature lifecycle workflow and all five skills with invocation examples. A docs-structure review was also run, surfacing and resolving issues in `README.md`, `CLAUDE.md`, `FEATURES.md`, `devproc/plugin.json`, and `feature-init/SKILL.md`.
