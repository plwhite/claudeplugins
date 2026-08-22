# Notes

Non-obvious findings. Do not record things derivable from reading the code.

---

## `feature-init` can be run from the CLI despite `disable-model-invocation`

`feature-init` has `disable-model-invocation: true`, which blocks only the
Skill tool — attempting `Skill(devproc:feature-init)` errors out. A CLI
invocation is not blocked: `claude -p --permission-mode bypassPermissions
"/feature-init"`, run with the working directory set to a scratch workspace,
runs the skill end to end (verified). To apply a model-text change without a
CLI run, hand-apply step 1b instead: copy
`devproc/skills/feature-init/FEATUREMODEL.md` over `features/FEATUREMODEL.md`
byte-for-byte. The two copies must stay identical, and
`diff devproc/skills/feature-init/FEATUREMODEL.md features/FEATUREMODEL.md`
is the check. Never hand-edit the installed copy: the next `/feature-init`
overwrites it from the canonical one, silently discarding the edit.

## Verifying a skill's internal steps needs the verbose transcript

`claude -p`'s default output is only the final summary text, which is not
enough to verify a skill took a specific *internal* step (e.g. which
directory it ran a command in) rather than merely reaching the right end
state. Add `--verbose --output-format stream-json` to get the full
tool-call transcript as JSONL — each assistant text block and tool_use/
tool_result pair — which can be grepped or parsed for the literal command and
its output (verified while testing `features-outside-repo` sub-task 3: the
default summary didn't name which repository `/feature-spec` step 1a read the
remote from, but the verbose transcript showed the exact `cd .../repo && git
remote -v` call and the resolved `owner/repo`).

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

## A severity ceiling in a review agent's tail can silently swallow a new criterion (#57)

Both `feature-spec-reviewer` and `feature-design-reviewer` end with the
constraint "Do not flag stylistic preference as MAJOR or BLOCKING". Adding a
Clarity criterion rated MAJOR does not conflict with it: an artefact exists to
convey meaning, so a reader who cannot extract that meaning has hit a functional
failure, not a matter of taste. The two rules govern different categories.

The hazard is that an agent may not see it that way. If it files clarity under
"style" — an easy slip, since both concern how the prose reads — it resolves an
apparent conflict by rating clarity findings MINOR, the new criterion silently
stops gating anything, and the only visible symptom is a clarity fixture failing
for no apparent reason. Both agents therefore now state the category distinction
explicitly rather than leaving it to be inferred: stylistic preference is wording
one would phrase differently where the meaning is *already clear*; a failure
against `### Readability` is a different kind of thing and is MAJOR.

`docs-structure-reviewer` had the same conflation in a worse form, and predates
this feature: its severity ladder defined MINOR as a "clarity or consistency
issue", and its constraints capped stylistic preference below MAJOR "unless they
cause genuine confusion" — making confusion an exception carved out of taste.
Split into separate Clarity and Stylistic Consistency criteria, with MINOR
now reserved for issues that do not obscure meaning.

Generalises two ways. First, the severity ceiling in a closing `## Constraints`
list is easy to miss when writing a new `## Review Criteria` entry, because the
two are ~100 lines apart — check the tail whenever a criterion is added with a
severity floor. Second, when a new criterion is adjacent to an existing capped
one, say what separates them; an agent left to infer the boundary will
sometimes infer it wrongly, and always in the direction of the older rule.

A related trap in the same feature, worth the same care: the fixture suites'
pass rule is "no BLOCKING or MAJOR findings against a section the case does not
target". Any new MAJOR-capable criterion is therefore evaluated against *every*
section of *every* fixture, so the shared `control.md` baselines must themselves
satisfy the new criterion or **all** cases in the suite fail, not just the new
one.

## Agent result delivery can fail silently mid-session (#57, Sub-task 7)

Sub-agents spawned via the `Agent` tool stopped returning their output partway
through a session. The first two spawns delivered full results; every spawn
after that returned only an `idle_notification` with no content, including a
re-run of the **same agent type** that had just succeeded. Sending the idle
agent a direct message asking for its findings also produced only another idle
notification.

The trap is that this looks like a defect in whatever you spawned. The
diagnosis went "the design reviewer is broken" for several rounds, because the
spec reviewer had worked and the design reviewer never had. That was wrong: the
distinguishing variable was **when** the agent was spawned, not which agent it
was — visible only after tabulating every spawn in the session against its
outcome. When an agent goes quiet, tabulate all spawns before blaming the
newest one.

Two practical consequences. **Do not tick a sign-off box on a review you never
saw** — an idle notification is not a pass, and a test whose result never
arrived is unrun, not passed. **And do not keep re-spawning**: four attempts
plus a deliberately minimal diagnostic fixture (a short, clean plan file with
codebase reading suppressed, to separate "workload too heavy" from "delivery
broken") all failed identically. The minimal fixture is the cheap experiment
worth running early, because it splits those two explanations in one spawn.

A degraded agent cannot be shut down either. `shutdown_request` to the one
agent that had delivered a result was processed and it terminated cleanly;
the same request to five degraded agents produced only more idle
notifications. So the degradation is not "fails to report its findings" but
"cannot act on anything" — do not spend turns trying to reach or tidy them up,
and expect to leave them stranded until the session ends.

Not established: what triggers the degradation, or whether it is spawn-count,
elapsed-time, or context related. A fresh session is the known-good reset.

**Superseded 2026-08-09 — there is a reliable workaround.** A fresh session is
no longer the only reset, and the degradation is not even reliably absent from
one: the *first* spawn of a brand-new session returned an idle notification with
no content, so "spawn early while delivery still works" is not a safe strategy.
Spawning synchronously (`run_in_background: false`) makes no difference — this
build spawns asynchronously either way, so it is the same delivery path.

The workaround is to bypass the in-session `Agent` tool entirely and invoke the
agent through the CLI, which returns its output on stdout:

```
claude -p --agent feature-design-reviewer '<the review prompt>'
```

Run from the repository root, so the agent resolves `features/FEATUREMODEL.md`
and can read the codebase as usual. This delivered a complete review — findings
and verdict — on the same fixture whose in-session spawns had gone silent. It is
now the preferred route for the fixture suites specifically, because a
regression run is a dozen-plus invocations and a silent failure partway through
is expensive to detect: stdout either has a verdict line or it does not.

Two things this does **not** change. The results are still agent output and are
still checked against the `.expected.md` files in the normal way. And the rule
above stands unaltered — a run whose verdict you never saw is unrun, not passed.

## Check what a backwards-compatibility carve-out actually protects (#57)

`/feature-design` step 1b was written to gate on `## Requirements` but
deliberately *not* on `## Spec`, reasoning that a plan file specced before
`## Spec` existed must stay designable. The reasoning was sound and the
conclusion still wrong, because the protected set turned out to be empty:
`/feature-design` only ever designs a feature listed in `features/PENDING.md`,
and both `PENDING.md` and `DEFERRED.md` (the only route back into pending) were
empty. Every legacy plan file was completed or in progress — none could reach
the skill. The carve-out bought nothing and cost the check that catches the
lifecycle skills being run out of order.

The generalisable move is cheap: before writing a compatibility carve-out, ask
what reaches the code path it guards, and check. Here that was two `cat`s. The
failure mode it permitted was also the worst kind — silent: with no `## Spec`
and no gate, `/feature-design` would have designed against `## Requirements`
alone, inventing the statement of what the feature must do that the user was
supposed to agree, and nothing in the output would have said so.

Two follow-on points found while fixing it. **A stale carve-out leaves
fingerprints elsewhere** — the same tolerance had propagated into the step-5
template ("if the file does not exist, create it with all sections", and a
`## Requirements` placeholder saying the section "may be omitted", both
contradicting the step-1b stop) and into `docs/workflow.md`, which told users
Claude fetches the GitHub issue "only if they are missing". Grep for the
behaviour, not just the rule. **And a reviewer needs its own guard**: the
skill's stop protects the main path, but `feature-design-reviewer` can be
invoked standalone, where "does this design implement the spec?" against an
absent spec is not a weaker review but an incoherent one. It now refuses with a
single BLOCKING finding rather than falling back to `## Requirements` — a review
against a standard the agent inferred for itself is worse than no review,
because it looks like one.

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

## A bare one-line description no longer forces NEEDS WORK (superseded, #57)

*The claim below describes behaviour that no longer ships; it is kept because
the reasoning that removed it is the useful part. Skip to "Superseded" for what
is true now.*

For a bare one-line feature description, `/feature-spec` **used to** reliably end at
`NEEDS WORK`: the skill wrote a "no requirements beyond the summary"
placeholder, and the reviewer rated a spec with no requirements as blocked.
That was read at the time as working as intended — the questions go to the user
— but it meant `READY FOR USER REVIEW` was not reachable from a one-liner,
which matters for unattended mode.

**Superseded by `clear-specs-and-designs` (#57) — and the behaviour above was a
defect, not a safety property.** The reasoning was circular: `/feature-spec`
wrote a "no requirements beyond the summary" placeholder into `## Requirements`
whenever the description was short, and the reviewer then blocked the spec for
having no requirements. The skill discarded what the user typed, and the
reviewer objected that nothing was typed.

**A one-line description is requirements.** "Add logging to the foo function"
states what is wanted; the feature exists because the user said so. The
placeholder is gone — `## Requirements` now records a short description verbatim
as the input it is — and a small, well-understood feature can legitimately reach
`READY FOR USER REVIEW` and run all the way through unattended. The gate exists
to stop work no human sanctioned, not to impose a minimum length on the
sanction.

Two wrong turns were taken before this landed, both worth remembering:

1. Reading the old NEEDS WORK guarantee as protective, and proposing to preserve
   it by treating every unconfirmed proposal in `## Spec` as a BLOCKING
   question. Since a thin-input spec is *entirely* proposals, that would have
   made small features permanently unable to pass — a defect dressed as caution.
   Proposals are judged like anything else: one resting on a judgement the user
   must make blocks, one filling an obvious gap does not.
2. More generally: when an existing behaviour looks like a safeguard, check
   whether anything actually *chose* it. This one was a side effect of a
   placeholder, and no one had ever decided that small features should be
   unable to pass review.

In practice the real constraint on an unattended thin-input run is the
**sign-off strategy**, which cannot be inferred from a one-liner — a user who
wants such a feature to run start to finish needs to supply it with the
description.

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
under `tests/devproc/internal-docs-reviewer/` is a small fixture *directory*
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
the fixtures under `/tmp`**, never against `tests/devproc/` or real repo
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

## A sync-marker must not live inside a file that gets copied downstream (`extract-feature-model`, #43)

The `/review-branch` gate caught a subtle one: the natural place to record the
"keep the two `FEATUREMODEL.md` copies byte-identical" obligation is a comment at
the top of the file — but `feature-init` copies `FEATUREMODEL.md` **verbatim**
into every consumer project, so any such note ships too, where it references a
twin path (`devproc/skills/feature-init/FEATUREMODEL.md`) that does not exist in
the consumer's repo and tells their maintainer to sync a file that isn't there.
A sync obligation between two files in *this* repo is a *this-repo* concern and
must be documented in this repo's own non-shipped docs (`CLAUDE.md` maintainer
note + this file), never inside the shipped artifact. General rule: anything
written inside a file that a skill copies out is addressed to the consumer, not
to this repo's maintainers.

The obligation is also *light*, because `/feature-init` is the sync mechanism,
not hand-maintenance: the canonical `devproc/skills/feature-init/FEATUREMODEL.md`
is the master, and `feature-init` step 1b **refreshes** the project's
`features/FEATUREMODEL.md` from it on every run (overwriting — the model is
canonical boilerplate, not project data). So this repo is a plain consumer with
no special-casing; the two copies diverge only if the master is hand-edited
without re-running `/feature-init`. (An earlier draft had step 1b *preserve* an
existing copy, which would have made this repo need special handling and let the
copies drift — corrected after user review to always refresh.)

(Also settled at the same review: keep `FEATUREMODEL.md` with **no** top-level
heading — `CLAUDE.md`'s `## Feature model` section supplies it, so the import
doesn't produce two consecutive `## Feature model` headings once expanded. The
cost is that the file read standalone opens on an `###` sub-heading, an
acceptable cosmetic since the every-session path is the imported one.)

## Sub-task 1 (`extract-feature-model`, #43) verification method

The precise check performed for the Testing sign-off, since "loads under
`/context`" can't be run non-interactively from this session: `sed -n
'84,203p' CLAUDE.md` (the exact original `## Feature model` section, verified
by content) `diff`ed byte-for-byte against the new `features/FEATUREMODEL.md`
— identical. Then confirmed by `grep` that `CLAUDE.md` no longer contains
`### Sign-off criteria` / `### Resuming after a session restart` / `###
Documents to support the model`, that the single remaining `## Feature model`
line 84 is followed only by the one-line `@features/FEATUREMODEL.md` import
prose, that the import token carries zero backticks, and that the count of
` ``` ` fence markers before that line is even (so the line sits outside any
fence, not just absent of literal backticks). Confirmed the referenced path
exists at `features/FEATUREMODEL.md` relative to the repo root where
`CLAUDE.md` lives.

**Live load subsequently confirmed by the manager (2026-07-26), so nothing is
left for the user here.** The definitive check the teammate's own session could
not run was run from the manager session with a headless subprocess: a fresh
`claude -p` launched in the repo root, **with `Read`/`Bash`/`Grep`/`Glob`/`Task`/`WebFetch`
disabled**, was asked to quote the first sentence under `### Sign-off criteria`.
It returned the sentence verbatim ("This section is the **canonical statement of
the sign-off model**.") — text that now exists *only* in `features/FEATUREMODEL.md`.
With every file-reading tool disabled, the sole way that text could be in context
is the `@import` expanding it at launch. This is a stronger check than `/context`
(it proves the content is actually present, not merely listed). Method worth
reusing for any future "does an `@import` load?" question: disable all read tools,
then ask the model to quote content unique to the imported file.

## Sub-task 3 (`extract-feature-model`, #43) traced walkthrough of the rewritten `feature-init`

`feature-init` has `disable-model-invocation: true` (see the note above), so —
as with Sub-task 7's dry-run of `feature-design` step 6 — the Testing sign-off
was validated by tracing the rewritten `devproc/skills/feature-init/SKILL.md`
step 1 by hand against two scenarios, not by a live invocation.

**Scenario A — fresh project** (no `features/` directory, `CLAUDE.md` has no
`## Feature model` section). Step 1.1: `features/FEATUREMODEL.md` does not
exist, so `features/` is created and the skill's own `FEATUREMODEL.md` (the
file sitting alongside `SKILL.md`) is copied to `features/FEATUREMODEL.md`.
Step 1.2: `CLAUDE.md` has no `## Feature model` section, so one is added
containing only the one-line `@features/FEATUREMODEL.md` import. Step 1.3: no
`### Sign-off criteria` sub-heading exists in `CLAUDE.md` to migrate, so this
step is a no-op. Result: project ends with `features/FEATUREMODEL.md` present
and the import in `CLAUDE.md` — correct.

**Scenario B — already-embedded project** (an older `feature-init` run wrote
the full model text as the body of `CLAUDE.md`'s `## Feature model` section,
complete with `### Sign-off criteria` / `### Resuming after a session restart`
/ `### Documents to support the model` sub-headings; no
`features/FEATUREMODEL.md` exists yet). Step 1.1: same as Scenario A — copies
the canonical file to `features/FEATUREMODEL.md`. Step 1.2: `CLAUDE.md` has a
`## Feature model` section but it lacks the un-backticked import (it has the
embedded text instead), so this is recognised as needing migration rather than
"import already present." Step 1.3: the sub-headings identify this as an
already-embedded project; the embedded section body is replaced with the
one-line import, removing the sub-headings and their prose. Result: same end
state as Scenario A, with no duplicated model text left in `CLAUDE.md` —
correct migration.

**Idempotency.** Re-running the walkthrough against either scenario's *output*
state (import present, `features/FEATUREMODEL.md` exists) hits step 1.1's
"does not already exist" guard (no-op), step 1.2's "already contains the
import" guard (no-op), and step 1.3's explicit "import already present and the
file exists — leave both as they are" clause. No step re-copies or re-writes
anything — confirms the rewrite is safe to re-run, consistent with the rest of
`feature-init`.

**One case the walkthrough also confirms is handled**, from the plan's "Dead
ends to avoid": a `## Feature model` section whose only path mention is inside
backticks or a Markdown link (not a real `@import`) is *not* mistaken for
"already migrated" — step 1.2 explicitly requires the import to be
un-backticked before treating it as present, so such a project would have the
correct import line added alongside the existing (inert) mention rather than
being skipped.

**Static check.** `diff /workspace/features/FEATUREMODEL.md
/workspace/devproc/skills/feature-init/FEATUREMODEL.md` — no output, confirming
this repo's own copy is byte-identical to the shipped canonical file the skill
copies from, as the design's audit check requires.

## Sub-task 2 (`extract-feature-model`, #43) scope boundary on `devproc/README.md`

Three `devproc/README.md` lines describe `feature-init`'s own current behaviour
("adds the feature model to `CLAUDE.md`", "writes the feature model section to
`CLAUDE.md`", "Adds a `## Feature model` section to `CLAUDE.md`" — the Contents
table entry and the `feature-init` section's opening two sentences). These were
deliberately **not** changed in Sub-task 2, even though grep flags them: they
are accurate descriptions of what `feature-init` still actually does today (it
has not been rewritten yet — that is Sub-task 3). Changing them now to claim
`feature-init` writes `features/FEATUREMODEL.md` would make the README
describe behaviour that does not yet exist. The one README line that *was*
changed (the parenthetical "(The canonical statement of the sign-off model
lives in the `### Sign-off criteria` section...)") is a **location reference**
for where other tools should look, not a description of `feature-init`'s
mechanism, so it correctly repoints now regardless of when `feature-init`
itself is rewritten. Sub-task 3 should update these three remaining lines as
part of rewriting `feature-init`'s actual behaviour, since they are the
README's documentation of that skill.

## Only some fixture flaws needed relocating when `## Spec` was added (Sub-task 7, #57)

When `## Spec` was added to both fixture suites and both reviewer agents
stopped treating `## Requirements` as "what the feature must do", only two of
the five `feature-spec-reviewer` cases (`premature-design`, renamed
`incomplete-spec`) actually needed their planted flaw *moved* into `## Spec`.
The other two content-bearing cases needed no such move, for two different
reasons, and it is worth recording why so a later reader does not "fix" them
unnecessarily:

- **`non-auditable-criteria`'s flaw was never in `## Requirements`** — it lives
  in `## Sign-off strategy`, which is still reviewed exactly as before. Adding
  the new `## Spec` (clean, matching `control.md`) was the only change needed.
- **`unresolved-blocker`'s flaw moved "for free."** Its contradiction and
  unstated dependency are facts about the underlying request, not about how
  `## Requirements` happens to be worded. Once `## Spec` is written to
  *faithfully* cover everything `## Requirements` says — which the reviewer's
  new "does everything in Requirements show up in Spec" check now demands
  anyway — the contradiction necessarily appears in `## Spec` too, and the
  still-active "Blocking issues" check catches it there. No deliberate
  rewording was needed beyond writing a properly-derived `## Spec`.

Only `incomplete-spec` (ex-`incomplete-requirements`) and `premature-design`
needed deliberate rewording, because their flaws are properties of *how a
section is written* (deferring instead of restating; stating *how* instead of
*what*) that only manifest if that specific section is reviewed for that
specific thing — and `## Requirements` is no longer reviewed for either.

One retained check is easy to lose track of: `feature-spec-reviewer` still
checks `## Requirements` for one narrow thing — whether source-issue content
was genuinely *captured* there rather than deferred to (e.g. "see issue #47
for detail"). None of the five spec-suite fixtures currently exercises that
specific check in isolation (the old `incomplete-requirements` case exercised
it before this sub-task, folded into a bundle of other flaws; the new
`incomplete-spec` deliberately keeps `## Requirements` clean so as to isolate
the `## Spec`-side flaw it now tests). That check therefore currently has no
dedicated fixture — a gap, not a defect, and not something this sub-task's
scope (relocate existing flaws, add the design suite's `no-spec` case) asked
to fix.

`incomplete-requirements.md`/`.expected.md` were renamed to
`incomplete-spec.md`/`.expected.md` (via `mv`, not `git mv` — this repo's rule
against git commands that change repository state applies to renames too; an
accidental `git mv` here was caught and unstaged with `git reset HEAD` before
any further edits).

## Obscuring a spec for the clarity fixture also plants an unsourced-claims flaw (Sub-task 8, #57)

`unclear-spec.md` breaks `### Readability` by burying the point, front-loading
formatting detail, and referring to "every other feed in the reporting
pipeline", "the other export types in the system" and "the dashboard's bulk
operations" as though the reader knows them. Those three phrases are the only
part of the mutation that is **added** rather than reorganised — they appear
nowhere in `control.md`. That makes them undefined cross-references (the
clarity fault under test) *and*, read literally, assertions about the codebase
that `## Requirements` never establishes and that carry no proposal marking —
which is a live "Complete and clear" fault in its own right.

So the case cannot isolate clarity as cleanly as its siblings do: a competent
reviewer has two legitimate angles on the same wording. A run on 2026-08-10
took the second angle and reported it at **BLOCKING `[decision]`**, above the
MINOR/SUGGESTION band the expectation originally allowed. The expectation was
**widened** rather than the agent or the fixture changed (user decision,
2026-08-10): the finding is correct, and a spec asserting unsourced facts about
the codebase *should* stop and ask. The accepted consequence is that this
fixture can halt an unattended `/feature-spec` run, since BLOCKING plus
`[decision]` is exactly the halting combination.

The general lesson for anyone writing a future clarity fixture: obscuring a
spec by inventing context is the easiest way to violate "Nothing assumed", but
invented context is indistinguishable from an unsourced claim. To isolate
clarity alone, bury and under-define material that `## Requirements` already
establishes instead of introducing new referents.

## A planted flaw must keep its wording as well as its salience (Sub-task 8, #57)

`unresolved-blocker`'s dependency finding has now been lost twice, for two
different reasons, and the pair is the useful part.

**2026-08-09 — placement.** When the flaw was relocated from `## Requirements`
into `## Spec`, the `multi-currency` dependency was demoted from a standalone
paragraph to a trailing subordinate clause inside the currency bullet. The
agent read past it. Fixed by restoring it to its own paragraph.

**2026-08-10 — wording.** With placement fixed, the agent *still* reported it
at MINOR `[rewrite]` — as a readability "nothing assumed" nit recommending a
link be added — rather than the required BLOCKING `[decision]`. The sentence
read "the rates table **delivered by** the `multi-currency` feature", which
asserts the dependency as already shipped. A dependency stated as met is not a
blocker, so there was nothing to escalate; the agent's MINOR was arguably the
correct reading of the text as written. Fixed by rewording to "Currency
conversion depends on a rates table. The `multi-currency` feature is expected
to provide one," in `## Requirements` and `## Spec` together — they carry the
paragraph byte-identically, and a `## Spec` alone calling the feature pending
would diverge from its own captured input.

The lesson: when auditing a fixture, check that the planted flaw is **findable**
— present, salient, *and* worded so the fault is still available to be found.
Confident phrasing defuses a planted blocker as effectively as burying it, and
both failures look identical from the outside (a missing required finding).

The agent is not generally blind to unconfirmed dependencies, which is what
made the wording the prime suspect: on the design suite's
`unresolved-design-question`, where the text leaves the dependency open, it
flagged `ReportStreamService` at MAJOR, searched for it, and then explicitly
declined to treat absence from this repository as evidence — asking for
confirmation instead of asserting it missing, which is exactly the required
behaviour.

## Skills can be invoked in a fresh process via `claude -p '/skill-name args'` (Sub-task 9, #57)

Testing skill *behaviour* from the session that is driving the test is weak
evidence: the driver already knows what the skill is supposed to do, and can
steer it there without meaning to. Slash commands work in print mode, so
`claude -p '/feature-design nospec-probe'` runs the skill in a cold process
that has none of that context, and returns its output on stdout. This is how
the `/feature-design` step-1b stop was verified, and it is the route to prefer
for any future test of what a skill *does* rather than what it says.

It is the same mechanism already recorded above for running agents
(`claude -p --agent <name>`), which remains necessary because in-session
`Agent` results can fail silently — so skill and agent testing both go through
the CLI, and neither is affected by that bug.

## `/feature-design` step 9's amendment trigger is a judgement call (Sub-task 9, #57)

Step 9 says `/feature-design` may amend `## Spec` when design shows it is
"wrong, incomplete, or impossible as written", and step 9d makes a proposed
amendment stop an unattended run — the same treatment as a `[decision]`
finding. The end-to-end run hit a case sitting right on that line, and it is
worth knowing which way it fell.

The throwaway spec proposed hiding a tmux status bar "per client", resting on
a premise that turned out to be false (`status` is a session option; there is
no per-client equivalent). But the spec's three *observable* requirements were
all still achievable by another mechanism. The run judged this a misdescribed
mechanism rather than a wrong spec, recorded the correction and its
verification in `## Design`, and continued without stopping.

That is defensible, and `feature-design-reviewer` independently endorsed it —
but note the shape of it: whether a falsified premise is "the spec is wrong"
or "the mechanism was misdescribed" is a judgement, and an unattended run has
an obvious incentive to resolve it toward not stopping. If step 9's stop is
meant to be load-bearing, this boundary is where it will leak, and the
mitigation that actually worked here was the design recording the
contradiction loudly enough that a human could catch it afterwards.

## `/feature-init` copies from the installed plugin, not the repo (Sub-task 11, #57)

The maintainer note in `CLAUDE.md` says: to change the feature model, edit the
canonical `devproc/skills/feature-init/FEATUREMODEL.md` and re-run
`/feature-init`. That is correct but incomplete, and the gap is a trap.

`/feature-init` is told its own base directory when invoked, and copies
`FEATUREMODEL.md` from *there*. In this container that is
`/home/claude/claudeplugins/devproc/skills/feature-init/` — the **installed
plugin**, not `/workspace/devproc/`. So "edit the canonical file and re-run
`/feature-init`" only works if the installed plugin has already been refreshed
from the repo. Edit the repo copy and re-run the skill directly, and it
overwrites `features/FEATUREMODEL.md` with the *old* text, silently reverting
the change — and leaving the repo's canonical file and the installed model
disagreeing, which is the exact drift the single-source-of-truth pattern
exists to prevent.

This was caught on 2026-08-11 only because the divergence was checked with
`diff` before the copy rather than after. The failure is quiet: `/feature-init`
reports success, and the resulting `features/FEATUREMODEL.md` is internally
consistent — just stale. Nothing downstream notices.

The existing note "Agents loaded through the `Agent` tool come from
`/home/claude/claudeplugins/devproc/`" covers agent *definitions*. This is the
same root cause with a wider blast radius: it applies to any **data file a
skill ships and copies**, where the effect is not "you tested old prose" but
"you reverted a committed change". The working order is: edit the repo, refresh
the plugin tree from the repo, verify byte-identical, *then* run the skill.

## An in-session agent being slow is not the same as it being degraded (Sub-task 11, #57)

Four review agents were spawned in one session. The first two returned full
results; the third and fourth went quiet. That matches the documented
degradation signature ("the first two spawns delivered full results; every
spawn after that returned only an `idle_notification`") closely enough that it
was called as a reproduction — and `ListAgents` reporting no reachable agents
seemed to confirm it.

It was wrong. The third agent delivered a complete review several minutes
later; only the fourth genuinely failed. The tell that should have prevented
the misdiagnosis: an idle notification arriving for an agent that has already
delivered is normal completion, whereas the degradation signature is an idle
notification *instead of* a result. Those look identical if you are matching on
"agent went idle" rather than on "agent went idle having produced nothing".

Two practical consequences. **Do not declare the degradation on a
still-running agent** — the cost of waiting is a few minutes, the cost of a
false call is duplicated work and a wrong entry in this file. And **a duplicate
CLI fallback is cheap insurance but needs cleaning up**: the re-run of the slow
agent was killed once its in-session twin reported, which is the right move,
but only because the duplication was noticed. The fourth agent's CLI fallback
is what actually produced the architectural review, so the fallback strategy
was still correct — it was the diagnosis that was premature, not the response.

## `features/tmp/regression/` harness scripts are superseded, not just stale (`move-tests-out-of-plugin`)

`features/tmp/regression/run.sh`, `runall.sh`, and `rerun.sh` — a leftover,
git-ignored regression harness from `clear-specs-and-designs` (#57) — each
hardcode `devproc/tests/${suite}/${case}.md` in the prompt string passed to
`claude -p --agent`, a path that no longer exists once `move-tests-out-of-plugin`
relocated the fixtures to `tests/devproc/`. That feature's requirement 6
promoted the harness into `tests/devproc/harness/run.sh` — one script, deriving
its case list from the fixtures on disk rather than the three old scripts'
hand-maintained (and already-drifted) lists. The `features/tmp/regression/`
scripts themselves were deliberately left as they are, dead path and all, since
only the harness concept was promoted, not the files; do not update or run
them — use `tests/devproc/harness/run.sh` instead.
