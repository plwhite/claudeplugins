# Completed features

Features that have been completed, described to reflect what was actually
developed. Headings must end with the date of completion in YYYY-MM-DD format.

---

### Create dev process manager agent [dev-process-manager] — 2026-06-03

Added a top-level Opus "dev process manager" agent (`devproc/agents/dev-process-manager.md`, run via `claude --agent dev-process-manager` or `claude-run --manager`) that orchestrates the feature workflow: it establishes the feature (creating/starting one if asked), agrees an autonomy boundary with the user, spawns a (normally Sonnet) teammate per sub-task briefed to run `/feature-checkpoint`, reviews the actual changes, shuts each teammate down, and pauses for the user at requirement/design decisions. The container infra gained `claude-run` options `--manager`/`--agent NAME` (with a `dpm` alias) and `--model NAME`, passed through to `run-claude.sh` via `CLAUDE_AGENT`/`CLAUDE_MODEL` on both initial launch and `--continue` relaunch. Testing surfaced that top-level `--agent` does not apply an agent's `model:` to the session, so `claude-run` derives the model from the agent definition and passes `--model` explicitly — keeping the agent file the single source of truth. Resolves #19.

### Fix bugs in container implementation [container-bugs] — 2026-06-01

Fixed three issues in container mode (#17). Automatic login failed because `claude-run` mounted `~/.claude/.credentials` (no `.json`) on both sides — Docker created an empty directory at the missing source and mounted that, so credentials never reached the container; the mount now points at `~/.claude/.credentials.json`. The tmux session was destroyed whenever Claude exited (Claude was the session's top-level process); a new baked-in `run-claude.sh` wraps Claude in a keep-alive loop that auto-relaunches it with `claude --continue` (resuming the conversation), traps SIGINT between runs so Ctrl-C cannot kill the session, and uses a sub-5-second crash-guard to avoid a tight respawn loop — only `claude-stop` now tears the session down. Also documented the Shift-highlight copy/paste tip and corrected the `claude-run` attach hint to print a project path rather than a container name.

### Allow running Claude in a container [claude-container] — 2026-05-28

Added a Docker-based container mode that runs Claude with full ("YOLO") permissions inside an isolated environment. The `docker/` directory contains a Dockerfile (Ubuntu base, Claude Code, python3, tmux) that bakes in the `devproc` plugin and a bypass-permissions `~/.claude/` config; UID/GID are parameterised at build time so files written in the container are owned by the host user. Four wrapper scripts in `bin/` (`claude-build`, `claude-run`, `claude-attach`, `claude-stop`) handle the full container lifecycle; all accept an optional project path and work correctly when symlinked from `/usr/local/bin` or `~/.local/bin`. Credentials are mounted read-only from the host; git identity is passed via env vars; git remote credentials are not passed, limiting Claude to local git operations. Resolves #15.

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
