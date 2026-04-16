# Workflow guide

This guide describes how to work through a software project using `devproc`. The approach is built around features: discrete pieces of work that are planned before they are implemented, checkpointed as they progress, and closed out once complete.

Best practice regarding git is to:

- create a branch for each feature at the start of the process;

- commit changes at each stage, including after every subtask;

- finish off by squashing commits as necessary, and merge the branch.

---

## Add a feature to the backlog

When you have a piece of work to track — from a GitHub issue, a design doc, or your own notes — add it to the project feature list. You should do this *either* when you are about to start work on it, *or* if this is a feature that is not covered by a GitHub issue (which would normally imply a small hobby project with less tracking.

- With a description:

  ```
  /feature-create "A short description of what you want to do"
  ```

- From a GitHub issue by number:

  ```
  /feature-create "issue 12"
  ```

- From a GitHub issue by description:

  ```
  /feature-create "the issue about improving error messages"
  ```

  When an issue reference is used, Claude calls `git remote -v` to identify your repo and fetches the issue via `gh`, using its title and body as the feature description. `gh` must be configured — see [setup.md](setup.md).

This adds an entry to `FEATURES.md` in the Pending section with a slug (e.g. `[improve-error-messages]`) that links it to its plan file.

---

## Start implementing a feature

When you are ready to work on a feature:

- If there is only one pending feature:

  ```
  /feature-start
  ```

- To name a specific feature:

  ```
  /feature-start improve-error-messages
  /feature-start "issue 12"
  ```

Claude reads the feature description (fetching the GitHub issue if needed), researches the relevant code, and produces a design and sub-task breakdown in `plans/<slug>.md`.

**Review the plan before approving it.** The plan is presented to you before any implementation begins. This is the moment to correct the approach, adjust scope, or add constraints. Implementation does not start until you confirm.

---

## Work through sub-tasks

Ask Claude to implement sub-tasks one at a time.

- After each one completes, review whatever Claude did (and provide feedback or fix it); `git diff` or the VSCode git plugin are ideal for this.

- When you are content, run `/feature-checkpoint` to mark the completed sub-task, advance the `▶ NEXT:` marker, and update the Handoff section so the session state is always recorded. Claude will often run this automatically; you can also run it explicitly at any point.

- Finally, ensure that you have done a git commit so you are ready for the next sub-task.

So long as you have run `/feature-checkpoint`, you can restart Claude at any time and it will be able to pick up where it is left off, as all context is recorded.

Often, you will find more necessary work as you go along; you can ask Claude to add more sub-tasks at any point.

---

## Resume after a session restart

When returning to an in-progress feature in a new session:

1. Open Claude in the project directory. It reads `FEATURES.md` on startup and sees the in-progress feature.
2. Open `plans/<slug>.md` and read the `## Handoff` section — this contains the session summary, current sub-task state, and the specific first action.
3. Ask Claude to continue. It resumes from exactly where the last session stopped.

You do not need to re-explain context. The Handoff section is the contract between sessions.

---

## Complete a feature

When all sub-tasks are done:

- Review that you are comfortable with the final state.

- Run `/feature-end` to tell Claude that the feature is done. This will run a full checkpoint, verifying all sub-tasks are marked complete, and move the feature entry from In Progress to Completed in `FEATURES.md` with the completion date. The plan file is kept as a record. It also triggers an intensive docs review over all docs in the project.

- Commit the final state changes to git, squash commits as required, and push and merge the feature branch.

