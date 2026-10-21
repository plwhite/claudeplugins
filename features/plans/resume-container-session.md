# Add capability to resume a session — Feature Plan

## Handoff

**Last updated:** 2026-10-21
**Session summary:** All sub-tasks are complete and every sign-off box is ticked, including the user's Docker test, where all 8 steps passed. Afterwards, at the user's request, the flag was renamed from `--reuse` to `--resume` throughout; the stub tests were re-run and pass.
**Sub-task in progress:** None.
**First action next session:** None. The feature is closed. Next, the user plans a full `/internal-docs-prune`.
**Open questions / decisions pending:** None for this feature. The user wants a full `/internal-docs-prune` to handle the history wording in `NOTES.md`, rather than trimming it here.
**Dead ends to avoid:** Do not pick the session by recency (`--continue`, or the newest transcript): the warm-up and any `claude -p` run inside the container also create conversations in `/workspace`.

## Requirements

From issue #73, "Add capability to resume a session" (verbatim):

> Suppose a session is running and the container is shut down (a system upgrade, a reboot). It would be nice to be able to start the container again and connect with the old session.
>
> This will not stop the problem that the session wasn't doing anything when shut down, but it avoids loss of any context.

The issue has no comments.

## Spec

### Purpose

In container mode ([docs/container.md](../../docs/container.md)), a Claude session runs in a container created by `bin/claude-run`. If that container stops while the session is in progress — the host reboots, or Docker is restarted during a system upgrade — the user currently has no supported way to get back to the conversation. This feature makes it possible to start the container again and carry on the old conversation with its context intact.

It does not make the stop harmless. Whatever Claude was doing when the container stopped is interrupted and is not restarted. The user gets the conversation back and can tell Claude to carry on.

### How things stand today

These facts come from the current scripts. They explain why resuming does not work today.

- **The conversation is stored inside the container.** Claude Code keeps conversation transcripts under `~/.claude/` (`/home/claude/.claude/` in the container). That directory sits in the container's own filesystem: it is not mounted from the host and is not in a volume.
- **A stopped container still exists.** `claude-run` creates the container without `--rm`, so a reboot stops the container but does not remove it, and the transcripts are still in it. `claude-stop` runs `docker rm -f`, which deletes the container and the transcripts with it.
- **`claude-run` cannot restart it.** `claude-run` always runs `docker create` under the fixed name `claude-<project-dirname>`. While the stopped container exists, that fails because the name is in use.
- **A manual `docker start` gives a fresh conversation.** The container's entrypoint launches `docker/files/home/run-claude.sh`. Its first launch is a plain `claude`, which starts a new conversation. Only later relaunches use `claude --continue`, which resumes the most recent conversation in `/workspace`. So restarting the container by hand gives a new, empty session. The old conversation is still on disk and could be found with `/resume`, but nothing points the user to it.
- **Each container keeps its own conversations.** Claude Code stores conversations under the home directory (`~/.claude/projects/<working-directory-path>/`), not in the working directory, even though `run-claude.sh` runs Claude in the mounted `/workspace`. Because `~/.claude/` is inside the container, each container holds only the conversations run in it. Conversations from another container, or from Claude run directly on the host, are never in the same place.
- **But the most recent conversation in a container is not always the session.** The container can hold conversations other than the interactive session. The known case: when an agent is selected (`claude-run --manager` or `--agent`), `run-claude.sh` runs `claude -p hello` before the first launch, to install the plugins, and that run is saved as a conversation in `/workspace`. Today it does no harm only because the first real launch is always a fresh `claude`. A restart would run the warm-up again, so the most recent conversation would then be the warm-up. Claude itself can also run `claude` inside the container (for example `claude -p` from a Bash command), which adds more conversations.
- **Credentials may be stale.** `claude-run` copies the OAuth credentials in once, before the first start. A container restarted days later still has that old copy.

### What must be true when it is done

1. **Resuming is an explicit choice, made with a `claude-run` flag.** `claude-run --resume` restarts the project's stopped container. Without `--resume`, `claude-run` behaves as it does now: it creates a new container with a new session, and fails if a container for the project already exists. Resuming therefore never happens by accident. When it fails because the container exists, the message says how to resume (`--resume`) or start again (`claude-stop`, then `claude-run`).
2. **`claude-run --resume` on a stopped container** runs `claude-run`'s existing login check (`claude -p hello --model haiku`, which also refreshes the host's credentials), copies fresh credentials into the container before Claude launches (as it does for a new container), and starts the container.
3. **The restarted container resumes the session it was running.** After the restart, Claude opens the interactive session that this container was running when it stopped, identified as that container's session rather than picked by recency. It never opens the agent warm-up run or any other conversation started inside the container. If the user switched conversations during the session (for example with `/clear` or `/resume`), the one resumed is the one active when the container stopped. Proposed: if the container's session cannot be found (for example the container stopped before the session began), Claude starts a fresh conversation and says nothing was resumed. How the session is identified is left to `/feature-design`. Because each container has its own `~/.claude/`, several containers restarted after the same reboot each resume their own session, and sessions run directly on the host are never involved. The user attaches with `claude-attach` as usual.
4. **The restarted session runs with the settings it was created with.** It keeps the `--manager`/`--agent` and `--model` choices made when the container was created. (These are stored in the container's environment, so they survive a restart.) Likewise, `GH_TOKEN` and the git identity keep the values they had when the container was created. Proposed: these are not refreshed on restart, and the docs say so. Proposed: if `--manager`, `--agent` or `--model` is given with `--resume`, `claude-run` warns that they are ignored, because the existing container's settings apply.
5. **The other cases of `--resume` are handled.**
   - Proposed: if the container is already running, `claude-run --resume` exits before its login check, prints the hint to attach with `claude-attach`, and changes nothing.
   - Proposed: if there is no container for the project, `claude-run --resume` fails with a message saying there is nothing to resume. It does not create a new container, because the user asked to resume.
6. **The existing paths still work.** With no container for the project, `claude-run` without `--resume` creates and starts one exactly as it does now, and the session starts as a fresh conversation. The keep-alive relaunch inside a running container still resumes the conversation. By the user's decision, the relaunch, like the restart, reopens the container's own session as identified for item 3, rather than the most recent conversation picked by `--continue`. Otherwise a `claude -p` run from Bash inside the container could take over the session on the next relaunch. The risk is small, but closing it costs little, and the symptoms would be very confusing.
7. **The user docs describe it.** `docs/container.md` explains how to get a session back after the container stops (`claude-run --resume`), and what that does and does not restore: the conversation comes back; interrupted work does not. It also says plainly that:
   - `claude-stop`, or removing the container any other way, deletes the conversation for good, so it cannot be resumed;
   - `claude-stop` followed by `claude-run` is the way to start again with a clean slate;
   - a restarted container still runs the image it was created from, so an image rebuilt with `claude-build` is only used once the container is removed, which loses the conversation.

   Existing statements in `docs/container.md` that this change makes false are corrected: that restarting the container loses session context (the "Refresh credentials mid-session" section), and that `claude-stop` is the only way to tear the session down.

   The agent docs that list the container scripts (`CLAUDE.md`) and the `NOTES.md` entry on session keep-alive are updated to match.

### Out of scope

- **Restarting interrupted work.** Whatever Claude was doing when the container stopped stays interrupted, as the issue says.
- **Restarting automatically when the host boots** (for example with a Docker `--restart` policy). Proposed as out of scope: resuming must be the user's explicit choice (item 1), and `claude-run --resume` also brings in fresh credentials.
- **Keeping the conversation after the container is removed** — by `claude-stop`, by removing the stopped container by hand, or to switch to a rebuilt image. The user decided this is out of scope: once a container is deleted its contents are gone. The cases this feature covers are the host rebooting and the Docker daemon restarting during a system upgrade, which stop the container without removing it.

## Sign-off strategy

- **Testing (agent):** An agent test, run inside this container, confirms that `run-claude.sh`'s first launch picks the right conversation in each case below, and records the launch arguments chosen in each case. How the cases are set up is left to `/feature-design`. The cases:
  - a new container: a fresh conversation, even after an agent warm-up run;
  - a restarted container with a session: that session, even when a warm-up run or another `claude` conversation in the container is more recent;
  - a restarted container whose session switched conversation (for example with `/clear`): the conversation active when it stopped;
  - a keep-alive relaunch after a more recent `claude -p` conversation in the container: the container's session;
  - a restarted container whose session cannot be found: a fresh conversation, with a message that nothing was resumed.

  `shellcheck` passes on every changed script.
- **Testing (user):** A manual test, performed by the user, because it needs Docker on the host. Confirm each of these:
  1. Start containers for two different projects with `claude-run`, one plain and one with `--manager`, and hold a short conversation in each. Stop both with `docker stop`, simulating a reboot. Run `claude-run --resume` for each and attach: each shows its own earlier conversation (not the warm-up run), the agent and model are unchanged, and Claude answers a prompt without a login error (confirming the credentials were refreshed).
  2. With a container stopped, plain `claude-run` fails and the message points to `--resume` and `claude-stop`.
  3. `claude-run --resume` on a running container only prints the attach hint.
  4. `claude-run --resume` with no container fails and says there is nothing to resume.
  5. `claude-run --resume --model sonnet` against a stopped container warns that the option is ignored, and the original model is kept.
  6. `claude-stop` followed by `claude-run` gives a fresh conversation.
- **Documentation:** Update `docs/container.md` (user docs), the `CLAUDE.md` container entries and the `NOTES.md` keep-alive entry, as described in Spec item 7. Comments in `claude-run` and `run-claude.sh` describe the restart path.
- **Code review (agent):** One `/review-branch` before `/feature-end`. The change is small and confined to the container scripts.
- **Docs review (agent):** One `/review-docs` over the change, all kinds, before `/feature-end`. Accuracy, style and agent docs are needed because user-doc prose and agent docs change. Architectural is needed because a new section may be added to `docs/container.md`, and the `claude-run` and `claude-stop` descriptions elsewhere in that document must stay consistent with it.
- **User review:** No separate review. The user's manual test already puts the working result in front of them.

## Design

### Overview

The container records which conversation its main Claude session is using, and `run-claude.sh` resumes exactly that conversation whenever it launches Claude. `claude-run --resume` restarts a stopped container, which re-runs `run-claude.sh` and so resumes the session.

There are three parts:

1. **Recording the session.** `run-claude.sh` launches the main Claude session with an extra `--settings` argument that adds a `SessionStart` hook. Claude Code runs that hook whenever the session starts, resumes, or switches conversation with `/clear` or `/resume`. The hook is given the conversation's session ID, and writes it to a file inside the container, `~/.claude/container-session-id`. Only the main session has the hook, because only it is launched with that argument. The agent warm-up and any `claude -p` that Claude runs from Bash never touch the file.
2. **Resuming it.** Every time `run-claude.sh` launches Claude — first launch and keep-alive relaunch alike — it reads the file. If the file names a conversation whose transcript exists, it launches `claude --resume <id>`. Otherwise it launches a fresh `claude`. This replaces today's plain first launch followed by `--continue` relaunches. If a restarted container has no conversation to resume, it says so before Claude starts.
3. **Restarting the container.** `claude-run --resume` checks the state of the project's container. If the container is stopped, `claude-run` refreshes the credentials and runs `docker start`. If it is running, `claude-run` prints the attach hint. If there is no container, it fails. Without `--resume`, `claude-run` behaves as today, but fails with a helpful message, before the login check, if the container already exists.

The file lives in the container's own filesystem, next to the transcripts. So it survives a stop, it is deleted with the container, and each container has its own.

### Recording the session: the `SessionStart` hook

- **What is passed.** `run-claude.sh` passes `--settings '<json>'` on every main launch. The JSON holds one `SessionStart` hook that runs `bash /home/claude/record-session.sh`. `--settings` adds a settings layer for that process only, on top of the baked-in `~/.claude/settings.json`.
- **What the hook does.** `record-session.sh` is a new file in `docker/files/home/`. It reads the hook's JSON input from stdin and takes `session_id` from it, parsing with `python3`, which is in the image (`jq` is not). It writes the ID and the hook's `transcript_path` atomically (a temporary file, then `mv`) to `~/.claude/container-session-id`: the ID on the first line and the path on the second. `run-claude.sh` checks the recorded path, so it does not depend on how Claude Code names its project directories.
- **Which events it covers.** Claude Code runs `SessionStart` hooks with a `source` of `startup`, `resume`, `clear` or `compact`. The hook records the ID for all of them. That covers spec item 3's "the conversation active when it stopped": `/clear` and `/resume` each fire the hook with the new conversation's ID. `compact` keeps the same ID, so recording it does no harm.
- **Checked during design.** In this container (Claude Code 2.1.301), `claude -p … --settings '<SessionStart hook>'` ran the hook. Its input was `{"session_id": …, "transcript_path": …, "cwd": …, "hook_event_name": "SessionStart", "source": "startup"}`. A child process inherits no environment variable naming the settings, so a `claude` started from Claude's Bash tool does not get the hook.
- **Checked during design: agent-team teammates.** Teammates do not get the hook either. A teammate spawned from the dev-process-manager session in this container ran `in-process` (its `backendType` in `~/.claude/teams/<team>/config.json`). It started no new `claude` process, and its transcript was written under the lead's own session folder (`<lead-session-id>/subagents/`), not as a separate conversation. Sub-task 1's agent test confirms the hook behaviour, the Bash-tool child, the teammate and the `/clear` case against the finished scripts.

*We record the session with a hook, not by picking by recency or reading Claude Code's internal files.* Rejected options:
- **`--continue`, or the newest transcript.** This is recency, which the spec rules out: the warm-up and any `claude -p` in the container also write conversations to `/workspace`.
- **The newest transcript whose entries say `"entrypoint": "cli"` (interactive).** This would exclude `-p` runs. But the field is undocumented, and it would still pick the wrong conversation if anything else ran Claude interactively in the container.
- **`~/.claude/sessions/<pid>.json`.** Claude Code keeps a registry there, holding the live session ID. It is an undocumented internal format, and it describes the running process, not the session at the moment the container stopped.
- **`--session-id <uuid>` chosen at first launch.** This fixes the ID only until the user runs `/clear` or `/resume`, which start or switch to a different conversation.

Hooks are a documented, stable interface, and the hook is told the session ID directly.

### Resuming it: the launch decision in `run-claude.sh`

On each launch:
- **The ID file names a session whose recorded transcript path exists:** launch `claude --resume <id>`.
- **Otherwise:** launch a fresh `claude`. A session that started but never got a message has no transcript yet, and resuming it would fail. Before a fresh first launch after a restart, `run-claude.sh` prints "No previous session to resume. Press Enter to start a new conversation." and waits for Enter. It waits, rather than printing and launching straight away, because Claude runs full-screen (`CLAUDE_CODE_NO_FLICKER=1`) and would cover the message before the user attached. The crash prompt already works this way. Waiting delays nothing that matters: there is no session to carry on, and the user has to attach to start a new one anyway.

How `run-claude.sh` tells a first launch from a restart: on its first run it creates a marker file, `~/.claude/container-started`. A container that has been restarted already has the marker. The marker is needed because a missing ID file is normal in a brand-new container, and spec item 6's fresh start there should not print the message. A later keep-alive relaunch with nothing to resume (Claude exited before any message was sent) starts fresh without the message, so an accidental exit never leaves the session waiting. This narrowing was made at `/review-branch`.

`--agent`, `--model` and `--dangerously-skip-permissions` are passed as today, along with `--resume` when it applies. **If a resume fails at startup.** If a `--resume` launch exits within the existing 5-second crash window (for example because the transcript was damaged by a hard stop), `run-claude.sh` does not keep retrying the same resume. It prompts: "Could not resume the previous session. Press Enter to try again, or type `new` and Enter to start a new conversation." We ask rather than falling back automatically: a quick exit can also have a passing cause, such as expired credentials, and an automatic fallback would abandon the session. The old transcript stays on disk either way.

The agent warm-up is unchanged. It still creates a conversation, but that no longer matters, because nothing picks by recency.

### Restarting the container: `claude-run --resume`

`claude-run` reads the container's state with `docker inspect -f '{{.State.Status}}' <name>`. It does this before the login check, so the cases that need no restart return at once.

| State | without `--resume` | with `--resume` |
|-------|-------------------|----------------|
| no container | create and start, as today | fail: nothing to resume |
| running | fail: container exists — attach with `claude-attach`, or `claude-stop` to start again | print the attach hint, exit 0 |
| exited or created (stopped) | fail: container exists — use `--resume` to resume, or `claude-stop` to start again | login check, copy credentials, `docker start`, `chown`, print the attach hint |
| any other state (`paused`, `restarting`, `dead`, `removing`) | fail, naming the state | fail, naming the state |

- **Ignored options.** With `--resume`, `--manager`, `--agent` and `--model` are ignored, with a warning, because the container's environment already fixes them. The warning names the option. `GH_TOKEN` and the git identity are not touched: on the `--resume` path, `claude-run` skips the `GH_TOKEN` lookup and its "no gh access" warning, which would describe a token that is never passed in.
- **Credentials.** They are copied with `docker cp` while the container is still stopped, as for a new container, so Claude reads the fresh copy on launch.
- **Shared steps.** The login check, the credential copy and the `chown` are already shared by both paths. They stay in one place rather than being duplicated.

*`--resume` is a flag on `claude-run`, not a new `claude-resume` script,* because the user asked for a flag, and the two paths share the login check, the credential copy and the attach hint.

### Documentation

- **`docs/container.md`:**
  - a new "Resume after the container stops" section, covering spec item 7. It also states that `--resume` keeps the agent, model, `GH_TOKEN` and git identity from when the container was created, and ignores `--manager`, `--agent` and `--model` with a warning (spec item 4);
  - the `claude-run` usage text and the "Refresh credentials mid-session" and "Stop and remove the container" sections corrected;
  - the "only way to tear the session down is `claude-stop`" statement under "Attach to Claude" corrected.
- **`CLAUDE.md`:** the container-mode list gains `record-session.sh`, and the `claude-run` and `run-claude.sh` entries mention `--resume` and resuming.
- **`NOTES.md`:** the keep-alive entry (#17), the warm-up entry and the dev-process-manager entry's references to `--continue` relaunches are revised. Relaunch no longer uses `--continue`, and the warm-up conversation is now harmless for a different reason.
- **Script comments:** the `claude-run` comment on passing the agent and model through to "every `--continue` relaunch" is corrected (sub-task 2).

All of this is written after the code, not docs-first. The interface the user would review in the docs (the `--resume` flag, its cases and messages) was already settled in detail in `## Spec`, so a docs-first review would re-check an agreed interface.

## Sub-tasks

**▶ NEXT:** None. The feature is complete.

> Run `/feature-checkpoint` after each sub-task completes.

Sub-tasks 1 and 2 carry no Docker-based test of their own. Docker is not available in the development container, so the user's test in the final sub-task covers both. Code review and docs review are end-of-feature gates only, per `## Sign-off strategy`.

### 1. Record and resume the container's session ✓ (2026-10-21)

Add `record-session.sh` and change `run-claude.sh` to pass the `SessionStart` hook and launch with `--resume <id>` or fresh, as in `## Design`.

- [x] Documentation: comments in `run-claude.sh` and `record-session.sh` describe how the session is recorded and resumed
- [x] Testing (agent): every case in Parts A and B of [the agent test](resume-container-session/test-plan.md#agent-test-sub-task-1) passes, with the launch arguments per case recorded under this sub-task
- [x] Testing (agent): `shellcheck` passes on `run-claude.sh` and `record-session.sh`

**Test results (2026-10-21).** All launches carry `--dangerously-skip-permissions --settings <hook JSON>`; listed below are only the other arguments, in launch order.
- A1 pass: no `--resume`, no prompt. A2 pass: warm-up `-p hello`, then no `--resume` (plus `--agent dev-process-manager --model opus`), no message.
- A3 pass: `--resume s1` (not the newer `w1`). A3b pass: `-p hello`, then `--resume s1 --agent dev-process-manager --model opus`.
- A4, A5 pass: "No previous session to resume" printed and waited for Enter; launch had no `--resume`.
- A6 pass: both launches `--resume s1`. A7 pass: first `--resume s1`, "Could not resume" printed, after `new` the second launch had no `--resume`.
- B1-B5 pass (real `claude`, `--model haiku`): `claude -p` records its ID; interactive startup records the session ID (before any message, so before its transcript exists); a `claude -p` run from the session's Bash tool and a named teammate left the file unchanged; `/clear` then a prompt recorded a new ID whose transcript held the prompt.
- `shellcheck` clean on both scripts.

**Fixes in passing.** `cd /workspace` became `cd /workspace || exit` (shellcheck SC2164). A new `NOTES.md` entry records the hook findings; the existing keep-alive entries are left for sub-task 3.

### 2. Add `claude-run --resume` ✓ (2026-10-21)

Add the `--resume` flag and the container-state handling in the `## Design` table to `claude-run`, including the ignored-option warnings and the helpful failure when the container exists.

- [x] Documentation: `claude-run`'s usage text documents `--resume`, and comments describe the restart path
- [x] Testing (agent): every case in [the `claude-run` agent test](resume-container-session/test-plan.md#claude-run-agent-test-sub-task-2) passes, with the result per case recorded under this sub-task
- [x] Testing (agent): `shellcheck` passes on `claude-run`

**Test results (2026-10-21).** Stub `docker` and `claude` on `PATH`, scratch `HOME` and project; every case is as expected in the test plan.
- C1 pass: login check, then `create`, `cp`, `start`, `exec chown`; exit 0.
- C2 pass: "no container ... to resume", only `inspect` called, exit 1.
- C3 pass: names `claude-attach` and `claude-stop`; no login check; exit 1.
- C4 pass: attach hint only; no login check, no `start`; exit 0.
- C5 pass: names `--resume` and `claude-stop`; no login check; exit 1.
- C6, C7 pass: login check, `cp` before `start`, no `create`, `chown`; exit 0. With `GH_TOKEN` unset, no "no gh access" warning on the `--resume` path.
- C8 pass: as C6, plus one warning each for `--model` and `--manager`.
- C9 pass: `paused` fails naming the state, with and without `--resume`; no login check; exit 1.
- `shellcheck bin/claude-run` clean.

**Notes.** Usage text documents `--resume`; the "every `--continue` relaunch" comment is corrected. The login check, credential copy, `start`, `chown` and attach hint are shared by both paths; the git identity, `GH_TOKEN` and `docker create` steps run only without `--resume`. The final message says "Restarted container" on the restart path.

### 3. Update the docs ✓ (2026-10-21)

Update `docs/container.md`, `CLAUDE.md` and `NOTES.md` as listed under `### Documentation` in `## Design`.

- [x] Documentation: `docs/container.md` covers every point in Spec items 4 and 7; the `CLAUDE.md` container entries match the new behaviour; and the `NOTES.md` keep-alive (#17), warm-up and dev-process-manager entries (including its `--agent` model subsection) no longer describe `--continue` relaunches

**Notes.** `docs/container.md` gained a "Resume after the container stops" section, and the intro bullets, `claude-run` section, agent/model persistence sentences, "Attach to Claude", "Refresh credentials mid-session" and "Stop and remove the container" were corrected or cross-linked. `CLAUDE.md` container entries (`run-claude.sh`, new `record-session.sh`, `claude-run`, `claude-stop`) updated. `NOTES.md` keep-alive (#17), dev-process-manager (incl. `--agent` model subsection) and warm-up entries revised; the one remaining `--continue` hit (NOTES.md keep-alive entry) is deliberate history, and the other (`claude -p --continue` stdin note) is unrelated. No other docs describe container restart behaviour.

### 4. Final sign-off criteria ✓ (2026-10-21)

End-of-feature gates for this feature, per `## Sign-off strategy`.

- [x] Code review (agent): `/review-branch` over all changed files; findings resolved or dismissed

  **`/review-branch` (2026-10-21).** Scope: `bin/claude-run`, `run-claude.sh`, `record-session.sh`. The docs go to `/review-docs`. The architectural agent was not run: the strategy's bar is a single `/review-branch`, and the design had its own review. Three passes converged.
  - **`claude-run`:** a `docker inspect` failure other than "No such container" (the daemon down, say) is now reported, not treated as "no container"; `--type container` is added. The ignore-warning loop is guarded for bash before 4.4, where an empty array under `set -u` fails (macOS ships 3.2). The warnings name the ignored value. Ignored `AGENT`/`MODEL` are cleared under `--resume`. The login check's temporary file is removed on exit.
  - **`run-claude.sh`:** the "No previous session" wait is now shown only on the first launch after a restart, and a keep-alive relaunch with nothing to resume starts fresh silently (Design updated). The resume-failure prompt is reworded, and `new` is accepted in any case.
  - **`record-session.sh`:** it validates the hook values and cleans up its temporary file with a trap.
  - **Comments:** fixed throughout.
  - **Tests:** the stub tests were re-run after the fixes, all passing, plus a new daemon-down case and a quiet-relaunch case. The user test gains step 8, restarting twice.
  - **Declined:** extracting a prompt helper, a single combined ignore warning (the design names each option), and an absolute path in the attach hint (kept consistent with the existing message).
- [x] Docs review (agent): `/review-docs` over the change, all kinds; findings resolved or dismissed

  **`/review-docs` (2026-10-21).** All four kinds ran; two passes converged, with no findings in pass 2.
  - **`docs/container.md`:**
    - the resume section is split up, with an "Edge cases and limits" subsection that adds the failed-resume prompt, older containers (an image without this feature cannot resume) and the need for one sent message;
    - the attach section's contradiction about `exit` is fixed;
    - the `claude-run` failure messages are described per state;
    - "Build the image" now notes that existing containers keep their image;
    - the `claude-stop` facts are deduplicated into "Stop and remove the container".
  - **`NOTES.md`:** the container-state entry, which described the pre-review `docker inspect` behaviour, is corrected; the keep-alive and crash-guard bullets now describe the restart-only prompt and the resume-failure prompt.
  - **Escalated to the user:** dropping the "Originally (#17)… / Since #73" history framing in the `NOTES.md` keep-alive and warm-up entries (removing agent-doc content).
  - **Not applied (suggestions):** a contents list for `docs/container.md`; widening the `README.md` row for `container.md` to mention resuming; moving the agent-persistence sentence in "Run as the Dev Process Manager"; the `reset` note in "Attach to Claude" (unchanged text).
- [x] Testing (user): the user rebuilds the image and every step of [the user test](resume-container-session/test-plan.md#user-test-final-sub-task) passes, on the code as it stands after both reviews

  **User test (2026-10-21).** All 8 steps passed, as the user annotated in the test plan.

## Review record

- 2026-10-21 — Spec reviewed by `feature-spec-reviewer` (2 passes): VERDICT: NEEDS WORK. Presented to the user for sign-off, with 1 open question (whether the conversation must survive removal of the container).
- 2026-10-21 — Spec revised to the user's comments (opt-in `--resume`; resume the container's own session; removed containers out of scope) and re-reviewed by `feature-spec-reviewer`: VERDICT: READY FOR USER REVIEW. Presented to the user for sign-off, with 1 open question (keep-alive relaunch behaviour), since settled by the user: the relaunch also reopens the container's own session.
- 2026-10-21 — Design reviewed by `feature-design-reviewer` (2 passes): VERDICT: NEEDS WORK. Findings from the second pass applied after it (no third review, per the cap). Presented to the user for sign-off.
- 2026-10-21 — Design agreed by the user, with one addition at their request: an automated agent test of `claude-run`'s container-state handling (sub-task 2).
- 2026-10-21 — Spec amended after implementation, at the user's request: the `claude-run` flag was renamed from `--reuse` to `--resume`, because it resumes the session (the container being reused is the mechanism). The rename was applied across the spec, design, code, docs and test plan. The stub tests were re-run, and the user's Docker test was not repeated for the rename.
- 2026-10-21 — Feature closed by /feature-end; all sign-off boxes ticked.
