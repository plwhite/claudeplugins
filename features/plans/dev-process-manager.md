# Create dev process manager agent — Feature Plan

## Handoff

**Last updated:** 2026-06-03
**Session summary:** Feature complete. All sub-tasks done and the full manual
test plan (Groups A–G) passed. One issue found and fixed during testing: the
manager ran as Sonnet because `--agent` does not apply an agent's `model:` to the
top-level session; `claude-run` now derives the model from the agent definition
and passes `--model` (via `CLAUDE_MODEL` → `run-claude.sh`). Ran `/feature-end`
(checkpoint + docs review) and moved the feature to Completed.
**Sub-task in progress:** None — feature finished.
**First action next session:** None for this feature. Pick the next feature from
`FEATURES.md`.
**Open questions / decisions pending:** None. (`--agent` + `--continue` on
relaunch was verified clean in test Group E.)
**Dead ends to avoid:** The container launches Claude from `run-claude.sh`, not
directly from `claude-run`, so the agent must flow host → `CLAUDE_AGENT` env var
→ `run-claude.sh` args; do not add `--agent` only in `claude-run`. Do not list
`tools:` explicitly in the agent — omitting it grants the full set the
orchestrator needs; an explicit list risks silently dropping a team tool.

## Requirements

From #19:

- Add a top-level **Opus** "dev process manager" agent that implements the dev
  workflow by:
  - creating agent-team instances (normally **Sonnet**) for each step of the
    dev process;
  - ensuring each spawned agent is briefed to call `/feature-checkpoint`;
  - checking the agents' outputs and that they did the right thing — proper
    review as required;
  - closing down each agent teammate when its task is fully complete;
  - checking with the **user** at points where user feedback is required
    (requirements, design questions) or where feedback is explicitly requested.
- The agent lives in the `devproc` module.
- Its capabilities, invoked with `--agent` when running claude, are exposed in
  the container infra code as an option.
- Goal: let the user say "go do several sub-tasks at once and check with me after
  sub-task 4", or "check the design and requirements with me", letting work
  proceed autonomously while the manager reviews the low-level agents' work and
  keeps the high-level context on track.

## Design

### Recon findings

- `claude --agent <name>` runs the session *as* that named agent (CLI help:
  "Agent for the current session. Overrides the 'agent' setting."). This is the
  invocation #19 refers to. The agent must be discoverable — the devproc plugin
  is already enabled inside the container (`docker/files/home/.claude/settings.json`)
  and copied in by the Dockerfile, so a new `devproc/agents/*.md` agent is
  available by name with no build-graph changes.
- Existing agents (`devproc/agents/*.md`) use frontmatter `name`, `description`,
  `tools`, `model`, `color`, then a system-prompt body. Review agents restrict
  `tools: Glob, Grep, Read` because they only produce findings. The manager is
  the opposite: it must spawn and manage teammates, so it needs the **Agent**
  tool plus team management (`SendMessage`, `TeamCreate`, `TeamDelete`),
  `Skill` (to drive `/feature-*` skills / brief checkpoints), and full
  Read/Write/Edit/Bash/Grep/Glob/TodoWrite for reviewing work.
- The container does **not** launch Claude directly in `claude-run`; it starts a
  detached tmux session whose keep-alive loop (`run-claude.sh`) runs
  `claude "${args[@]}"`. So a chosen agent on `claude-run` must be passed
  through to that loop, not just added to the `docker run` line. Cleanest path:
  `claude-run` resolves the selected agent to a name → `docker run -e
  CLAUDE_AGENT=NAME` → `run-claude.sh` appends `--agent "$CLAUDE_AGENT"` to its
  `args` array when the env var is set. The relaunch (`--continue`) path must
  keep the `--agent` too.

### Approach

The manager is implemented purely as a **devproc agent definition** plus a thin
container pass-through — no new orchestration runtime. The intelligence lives in
the agent's system prompt, which encodes the workflow:

1. On start, establish what feature is being developed — but do **not** mandate
   that one already exists. The manager may be asked to create and/or start a
   feature itself (e.g. "create feature #123" → drive `/feature-create` then
   `/feature-start`). If a feature is already in progress, read `FEATURES.md` to
   find it and its plan file and read the plan's Handoff and Sub-tasks. Either
   way, establish the high-level goal and the planned sub-task sequence as the
   context it must keep on track.
2. Agree an **autonomy boundary** with the user up front (e.g. "run sub-tasks
   1–4, check with me after 4", or "check requirements/design first"). Honour
   explicit "check with me" points and always pause when requirements or design
   decisions are genuinely the user's to make.
3. For each sub-task within the boundary: spawn a teammate (normally Sonnet)
   via the Agent tool with a brief that (a) states the single sub-task, (b)
   points at the plan/NOTES for context, and (c) **requires the teammate to run
   `/feature-checkpoint` when its sub-task completes**.
4. Review the teammate's output — read the diff/files, confirm it did the right
   thing, run a proper review where warranted (the existing review skills/agents
   are available). If inadequate, send corrections via SendMessage; otherwise
   close the teammate down (stop it / TeamDelete) when its task is fully done.
5. Keep the user informed at agreed autonomy boundaries and stop for feedback when reached.

The agent is usable anywhere (`claude --agent dev-process-manager`, or selected
via the `agent` setting); the container simply adds a convenient option. Model:
the generic alias `model: opus` for the manager, with teammate briefs specifying
`sonnet` — the aliases resolve to the latest model in each family at runtime, so
the agent never goes stale and needs no manual version bumps. (The existing
review agents pin explicit ids like `claude-opus-4-6`, which are already two
releases behind; the manager deliberately uses aliases instead.)

Non-obvious findings during implementation go in `NOTES.md`.

## Sub-tasks

1. ✓ **Write the dev-process-manager agent** (2026-06-02) — added
   `devproc/agents/dev-process-manager.md`: Opus, `tools:` omitted (inherits the
   full set), system prompt encoding the establish-feature → autonomy-boundary →
   delegate → review → shut-down workflow with explicit team-tool and
   `/feature-checkpoint` instructions.
2. ✓ **Add an agent option to the container infra** (2026-06-02) — `claude-run`
   now parses options: `--manager`/`-m` (no arg, selects dev-process-manager),
   generic `--agent NAME` (with a `dpm` → dev-process-manager alias), `--help`,
   plus the optional positional project path. It passes the choice via
   `docker run -e CLAUDE_AGENT=NAME`; `run-claude.sh` appends `--agent
   "$CLAUDE_AGENT"` to both the initial and `--continue` relaunch args when set.
3. ✓ **Documentation** (2026-06-02) — added the agent to `devproc/README.md`
   (table + Agent reference) and `CLAUDE.md` contents/status; new "Dev process
   manager" section in `docs/capabilities.md`; `--manager`/`--agent` documented
   in `docs/container.md`; a pointer in `docs/workflow.md`; updated `plugin.json`
   and root `README.md` descriptions. (`docs/setup.md` needed no change — its
   only "agents" mention is already generic.)
4. ✓ **Test the feature and fix issues** (2026-06-03) — user ran the full manual
   [test plan](dev-process-manager-test-plan.md); Groups A–G all passed. Found
   and fixed the top-level-`--agent` model bug (manager ran as Sonnet); now
   `claude-run` derives `--model` from the agent definition. `--agent` +
   `--continue` relaunch confirmed clean (Group E).
5. ✓ **Final checkpoint** (2026-06-03) — synced FEATURES/plan/NOTES/docs and ran
   `/feature-end` (docs-structure review included).

**▶ NEXT:** Feature complete.

> Run `/feature-checkpoint` after each sub-task completes.
