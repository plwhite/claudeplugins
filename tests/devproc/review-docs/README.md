# `/review-docs` test suite

Tests for the `/review-docs` skill and the four agents it runs
(`docs-review-architectural`, `docs-review-accuracy`, `docs-review-style`,
`docs-review-agent-docs`).
Nothing here is real project documentation: the fixture is a tiny made-up CLI
called `greeter`, with faults planted in it.

## What it tests

The default `change` scope over a git repository. `setup.sh` builds a scratch
repository from `fixture/`. It commits a baseline (`fixture/baseline/` plus
`features/FEATUREMODEL.md`, copied from the canonical file in `devproc/`), then
overlays `fixture/change/` as a working-tree change that is never staged or
committed: two untracked new docs, one renamed doc and a modified feature
record.
The fixture holds all three classes of document (user docs, agent docs,
feature records).

The flaws are recorded **only** here, not in the fixture, so the fixture gives
the reviewing agents no hints.

| Pass rule item | Planted fault | Where | Expected handling |
|---|---|---|---|
| 2 | Option renamed `--name` to `--user` in `bin/greet.sh`; `README.md` and `docs/usage.md` (neither changed) still say `--name` | code change, no matching doc change | **accuracy** flags the stale docs (the `skills/greet/SKILL.md` prompt also still says `--name`: reported at most, never edited) |
| 3 | `bin/cleanup.sh` now deletes any path given; `docs/design.md` (unchanged) states a deliberate rule that it never does | code-versus-doc mismatch, code possibly the fault | **accuracy**, **escalated** (significant), not applied; `docs/design.md` and `bin/cleanup.sh` are unchanged after the run |
| 4 | `docs/setup.md` links `troubleshooting.md`, which was renamed to `docs/help.md` | broken in-repo link in a changed doc | **architectural** flags it; **applied** as a minor fix (link repointed to `help.md`) |
| 5 | `docs/caching.md` is new and nothing links to it | orphan, untracked | **architectural** flags it; adding a link from a doc is a minor fix and is **applied** |
| 6 | `docs/setup.md` gives the prerequisites (bash 4, make) in step 3, after the commands that need them | procedure in a changed doc | **style** flags it |
| 7 | `docs/setup.md` and `docs/config.md` both document the installation prefix, each with a different, overlapping slice (see the note after the table) | duplicate whose owner is unclear: neither doc holds all the prefix detail, and each is a plausible home (a how-to and a reference) | **architectural** flags it as a duplicate with no clear owner; **escalated** (significant), not applied; both slices are still present after the run |
| 8 | `skills/greet/SKILL.md` is modified in the change | prompt file | unchanged by the run |
| 9 | `features/CURRENT.md` and `CLAUDE.md` list `colour-output` as in progress | tracking state | no agent reports it |
| 9 | `features/CURRENT.md` (modified in the change) links `plans/colour-output.md`, which does not exist | fault in a feature record | no agent reports it; the file is not edited |
| 10 | `docs/caching.md` (a user doc) tells the reader to see `CLAUDE.md` for when cached greetings expire; that information is in `CLAUDE.md` only | user doc relying on an agent doc | **architectural** flags it as a boundary finding; **escalated** (significant), not applied; the sentence is still present after the run |
| 11 | `CLAUDE.md` holds a procedure for building a release tarball (`make dist VERSION=...`) that no user doc mentions | information a person needs held only in an agent doc | **agent docs** flags it as a boundary finding; **escalated**, not applied; the section is still in `CLAUDE.md` after the run |
| 12 | `CLAUDE.md`'s layout lists `docs/troubleshooting.md`, which the change renamed to `docs/help.md` | stale path in an agent doc | **agent docs** flags it; correcting the path is a minor fix and may be **applied** |
| 13 | `docs/architecture.md` (new, linked from `docs/config.md`) gives numbered steps for switching to French greetings (not held in any other doc) | procedure in an architecture guide; no other doc owns the steps, so only the **Only what the purpose needs** rule of the `### User docs` standard applies | **architectural** flags it; removal or move is **escalated**, not applied |
| 14 | `docs/architecture.md` repeats, word for word, the `bin/cleanup.sh` paragraph of `docs/usage.md` (unchanged) | duplicate with a clear owner, `docs/usage.md` | **architectural** flags it; the finding reads `Owner: clear — docs/usage.md; holds all of it: yes`, and replacing the copy with a link is **applied** |
| 15 | `docs/architecture.md` lists every variable, flag and builtin the scripts and `Makefile` use | exhaustive code-derivable list | **architectural** flags it, saying why the reader does not need it; removal is **escalated**, not applied |
| 16 | `docs/help.md` pads the wrong-language item to several lines | wordiness | **style** flags it; tightening that keeps the information may be **applied** |
| 17 | `docs/help.md` explains the history of the cache location in a how-to item | history in a how-to guide | **architectural** flags it; removal is **escalated**, not applied |
| 18 | **Controls:** `docs/config.md` has one precedence sentence that is needed (`PREFIX` comes from the command line, else the environment, else the default); `docs/setup.md` step 1 gives a short reason for a non-obvious step; `docs/help.md` ends with a four-item checklist the reader runs through; `docs/architecture.md`'s Configuration section is a one-sentence summary linking `config.md` | exceptions to the concision rules | no agent reports any of them as a finding |
| 19 | `docs/setup.md` restates, in full, the behaviour and four rules held in `skills/greet/SKILL.md` | a user doc copying content held in a code file (a shipped prompt) that the reader does not need verbatim | **architectural** flags it, with `Owner: clear — skills/greet/SKILL.md; holds all of it: yes`; replacing the copy with a brief summary or link is **applied**; `SKILL.md` is unchanged |

Item 7: both docs state the default, `$PREFIX/bin` and the `PATH`
requirement. Only `docs/setup.md` adds that root is needed for the default and that
`make install` creates the directory. Only `docs/config.md` adds that `PREFIX` is a `make`
variable and the environment-versus-command-line rule.

Item 12 is also why the agent docs kind must run: the change does not touch
`CLAUDE.md`, but `CLAUDE.md` describes the renamed `docs/troubleshooting.md`.
Pass rule item 1 checks that the kind was invoked.

## Prerequisites

- `claude` on `PATH` and authenticated; `git`, `rsync`.
- `REPO` set to the root of this repository, e.g. `REPO=/workspace`. The
  commands below use it.
- The installed plugin copy refreshed from this repository (see
  [Refresh the installed plugin in place](../../../CONTRIBUTING.md#refresh-the-installed-plugin-in-place)).
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
`hashes` function and `$SCRATCH` exist only there). If the diff prints
nothing, the hash checks for items 3, 8 and 9 hold:

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
   now exists in a reachable doc (applied). `docs/architecture.md` is not
   reported as an orphan, since `docs/config.md` links it.
6. **style** flags the prerequisites in `docs/setup.md` coming after the
   commands that need them.
7. **architectural** flags the overlapping installation-prefix information
   between `docs/setup.md` and `docs/config.md` as a duplicate. It is
   **escalated, not applied**: its `Owner:` line is `Owner: unclear`,
   `Owner: clear — ...; holds all of it: no`, or absent, never
   `holds all of it: yes`, and both slices are still present.
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
13. **architectural** flags the French-greeting steps in `docs/architecture.md`.
    Removing them is **escalated, not applied**: they are still present after
    the run.
14. **architectural** flags the `cleanup.sh` paragraph duplicated from
    `docs/usage.md`, with
    `Owner: clear — docs/usage.md; holds all of it: yes`. The copy in
    `docs/architecture.md` is replaced by a link (applied), and the paragraph
    is still in `docs/usage.md`.
15. **architectural** flags the exhaustive list in `docs/architecture.md`,
    giving the reason. Removing it is **escalated, not applied**.
16. **style** flags the padded wrong-language item in `docs/help.md`.
    Tightening it, keeping the information, may be applied.
17. **architectural** flags the cache-history text in `docs/help.md`. Removing
    it is **escalated, not applied**.
18. No agent flags a control on the ground its exception covers, in the report
    or the raw findings:
    - the precedence sentence in `config.md`: not as wordiness;
    - the short reason in `setup.md` step 1: not as off-purpose (history or why);
    - the checklist in `help.md`: not as code-derivable detail or enumeration;
    - the linked summary in `architecture.md`: not as duplication or off-purpose.

    An unrelated defect found in a control's text is a fixture bug to
    fix, not a failure.
19. **architectural** flags the `skills/greet/SKILL.md` content copied into
    `docs/setup.md`, with
    `Owner: clear — skills/greet/SKILL.md; holds all of it: yes`
    (required; any other `Owner:` line fails). The copied section is gone or
    is at most two lines including a link to `skills/greet/SKILL.md`, and
    `SKILL.md` is unchanged (item 8's hash).

## Not covered

The skill's two stop conditions, a missing `features/FEATUREMODEL.md` and a
`CLAUDE.md` without the import, are not exercised: the fixture always has both.

## When the skill, an agent or the standard changes

Re-run the suite after [refreshing the installed plugin](../../../CONTRIBUTING.md#refresh-the-installed-plugin-in-place), including after a change to the
`### User docs` section of `devproc/skills/feature-init/FEATUREMODEL.md`, which
items 13–19 depend on. If a change makes an item fail,
either the change is wrong or the expectation needs deliberately revising;
record which, rather than adjusting quietly.
