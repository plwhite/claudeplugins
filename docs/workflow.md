# Workflow guide

This guide describes how to work through a software project using `devproc`. The approach is built around features: discrete pieces of work that are specified and designed before they are implemented, checkpointed as they progress, and closed out once complete.

Each feature moves through a lifecycle, with a slash command for each stage:

1. **Specify** (`/feature-spec`) — create the feature and record *what* it must do.
2. **Design** (`/feature-design`) — decide *how* to build it and break it into sub-tasks.
3. **Implement** — work through the sub-tasks (no slash command; `/feature-checkpoint` keeps state in sync as you go).
4. **End** (`/feature-end`) — verify completion, close the feature out, and review the docs.

`/feature-init` sets the model up once per repository before any of this.

Best practice regarding git is to:

- create a branch for each feature at the start of the process;

- commit changes at each stage, including after every subtask;

- finish off by squashing commits as necessary, and merge the branch.

This guide describes driving the workflow yourself, one step at a time. You can also hand the same workflow to the [dev process manager](capabilities.md#dev-process-manager), a top-level agent that works through sub-tasks semi-autonomously — spawning a teammate per sub-task, reviewing its work, and checking in with you at the points you choose. The steps below are exactly what that agent automates.

---

## Specify a feature

When you have a piece of work to track — from a GitHub issue, a design doc, or your own notes — specify it as a feature. This records *what* the feature must do, without yet deciding how. Specify a feature when you are about to start work on it. You can also specify features that have no backing GitHub issue — common in smaller projects with lighter tracking.

- With a description:

  ```
  /feature-spec "A short description of what you want to do"
  ```

- From a GitHub issue by number:

  ```
  /feature-spec "issue 12"
  ```

- From a GitHub issue by description:

  ```
  /feature-spec "the issue about improving error messages"
  ```

  When an issue reference is used, Claude calls `git remote -v` to identify your repo and fetches the issue (and its comments) via `gh`, using its title for the feature and copying the full description plus any design/requirements-relevant comments into the plan file. `gh` must be configured — see [setup.md](setup.md).

This adds an entry to `features/PENDING.md` with a slug (e.g. `[improve-error-messages]`) and creates the plan file `features/plans/<slug>.md`, whose `## Requirements` section holds the captured specification so you never need to re-open the issue.

---

## Design a feature

When you are ready to work on a feature, design it: Claude decides *how* it will be built and breaks the work into sub-tasks. This does not yet write any implementation.

- If there is only one pending feature:

  ```
  /feature-design
  ```

- To name a specific feature:

  ```
  /feature-design improve-error-messages
  /feature-design "issue 12"
  ```

Claude reads the captured specification in the plan file (fetching the GitHub issue only if it is missing), researches the relevant code, and fleshes out the design and sub-task breakdown in `features/plans/<slug>.md`.

**Review the design before approving it.** The design and sub-task plan are presented to you before any implementation begins. This is the moment to correct the approach, adjust scope, or add constraints. Implementation does not start until you confirm.

---

## Implement: work through sub-tasks

Implementation has no slash command of its own — once the design is approved, ask Claude to implement the sub-tasks one at a time.

- After each one completes, review whatever Claude did (and provide feedback or fix it); `git diff` or the VSCode git plugin are ideal for this.

- When you are content, run `/feature-checkpoint` to mark the completed sub-task, advance the `▶ NEXT:` marker, and update the Handoff section so the session state is always recorded. Claude will often run this automatically; you can also run it explicitly at any point.

- Finally, ensure that you have done a git commit so you are ready for the next sub-task.

So long as you have run `/feature-checkpoint`, you can restart Claude at any time and it will be able to pick up where it is left off, as all context is recorded.

Often, you will find more necessary work as you go along; you can ask Claude to add more sub-tasks at any point.

---

## Resume after a session restart

When returning to an in-progress feature in a new session:

1. Open Claude in the project directory. It reads `features/CURRENT.md` on startup and sees the in-progress feature.
2. Open `features/plans/<slug>.md` and read the `## Handoff` section — this contains the session summary, current sub-task state, and the specific first action.
3. Ask Claude to continue. It resumes from exactly where the last session stopped.

You do not need to re-explain context. The Handoff section is the contract between sessions.

---

## Complete a feature

When all sub-tasks are done:

- Review that you are comfortable with the final state.

- Run `/feature-end` to tell Claude that the feature is done. This will run a full checkpoint, verifying all sub-tasks are marked complete, and move the feature entry from `features/CURRENT.md` to `features/COMPLETED.md` with the completion date. The plan file is kept as a record. It also triggers an intensive docs review over all docs in the project.

- Commit the final state changes to git, squash commits as required, and push and merge the feature branch.

