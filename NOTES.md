# Notes

Non-obvious findings. Do not record things derivable from reading the code.

---

`feature-init` has `disable-model-invocation: true`, so it cannot be launched
via the Skill tool — attempting it errors out. To "run feature-init" (e.g. to
test a change to its `## Feature model` template), apply its step 1 by hand:
update the project `CLAUDE.md` Feature model section to match the template block.
The project `CLAUDE.md` is therefore kept in sync with the template manually, not
automatically; a diff of the two (ignoring line-wrapping) is the check that they
agree.

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

The container Dockerfile COPYs the plugin directory (`devproc/`) from the repo. This requires the build context to be the repo root, not `docker/` — so the command is `docker build -f docker/Dockerfile .` not `docker build docker`. The config files copy path therefore changes from `files/home` to `docker/files/home`. The old `docker build docker` form will fail silently on the COPY steps if the repo root is not the context.

`ARG UID`/`ARG GID` are declared without defaults so that a bare `docker build` fails visibly rather than silently using UID 1000. The build script always passes `$(id -u)`/`$(id -g)`.


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

## Agent memory paths must be anchored to `$CLAUDE_PROJECT_DIR` (#23)

A bare relative path in an agent prompt (e.g. "Store findings in
`.claude/agent-memory/...`") resolves against the agent's current working
directory, not the repo root. The `docs-structure-reviewer` agent was run from
various directories and created stray `.claude/agent-memory/` trees wherever it
happened to be. The `memory: project` frontmatter field does not save this — the
prose path in the prompt body is what governs where files actually land. The fix
is to write the path as `$CLAUDE_PROJECT_DIR/.claude/agent-memory/...`, which
Claude Code expands to the project root regardless of cwd, and to use the same
anchored path for both the write target and the start-of-review `MEMORY.md` read.

A second, subtler point surfaced during the feature-end review: a plugin agent's
`memory: project` directory is **namespace-prefixed** with the plugin name. The
runtime tree for this agent is `.claude/agent-memory/devproc-docs-structure-reviewer/`,
not the bare `.claude/agent-memory/docs-structure-reviewer/` — so the prose path
must include the `devproc-` prefix to match where memory actually lands, otherwise
the agent's manual reads/writes miss the automatically provisioned tree. (A stale
unprefixed `docs-structure-reviewer/` tree from before the fix is a leftover
artifact and can be deleted manually.)

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

## Testing a new agent in the session that creates it (#20)

A newly written `devproc/agents/<name>.md` is **not** invocable as an agent type
in the session that creates it — the available agent types are resolved when the
session starts, so the file on disk is invisible to the Agent tool until a
restart. To test a new agent definition in the same session, spawn a
`general-purpose` agent and instruct it to read the definition file, treat the
body after the frontmatter as its system prompt, and follow it. That exercises
the prompt (which is the whole deliverable for a prose agent) but *not* the
frontmatter wiring — `tools:`, `model:`, and the description-based dispatch are
untested by this route and need a restarted session to verify.

When doing this, explicitly forbid the test agent from reading the
`.expected.md` files and the fixture `README.md`: they state the flaw under test
and the agent will otherwise read the answer off them.

## Spec-review fixtures: sections are not independent (#20)

The `feature-spec-reviewer` fixtures each mutate one section of a shared clean
baseline, so a case can test one check in isolation. The obvious expectation —
"the agent must report nothing against the section this case did not target" —
turned out to be wrong, and three of five cases failed on it in the first round.

Two distinct causes, both instructive:

1. The baseline genuinely had defects. The docs sign-off criterion said "a
   `NOTES.md` entry for the streaming approach", which presumes a design outcome
   the requirements never state; the filename date had no timezone. The agent
   was right on both counts, in the control run too.
2. The sections are legitimately coupled. A vague `## Requirements` really does
   make a `## Sign-off strategy` criterion harder to audit ("confirms it is what
   finance needs" means nothing if nothing states what finance needs), and the
   agent reported that as a consequence rather than as a fault of the strategy.

The rule is therefore "no BLOCKING or MAJOR findings against the untargeted
section", with MINOR and SUGGESTION tolerated. A competent reviewer always finds
polish; only a serious finding against untouched text indicates it is
mis-firing.

The design-reviewer fixtures needed a third refinement of the same rule: a
finding against the untargeted section is also legitimate when the *targeted*
flaw creates it. In `oversized-subtasks`, a planted trivia sub-task bumps a CSV
library "for the quoting fix", which implies a serialiser choice the design
never records — a real design gap, but one the control does not exhibit. The
control not raising it is the evidence that its source is the sub-tasks. The
wording is now "faulting the untargeted section **on its own terms**".

## Writing review fixtures: expect the agent to find your own bugs (#20)

Across three rounds, every design-reviewer fixture failure was a defect in the
fixture, not in the agent. Worth knowing before writing the next set, because
the instinct is to tune the agent until the tests pass, and that would have been
wrong every time:

- The baseline design took care to avoid a second definition of the *filters*,
  then left the *column set* undefined — the same failure one layer up.
- The sign-off strategy's manual large-tenant export was owned by no sub-task,
  so every box could be ticked without it happening.
- A sub-task carried `- [ ] User review: none — no user-visible surface yet`: a
  box that can never legitimately be ticked, so the sub-task could never
  complete. Waived categories must be *omitted* and explained once at feature
  level, not written as an unchecked box.
- The design named CSV serialisation as a distinct layer that no sub-task
  tested.

Two expectation errors were mine as well: demanding a specific severity where
reasonable reviewers differ (ordering problems land at BLOCKING or MAJOR
depending on whether a workaround exists), and assuming the reviewer could
settle a dependency question by searching this repository — the fixtures
describe a product that is not this repo, so absence proves nothing. The agent
now says "unconfirmed" rather than "absent" for components it cannot verify.

One genuine agent bug did surface, from a contradiction between the fixture and
the prompt: the verdict rule allowed `READY FOR USER REVIEW` with an outstanding
MAJOR `[rewrite]` finding. Both agents now require no BLOCKING **and** no MAJOR,
and state that the verdict describes the artefact as it stands rather than as it
could easily become.

## Testing a skill end to end, and what it caught (#20)

The review step in `/feature-spec` and `/feature-design` was tested by running
each skill for real against a throwaway project under the scratchpad (a
`CLAUDE.md` with a Feature model section, `features/` with the status files, and
for the design tests a pre-seeded pending feature and spec-stage plan). Four
runs: each skill in reviewed and skipped mode. This is worth repeating for any
future change to skill prose — none of the four problems below was visible from
re-reading the instructions.

1. **Review-control tokens polluted `$ARGUMENTS`.** `/feature-design
   archive-widgets skip review` has the skill match the *whole* string against
   pending feature names; in `/feature-spec` the token could reach the feature
   title or slug. Both skills now say to strip the token before interpreting the
   argument.
2. **`[decision]` is a reviewer concept**, so with the review skipped the final
   step said nothing about open questions the author found themselves. Both
   skills now require surfacing those regardless of whether the review ran.
3. **The agent contradicted the skill.** `feature-spec-reviewer` twice asked for
   a `## Handoff` section, which `/feature-spec` explicitly must not create —
   `/feature-design` adds it on taking the feature into progress. The agent now
   knows the spec-stage shape. The general lesson: an agent reviewing an
   artefact produced by a skill needs to know that skill's rules, or it will
   confidently demand conformance to a different stage's shape.
4. **The second review pass can be pure waste.** If every outstanding finding is
   `[decision]`, re-reviewing unchanged questions cannot change the verdict.
   Both skills now say not to spend the second invocation in that case.

## `/home/claude/claudeplugins` is a live plugin copy, separate from this repo

`/home/claude/claudeplugins` is registered as the `local-plugins` marketplace
(`~/.claude/settings.json` → `enabledPlugins: {"devproc@local-plugins": true}`,
`extraKnownMarketplaces.local-plugins.source.path: /home/claude/claudeplugins`)
— it is **not** a symlink into `/workspace`, just a separate directory that
happened to start as a copy of `/workspace/devproc`. This is the copy the
`Skill`/`Agent` tools actually load `devproc:*` skills and agents from in this
session, so it is where skill-prose changes must be made to be testable/usable
right away — but it is invisible to git. `git status` in `/workspace` confirms
`devproc/skills/feature-init/SKILL.md` (Sub-task 1's change) has **no tracked
diff**: Sub-task 1's scaffolding step and Sub-task 2's `features/tmp` ingestion
route (this file) exist only under `/home/claude/claudeplugins/devproc/`, not
under the git-tracked `/workspace/devproc/`.

**Consequence:** skill-prose edits must be made in the git-tracked
`/workspace/devproc/` (the deliverable), not only the live copy; the live copy
may drift and that is fine. Diffing the two trees is the check before
`/feature-end`.

## `/feature-spec` from a bare one-line description ends at NEEDS WORK

For a bare one-line feature description, `/feature-spec` will reliably end at
`NEEDS WORK`: the skill writes a "no requirements beyond the summary"
placeholder, and the reviewer correctly rates a spec with no requirements as
blocked. That is working as intended — the questions go to the user — but it
means `READY FOR USER REVIEW` is not reachable from a one-liner, which matters
for unattended mode.

## Unattended mode rarely proceeds at spec stage (#20)

Unattended mode proceeds only on `READY FOR USER REVIEW` with zero `[decision]`
findings. In testing, `/feature-design` reached that state on a small,
fully-specified feature, but `/feature-spec` did not — twice, on deliberately
thorough descriptions. Both times the verdict was READY and exactly one
`[decision]` finding held it: whether whitespace-only notes count as empty, and
where a user's timezone comes from.

The pattern looks inherent rather than a tuning problem. A spec written from a
description almost always leaves one thing genuinely worth asking, and a
`[decision]` blocks regardless of severity — deliberately, since a question is a
question whatever its severity.

A plausible mitigation, untested: both blocking questions were about *existing
application infrastructure*, which the stub test project does not have. In a
real repository those become lookups rather than judgement calls, and the skills
now say explicitly to establish a fact rather than manufacture a question from
it. Whether that is enough to make unattended spec runs practical is a question
for system test, not something the fixtures here can answer.

## First container run installs plugins; `--agent` fails until then

In a fresh container, the devproc plugin is not installed until Claude's first
startup processes `extraKnownMarketplaces`/`enabledPlugins` from the baked-in
`settings.json` — and `--agent` validation happens before that sync completes.
So `claude --agent dev-process-manager` **always** fails on the very first run
in a new container (the exact failure `claude-run --manager` hit: entrypoint →
tmux → `run-claude.sh` makes the agent launch the first-ever invocation).
Retrying without a successful run in between still fails; one successful
non-agent run installs the plugins and after that the agent lookup works
permanently. Confirmed by testing: a manual `claude --agent dev-process-manager`
in an already-used container works fine.

Fix: `run-claude.sh` does a throwaway warm-up (`claude -p hello > /dev/null`)
before the keep-alive loop, guarded on an agent being selected — plain
`claude-run` never hit the bug, and the warm-up costs a model call and a few
seconds of startup. The warm-up's throwaway conversation is never resumed: the
first real launch is plain `claude` (fresh), and later `--continue` relaunches
resume the interactive session, which is more recent.

## Sub-task 4 consistency check method

To verify the `feature-init` CLAUDE.md template's "Documents to support the
model" list and this repo's `/workspace/CLAUDE.md` copy agree "ignoring
line-wrapping" (the check NOTES.md and the plan both call for), a byte diff is
the wrong tool — the two files wrap the same prose at different column widths
by design (the template is indented under a numbered step; `CLAUDE.md` is
top-level). The check that actually answers the question: split each section
into paragraphs on blank lines, collapse all whitespace within each paragraph
to single spaces, then compare the resulting paragraph lists for exact
equality. Confirmed equal for both files after adding the new `features/tmp/`
bullet to both.

## Dogfooding: run the reviewers at spec/design time, not feature-end (#20)

The `spec-design-review-agents` sign-off strategy included running
`feature-spec-reviewer` over this feature's own plan. Done at `/feature-end`, it
returned NEEDS WORK and named things we had already hit the hard way — the spec
never scoped "proceed without human review" versus "a lighter human process" as
distinct outcomes (the gap that later split sub-task 3 into 3 and 4), the
testing pass condition was unsatisfiable as written (the fixture-rework round),
and there was no test criterion for the skill changes.

The lesson is only that the spec was loose and the review would have caught it up
front. There was nothing to *fix* retrospectively — rewriting a shipped spec to
pass a review dated after the work would falsify the record — so the findings are
recorded here rather than applied. Going forward this is not a special step:
running the reviewers is simply what `/feature-spec` and `/feature-design` now
do, and the value is in running them at spec/design time, not as an end-of-feature
audit.

## `internal-docs-reviewer` fixtures are directories, not single files (Sub-task 1, #46)

`feature-spec-reviewer`/`feature-design-reviewer` fixtures are one `.md` file
per case because those agents review one file. `internal-docs-reviewer`
reviews a *set* of files together — some checks (a `CLAUDE.md` status entry
duplicating `features/COMPLETED.md`, a `NOTES.md` claim contradicted by a
config file, a `.claude/rules/*.md` claim contradicted by the hook it
describes) only make sense with more than one file present. So each case
under `devproc/tests/internal-docs-reviewer/` is a small fixture *directory*
(`<case>/`, using real relative paths like `CLAUDE.md`, `features/COMPLETED.md`,
`.claude/rules/...`) paired with a top-level `<case>.expected.md`, and the
agent is pointed at the directory as if it were the repository root.

(Historical: at Sub-task 1 the agent carried `memory: project`. **Superseded
2026-07-25** — the agent was made *stateless* (see the caller-owns-memory note
below), so it has no memory directory and fixture runs neither read nor write
any memory; the settled-decision record now lives with the
`/internal-docs-prune` skill.)

## Writing a genuine `judgment` fixture is harder than it looks (Sub-task 1, #46)

The first `judgment/NOTES.md` fixture — a note that local dev DB seeding takes
about 40 seconds — failed on first test: a general-purpose agent playing the
`internal-docs-reviewer` persona correctly found **no** finding, because the
entry is, on reflection, exactly what NOTES.md's durability criterion asks
for (a lasting environmental gotcha, not contradicted by anything). A
"borderline" fixture has to actually exhibit the *symptoms* the review
criteria call out as suspect — not just be a plausible edge case in the
fixture author's head. The fix: rewrote the entry as a dated, stopgap-flavoured
note about a flaky test ("flaked twice this week... bumped the timeout as a
stopgap") — language that visibly resembles the durability criterion's own
listed suspect categories (transient remark, completed-workaround post-mortem)
while still holding one durable nugget worth keeping (profile the CSV writer
on recurrence). Re-tested and got the expected `judgment`/`condense` result.
General lesson for any future fixture in this class: write the *symptom* the
criterion names, don't just assert ambiguity and hope.

## Validating `/internal-docs-prune`'s application logic without a live agent (Sub-task 2, #46)

`internal-docs-reviewer` is a newly written agent (Sub-task 1), so — per the
"Testing a new agent in the session that creates it" note above — it is not
invocable as an agent type in this session either. The skill's Testing box
("a worked run confirms...") was therefore validated a level down: using the
reviewer's *known* findings, taken verbatim from its fixtures'
`.expected.md` files, as the input to the skill's application steps (Step 4
`redundant`/`stale` auto-apply, Step 5 `judgment` escalation, the Step 4
`move` write→verify→remove ordering), executed by hand against **copies of
the fixtures under `/tmp`**, never against `devproc/tests/` or real repo
docs.

What each scenario proved:
- **Unattended, `redundant`+`stale` auto-apply, `judgment` deferred:** applied
  the `redundant` fixture's delete finding and the `stale` fixture's delete
  finding; both landed cleanly. The `judgment` fixture's NOTES.md was left
  completely untouched — confirming unattended mode takes no action on
  `judgment`, only lists it.
- **Interactive, `judgment` default:** applied the `judgment` fixture's
  finding via `condense` (the fixed default), confirming `delete` is never
  used for a `judgment` finding by default.
- **Move without loss:** the `redundant` fixture itself isn't a clean move
  test — its destination (`features/COMPLETED.md`) already has the content,
  since that's *why* it's redundant. Built a derived copy with the
  destination entry stripped out first, then applied the skill's exact
  ordering (write destination → re-read to verify → only then remove from
  source). Confirmed both that the content lands at the destination and
  disappears from the source, and — separately — that if the post-write
  verification were to fail, the source is left untouched and the anchor
  text is provably still there (a deliberate second run with the write step
  skipped).
- **Idempotency:** the auto-applied `redundant` fixture's `CLAUDE.md`, after
  pruning, was byte-identical to the `idempotent/` fixture's `CLAUDE.md` (the
  fixture representing "output of a previous prune pass") — i.e. auto-apply
  reaches exactly the steady state a second pass is expected to find nothing
  further to do with.

This exercises the skill's *application* logic (the actual deliverable this
sub-task adds) faithfully, but not the end-to-end path of spawning the real
agent and parsing its live prose output — that remains untested until a
session restart makes `internal-docs-reviewer` invocable, same caveat as
Sub-task 1's fixture validation.

## Sub-task 3 three-way consistency check (#46)

The status-section cap is now stated in three places and must agree. Wording
compared, paraphrase-for-paraphrase:

- `feature-init/SKILL.md` template (`### Documents to support the model` →
  `CLAUDE.md` bullet): "holds **only** the in-progress feature (if any) plus
  **at most one line** for the single most recent completion. Older
  completion entries live in `features/COMPLETED.md` only and are deleted
  from `CLAUDE.md` — `/feature-end` performs this trim when it closes a
  feature."
- `feature-end/SKILL.md` step 3 (new bullet, added alongside the existing
  `COMPLETED.md` entry step): "retain only the in-progress feature (if any is
  starting next) plus **at most one line** for this single most-recent
  completion; delete any older completion entries or status lines. Nothing
  is lost — that content is already preserved in `features/COMPLETED.md`."
- `internal-docs-reviewer.md` (frontmatter `description` example, and
  criterion 2's `CLAUDE.md` duplication check): assumes the same target —
  "the feature in progress, plus at most one line for the most recent
  completion; older completions live in `features/COMPLETED.md` only" — and
  treats a status entry as `redundant` precisely when it duplicates
  `features/COMPLETED.md`.

All three name the same cap (in-progress feature, if any, + at most one
most-recent-completion line; everything older deleted from `CLAUDE.md` and
preserved only in `COMPLETED.md`). No contradiction found — the reviewer's
existing wording did not need editing, matching the manager's instruction not
to touch the agent in this sub-task.

Deliberately left alone per scope: the project's own root `/workspace/CLAUDE.md`
`## Current status` section is *not* trimmed to this cap as part of this
sub-task — that's `/internal-docs-prune`'s job (or a future `/feature-end`
run), not a prevention-rule edit.

## internal-docs-prune documentation placement (sub-task 4)

`internal-docs-reviewer` was grouped next to `docs-structure-reviewer` in both
`devproc/README.md`'s Contents table and its `## Agent reference` section
(rather than at the end, alphabetically, or beside the code-review agents) —
the two are thematically paired (both are read-only findings-only review
agents over documentation), even though one covers internal docs and the
other user-facing docs. Same reasoning for the equivalent root `CLAUDE.md`
contents-list placement.

`docs/workflow.md`'s new `## Keep internal docs tidy` section was placed at
the very end, after `## Complete a feature`, rather than folded into the
"Complete a feature" section or inserted earlier in the lifecycle — it isn't
a lifecycle step, it's an ongoing hygiene task, so it reads better as a
standalone bookend than as a sub-point of any one stage. Its heading anchor
(`#keep-internal-docs-tidy`) is linked from `docs/capabilities.md`, and the
new capabilities.md section's anchor (`#internal-docs-hygiene`) is linked back
from workflow.md — checked both resolve under GitHub's heading-to-anchor
convention (lowercase, spaces to hyphens) since Markdown doesn't fail loudly
on a broken in-repo anchor.

The `feature-init` CLAUDE.md template already stated the status-cap and
referenced `/internal-docs-prune` (added in sub-task 3) — verified it against
the shipped skill/agent behaviour and left it untouched, per the manager's
brief not to rewrite what already covers the requirement.

## Sub-task 7 dry-run: `/feature-design` step 6 produces the right shape both ways (#47)

Reasoning walkthrough (no live skill invocation — traced the updated
`devproc/skills/feature-design/SKILL.md` step 6 instructions by hand against
two representative strategies), as the dry-run evidence for Sub-task 7's
Testing box.

**Scenario A — gates exist.** A feature ("add rate limiting to the public
API") whose `## Sign-off strategy` has: Testing and Documentation scoped to
specific sub-tasks; Code review = "one agent `/review-branch` before
`/feature-end`"; Docs review = "one agent `docs-structure-reviewer` over the
updated docs at `/feature-end`"; User review tied to one specific sub-task
(not end-of-feature). Step 6's new bullets: only Code review and Docs review
are genuine end-of-feature gates (once-only, not owned by any ordinary
sub-task) — Testing/Documentation/User review are all already per-sub-task, so
they are not gates. Result: a last sub-task is added —

```
N. **Final sign-off criteria** — end-of-feature gates for this feature, per `## Sign-off strategy`
   - [ ] Code review (agent): /review-branch over all changed files
   - [ ] Docs review (agent): docs-structure-reviewer over the updated docs (performed at `/feature-end`)
```

Confirms two things worth recording: (1) the annotation attaches to *only* the
docs-review box, not the code-review box — `/review-branch` is performed by a
separate skill invocation before `/feature-end` runs, so it is not
`/feature-end`-performed and must not carry the annotation; getting this wrong
either way (annotating both, or neither) would be a real bug. (2) This exactly
reproduces the shape used throughout Sub-task 5's fixtures and this feature's
own Sub-task 7, which is expected — they were built from this same reading of
step 6.

**Scenario B — no gates.** A feature ("rename a config field for clarity")
whose strategy is: Testing on the one sub-task; Documentation = "None — no
user-facing or architectural doc touches this field"; Code review = "user
reads the diff" (tied to the one sub-task, not an agent end-of-feature gate);
Docs review = "None — no docs affected"; User review folded into the same
sub-task's code-review box. Step 6: no category here is a genuine end-of-feature
gate (nothing is "once, at close, by an agent, owned by no sub-task"), so no
"Final sign-off criteria" sub-task is added — the plan ends at its ordinary
sub-task(s), matching the spec-stage settled decision that the sub-task is
conditional, not mandatory.

One design point the dry-run confirms works as intended: the step 5
target-structure template itself shows the final sub-task as `N. **Final
sign-off criteria** — <only when ... omitted entirely otherwise — see step
6>` — the caveat is inline in the template line, not only in step 6's prose.
That stops the literal-minded misreading "the template always has one, so
always add it," which a template-only skim could otherwise produce.

Also confirms `feature-design-reviewer`'s Sub-task 4 criteria are consistent
with both outcomes: it would flag a missing final sub-task in Scenario A if
omitted, and would flag an unwarranted one in Scenario B if incorrectly added
— neither false-positives on the correct output of either scenario.

## Memory belongs to the skill, not the agent (#46, code-review resolution)

The requirement "uses project-scoped agent memory to avoid re-litigating
borderline entries" was first wired as `memory: project` on the
`internal-docs-reviewer` agent. That is **non-functional**: the agent is
read-only and finishes *before* the calling session decides anything, so it can
never observe an outcome to record. Resolved 2026-07-25 (code review) by
inverting ownership:

- The **agent is stateless** — no `memory:` field, no memory section. It
  re-reports every borderline `judgment` call on every run.
- The **skill owns the record** of settled `judgment` calls, under
  `.claude/agent-memory/devproc-internal-docs-reviewer/MEMORY.md`. It reads the
  record at Step 5 to suppress a call already decided (unless the anchor text
  has changed since), and writes it only when an interactive decision settles a
  call. Only the caller sees the decision, so only the caller can remember it.

The key framing: this memory is a **convenience** (it stops the skill re-asking
about calls the user already ruled on), never a correctness gate. Nothing is
lost or wrongly applied without it — `redundant`/`stale` gate the real changes,
and those are re-verified live on every run and never remembered.

Two findings-contract constraints were settled at the same review, both
following from what the gating classes *mean*:
- **`redundant` ⇒ `delete` only.** The class means the content is already at
  its canonical home, so `move` would write a duplicate and there is nothing to
  condense.
- **`judgment` + `move` applies on plain confirmation.** The interactive
  default is the agent's *proposed* action (`condense` or `move`), never
  `delete`; action and gating class vary independently, so a `judgment` finding
  can legitimately be a `move`. Invalid class/action pairings
  (`redundant`+non-`delete`, `judgment`+`delete`) are rejected as defects in the
  skill's Step 3, so Steps 4/5 can assume a valid action.
