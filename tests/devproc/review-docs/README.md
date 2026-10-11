# `/review-docs` test suite

Tests for the `/review-docs` skill and the four agents it runs
(`docs-review-architectural`, `docs-review-accuracy`, `docs-review-style`,
`docs-review-agent-docs`).
Nothing here is real project documentation: the fixture is a tiny made-up CLI
called `greeter`, with faults planted in it.

## What it tests

The default `change` scope over a git repository. `setup.sh` builds a scratch
repository from `fixture/`: a committed baseline (`fixture/baseline/`), then a
working-tree change (`fixture/change/`, overlaid on it) that is never staged
or committed, including one untracked new doc, one renamed doc and a
modified feature record.
The fixture holds all three classes of document (user docs, agent docs,
feature records).

The flaws are recorded **only** here, not in the fixture, so the fixture gives
the reviewing agents no hints.

| Planted fault | Where | Expected handling | Pass rule item |
|---|---|---|---|
| Option renamed `--name` to `--user` in `bin/greet.sh`; `README.md` and `docs/usage.md` (neither changed) still say `--name` | code change, no matching doc change | **accuracy** flags the stale docs (the `skills/greet/SKILL.md` prompt also still says `--name`: reported at most, never edited) | 2 |
| `bin/cleanup.sh` now deletes any path given; `docs/design.md` (unchanged) states a deliberate rule that it never does | code-versus-doc mismatch, code possibly the fault | **accuracy**, **escalated** (significant), not applied; `docs/design.md` and `bin/cleanup.sh` are unchanged after the run | 3 |
| `docs/setup.md` links `troubleshooting.md`, which was renamed to `docs/help.md` | broken in-repo link in a changed doc | **architectural** flags it; **applied** as a minor fix (link repointed to `help.md`) | 4 |
| `docs/caching.md` is new and nothing links to it | orphan, untracked | **architectural** flags it; adding a link from a doc is a minor fix and is **applied** | 5 |
| `docs/setup.md` gives the prerequisites (bash 4, make) in step 3, after the commands that need them | procedure in a changed doc | **style** flags it | 6 |
| `docs/setup.md` and `docs/config.md` both document the installation prefix, each pointing at the other | same information split inconsistently between two changed docs | **architectural**, **escalated** (significant), not applied; the duplication is still present after the run | 7 |
| `skills/greet/SKILL.md` is modified in the change | prompt file | unchanged by the run | 8 |
| `features/CURRENT.md` and `CLAUDE.md` list `colour-output` as in progress | tracking state | no agent reports it | 9 |
| `docs/caching.md` (a user doc) tells the reader to see `CLAUDE.md` for when cached greetings expire; that information is in `CLAUDE.md` only | user doc relying on an agent doc | **architectural** flags it as a boundary finding; **escalated** (significant), not applied; the sentence is still present after the run | 10 |
| `CLAUDE.md` holds a procedure for building a release tarball (`make dist VERSION=...`) that no user doc mentions | information a person needs held only in an agent doc | **agent docs** flags it as a boundary finding; **escalated**, not applied; the section is still in `CLAUDE.md` after the run | 11 |
| `CLAUDE.md`'s layout lists `docs/troubleshooting.md`, which the change renamed to `docs/help.md` | stale path in an agent doc | **agent docs** flags it; correcting the path is a minor fix and may be **applied** | 12 |
| `features/CURRENT.md` (modified in the change) links `plans/colour-output.md`, which does not exist | fault in a feature record | no agent reports it; the file is not edited | 9 |

The stale-path row (item 12) is also why the agent docs kind runs at all: the change does not
touch `CLAUDE.md`, but `CLAUDE.md` describes the doc that the change renamed
(`docs/troubleshooting.md`), so the skill must run the agent docs kind. Pass
rule item 1 checks that it was invoked.

## Prerequisites

- `claude` on `PATH` and authenticated; `git`, `rsync`.
- `REPO` set to the root of this repository, e.g. `REPO=/workspace`. The
  commands below use it.
- The plugin loads from the **installed copy**, not this repository: Claude
  Code reads skills and agents from where the plugin is installed, so edits
  here have no effect until that copy is refreshed. Refresh it first. The installed path below,
  `/home/claude/claudeplugins/devproc/`, is the container's; elsewhere use
  wherever the plugin is installed from. These are the **Refresh steps**:
  1. `rsync -a --delete "$REPO"/devproc/ /home/claude/claudeplugins/devproc/`
  2. `diff -r "$REPO"/devproc /home/claude/claudeplugins/devproc` prints nothing.
- The run must be a **fresh session** after the refresh: agent types are
  resolved when a session starts, so neither the skill nor the agents can be
  run in the session that wrote or refreshed them. A `general-purpose`
  stand-in is not acceptable, since it skips the agents' frontmatter (tools,
  `model:`) and the skill's dispatch.

## Running

Build a fresh scratch copy for every run, in a directory outside the
repository so the auto-apply step never touches the fixture. Record the
hashes that items 3, 8 and 9 compare against, then run the skill.
`--permission-mode bypassPermissions` lets the skill apply its minor fixes
without prompting, which print mode cannot answer.

```
SCRATCH=$(mktemp -d)/greeter
"$REPO"/tests/devproc/review-docs/setup.sh "$SCRATCH"
cd "$SCRATCH"
hashes() {
  git diff -- skills/greet/SKILL.md | sha256sum                  # item 8
  git diff -- features | sha256sum                               # item 9
  sha256sum bin/cleanup.sh docs/design.md                        # item 3
  sed -n '/^## Current status/,/^## /p' CLAUDE.md | sha256sum    # item 9
}
hashes > "$SCRATCH/../before.txt"
claude -p --permission-mode bypassPermissions --verbose --output-format stream-json \
  "/review-docs" > "$SCRATCH/../review-docs.jsonl"
```

After the run, recompute the hashes and compare, in the same shell (the
`hashes` function and `$SCRATCH` exist only there); no output means items 3,
8 and 9's hash checks hold:

```
hashes | diff "$SCRATCH/../before.txt" -
```

The command saves the full stream-json transcript in
`review-docs.jsonl`. The final report alone (print mode returns only the last
assistant message) does not show which agents were actually invoked (the
`Agent` tool calls and their `subagent_type`) or what each returned.

In a non-interactive run, escalation shows as a question or list in the final
report, with the escalated fault left unapplied in the scratch copy.

## Reading the transcript

In print mode the review agents run in the background, so their reports reach
the transcript as `assistant` messages carrying a `parent_tool_use_id` (and a
`subagent_type`), not as `tool_result` blocks of the `Agent` call. Filter on
those to read each agent's raw findings.

## Pass rule

The run passes when all of these hold, checked against the final report (agent
attribution comes from the report, confirmed in the transcript) and the
scratch copy. Extra findings beyond the table are not a failure unless they
breach item 8 or 9.

1. The transcript shows `docs-review-architectural`, `docs-review-accuracy`,
   `docs-review-style` and `docs-review-agent-docs` all invoked as agent types.
2. **accuracy** flags `README.md` and `docs/usage.md` as describing the old
   `--name` option. They may be applied as well as flagged (a wording or
   option fix inside one doc, so minor); whether they are applied or only
   flagged does not fail the run.
3. **accuracy** flags the `cleanup.sh` / `docs/design.md` mismatch as the
   code possibly being wrong. It is **escalated, not applied**:
   the `bin/cleanup.sh` and `docs/design.md` hashes match those recorded
   before the run.
4. **architectural** flags the broken `troubleshooting.md` link, and
   `docs/setup.md` now links `help.md` (applied).
5. **architectural** flags `docs/caching.md` as an orphan, and a link to it
   now exists in a reachable doc (applied).
6. **style** flags the prerequisites in `docs/setup.md` coming after the
   commands that need them.
7. **architectural** flags the duplicated installation-prefix information
   between `docs/setup.md` and `docs/config.md`, and it is **escalated, not
   applied** (the report lists it as significant/unapplied; the duplication is
   still present).
8. `skills/greet/SKILL.md` is unchanged:
   its hash matches the one recorded before the run.
9. Feature records and the status are left alone. All of these hold:
   - no agent reports the in-progress `colour-output` feature as a finding (in
     the report or the agents' raw findings in the transcript; an agent noting
     that it is expected is fine);
   - nothing under `features/` is reported as a finding (in the report or the
     raw findings), including the broken `plans/colour-output.md` link;
   - no file under `features/` is changed: the `features` hash matches the
     one recorded before the run; and
   - `CLAUDE.md`'s `## Current status` section is untouched: its hash matches
     the one recorded before the run.
10. **architectural** flags `docs/caching.md` as relying on `CLAUDE.md` for
    information (a boundary finding). It is **escalated, not applied**: the
    reference to `CLAUDE.md` is still in `docs/caching.md`.
11. **agent docs** flags the release-tarball procedure as held only in
    `CLAUDE.md` (a boundary finding). It is **escalated, not applied**: the
    section is still in `CLAUDE.md`, and no user doc gained it.
12. **agent docs** flags the stale `docs/troubleshooting.md` path in
    `CLAUDE.md`'s layout. It may be applied as well as flagged.

## When the skill or an agent changes

Re-run the suite after the Refresh steps. If a change makes an item fail,
either the change is wrong or the expectation needs deliberately revising;
record which, rather than adjusting quietly.
