# Fix bugs in container implementation — Feature Plan

## Handoff

**Last updated:** 2026-06-01
**Session summary:** All three sub-tasks complete. Sub-task 1 (credentials
mount) user-tested; Sub-task 2 (keep-alive auto-resume loop with SIGINT trap and
crash-guard) user-tested and accepted; Sub-task 3 documented the Shift-highlight
copy/paste tip. Feature is functionally complete and ready for `/feature-end`.
**Sub-task in progress:** None (all sub-tasks done)
**First action next session:** Run `/feature-end` to move the feature to
Completed (no implementation work remains).
**Open questions / decisions pending:** None.
**Dead ends to avoid:** For relaunch use `claude --continue` (auto-resumes the
latest conversation), not `-r`/`--resume`, which with no session ID opens an
interactive picker — wrong for an unattended loop.

## Requirements

From #17:

- **Automatic login does not work in the container.** Looks like the
  credentials file may not get mounted into the container.
- **The tmux session is too easy to close accidentally.** Hitting `exit` or
  Ctrl-D ends the session. At minimum document that `Ctrl-B D` is the correct
  way to detach; better, make accidental closure harder.
- **Copy/paste out of the tmux session is painful.** Document that holding
  Shift while highlighting helps.

## Design

These three issues are largely independent and will be tackled sequentially.
The plan keeps each sub-task light: the first action in each is to confirm the
right approach before changing code, since some causes still need verification.

Recon findings that inform the plan:

- **Login (likely cause found):** [bin/claude-run](../bin/claude-run) mounts
  `$HOME/.claude/.credentials` into the container, but the actual host
  credentials file is `~/.claude/.credentials.json`. Bind-mounting a path that
  does not exist causes Docker to create an empty *directory* at the source
  (the `nobody:nogroup` `~/.claude/.credentials/` dir observed on the host) and
  mount that, so no credentials reach the container. The fix is almost
  certainly to mount `.credentials.json` to the path Claude reads inside the
  container — but Sub-task 1 should confirm the exact expected filename/location
  before committing to it.

- **Accidental closure:** [entrypoint.sh](../docker/files/home/entrypoint.sh)
  launches `tmux new-session -d -s claude claude ...`, i.e. Claude *is* the
  session's top-level process. When Claude exits (via `exit`/Ctrl-D) the window
  closes and the session dies. Options to harden this (to be evaluated in
  Sub-task 2): run Claude inside a respawning shell/loop, use tmux
  `set remain-on-exit on`, or otherwise keep the session alive. Whatever the
  hardening, also document `Ctrl-B D` as the correct detach.

- **Copy/paste:** [.tmux.conf](../docker/files/home/.tmux.conf) already has
  `mouse off`. The Shift-highlight behaviour is terminal-native selection; this
  is purely a documentation gap in [docs/container.md](../docs/container.md).

Documentation for all three lives in `docs/container.md`; record any non-obvious
findings (e.g. confirmed credentials path, tmux hardening mechanism) in
`NOTES.md` as they surface.

## Sub-tasks

1. ✓ **Fix automatic login** (2026-06-01) — corrected the `claude-run` mount to
   `~/.claude/.credentials.json` on both sides; user-tested, login works.
2. ✓ **Harden against accidental session closure** (2026-06-01) — added
   `run-claude.sh` keep-alive loop; `entrypoint.sh` runs it; documented
   `Ctrl-b d` as the detach. Revised after testing: now **auto-resumes**
   (`claude --continue`) on exit with a <5s crash-guard, and traps SIGINT
   between runs so Ctrl-C can no longer kill the session.
3. ✓ **Document copy/paste tip** (2026-06-01) — added a "Copying and pasting"
   subsection to `docs/container.md`: hold Shift while highlighting to use the
   terminal's native selection rather than tmux's.
4. **Final checkpoint** — sync docs/NOTES, confirm all three issues resolved,
   ready for `/feature-end`.

**▶ NEXT:** Sub-task 4 (final checkpoint) — then `/feature-end`.

> Run `/feature-checkpoint` after each sub-task completes.
