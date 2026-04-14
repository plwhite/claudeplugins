---
name: review-branch
description: Code review scoped to files changed in the current feature branch — runs simplicity, general, and nitty agents over the diff, auto-applies code-level findings until convergence, and escalates architectural findings for user confirmation
argument-hint: ["including architectural review" to also run the architectural agent]
---

Run a code review over files changed in the current feature branch.

The invocation is: $ARGUMENTS

## Step 1 — Identify changed files

Run `git diff --name-only main` (or the appropriate base branch) to get the list of files changed on this branch. If the base branch is not `main`, try `master`, then ask the user if still unclear.

Exclude deleted files (they cannot be reviewed). Show the user the file list before proceeding — if it looks wrong or empty, stop and ask.

Also capture the full diff (`git diff main`) to pass as context to the agents so they understand what changed and why, not just the current file state.

## Step 2 — Determine whether to include architectural review

Check $ARGUMENTS for any indication that the user wants an architectural review (e.g. "including architectural review", "with architecture", "arch review", or similar).

If it is not clear from the invocation, ask the user: "Should I include an architectural review? (This uses a more capable model and takes longer.)" Wait for their answer before proceeding.

## Step 3 — Run the review agents

Invoke the following agents via the Agent tool. Pass each agent both the file list and the git diff as context. Run them in parallel where possible.

Always run:
- `code-review-simplicity` — finds unnecessary complexity and dead code
- `code-review-general` — checks correctness, error handling, and robustness
- `code-review-nitty` — checks naming, comments, and fine-grained clarity

If architectural review was confirmed in Step 2, also run:
- `code-review-architectural` — checks module boundaries, coupling, and design fit; also pass any relevant design/architecture documents (README.md, CLAUDE.md, plans/)

Collect all findings from all agents.

## Step 4 — Classify findings

For each finding, classify it as one of:

- **Code-level**: contained within a single function or file; does not change a public API, module boundary, or data contract. These are auto-applied without asking.
- **Architectural**: changes a module boundary, public interface, exported type, or structural design. These require user confirmation before applying.

When in doubt, treat a finding as architectural.

## Step 5 — Apply code-level findings

Apply all code-level findings now, file by file. Do not ask for confirmation — just make the changes.

## Step 6 — Iterate to convergence

After applying code-level changes, re-run the three standard agents (simplicity, general, nitty) over only the files that were changed, passing the updated diff as context. Repeat Steps 4–5 until no new code-level findings are produced. Limit to 5 iterations; if findings persist after 5 passes, report what remains rather than continuing.

## Step 7 — Present architectural findings

If there are any architectural findings, present them to the user now.

For each:
- State the finding clearly (file, issue, recommendation)
- Ask whether to apply it

Apply each one only if the user confirms.

## Step 8 — Summary

Report:
- The branch and base branch used, and how many files were in scope
- How many code-level findings were applied and across how many files
- How many iterations were needed to converge
- Which architectural findings (if any) were applied or deferred
- Any findings that persisted after the iteration limit
