# Dev process manager — manual test plan

Test plan for the `dev-process-manager` feature (#19). You run these by hand;
record PASS/FAIL and notes against each. Anything that fails feeds back into
Sub-task 4 (fix issues arising) before `/feature-end`.

Throughout, `REPO` is the absolute path to this checked-out repo (the one
containing `bin/claude-run`). Substitute it in the commands.

---

## Prerequisites

- [Y ] Docker installed and running (`docker info` succeeds).
- [Y ] You are logged in to Claude on the host (`~/.claude/.credentials.json` exists).
- [Y ] The image is buildable from a clean state — no stale `claudedev` assumptions.

---

## Group A — `claude-run` option parsing (host, no container needed)

These are fast CLI-surface checks. They do **not** need a built image; you are
only checking argument handling and the printed agent line. To avoid actually
starting containers you can read the echoed output and immediately
`claude-stop` any container that does start, or run them after Group B and let
them start real containers.

| ID | Steps | Expected |
|----|-------|----------|
| A1 | `bash $REPO/bin/claude-run --help` | Usage text lists `--manager`/`-m`, `--agent NAME`, `--help`; exit code 0; no container started. |
| A2 | `bash $REPO/bin/claude-run --bogus` | Error `unknown option '--bogus'`, usage printed to stderr, exit code 1, no container started. |
| A3 | `bash $REPO/bin/claude-run --agent` (no value) | Error `--agent requires an agent name`, exit code 1. |
| A4 | `bash $REPO/bin/claude-run --manager /tmp/does-not-exist` | Fails resolving the project path (cd error), exit non-zero — confirms options are parsed before the path is used. |

> A1–A4 only check parsing. The behaviour tests are Groups C–G.

results: all good

---

## Group B — Build the image

| ID | Steps | Expected |
|----|-------|----------|
| B1 | `bash $REPO/bin/claude-build` | Build completes; image `claudedev` exists (`docker images | grep claudedev`). The build copies in the `devproc` plugin including the new `dev-process-manager.md` agent. |
| B2 | After B1: `docker run --rm --entrypoint sh claudedev -c 'ls /home/claude/claudeplugins/devproc/agents'` | Output includes `dev-process-manager.md` — the agent is baked into the image. |

results: all good

---

## Group C — Container launches as the manager agent

Use a **scratch project** so orchestration cannot touch this repo:

```bash
mkdir -p /tmp/dpm-test && cd /tmp/dpm-test && git init
```

| ID | Steps | Expected |
|----|-------|----------|
| C1 | `bash $REPO/bin/claude-run --manager /tmp/dpm-test` | Prints `Started container: claude-dpm-test`, a `Top-level agent: dev-process-manager` line, and an attach hint. |
| C2 | `docker exec claude-dpm-test sh -c 'cat /proc/$(pgrep -f "claude .*--agent" | head -1)/cmdline | tr "\0" " "; echo'` (or `ps -ef` inside the container) | The running `claude` process command line contains `--agent dev-process-manager`, `--model opus`, and `--dangerously-skip-permissions`. The `--model opus` confirms the model-derivation fix. |
| C3 | `bash $REPO/bin/claude-attach /tmp/dpm-test`, then ask the session: "What are you and how will you work?" | It responds in the dev-process-manager persona: explains it orchestrates the feature workflow, will spawn teammates per sub-task, and will agree an autonomy boundary / check in at decisions. Detach with `Ctrl-b d` (do not `exit`). |
| C4 | In the attached session, ask: "What model are you running as?" (or run `/status`) | Reports **Opus**, not Sonnet — the manager runs as its declared `model: opus`. This is the regression check for the bug found in testing. |

results: all good

---

## Group D — Orchestration behaviour (the core test)

Still attached to the `/tmp/dpm-test` session as the manager.

| ID | Steps | Expected |
|----|-------|----------|
| D1 | Ask: "Set this project up and create + start a tiny feature: add a `HELLO.md` file saying hello. Check the design with me before coding." | Manager drives `/feature-init` then `/feature-create` + `/feature-start`; presents a short design/sub-task plan; **pauses for your approval** before implementing (honouring the requirement/design check-in). |
| D2 | Approve the plan and say: "Do sub-task 1, then check with me." | Manager creates a team and spawns a teammate (normally Sonnet) for sub-task 1, with a brief naming the single sub-task and pointing at the plan. |
| D3 | Observe the teammate's completion | The teammate runs `/feature-checkpoint` (plan/FEATURES updated, `HELLO.md` created). Confirm by inspecting files in `/tmp/dpm-test`. |
| D4 | Observe the manager after the teammate reports done | Manager **inspects the actual change** (reads the diff/file), confirms it is correct, then **shuts the teammate down** (it should no longer appear as an active team member), and **stops to check in with you** rather than barrelling past the agreed boundary. |
| D5 | Ask: "Now finish the rest autonomously and only tell me when done." | Manager proceeds through remaining sub-tasks without per-step prompting, checkpoints each, and reports a clear summary at the end. |

What to verify across D1–D5:
- [ ] Pauses for requirements/design (D1) and at the stated boundary (D2/D4).
- [ ] Spawns a teammate per sub-task; teammate uses the correct (Sonnet) model.
- [ ] Each teammate is briefed to and does run `/feature-checkpoint`.
- [ ] Manager reviews real changes, not just the teammate's claim.
- [ ] Manager shuts teammates down when their task is complete.
- [ ] Honours the autonomy boundary you set (no run-ahead).

results: all good

---

## Group E — Agent persists across relaunch (`--agent` + `--continue`)

This verifies the open question: that `run-claude.sh` keeps the agent on the
auto-relaunch path, and that `--agent` combined with `--continue` is accepted.

| ID | Steps | Expected |
|----|-------|----------|
| E1 | In the attached manager session, type `/quit` (or `exit`) to make Claude exit; watch the keep-alive loop relaunch it (~2s). | The session relaunches automatically (does not die). |
| E2 | From another shell: `docker exec claude-dpm-test ps -ef | grep -- '--agent'` | The relaunched `claude` process still has `--agent dev-process-manager` **and** `--continue` — confirms the agent survives relaunch and the two flags coexist without error. |
| E3 | Back in the session, ask "what were we doing?" | It resumes the prior conversation/context (the `--continue` resume worked) while still in the manager persona. |

> If E2/E3 show `--agent` and `--continue` conflict (e.g. an error in the
> pane, or the agent is lost), record it — the fix would live in
> `run-claude.sh` and is exactly the kind of issue Sub-task 4 exists to catch.

results: all good


---

## Group F — Generic `--agent` and alias

| ID | Steps | Expected |
|----|-------|----------|
| F1 | Stop C/D/E container: `bash $REPO/bin/claude-stop /tmp/dpm-test`. Then `bash $REPO/bin/claude-run --agent dpm /tmp/dpm-test` | Prints `Top-level agent: dev-process-manager` — the `dpm` alias resolves. |
| F2 | `docker exec claude-dpm-test ps -ef | grep -- '--agent'` | Command line shows `--agent dev-process-manager` (resolved, not the literal `dpm`). |
| F3 | `bash $REPO/bin/claude-stop /tmp/dpm-test`; `bash $REPO/bin/claude-run --agent some-unknown-agent /tmp/dpm-test`, then attach | Document Claude's behaviour when asked to run as a non-existent agent (graceful message vs. fallback). Not necessarily a bug — record what happens. |

results: all good


---

## Group G — Default (no agent) still works

| ID | Steps | Expected |
|----|-------|----------|
| G1 | `bash $REPO/bin/claude-stop /tmp/dpm-test`; `bash $REPO/bin/claude-run /tmp/dpm-test` | No `Top-level agent:` line printed. |
| G2 | `docker exec claude-dpm-test ps -ef | grep claude` | The `claude` process has **no** `--agent` flag — confirms the option is purely additive and the default path is unchanged. |
| G3 | Attach and interact briefly | Behaves as an ordinary Claude container session (the existing, pre-feature behaviour). |

results: all good

---

## Teardown

```bash
bash $REPO/bin/claude-stop /tmp/dpm-test
rm -rf /tmp/dpm-test
```

---

## Results log

Record outcomes here as you go (ID — PASS/FAIL — notes), and raise any FAILs
back to me so they can be fixed under Sub-task 4 before `/feature-end`.
