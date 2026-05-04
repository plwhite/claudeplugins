# Project features

Features being developed for this project. Each feature has a level three (`###`) heading and a short, normally one-paragraph description that explains what the feature is. The feature heading should have a slug (such as `initial-development` or `code-coverage-00` so the plan can be found when created.

---

## In progress

*No features currently in progress.*

---

## Pending

*No features pending.*

---

## Explicitly deferred

*Features that are explicitly deferred; these are not expected to happen but may be resurrected.*

---

## Completed

### Add a .claudeignore setup [claudeignore-docs] — 2026-05-04

Added a new top-level `setup-files/` directory holding files users copy into their environments rather than recreating from heredocs. Initial contents: a recommended `.claudeignore` template (covering dependencies, build output, lockfiles, large data, IDE cruft) for each project root, the existing `block-git-writes.sh` hook (extracted out of the inlined heredoc in `docs/setup.md`), and a directory README mapping each file to its destination and the documenting section of `docs/setup.md`. Substantially restructured `docs/setup.md` to support the new copy-from-repo pattern: pulled the `git clone` step out of the plugin section into its own "Clone this repository" sub-section near the start, replaced the heredoc with `cp` + `chmod +x`, renamed the plugin section to "Enable the devproc plugin", added a "Configure .claudeignore" sub-section, and updated the intro and "Detailed steps" navigation list to eight ordered steps. Resolves #9.

### Document security permissions in settings.json [security-permissions-docs] — 2026-05-04

Added a "Block reads of sensitive files" section to `docs/setup.md` documenting a `permissions.deny` stanza for `~/.claude/settings.json` that blocks Claude reads of `.env`, generic secrets files, PEM/key/p12 material, SSH private keys, and `credentials.json`. Wired the new section into the setup.md intro bullets, "Detailed steps" navigation list, and the root README docs table. Resolves #10.

### Docs and usability improvements [docs-usability-issue6] — 2026-04-16

Repositioned the repo from "a collection of Claude plugins" to "Claude best practice and recommendations, supported by plugins." Added a new `docs/` directory with `setup.md` (environment configuration: sandbox, git write protection, `gh` install, devproc install), `workflow.md` (imperative feature lifecycle guide), and `capabilities.md` (code review and docs review). Rewrote root `README.md` to lead with the best-practice framing. Trimmed `devproc/README.md` to a pure plugin reference with pointers to the new docs. Updated `feature-create` and `feature-start` skills to resolve GitHub issue references via `git remote -v` and `gh`, so users can pass "issue 6" or a natural-language description directly as a feature argument.

### Code review agents and skills [code-review] — 2026-04-14

Four specialist code review agents (architectural using `claude-opus-4-6`, plus simplicity, general, and nitty using `claude-sonnet-4-6`) and three review skills (`/review-full`, `/review-component`, `/review-branch`). All skills auto-apply code-level findings iterating to convergence, and escalate architectural or interface-level changes for user confirmation. The architectural agent is opt-in via natural language. `devproc/README.md`, `CLAUDE.md`, and `plugin.json` updated to cover the new capabilities.

### Plugin documentation [plugin-documentation] — 2026-04-13

Added `README.md` to both plugins (`demo/` and `devproc/`) with full user-facing documentation covering what each plugin provides and how to use it. The `devproc/README.md` documents the full feature lifecycle workflow and all five skills with invocation examples. A docs-structure review was also run, surfacing and resolving issues in `README.md`, `CLAUDE.md`, `FEATURES.md`, `devproc/plugin.json`, and `feature-init/SKILL.md`.
