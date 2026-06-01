---
name: Recurring issues
description: Structural and style problems observed across reviews of this repo
type: project
---

(Prior history retained — see git log for older entries.)

## Ninth review (2026-05-04) — security-permissions-docs feature close-out

Scope: new "Block reads of sensitive files" section in `docs/setup.md`, README docs-table row update.

Findings:
- MAJOR: CLAUDE.md "Current status" still reads `**In progress: security-permissions-docs**` while the task is described as a close-out for `/feature-end`. Either /feature-end has not yet been run (process gap) or CLAUDE.md was not refreshed during checkpoint. The completed-feature framing in the task brief contradicts the live status block.
- MINOR: docs/setup.md "Detailed steps" list shows 6 steps but the intro bullets above it list only 4 of those goals (sandbox, git lockdown, secret-file blocking, plugin install) — the GitHub CLI install (step 4) and the per-repo plugin init (step 6) are absent from the intro framing. Mildly inconsistent but not blocking.
- MINOR: docs/setup.md "Block reads of sensitive files" section: the "Edit ~/.claude/settings.json …" bullet contains a complete, copy-pasteable JSON snippet that is *only* the `permissions` key. A reader following along literally and pasting this would overwrite the file. The instruction says "add or merge … do not replace them", but the snippet itself does not include the surrounding sandbox/hooks keys to make the merge target obvious. Sandbox section has the same shape, so this is consistent — flag as a class-wide minor.
- NIT: docs/setup.md line 13 — "this is 'how to configure your system in the right way for me'" is informal and slightly opaque; consider "this reflects one working configuration; tweak to taste".
- NIT: README.md docs-table row for setup.md says "secret-file deny-list" — accurate but mildly jargon. "blocked sensitive-file reads" or similar would parallel the in-doc heading "Block reads of sensitive files" more closely.

No CRITICAL findings. No new orphaned documents. CONTRIBUTING.md remains linked from README.md (verified). All cross-references between docs/setup.md, docs/workflow.md, docs/capabilities.md, devproc/README.md, FEATURES.md, plans/security-permissions-docs.md confirmed live.

Recurring patterns to watch:
- CLAUDE.md status drift at feature close-out (third occurrence of "in-progress label not flipped before docs review runs").
- `permissions`/`sandbox`/`hooks` JSON snippets in setup.md show a single top-level key in isolation, relying on prose to convey "merge with existing keys". A reader who skims may overwrite. Could warrant a single combined example block.

## Tenth review (2026-05-04) — claudeignore-docs feature close-out (issue #9)

Scope: new `setup-files/` directory (`.claudeignore`, `block-git-writes.sh`, `README.md`); restructured `docs/setup.md` (8-step ordered list, new Clone/Configure-claudeignore sub-sections, hook moved out of heredoc); root README docs-table updated.

Findings:
- SHOULD-FIX: CLAUDE.md "Current status" still reads `In progress: claudeignore-docs` at close-out review time. FOURTH occurrence of this drift.
- SHOULD-FIX: docs/setup.md intro bullets list 5 goals; Detailed steps lists 8. Clone/gh/init missing from intro framing. SECOND consecutive review flagging an intro vs detailed-steps mismatch in this file.
- NIT: setup.md line 87 — "copy verbatim" is residual heredoc-era wording.
- NIT: setup.md Clone section lacks forward-reference to sections that reuse the path.
- NIT: `.claudeignore` category list is duplicated three places (setup.md prose, file comments, setup-files/README.md Purpose column).
- NIT: setup-files/README.md table row order (`.claudeignore` first) does not match setup.md step order (hook first).
- NIT: root README docs-table coverage cell mixes verb-noun and bare-noun phrasing.

All 8 anchor links in setup.md "Detailed steps" verified to resolve. Both anchors in setup-files/README.md (`#configure-claudeignore`, `#sandbox-configuration`) verified. No orphaned documents introduced.

Recurring patterns now strongly established:
- CLAUDE.md status block flip at /feature-end is unreliable. Worth treating as a process bug rather than a per-feature reminder.
- docs/setup.md intro bullets vs Detailed steps drift each time a step is added (twice in a row now).

## Eleventh review (2026-05-04) — claudeignore-docs final close-out pass

Scope: cross-doc consistency check after sub-task 6 + status-block flip.

Verified clean:
- CLAUDE.md "Current status" now reads "No feature currently in progress" with claudeignore-docs as recently completed. Drift recurrence finally resolved.
- New "## setup-files directory" section sits between "## devproc plugin" and "## Feature model" in CLAUDE.md, mirrors demo/devproc section style (Location / one-line purpose / Contents bullets), and adds the rule for new files.
- FEATURES.md entry moved to Completed, dated 2026-05-04, single multi-sentence paragraph, no tables/sub-task lists. Matches Feature-model schema.
- Full hierarchy (root README → docs/{setup,workflow,capabilities}.md → devproc/README.md → demo/README.md → setup-files/README.md → plans) cross-resolves with no broken links or orphans. README docs-table row for setup-files/README.md is live; setup-files/README.md back-links to docs/setup.md sections; setup.md forward-references to setup-files paths all match.

No findings.

## Twelfth review (2026-05-28) — claude-container feature close-out

Scope: new `docs/container.md`, new `bin/` scripts, `docker/` directory, README updated with container entry.

Findings:
- MAJOR: CLAUDE.md "Current status" still reads `**Feature in progress: claude-container**` — feature complete per plan but /feature-end not yet run. FIFTH occurrence of CLAUDE.md status drift at close-out review time.
- MAJOR: docs/container.md "Convenience: symlink the scripts" — all four `ln -s` commands prefixed with `sudo`, but the target is `~/.local/bin` (user-owned). `sudo` is wrong and would create symlinks owned by root in the user's home directory, which is unexpected behaviour.
- MINOR: CLAUDE.md has no mention of `bin/` or `docker/` directories, both of which are significant new artefacts (four wrapper scripts, Dockerfile, baked config). The `setup-files/` directory has its own ## section; these new directories have nothing. A reader using CLAUDE.md as a workspace map would not know bin/ or docker/ exist.
- MINOR: docs/container.md Prerequisites section cross-references `setup.md` for the clone step — correct — but the clone forward-reference says only "see [setup.md](setup.md)" with no section anchor. Prefer `[Clone this repository in setup.md](setup.md#clone-this-repository)` for directness.
- MINOR: docs/container.md intro bullet "Passes your Anthropic credentials and git name and email through automatically (though it does not pass git credentials - only local git operations can be done)" uses passive voice and is parenthetically structured in a way that is easy to misread. The distinction between "Anthropic credentials" and "git credentials" is not obvious to a new reader; a brief parenthetical explanation of what each means would help.
- MINOR: docs/container.md "Convenience: symlink the scripts" recommends `~/.local/bin` without noting it must be on `$PATH` (it is not by default on all distros). A reader whose `~/.local/bin` is not on PATH will silently get no benefit.
- NIT: docs/container.md uses an em dash inconsistently with the rest of the docs suite — "only local git operations can be done" is the only place hyphens are used mid-sentence in a way that would be dashes in the other documents.

CLAUDE.md status drift now documented five times across twelve reviews. Strongly established as a process gap.
No new orphaned documents. docs/container.md is correctly wired into README.md (intro bullet + docs table). docs/setup.md and devproc/README.md do not reference container.md, which is correct — container mode is an independent capability, not a setup prerequisite or plugin feature.

## Thirteenth review (2026-05-28) — claude-container five-fix verification pass

Scope: verification of five targeted fixes from twelfth review, plus carryover check.

All five claimed fixes verified correct:
1. sudo removed from all four ln -s commands in docs/container.md symlink block. MAJOR RESOLVED.
2. CLAUDE.md ## Container mode section added (lines 73–88), covering bin/ and docker/ with full file inventory. MINOR RESOLVED.
3. docs/container.md Prerequisites anchor link updated to setup.md#clone-this-repository. MINOR RESOLVED.
4. PATH note added after symlink block in docs/container.md (line 88). MINOR RESOLVED.
5. Intro bullets for Anthropic vs git credentials split into two separate bullet points; distinction now explicit. MINOR RESOLVED.

Carryover findings:
- MINOR (carryover from ninth/tenth review, still present): docs/setup.md intro bullets (5 items) vs Detailed steps (8 items) mismatch. Steps 1 (prerequisites), 2 (clone), 5 (GitHub CLI), and 8 (init devproc) are absent from the intro framing. Second consecutive re-audit without this being fixed.
- NIT (eighth review): docs/workflow.md line 17 unclosed parenthesis — RESOLVED (parenthesis is now closed).
- NIT (tenth review): "copy verbatim" in setup.md — RESOLVED (text no longer present).
- NIT (twelfth review): docs/container.md em dash inconsistency — not re-checked in this pass; low priority.

CLAUDE.md status drift: still In Progress for claude-container, but /feature-end is explicitly imminent per user brief — not flagged.
No new findings identified. FEATURES.md and CLAUDE.md status consistent with pre-/feature-end state per user's instruction.

## Fourteenth review (2026-06-01) — container-bugs feature close-out

Scope: updates to docs/container.md (keep-alive auto-resume + Shift copy/paste), docker/files/home/run-claude.sh (new), entrypoint.sh, bin/claude-run credentials mount fix. Discoverability of container.md from README/CLAUDE re-verified.

Findings:
- MAJOR: CLAUDE.md "Current status" is internally contradictory — opens "Sub-tasks 1–2 done:" then mid-sentence says "All three sub-tasks done; ready for /feature-end." A reader cannot tell whether 2 or 3 sub-tasks are complete. The "1–2 done" framing is stale; plan + FEATURES describe all 3 done.
- MINOR: FEATURES.md still lists container-bugs under "## In progress" although plan Handoff + CLAUDE.md both say all sub-tasks complete and ready for /feature-end. SIXTH occurrence of close-out status drift (this time in FEATURES.md, not the CLAUDE.md status line). Per established pattern, /feature-end is imminent — flagged MINOR not MAJOR since brief states feature "just completed".
- MINOR: bin/claude-run final echo prints `Attach with: bash bin/claude-attach $CONTAINER` (a container NAME, e.g. claude-myproj), but claude-attach takes a PROJECT PATH (`${1:-$(pwd)}`) per the script and per docs/container.md. The echoed hint contradicts documented usage; following it from another dir would build the wrong container name. Code-adjacent but it is user-facing guidance text.
- NIT (carryover, twelfth review): docs/container.md em dash usage — now consistent with suite (heavy em-dash use throughout); no longer an outlier. RESOLVED.

Verified clean:
- docs/container.md keep-alive description (intro bullet line 7 + Attach section line 61) accurately matches run-claude.sh behaviour (auto-relaunch, --continue resume, exit/Ctrl-D/Ctrl-C cannot destroy session). Imperative style throughout. Prerequisites precede commands. "Copying and pasting" subsection correctly placed under Attach, explains WHY (tmux captures selection).
- container.md discoverable from README (intro bullet + docs table) and CLAUDE.md (## Container mode section + Feature model). No orphans introduced. run-claude.sh is a new docker/ artifact — CLAUDE.md ## Container mode Contents list does NOT inventory it (lists Dockerfile, CLAUDE.md, settings.json, 4 bin scripts; entrypoint.sh and run-claude.sh both absent). MINOR completeness gap below.
- MINOR: CLAUDE.md ## Container mode "Contents" omits docker/files/home/entrypoint.sh and docker/files/home/run-claude.sh — both are significant baked-in scripts (run-claude.sh is the keep-alive loop central to this feature). A reader using CLAUDE.md as a workspace map would not know they exist.
- NOTES.md: two new well-formed sections (credentials mount path #17, session keep-alive #17), non-obvious-only, correct per schema.

## Fifteenth review (2026-06-01) — container-bugs five-fix verification pass

All five fixes verified correct; feature converged:
1. CLAUDE.md status block rewritten to "No feature currently in progress. container-bugs completed 2026-06-01 — …", contradiction gone, claude-container entry retained below. MAJOR RESOLVED.
2. CLAUDE.md ## Container mode Contents now lists entrypoint.sh and run-claude.sh. MINOR RESOLVED.
3. /feature-end ran: FEATURES.md ## In progress shows "No features currently in progress", container-bugs under ## Completed dated 2026-06-01 with single multi-sentence paragraph (matches feature-model schema). Close-out drift NOT recurrent this cycle.
4. bin/claude-run line 22 echoes `$PROJECT` not `$CONTAINER` — matches documented claude-attach <project-path> contract. MINOR RESOLVED.
5. docs/container.md detach paragraph split: bolded "detach with Ctrl-b d" stands alone (line 61); auto-relaunch/claude-stop moved to following paragraph (line 63). SUGGESTION RESOLVED.

No new findings. No orphans. Full hierarchy cross-resolves. First cycle in several where the status flip was already correct at re-audit time — possible the close-out drift pattern is being addressed.
