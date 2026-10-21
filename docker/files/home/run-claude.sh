#!/bin/bash
# Keep the Claude session alive.
#
# Claude runs as the only process in the tmux session, so if it exits (via
# `exit`, Ctrl-D, `/quit` or a crash) the pane would close and the whole session
# would be destroyed — an accidental keypress would throw away the working
# session. To prevent that we run Claude in a loop and relaunch it whenever it
# exits, resuming the recorded conversation so no context is lost.
#
# The session is only ever torn down by `claude-stop`.
cd /workspace || exit

# Optional top-level agent, passed through from `claude-run --manager`/`--agent`
# via the CLAUDE_AGENT env var. Applied to every launch, so the resumed
# session keeps running as the same agent.
agent_args=()
if [[ -n "${CLAUDE_AGENT:-}" ]]; then
    agent_args=(--agent "$CLAUDE_AGENT")
fi

# Optional session model, passed through from claude-run via the CLAUDE_MODEL
# env var. claude-run derives it from the selected agent's `model:` field (or
# takes an explicit --model), because `--agent` alone does not apply the agent's
# model to the top-level session. Applied to every launch.
if [[ -n "${CLAUDE_MODEL:-}" ]]; then
    agent_args+=(--model "$CLAUDE_MODEL")
fi

# Warm-up run before an agent session. In a fresh container the first Claude
# startup is what installs the devproc plugin (from extraKnownMarketplaces /
# enabledPlugins in settings.json), and `--agent` validation happens before that
# sync completes — so `claude --agent dev-process-manager` always fails on the
# very first run. A throwaway non-agent run loads the plugins, after which the
# agent lookup succeeds.
if [[ ${#agent_args[@]} -gt 0 ]]; then
    claude -p hello > /dev/null || true
fi

# Recording and resuming the session.
#
# The main session is launched with a SessionStart hook (record-session.sh, added
# through --settings so only this session has it). The hook records the session
# ID and transcript path in $id_file whenever the conversation starts or changes
# (including /clear and /resume). Every launch below — the first, a keep-alive
# relaunch, or the first one after the container is restarted — resumes that
# recorded conversation, rather than the most recent one in /workspace, which
# could be the agent warm-up or a `claude -p` run from Claude's Bash tool.
#
# Keep $id_file in sync with record-session.sh. The hook's script path is fixed
# by the Dockerfile, which copies docker/files/home to /home/claude.
id_file="$HOME/.claude/container-session-id"
started_file="$HOME/.claude/container-started"
hook_settings='{"hooks":{"SessionStart":[{"hooks":[{"type":"command","command":"bash /home/claude/record-session.sh"}]}]}}'

# The marker file tells a brand-new container from a restarted one. A missing
# session ID is normal in a new container, but on the first launch after a
# restart it means there is nothing to resume, and the user should be told.
# Later keep-alive relaunches just start fresh silently if there is nothing to
# resume (say, Claude exited before any message was sent), so an accidental
# exit never leaves the session waiting. The marker is written here, at script
# start, rather than after the first successful launch.
notify_if_nothing_to_resume=false
if [[ -e "$started_file" ]]; then
    notify_if_nothing_to_resume=true
fi
touch "$started_file"

while true; do
    # Resume the recorded session if its transcript exists. A session that
    # started but never received a message has no transcript, and resuming it
    # would fail. A short or empty file leaves session_id or transcript empty,
    # which the test below treats as nothing to resume.
    session_id=""
    transcript=""
    if [[ -r "$id_file" ]]; then
        { read -r session_id; read -r transcript; } < "$id_file"
    fi
    resume_args=()
    if [[ -n "$session_id" && -f "$transcript" ]]; then
        resume_args=(--resume "$session_id")
    elif [[ "$notify_if_nothing_to_resume" == true ]]; then
        # Wait for Enter rather than launching straight away: Claude runs
        # full-screen and would cover the message before the user attached.
        # Ignore Ctrl-C while waiting, as after Claude exits below.
        trap '' INT
        printf '\n\033[1mNo previous session to resume.\033[0m  Press Enter to start a new conversation.\n'
        while ! read -r _; do sleep 1; done
    fi
    notify_if_nothing_to_resume=false

    # Claude runs in the foreground with default signal handling, so Ctrl-C
    # interrupts Claude as normal.
    trap - INT
    start=$SECONDS
    claude --dangerously-skip-permissions --settings "$hook_settings" \
        "${resume_args[@]}" "${agent_args[@]}" || true

    # Between Claude runs, ignore Ctrl-C so an accidental keypress can never kill
    # the keep-alive loop (and therefore the tmux session).
    trap '' INT

    if (( SECONDS - start < 5 )); then
        # Claude exited almost immediately — likely a startup crash. Wait for the
        # user rather than respawning in a tight loop. `read` returns non-zero on
        # EOF (Ctrl-D), so holding Ctrl-D just sleeps quietly here.
        if [[ ${#resume_args[@]} -gt 0 ]]; then
            # While resuming, a quick exit may mean a damaged transcript, or a
            # transient problem such as expired credentials, so ask rather than
            # abandoning the session. Typing `new` only forgets which
            # conversation to resume; its transcript stays on disk.
            printf '\n\033[1mClaude exited within a few seconds of resuming the previous session.\033[0m  Press Enter to try resuming again, or type new and Enter to start a new conversation.\n'
            reply=""
            while ! read -r reply; do sleep 1; done
            if [[ "${reply,,}" == new ]]; then
                rm -f "$id_file"
            fi
        else
            printf '\n\033[1mClaude exited immediately.\033[0m  Press Enter to retry, or detach with Ctrl-b d.\n'
            while ! read -r _; do sleep 1; done
        fi
    else
        printf '\n\033[1mClaude exited — resuming.\033[0m  Detach with Ctrl-b d.\n'
        sleep 2
    fi
done
