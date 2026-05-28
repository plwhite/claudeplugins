# Allow running Claude in a container — Feature Plan

## Handoff

**Last updated:** 2026-05-28
**Session summary:** All sub-tasks complete. Dockerfile, baked-in config, four wrapper scripts, credentials mounting, marketplace.json fix, and documentation all done. Feature ready to close.
**Sub-task in progress:** None
**First action next session:** N/A — feature complete.
**Open questions / decisions pending:** None.
**Dead ends to avoid:** Do not mount the whole `~/.claude/` directory from the host — it would shadow the baked-in `settings.json` and `.claude.json`. Mount only the specific `.credentials` file. Do not give `ARG UID`/`ARG GID` default values — omitting defaults causes a visible build failure if the args are not passed, which is the desired behaviour.

## Existing prototype

A Docker container is provided in the `docker/` directory. The prototype is structurally sound and proves the concept:

- `Dockerfile` — Ubuntu base, installs curl/git/tmux/nodejs/npm/locales, sets en_GB locale, installs Claude Code via npm, renames the `ubuntu` user to `claude`, copies baked-in config files, runs `entrypoint.sh`.
- `files/home/entrypoint.sh` — changes to `/workspace`, starts a detached tmux session running `claude --dangerously-skip-permissions`, keeps the container alive with `tail -f /dev/null`.
- `files/home/.claude/settings.json` — bypass-permissions mode, experimental agent teams, devproc plugin enabled.
- `files/home/.claude.json` — marks onboarding complete, trusts `/workspace`.
- `files/home/.tmux.conf` — mouse off.

Manual usage (to be replaced by wrapper scripts):

```bash
docker build -t claudedev docker
docker run -d -v $(pwd):/workspace --name "claude-$(basename $(pwd))" claudedev
docker exec -it "claude-$(basename $(pwd))" tmux attach
reset   # cleans up terminal after detach
```

Identified gaps (from prototype comments):
1. Plugin path in `settings.json` is a hardcoded host path — wrong inside the container.
2. No global `~/.claude/CLAUDE.md` in the container.
3. No automated login — user must run `/login` interactively.
4. UID/GID hardcoded to the `ubuntu` default (1000) — fragile on multi-user systems.
5. Python missing from the base image.
6. No wrapper scripts.

## Design

The prototype structure is kept as-is. Each gap is addressed minimally:

### Plugin path and plugin baking

`files/home/.claude/settings.json` references the host path `/home/plw/work/claudeplugins` as the plugin source. Inside the container this path does not exist. The fix is:

1. Change the path in `settings.json` to `/home/claude/claudeplugins`.
2. Bake the plugins into the image at build time by COPYing the plugin directories (`devproc/`, `demo/`) from the repo into `/home/claude/claudeplugins/` in the Dockerfile.

To COPY from the repo root, the build context must be the repo root rather than the `docker/` subdirectory. The Dockerfile moves to referencing `docker/files/home` for the config files copy. The build script invokes: `docker build -t claudedev -f docker/Dockerfile .` (from the repo root).

Baking means plugin updates require a rebuild, which is acceptable — it keeps the container self-contained and avoids any RO mount complexity at run time.

### Global CLAUDE.md

Claude looks for a global CLAUDE.md at `~/.claude/CLAUDE.md`. The container needs one conveying maximal-privileges context. It is baked into the image as `files/home/.claude/CLAUDE.md` — a short file telling Claude it is running inside an isolated container with full permissions and no sandbox restrictions.

### Credentials

The host stores Anthropic credentials in `~/.claude/.credentials`. The run script mounts this file RO into the container:

```
-v ~/.claude/.credentials:/home/claude/.claude/.credentials:ro
```

Only the specific file is mounted — not the whole `~/.claude/` directory — so the baked-in `settings.json` and `.claude.json` are not shadowed.

### UID/GID

The Dockerfile renames `ubuntu` to `claude` but leaves the UID at 1000. If the host user has a different UID, files written in `/workspace` will be owned by 1000. Fix: add `ARG UID` and `ARG GID` (no defaults — omitting defaults makes a bare `docker build` fail visibly rather than silently using the wrong UID) and apply them via `usermod -u $UID` and `groupmod -g $GID` after the rename step. The build script passes `--build-arg UID=$(id -u) --build-arg GID=$(id -g)`.

### Python and base tooling

Add `python3` and `python3-pip` to the `apt-get install` line in the Dockerfile. This is the minimum identified as definitely needed. A variant/layer approach for heavier tooling stacks (data science, etc.) is left for a future feature.

### Wrapper scripts

Four scripts in `bin/`:

- `bin/claude-build` — runs `docker build` with `--build-arg UID=$(id -u) --build-arg GID=$(id -g)`, tags the image `claudedev`.
- `bin/claude-run` — accepts an optional project directory argument (defaults to `$(pwd)`); mounts it at `/workspace` RW; names the container `claude-<project-dirname>`; passes git identity via `GIT_AUTHOR_NAME`, `GIT_AUTHOR_EMAIL`, `GIT_COMMITTER_NAME`, `GIT_COMMITTER_EMAIL` env vars (read from host `git config`); runs detached. (Credentials mount added in Sub-task 5.)
- `bin/claude-attach` — accepts an optional project directory argument (defaults to `$(pwd)`); derives container name the same way as `claude-run`; runs `docker exec -it <name> tmux attach`; runs `reset` afterwards.
- `bin/claude-stop` — accepts an optional project directory argument (defaults to `$(pwd)`); runs `docker rm -f <container>`.

Scripts are not made executable — users run them as `bash bin/claude-build` etc. All four accept a path argument so they work consistently whether invoked from the project directory or elsewhere.

### Script location note

Scripts live in `bin/` at the repo root. `claude-build` derives the repo root with `readlink -f "$0"` before `dirname`, so it works correctly when symlinked from `/usr/bin` or anywhere else.

### No ANTHROPIC_API_KEY env var

The credentials file approach is preferred over passing a raw API key as an env var, since the credentials file is already what Claude Code uses natively and avoids exposing the key in `docker inspect` output.

## Sub-tasks

1. **Capture design from trial container** ✓ 2026-05-28 — prototype reviewed, design written.
2. **Fix baked-in config** ✓ 2026-05-28 — plugin path fixed in `settings.json`; plugin dirs baked in via Dockerfile COPY (build context → repo root); `files/home/.claude/CLAUDE.md` added; `python3`/`python3-pip` added to Dockerfile.
3. **Wrapper scripts** ✓ 2026-05-28 — `bin/claude-build`, `bin/claude-run`, `bin/claude-attach`, `bin/claude-stop` written; all accept optional project path; `claude-build` uses `readlink -f` for symlink safety.
4. **Fix UID/GID** ✓ 2026-05-28 — `ARG UID`/`ARG GID` (no defaults) in Dockerfile; `usermod -u`/`groupmod -g` applied after rename; build script passes `$(id -u)`/`$(id -g)`.
5. **Credentials mounting** ✓ 2026-05-28 — `bin/claude-run` mounts `~/.claude/.credentials` RO at `/home/claude/.claude/.credentials`.
6. **Documentation** ✓ 2026-05-28 — `docs/container.md` written; `README.md` updated with new intro bullet and docs table entry.
7. **Fix marketplace.json missing from container** ✓ 2026-05-28 — added `COPY --chown=claude:claude .claude-plugin /home/claude/claudeplugins/.claude-plugin` to Dockerfile; the repo-root `.claude-plugin/marketplace.json` was not being baked in, causing plugin discovery to fail.

**▶ NEXT:** N/A — feature complete.

> Run `/feature-checkpoint` after each sub-task completes.
