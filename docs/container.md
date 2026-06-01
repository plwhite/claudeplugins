# Container mode

Container mode runs Claude inside an isolated Docker container with full permissions ("YOLO" mode). Claude can install tools, modify files, and take any action it needs — but the blast radius is limited to the mounted project directory. This is useful when you want Claude to work autonomously on a task without the friction of sandbox restrictions or permission prompts.

The container:

- Runs Claude in a detached tmux session so it continues working after you detach.
- Mounts the project directory read-write at `/workspace`.
- Bakes in the `devproc` plugin so the full feature workflow is available.
- Uses a "YOLO" `~/.claude/` config: `--dangerously-skip-permissions`, bypass-permissions mode, onboarding skipped.
- Passes your Claude login credentials (from `~/.claude/.credentials.json`) automatically.
- Does not pass git remote credentials — only local git operations (`git status`, `git diff`, `git log`) are available inside the container.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed and running.
- This repository cloned to a stable location (see [Clone this repository in setup.md](setup.md#clone-this-repository)).

## Build the image

Run this once, and again whenever you update plugins or pull changes from this repo:

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

## Attach to Claude

From the project directory you want Claude to work on:

```bash
bash /some/path/claudeplugins/bin/claude-attach
```

Or with an explicit path:

```bash
bash /some/path/claudeplugins/bin/claude-attach /path/to/project
```

This attaches to the tmux session running in the container. Detach at any time with `Ctrl-b d` — Claude keeps running in the background. The `reset` at the end of the attach script cleans up the terminal after you detach.

## Stop and remove the container

From the project directory that the container is running on:

```bash
bash /some/path/claudeplugins/bin/claude-stop
```

Or with an explicit path:

```bash
bash /some/path/claudeplugins/bin/claude-stop /path/to/project
```

This stops and removes the container. Work is preserved in the project directory — only the container itself is removed.

## Convenience: symlink the scripts

If you want to call the scripts without specifying the full path each time, symlink them into a directory on your `PATH`:

```bash
ln -s /some/path/claudeplugins/bin/claude-build  ~/.local/bin
ln -s /some/path/claudeplugins/bin/claude-run    ~/.local/bin
ln -s /some/path/claudeplugins/bin/claude-attach ~/.local/bin
ln -s /some/path/claudeplugins/bin/claude-stop   ~/.local/bin
```

Ensure `~/.local/bin` is on your `$PATH`; if it is not, add `export PATH="$HOME/.local/bin:$PATH"` to your shell profile (`.bashrc`, `.zshrc`, etc.).

The scripts handle symlinks correctly — they resolve their own path before locating the repo root, so the build context is always correct.

After symlinking you can run `claude-build`, `claude-run`, `claude-attach`, and `claude-stop` directly from any directory.
