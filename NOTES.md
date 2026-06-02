# Notes

Non-obvious findings. Do not record things derivable from reading the code.

---

## gh CLI and sandbox

`gh issue view` and `gh api` time out in sandbox mode even when `WebFetch(domain:api.github.com)` is listed in project permissions. The `WebFetch(...)` permission only covers Claude's WebFetch tool — it has no effect on outbound network access from Bash processes. The sandbox blocks Bash network independently.

The correct configuration is `sandbox.network.allowedDomains` in `~/.claude/settings.json` (global, since `gh` is used across projects):

```json
{
  "sandbox": {
    "enabled": true,
    "network": {
      "allowedDomains": ["github.com", "api.github.com"]
    }
  }
}
```

Wildcards are supported (e.g. `*.npmjs.org`). Domain arrays merge across settings scopes, so adding entries globally does not override project-level entries.

On macOS with a MITM proxy and custom CA, Go-based tools like `gh` may additionally need `"enableWeakerNetworkIsolation": true` under `sandbox.network` to reach the system TLS trust service — but this relaxes isolation and should only be used if needed.

---

## Docker build context must be repo root when baking plugins

The container Dockerfile COPYs plugin directories (`devproc/`, `demo/`) from the repo. This requires the build context to be the repo root, not `docker/` — so the command is `docker build -f docker/Dockerfile .` not `docker build docker`. The config files copy path therefore changes from `files/home` to `docker/files/home`. The old `docker build docker` form will fail silently on the COPY steps if the repo root is not the context.

`ARG UID`/`ARG GID` are declared without defaults so that a bare `docker build` fails visibly rather than silently using UID 1000. The build script always passes `$(id -u)`/`$(id -g)`.

## Container credentials mount path (#17)

Claude Code on Linux reads OAuth login from `~/.claude/.credentials.json`. The
original `claude-run` mounted `$HOME/.claude/.credentials` →
`/home/claude/.claude/.credentials` — the `.json` suffix was missing on both
sides. Because the host source path did not exist, Docker silently created an
empty *directory* there (visible on the host as `~/.claude/.credentials/`, owned
`nobody:nogroup`) and bind-mounted that empty dir, so no credentials ever
reached the container and automatic login failed. Fix: mount
`.credentials.json` on both sides. The stray empty `~/.claude/.credentials/`
directory created by the old bug is a host-side artifact and can be removed
manually.

## Container session keep-alive (#17)

Claude is the tmux session's top-level process, so when it exits (`exit`,
Ctrl-D, `/quit` or a crash) the pane closes and the session is destroyed — an
accidental keypress would discard the working session. `run-claude.sh` wraps
Claude in a loop that **auto-relaunches** it on exit, resuming the previous
conversation, so the session is always running when you attach. `entrypoint.sh`
runs `bash /home/claude/run-claude.sh` as the session command.

Non-obvious details:

- Relaunch uses `claude --continue`, which auto-resumes the most recent
  conversation in the current directory. `-r`/`--resume` with no session ID
  instead opens an interactive picker — wrong for an unattended loop. The first
  launch is plain `claude` (nothing to resume yet).
- **Ctrl-C handling is the subtle part.** Between Claude runs the loop sets
  `trap '' INT` so Ctrl-C cannot kill the wrapper (and thus the session); it
  resets `trap - INT` immediately before launching Claude so Claude still gets
  normal Ctrl-C handling. Without this, a Ctrl-C while the wrapper was between
  runs terminated the script and destroyed the tmux session irrecoverably — the
  original keep-alive bug found in testing.
- A crash-guard avoids a tight respawn loop: if Claude exits within 5s of
  launch it is treated as a startup crash and the loop waits on a prompt
  (`while ! read -r _; do sleep 1; done`, which also ignores EOF/Ctrl-D) instead
  of respawning immediately. A normal exit pauses ~2s then resumes.

`run-claude.sh` is invoked via `bash`, so unlike `entrypoint.sh` it does not
need the executable bit set in the Dockerfile.

## setup-files/ as a checked-in resources directory

`setup-files/` (added during `claudeignore-docs`) holds files users copy into their environments rather than recreate from heredocs. The directory name was chosen for direct pairing with `docs/setup.md`. Alternatives considered and rejected: `templates/` (implies edit-before-use, which most files here do not need), `resources/` (too generic), `dotfiles/` (the script isn't a dotfile).

Adding a file to `setup-files/` requires three coordinated edits: the file itself, an entry in `setup-files/README.md`, and a corresponding "copy from `/some/path/claudeplugins/setup-files/...`" instruction in `docs/setup.md`. The setup.md "Clone this repository" sub-section is the prerequisite for all such copy steps; reorder with care if it ever moves.

## dev-process-manager agent (#19)

`claude --agent <name>` runs the session *as* a named agent (CLI help: "Agent
for the current session. Overrides the 'agent' setting"). This is the top-level
invocation #19 calls for — distinct from the Task/Agent tool, which spawns
*sub*-agents from within a session. The `dev-process-manager` agent is the
session lead; it then uses the team tools to spawn its own teammates.

The agent definition deliberately **omits the `tools:` frontmatter field**.
Omitting it grants the agent the full tool set; the review agents restrict
`tools:` because they are read-only, but the manager must spawn and manage
teammates (TeamCreate, Agent, TaskCreate/TaskUpdate, SendMessage, TaskStop,
TeamDelete) and drive the `/feature-*` skills, so it needs everything. Listing
tools explicitly would risk omitting one and silently breaking orchestration.

Model is the alias `model: opus` (and teammate briefs specify `sonnet`) rather
than a pinned id like the review agents' `claude-opus-4-6` — the aliases resolve
to the latest model in each family at runtime, so the agent never goes stale.

Teammate shutdown is via `SendMessage` with `{type: "shutdown_request"}`;
`TeamDelete` only succeeds once all members have shut down.

The container exposes the agent via `claude-run --manager` (or `--agent NAME`).
The selected agent flows host → `CLAUDE_AGENT` env var (`docker run -e`) →
`run-claude.sh`, which appends `--agent "$CLAUDE_AGENT"` to the claude command
line. Because `run-claude.sh` relaunches with `--continue` on exit, the agent
flag is added to the relaunch args too, so a resumed session keeps running as the
same agent. **To verify in testing:** whether `--agent` alongside `--continue` is
accepted cleanly or whether the resumed conversation already retains its agent
(making the flag redundant but harmless).

### `--agent` does not apply the agent's model to the top-level session

Found in Sub-task 4 testing: `claude --agent dev-process-manager` ran as Sonnet,
not the agent's `model: opus`. The `model:` frontmatter field only governs the
model when an agent is invoked as a **sub-agent** (via the Task/Agent tool). When
an agent is used as the **top-level** session via `--agent`, Claude resolves the
session model at startup from `--model` / settings / the account default and
ignores the agent's `model:`. The container `settings.json` pins no model, so the
manager fell back to the default.

Fix: `claude-run` derives the model from the agent's own definition and passes it
explicitly. `derive_model()` reads the `model:` line from
`devproc/agents/<agent>.md` (found via the repo root resolved with
`readlink -f`), and the value flows host → `CLAUDE_MODEL` env var →
`run-claude.sh`, which appends `--model "$CLAUDE_MODEL"` to both the initial and
`--continue` relaunch args. The agent definition stays the single source of
truth — no model is hardcoded in `claude-run`. An explicit `claude-run --model`
overrides it, and an agent whose definition is not in this repo (so the model
cannot be derived) falls back to no `--model`, i.e. the previous default
behaviour. Verified the derivation handles both the alias (`opus`) and pinned
ids (`claude-opus-4-6`).
