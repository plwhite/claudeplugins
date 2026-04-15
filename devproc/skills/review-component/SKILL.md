---
name: review-component
description: Code review scoped to a described component or area — resolves the description to files, then runs simplicity, general, and nitty agents; auto-applies code-level findings until convergence; escalates architectural findings for user confirmation
argument-hint: [component or area description, e.g. "the auth module" or "src/payments/"]
---

Run a code review over a specific component or area of the codebase.

The invocation is: $ARGUMENTS

## Step 1 — Resolve the component to a file set

Use the component description in $ARGUMENTS to identify which files to review. Try these strategies in order until you have a confident file set:

1. If $ARGUMENTS looks like a path or glob (e.g. `src/auth/`, `*.test.ts`), use it directly with Glob.
2. Otherwise, search for files whose path or content matches the description — use Glob for directory/naming patterns and Grep for keyword matches in file contents.
3. If the result is ambiguous or empty, tell the user what you found and ask them to clarify before proceeding.

Show the user the resolved file list and confirm it looks right before running any agents. If the list is clearly wrong, stop and ask.

## Step 2 — Determine whether to include architectural review

Check $ARGUMENTS for any indication that the user wants an architectural review (e.g. "including architectural review", "with architecture", "arch review", or similar).

If it is not clear from the invocation, ask the user: "Should I include an architectural review of this component? (This uses a more capable model and takes longer.)" Wait for their answer before proceeding.

## Step 3 — Run the review agents

Invoke the following agents via the Agent tool, passing the resolved file list in each prompt. Run them in parallel where possible.

Always run:
- `code-review-simplicity` — finds unnecessary complexity and dead code
- `code-review-general` — checks correctness, error handling, and robustness
- `code-review-nitty` — checks naming, comments, and fine-grained clarity

If architectural review was confirmed in Step 2, also run:
- `code-review-architectural` — checks module boundaries, coupling, and design fit; pass the file list and any relevant design/architecture documents found nearby (README.md, CLAUDE.md, plans/)

Collect all findings from all agents.

> Steps 4–7 below are identical across all review skills (`review-full`, `review-component`, `review-branch`). If you change the convergence logic (e.g. the iteration cap), update all three.

## Step 4 — Classify findings

For each finding, classify it as one of:

- **Code-level**: contained within a single function or file; does not change a public API, module boundary, or data contract. These are auto-applied without asking.
- **Architectural**: changes a module boundary, public interface, exported type, or structural design. These require user confirmation before applying.

When in doubt, treat a finding as architectural.

## Step 5 — Apply code-level findings

Apply all code-level findings now, file by file. Do not ask for confirmation — just make the changes.

## Step 6 — Iterate to convergence

After applying code-level changes, re-run the three standard agents (simplicity, general, nitty) over only the files that were changed. Repeat Steps 4–5 until no new code-level findings are produced. Limit to 5 iterations; if findings persist after 5 passes, report what remains rather than continuing.

## Step 7 — Present architectural findings

If there are any architectural findings, present them to the user now.

For each:
- State the finding clearly (file, issue, recommendation)
- Ask whether to apply it

Apply each one only if the user confirms.

## Step 8 — Summary

Report:
- The component reviewed and the files included
- How many code-level findings were applied and across how many files
- How many iterations were needed to converge
- Which architectural findings (if any) were applied or deferred
- Any findings that persisted after the iteration limit
