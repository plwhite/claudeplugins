---
name: review-docs
description: Docs review scoped to the whole documentation set, the current change, or a described area — runs architectural, accuracy, style and agent docs agents, auto-applies minor fixes inside a single doc until convergence, and escalates significant findings (always including boundary findings) for user confirmation
argument-hint: [full | change (default) | an area, e.g. "the container docs"] [kinds, e.g. "accuracy only"]
---

Run a documentation review.

The invocation is: $ARGUMENTS

## Step 1 — Determine the scope

Read the scope from $ARGUMENTS:

- `full` — the whole documentation set.
- `change` — the docs touched by, or describing, the current change. This is the default when no scope is given.
- Anything else is an area described in plain language (e.g. "the container docs"). Resolve it to files as `review-component` does: use a path or glob directly with Glob; otherwise search file names and contents with Glob and Grep. If the result is ambiguous or empty, say what you found and ask the user to clarify.

## Step 2 — Determine the kinds

Four kinds of review exist, each with its own agent. The first three review **user docs**; the fourth reviews **agent docs** (Step 3 defines both):

- **architectural** — `docs-review-architectural`: structure of the user docs (entry points, orphans, broken links, hierarchy, one source of truth, docs elsewhere that should have changed) and the boundary check that no user doc relies on an agent doc or feature record
- **accuracy** — `docs-review-accuracy`: user docs still match the code and its behaviour
- **style** — `docs-review-style`: how the user docs read (clarity, procedural form, consistency)
- **agent docs** — `docs-review-agent-docs`: agent docs still match the repository, hold nothing a person needs, and link to the user docs rather than repeat them

Run all four unless $ARGUMENTS names a subset by these kind names (e.g. "accuracy only", "architectural and style", "agent docs only"). The agent docs kind is skipped, and reported as skipped, only when no agent doc exists, or in `change` scope when no agent doc is in the change and nothing the change touches (a file, path, command or component) is described by one. When in doubt, run it.

## Step 3 — Build the file list

**What counts as documentation.** Files fall into three classes, or into none:

- **User docs**: `README.md` and every document reachable from it, for people using what the repository delivers, plus orphans: Markdown or text documents that nothing links to and that belong to no other class.
- **Agent docs**: `CLAUDE.md` at any depth, `NOTES.md` and `.claude/rules/*.md`, for Claude only. Found by name, not by links. Only `docs-review-agent-docs` reviews them.
- **Feature records**: everything under `features/`, including `FEATUREMODEL.md` (plugin content that `/feature-init` overwrites) and `features/tmp/`. Never reviewed and never edited by this skill. Agents may read them only as context.
- **No class**: test fixtures, which may hold `CLAUDE.md`, `NOTES.md` or docs with deliberately planted faults, and non-project trees (`.git/`, `node_modules/`, git-ignored output). A test fixture is a file under a `tests/` or `fixtures/` directory of the repository that is not reachable from `README.md`; a doc reachable from `README.md` is a user doc wherever it lives. Never review or edit files in no class, even when a name matches.

**Prompts are code, not docs.** Skill and agent prompts (`SKILL.md`, `agents/*.md`) belong to no class, are never edited by this skill, and may be read by the accuracy and architectural agents as the thing docs describe.

The boundary runs one way: agent docs may rely on user docs; user docs must never rely on agent docs or feature records. A user doc that *describes* such files as something the project or its tooling creates is not relying on them.

**For `full` scope**, build the list yourself and pass it to every agent: trace links recursively from `README.md` alone (not from `CLAUDE.md`); search for orphaned user docs; and find the agent docs by name with Glob.

**For `change` scope**, build the list from the union of:

- `git diff --name-only <base>`, where `<base>` is `main`; if that does not exist, `master`; if neither, ask the user.
- untracked files from `git status --porcelain --untracked-files=all` (lines starting `??`), so a new directory is listed file by file.

Exclude deleted files. In an untracked workspace (not itself a git repository, with repositories beneath it), do this in each repository beneath it. Also capture the diff (`git diff <base>`) and the content of the untracked files to pass as context.

Classify each listed file as a user doc, an agent doc, a feature record, or not a doc. A new Markdown or text file outside the other classes is a user doc that should be reachable (the architectural agent flags it if it is an orphan). **A change that touches no doc is normal and does not stop the skill**: code changed and its docs did not is exactly what this review exists to catch. The architectural and accuracy agents still run, to find user docs that describe the changed files, and `docs-review-agent-docs` runs when Step 2 requires it. The style agent reviews only changed user docs; with none, skip it and say so in the report. Changed feature records are listed but not passed for review.

Show the user the file list (changed files, with their class) before proceeding. Stop and ask only if the list is clearly wrong or the whole change is empty.

## Step 4 — Run the review agents

Invoke the selected agents via the Agent tool, in parallel, passing each the scope, the file list (with each file's class marked) and, for `change`, the actual diff text from `git diff <base>` and the full text of untracked files — not a paraphrase of them. Collect all findings, noting which agent raised each.

> Steps 5–7 and 9 below derive from the loop shared by the code-review skills (`review-full`, `review-component`, `review-branch`: classify, apply, iterate, escalate). Keep them consistent with those skills — if you change the convergence logic (e.g. the iteration cap), update them together. Step 7's limit on what later passes apply is a deliberate difference from the code-review skills: prose review churns, with each rewrite prompting new wording points, where code review does not.

## Step 5 — Classify findings

For each finding, classify it as one of:

- **Minor**: a tweak inside one existing doc — a wording fix, a wrong command or path corrected, a broken link repointed, a missing link added, a small reorder. Applied without asking, whichever agent raised it.
- **Significant**: creating, deleting, moving or splitting a doc; changing how information is divided between docs; rewriting a section rather than tweaking it; or an accuracy finding saying the *code*, not the doc, may be wrong. These require user confirmation before applying.

Two kinds of finding are always significant, never auto-applied:

- **Boundary findings**, because each changes which class of document holds a piece of information: a user doc relying on an agent doc or feature record, information a person needs held only in an agent doc, and agent doc content repeating the user docs. Report them as boundary findings.
- **Removing content from an agent doc** (for example history an agent does not need), unless it is an exact duplicate of what is kept.

When in doubt, treat a finding as significant. If a finding has a minor part that stands whichever way a linked significant decision goes, split it: apply the minor part and escalate the rest. In particular, **a link broken by a rename or move is always repointed to where the content now lives (a minor fix), even when the new name or location is itself questioned and escalated**; if the user later reverses the rename, repointing the link again is part of that decision. A finding that would require editing a prompt is significant.

## Step 6 — Apply minor findings

Apply all minor findings now, file by file. Do not ask for confirmation.

## Step 7 — Iterate to convergence

The run in Steps 4–6 is pass 1. Each further pass re-runs the selected agents over only the docs that were changed, passing the updated diff, then classifies and applies as in Steps 5–6. Stop when a pass produces nothing to apply, or after 5 passes in all; if findings to apply persist after pass 5, report what remains rather than continuing.

From the second pass on, apply only:

- **regressions from an earlier fix**: a finding that a fix applied in an earlier pass is wrong or broke something (a false statement, a broken link, a contradiction), whatever its severity; and
- **new CRITICAL or MAJOR findings**.

Every other finding first raised after pass 1 (new MINOR and SUGGESTION findings, including further wording preferences about an earlier fix) is not applied: list it in the report as "not applied (raised after pass 1)". Significant findings seen in any pass are collected for the Step 8 report and the Step 9 escalation, not re-raised each pass.

## Step 8 — Report

Write the complete report as a single message **before asking the user anything**. It is the deliverable: in a run that cannot be answered (e.g. `claude -p`) it is all the user gets. It contains:

- The scope, and the files in it (and the class of each)
- The kinds run, and any skipped, with why
- Every finding, applied ones included, as a list or table giving the agent that raised it (by full name: `docs-review-architectural`, `docs-review-accuracy`, `docs-review-style` or `docs-review-agent-docs`), the file, and the outcome: applied, or escalated. Do not group findings by file in a way that loses the agent attribution
- For each escalated (significant) finding, the issue and a recommendation, numbered
- How many passes were needed to converge
- Minor and suggestion findings not applied because they were raised after pass 1
- Anything left after the 5-pass cap

## Step 9 — Escalate significant findings

If there are significant findings and the user can answer, go through them one by one after the report: state the finding again briefly and ask whether to apply it. Apply each only if the user confirms, and say what was applied.

If the run cannot be answered (print mode, or no user to ask), apply none of them and do not ask: the numbered list in the report, marked unapplied, is the escalation.
