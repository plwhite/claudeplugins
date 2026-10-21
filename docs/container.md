# Container mode

Container mode runs Claude inside an isolated Docker container with full permissions ("YOLO" mode). Claude can install tools, modify files, and take any action it needs — but the blast radius is limited to the mounted project directory. This is useful when you want Claude to work autonomously on a task without the friction of sandbox restrictions or permission prompts.

The container:

- Runs Claude in a detached tmux session so it continues working after you detach. The session survives Claude exiting — if Claude exits it is automatically relaunched (resuming the same conversation), and `exit`/Ctrl-D/Ctrl-C cannot destroy the session. If the container itself stops (a host reboot, say), you can [resume the session](#resume-after-the-container-stops).
- Mounts the project directory read-write at `/workspace`. That directory is the *workspace* in the feature model's sense — the one holding `CLAUDE.md`, `NOTES.md` and `features/` — whether or not it is itself a git repository (see [workflow.md](workflow.md#where-the-workspace-is)); container mode is a common place for a workspace that merely contains repositories.
- Bakes in the `devproc` plugin so the full feature workflow is available.
- Uses a "YOLO" `~/.claude/` config: `--dangerously-skip-permissions`, bypass-permissions mode, onboarding skipped.
- Copies in your Claude login credentials (from `~/.claude/.credentials.json`) automatically when the container starts.
- Passes `GH_TOKEN` through so Claude can read GitHub issues — see [GitHub access](#github-access).
- Does not pass git remote credentials, and is instructed only to run local read operations (`git status`, `git diff`, `git log`) inside the container.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed and running.
- This repository cloned to a stable location (see [Clone this repository in setup.md](setup.md#clone-this-repository)).

## Build the image

Run this once, and again whenever you update plugins or pull changes from this repo. A rebuilt image is used only by containers created afterwards; an existing container keeps its image even when [resumed](#edge-cases-and-limits).

```bash
bash /some/path/claudeplugins/bin/claude-build
```

The build tags the image as `claudedev`. It bakes your current user's UID and GID into the image so that files written inside the container are owned by you on the host.

## Run the container

From the project directory you want Claude to work on:

```bash
bash /some/path/claudeplugins/bin/claude-run
```

Or pass the path explicitly:

```bash
bash /some/path/claudeplugins/bin/claude-run /path/to/project
```

This starts a detached container named `claude-<project-dirname>`, mounts the project at `/workspace`, and passes your git identity. Claude starts immediately in the tmux session.

`claude-run` fails if a container for the project already exists, whether running or stopped. The message points to what fits the container's state: attach with `claude-attach` if it is running, [resume it with `--resume`](#resume-after-the-container-stops) if it is stopped, or [start fresh](#stop-and-remove-the-container) with `claude-stop` and then `claude-run`.

### GitHub access

Skills such as `/feature-spec` read GitHub issues with `gh`, which is installed in the image. The host's `gh` login is *not* copied in, so authentication comes from the **`GH_TOKEN` environment variable**, which `claude-run` passes into the container. It is expected to be set.

`claude-run` finds it in one of two places:

1. **`GH_TOKEN` already exported in your shell** — used as-is, and takes precedence.
2. **`~/.config/gh/env`** — if `GH_TOKEN` is not already set and this file exists, `claude-run` sources it and takes the token from there. This is the convenient option, since it needs no shell setup:

   ```bash
   mkdir -p ~/.config/gh
   printf 'GH_TOKEN=github_pat_yourtoken...\n' > ~/.config/gh/env
   chmod 600 ~/.config/gh/env
   ```

Use a read-only, issues-only PAT — the same token described under [Install and authenticate GitHub CLI in setup.md](setup.md#install-and-authenticate-github-cli).

If neither source provides a token, `claude-run` prints a warning and starts the container anyway: a session that never touches GitHub is unaffected. Claude will tell you it needs the token if it hits a task that requires one, rather than trying to work around its absence.

### Run as the Dev Process Manager

By default the container runs an ordinary Claude session. To instead run Claude as the [Dev Process Manager](capabilities.md#dev-process-manager) — the orchestrator that drives the feature workflow semi-autonomously, spawning teammates per sub-task — pass `--manager`:

```bash
bash /some/path/claudeplugins/bin/claude-run --manager
```

This is the natural pairing with container mode: the manager works through sub-tasks autonomously inside the isolated container, while still checking in with you at the boundary you set.

To run as a different top-level agent, name it explicitly:

```bash
bash /some/path/claudeplugins/bin/claude-run --agent some-agent-name
```

`--agent dpm` is accepted as a short alias for `--agent dev-process-manager`. The agent must be discoverable in the container (the baked-in `devproc` plugin's agents always are). Options come before the optional project path, e.g. `claude-run --manager /path/to/project`. The selected agent persists across the container's automatic relaunches and across a [restart with `--resume`](#resume-after-the-container-stops), so a resumed session keeps running as the same agent.

#### Session model

By default `claude-run` runs the session as the **model declared in the agent's own definition** — the manager runs as Opus because `devproc/agents/dev-process-manager.md` sets `model: opus`. This is necessary because `--agent` on its own applies the agent's persona and tools but *not* its model to the top-level session, so `claude-run` reads the agent's `model:` field and passes it through explicitly.

To override the model, or to set one for an agent whose definition is not in this repo (where it cannot be derived), pass `--model`:

```bash
bash /some/path/claudeplugins/bin/claude-run --agent some-agent-name --model opus
```

Like the agent, the model persists across the container's automatic relaunches and across a restart with `--resume`.

## Attach to Claude

From the project directory you want Claude to work on:

```bash
bash /some/path/claudeplugins/bin/claude-attach
```

Or with an explicit path:

```bash
bash /some/path/claudeplugins/bin/claude-attach /path/to/project
```

This attaches to the tmux session running in the container.

**To leave Claude without stopping it, detach with `Ctrl-b d`.** Claude keeps running in the background and you can re-attach later.

`exit` and Ctrl-D are not the way to leave: they exit Claude itself, interrupting whatever it was doing. They are safe, though. Claude is relaunched automatically, resuming the same conversation, so the session is always running when you re-attach. The same happens if Claude crashes. Only removing the container, with `claude-stop`, ends the session and deletes its conversation (see [Stop and remove the container](#stop-and-remove-the-container)).

The `reset` at the end of the attach script cleans up the terminal after you detach.

### Copying and pasting

Copying text out of the tmux session can be awkward: a normal click-drag selection is captured by tmux rather than your terminal. To select text for the system clipboard, **hold Shift while highlighting** — this bypasses tmux and uses your terminal emulator's own selection, so the usual copy (and paste) shortcuts work as expected.

## Refresh credentials mid-session

Credentials are copied into the container once, at startup — they are not bind-mounted, so a token refreshed on the host afterwards does not automatically propagate in. If the OAuth token expires during a long-running session, refresh it in place rather than restarting the container:

```bash
bash /some/path/claudeplugins/bin/claude-creds-refresh
```

Or with an explicit path:

```bash
bash /some/path/claudeplugins/bin/claude-creds-refresh /path/to/project
```

This forces a host-side token refresh (in case the host's own copy is also stale), then copies the refreshed credentials into the running container.

A container restarted with `claude-run --resume` gets fresh credentials automatically, so this is only needed for a container that stays running.

## Resume after the container stops

If the container stops while a session is in progress — the host reboots, or Docker restarts during a system upgrade — the container still exists, stopped, and so does the conversation inside it. To carry on:

```bash
bash /some/path/claudeplugins/bin/claude-run --resume
```

Or with an explicit path:

```bash
bash /some/path/claudeplugins/bin/claude-run --resume /path/to/project
```

This runs the usual login check, copies fresh credentials into the container, and restarts it. Attach with `claude-attach` as usual: you should see your earlier conversation.

The conversation that comes back is the one the session was in when the container stopped. If you switched conversations with `/clear` or `/resume`, it is the one that was active last. It is never another conversation that happened to run inside the container, such as the short throwaway run a container started with `--manager` or `--agent` makes at startup to load the plugins.

**What comes back, and what does not.** The conversation comes back; interrupted work does not. Whatever Claude was doing when the container stopped is not restarted, so tell Claude to carry on.

**Settings stay as they were.** Credentials are refreshed; the agent, model, `GH_TOKEN` and git identity are not. They keep the values the container was created with, so a changed `GH_TOKEN` takes effect only in a new container. `--manager`, `--agent` and `--model` are ignored with a warning when given with `--resume`.

### Edge cases and limits

- **Nothing to resume.** A conversation can be resumed only once at least one message has been sent in it. If there is nothing to resume (for example the container stopped before you sent anything), the attached pane shows "No previous session to resume. Press Enter to start a new conversation."
- **If resuming fails.** If Claude exits within a few seconds of resuming, the pane says so and waits. Press Enter to try resuming again — if the cause is expired credentials, [refresh them](#refresh-credentials-mid-session) first. Or type `new` and Enter to start a new conversation instead; the old conversation then can no longer be resumed, though its transcript stays inside the container.
- **Already running, or no container.** If the container is already running, `claude-run --resume` only prints the attach hint. If there is no container for the project, it fails and does not create one.
- **Removed containers.** Removing the container deletes the conversation for good; see [Stop and remove the container](#stop-and-remove-the-container).
- **Rebuilt images.** A restarted container keeps its original image. To use an image rebuilt with `claude-build`, run `claude-stop` and then `claude-run`. This deletes the conversation.
- **Older containers.** Only containers created from an image that includes this feature can be resumed. A container created from an older image restarts with a new conversation.

## Stop and remove the container

From the project directory that the container is running on:

```bash
bash /some/path/claudeplugins/bin/claude-stop
```

Or with an explicit path:

```bash
bash /some/path/claudeplugins/bin/claude-stop /path/to/project
```

This stops and removes the container. Work is preserved in the project directory — only the container itself is removed. The conversation is deleted with it and cannot be resumed, because Claude keeps conversations inside the container. To get a stopped session back, use [`claude-run --resume`](#resume-after-the-container-stops), not `claude-stop`.

To start fresh, run `claude-stop` and then `claude-run`.

## Convenience: symlink the scripts

If you want to call the scripts without specifying the full path each time, symlink them into a directory on your `PATH`:

```bash
ln -s /some/path/claudeplugins/bin/claude-build         ~/.local/bin
ln -s /some/path/claudeplugins/bin/claude-run           ~/.local/bin
ln -s /some/path/claudeplugins/bin/claude-attach        ~/.local/bin
ln -s /some/path/claudeplugins/bin/claude-creds-refresh ~/.local/bin
ln -s /some/path/claudeplugins/bin/claude-stop          ~/.local/bin
```

Ensure `~/.local/bin` is on your `$PATH`; if it is not, add `export PATH="$HOME/.local/bin:$PATH"` to your shell profile (`.bashrc`, `.zshrc`, etc.).

The scripts handle symlinks correctly — they resolve their own path before locating the repo root, so the build context is always correct.

After symlinking you can run `claude-build`, `claude-run`, `claude-attach`, `claude-creds-refresh`, and `claude-stop` directly from any directory.
