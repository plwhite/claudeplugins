# Test plan — resume-container-session

Steps for the two testing sign-offs in [the plan](../resume-container-session.md). The "session ID file" is `~/.claude/container-session-id` inside the container (session ID on line 1, transcript path on line 2), written by the `SessionStart` hook that `run-claude.sh` passes to the main session (see the plan's `## Design`).

## Agent test (sub-task 1)

Run inside the development container. It needs no Docker. Record the result of each case, with the launch arguments observed, in the sub-task's notes in the plan.

### Part A — the launch decision in `run-claude.sh`

Run the real `docker/files/home/run-claude.sh` with a stub `claude` placed first on `PATH`. The stub appends its arguments to a log file. For a `-p` call (the warm-up) it returns at once. For an interactive call it stops the loop by killing its parent (`kill "$PPID"`), so each run records exactly one interactive launch, except in case A6 and A7, which need a second launch. Use a scratch `HOME` for each case, so the real `~/.claude` is untouched, and set or unset `CLAUDE_AGENT` as the case says.

| Case | Set up in scratch `HOME` | Expected interactive launch |
|------|--------------------------|-----------------------------|
| A1 New container, no agent | nothing | no `--resume`; no prompt, no waiting |
| A2 New container, agent | `CLAUDE_AGENT=dev-process-manager`; a warm-up-style transcript `.claude/projects/-workspace/<w>.jsonl` exists | no `--resume`; no message |
| A3 Restart, session present | started marker; session ID file holds `<s>` and the path of an existing transcript `<s>.jsonl`; a newer transcript `<w>.jsonl` also exists in the same folder | `--resume <s>` |
| A3b Restart with agent and model | as A3, with `CLAUDE_AGENT=dev-process-manager` and `CLAUDE_MODEL=opus` | warm-up runs, then `--resume <s>` with `--agent dev-process-manager --model opus` and `--settings` |
| A4 Restart, session ID file but no transcript | started marker; session ID file holds `<s>` and a transcript path that does not exist | "No previous session to resume" prompt printed and waits for Enter (feed a newline on stdin); then a launch with no `--resume` |
| A5 Restart, no session ID file | started marker only | as A4 |
| A6 Keep-alive relaunch after a newer conversation | as A3. On its first interactive call the stub creates a newer transcript `<w2>.jsonl`, sleeps 6 seconds (longer than the crash window, so the crash prompt is not triggered), and exits normally; on its second call it kills its parent | second launch is `--resume <s>` |
| A7 Resume fails at startup | as A3. On its first interactive call the stub exits at once with an error. Feed `new` and a newline on stdin; on its second call the stub kills its parent | the "Could not resume" prompt is printed; second launch has no `--resume` |

Every launch also carries `--settings` with the hook and, where set, `--agent`/`--model`.

### Part B — the hook records the right session

Use the real `claude` in the real `HOME`, from a scratch working directory. Save any existing session ID file first and restore it afterwards. The running development container's `/home/claude/` comes from the old image, so first copy `docker/files/home/record-session.sh` to `/home/claude/record-session.sh`, and remove it afterwards. This lets the hook settings be used exactly as `run-claude.sh` builds them.

1. **Main session records its ID.** Run `claude -p "say ok" --model haiku --settings '<the hook settings run-claude.sh uses>'`. The session ID file now holds that run's session ID, matching the transcript name it created.
2. **Start a hooked interactive session.** In a scratch tmux session, start interactive `claude --model haiku --settings '<hook settings>'` and send one prompt (`tmux send-keys`). Note the ID in the file: it is this session's.
3. **A `claude` run from the session's Bash tool does not overwrite it.** Prompt the session to run `claude -p "say ok" --model haiku` with its Bash tool. Once it has run, the file still holds the session's ID.
4. **A teammate does not overwrite it.** Prompt the session to spawn a named teammate that replies "ok" and is then shut down. The file still holds the session's ID.
5. **`/clear` records the new conversation.** Send `/clear`, then another prompt. The file now holds a different ID, the one whose transcript holds that prompt. Kill the tmux session.

`shellcheck` passes on every changed script.

## `claude-run` agent test (sub-task 2)

Run inside the development container, which has no Docker. Put stubs for `docker` and `claude` first on `PATH`:
- the `docker` stub answers `inspect -f '{{.State.Status}}' <name>` with a state taken from an environment variable (or fails, as for "no such container", when that variable is unset), logs every call with its arguments, and succeeds for `create`, `cp`, `start` and `exec`;
- the `claude` stub logs that the login check ran and succeeds.

Run `bin/claude-run` against a scratch project directory for each case and record its exit status, its output, and the stub logs.

| Case | Container state | Flags | Expected |
|------|-----------------|-------|----------|
| C1 | none | none | login check runs; `docker create`, `cp`, `start`; exit 0 |
| C2 | none | `--resume` | fails saying there is nothing to resume; no login check; no `create` or `start`; non-zero exit |
| C3 | `running` | none | fails, naming `claude-attach` and `claude-stop`; no login check; non-zero exit |
| C4 | `running` | `--resume` | prints the attach hint; no login check; no `start`; exit 0 |
| C5 | `exited` | none | fails, naming `--resume` and `claude-stop`; no login check; non-zero exit |
| C6 | `exited` | `--resume` | login check runs; `docker cp` of the credentials comes before `docker start`; no `create`; no `GH_TOKEN` warning; exit 0 |
| C7 | `created` | `--resume` | as C6 |
| C8 | `exited` | `--resume --model sonnet --manager` | as C6, plus a warning naming each ignored option |
| C9 | `paused` | `--resume`, then without | fails naming the state, both times; no login check; non-zero exit |

## User test (final sub-task)

Needs Docker on the host. Rebuild the image first with `claude-build`. Each step has a definite pass or fail.

1. Start containers for two different projects with `claude-run`, one plain and one with `--manager`, and hold a short conversation in each, using a distinctive word you can recognise. Stop both with `docker stop claude-<project-dirname>`, simulating a reboot. Run `claude-run --resume` for each and attach with `claude-attach`. **Pass:** each shows its own earlier conversation (not the "hello" warm-up), `/model` shows the original model, the manager container is still the manager, and Claude answers a new prompt without a login error.

*Passed as expected*

2. With a container stopped, run plain `claude-run`. **Pass:** it fails before the login check, and the message names `--resume` and `claude-stop`.

*Passed as expected*

3. With a container running, run `claude-run --resume`. **Pass:** it prints only the attach hint, and the session is undisturbed.

*Passed as expected*

4. For a project with no container, run `claude-run --resume`. **Pass:** it fails and says there is nothing to resume, and no container is created (`docker ps -a`).

*Passed as expected*

5. With a container stopped, run `claude-run --resume --model sonnet`. **Pass:** it warns that `--model` is ignored, and `/model` in the resumed session shows the original model.

*Passed as expected*

6. Run `claude-stop`, then `claude-run`, and attach. **Pass:** the session is a fresh conversation.

*Passed as expected*

7. Start a container with `claude-run` and do not send any message. Stop it with `docker stop`, run `claude-run --resume`, and attach. **Pass:** the pane shows "No previous session to resume. Press Enter to start a new conversation.", and pressing Enter starts a fresh conversation.

*Passed as expected*


8. In one of the containers from step 1, after resuming, send one more message. Stop it with `docker stop` again, run `claude-run --resume`, and attach. **Pass:** the conversation shows both the original messages and the one sent after the first resume, so resuming works more than once.

*Passed as expected*

