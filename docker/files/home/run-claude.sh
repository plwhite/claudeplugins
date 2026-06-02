#!/bin/bash
# Keep the Claude session alive.
#
# Claude runs as the only process in the tmux session, so if it exits (via
# `exit`, Ctrl-D, `/quit` or a crash) the pane would close and the whole session
# would be destroyed — an accidental keypress would throw away the working
# session. To prevent that we run Claude in a loop and relaunch it whenever it
# exits, resuming the previous conversation so no context is lost.
#
# The session is only ever torn down by `claude-stop`.
cd /workspace

# Optional top-level agent, passed through from `claude-run --manager`/`--agent`
# via the CLAUDE_AGENT env var. Applied to both the first launch and every
# relaunch, so the resumed session keeps running as the same agent.
agent_args=()
if [[ -n "${CLAUDE_AGENT:-}" ]]; then
    agent_args=(--agent "$CLAUDE_AGENT")
fi

# Optional session model, passed through from claude-run via the CLAUDE_MODEL
# env var. claude-run derives it from the selected agent's `model:` field (or
# takes an explicit --model), because `--agent` alone does not apply the agent's
# model to the top-level session. Applied to the first launch and every relaunch.
if [[ -n "${CLAUDE_MODEL:-}" ]]; then
    agent_args+=(--model "$CLAUDE_MODEL")
fi

# First launch starts a fresh conversation; every relaunch resumes it.
# `--continue` auto-resumes the most recent conversation in this directory
# (unlike `-r`/`--resume`, which with no session ID opens an interactive picker).
args=(--dangerously-skip-permissions "${agent_args[@]}")

while true; do
    # Claude runs in the foreground with default signal handling, so Ctrl-C
    # interrupts Claude as normal.
    trap - INT
    start=$SECONDS
    claude "${args[@]}" || true
    args=(--continue --dangerously-skip-permissions "${agent_args[@]}")

    # Between Claude runs, ignore Ctrl-C so an accidental keypress can never kill
    # the keep-alive loop (and therefore the tmux session).
    trap '' INT

    if (( SECONDS - start < 5 )); then
        # Claude exited almost immediately — likely a startup crash. Wait for the
        # user rather than respawning in a tight loop. `read` returns non-zero on
        # EOF (Ctrl-D), so holding Ctrl-D just sleeps quietly here.
        printf '\n\033[1mClaude exited immediately.\033[0m  Press Enter to retry, or detach with Ctrl-b d.\n'
        while ! read -r _; do sleep 1; done
    else
        printf '\n\033[1mClaude exited — resuming.\033[0m  Detach with Ctrl-b d.\n'
        sleep 2
    fi
done
