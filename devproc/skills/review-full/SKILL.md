---
name: review-full
description: Full-codebase code review — runs simplicity, general, and nitty agents over all files, auto-applies code-level findings until convergence, and escalates architectural findings for user confirmation
argument-hint: ["including architectural review" to also run the architectural agent]
---

Run a full code review over the entire codebase.

The invocation is: $ARGUMENTS

## Step 1 — Determine scope of review

The scope is the full codebase. Use Glob to identify all source files to review, excluding build artefacts, dependency directories (node_modules, vendor, .venv, dist, etc.), and generated files.

## Step 2 — Determine whether to include architectural review

Check $ARGUMENTS for any indication that the user wants an architectural review (e.g. "including architectural review", "with architecture", "arch review", or similar). 

If it is not clear from the invocation, ask the user: "Should I include an architectural review? (This uses a more capable model and takes longer.)" Wait for their answer before proceeding.

## Step 3 — Run the review agents

Invoke the following agents via the Agent tool, passing the list of files to review in each prompt. Run them in parallel where possible.

Always run:
- `code-review-simplicity` — finds unnecessary complexity and dead code
- `code-review-general` — checks correctness, error handling, and robustness
- `code-review-nitty` — checks naming, comments, and fine-grained clarity

If architectural review was confirmed in Step 2, also run:
- `code-review-architectural` — checks module boundaries, coupling, and design fit

Collect all findings from all agents.

## Step 4 — Classify findings

For each finding, classify it as one of:

- **Code-level**: contained within a single function or file; does not change a public API, module boundary, or data contract. These are auto-applied without asking.
- **Architectural**: changes a module boundary, public interface, exported type, or structural design. These require user confirmation before applying.

When in doubt, treat a finding as architectural.

## Step 5 — Apply code-level findings

Apply all code-level findings now. Group related changes and apply them file by file. Do not ask for confirmation — just make the changes.

## Step 6 — Iterate to convergence

After applying code-level changes, re-run the three standard agents (simplicity, general, nitty) over the files that were changed. Repeat Steps 4–5 until no new code-level findings are produced. Limit to 5 iterations; if findings persist after 5 passes, report what remains rather than continuing.

## Step 7 — Present architectural findings

If there are any architectural findings (from the architectural agent, or from other agents whose findings were classified as architectural), present them to the user now.

For each:
- State the finding clearly (file, issue, recommendation)
- Ask whether to apply it

Apply each one only if the user confirms.

## Step 8 — Summary

Report:
- How many code-level findings were applied and across how many files
- How many iterations were needed to converge
- Which architectural findings (if any) were applied or deferred
- Any findings that persisted after the iteration limit
