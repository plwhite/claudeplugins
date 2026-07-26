# Workflow guide

This guide describes how to work through a software project using `devproc`. The approach is built around features: discrete pieces of work that are specified and designed before they are implemented, checkpointed as they progress, and closed out once complete.

Each feature moves through a lifecycle, with a slash command for each stage:

1. **Specify** (`/feature-spec`) — create the feature, record *what* it must do, and agree its sign-off strategy.
2. **Design** (`/feature-design`) — decide *how* to build it, break it into sub-tasks, and set each sub-task's sign-off criteria.
3. **Implement** — work through the sub-tasks (no slash command; `/feature-checkpoint` keeps state in sync as you go). A sub-task is complete only when all its sign-off boxes are ticked.
4. **End** (`/feature-end`) — verify completion, close the feature out, and review the docs.

`/feature-init` sets the model up once per repository before any of this.

Best practice regarding git is to:

- create a branch for each feature at the start of the process;

- commit changes at each stage, including after every sub-task;

- finish off by squashing commits as necessary, and merge the branch.

This guide describes driving the workflow yourself, one step at a time. You can also hand the same workflow to the [Dev Process Manager](capabilities.md#dev-process-manager), a top-level agent that works through sub-tasks semi-autonomously — spawning a teammate per sub-task, reviewing its work, and checking in with you at the points you choose. The steps below are exactly what that agent automates.

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

- From material staged in `features/tmp`:

  ```
  /feature-spec "use what's in features/tmp"
  ```

  For requirements too big or too messy for a one-line description or an issue — notes, one or more documents (including link or index pages), screenshots — drop them into `features/tmp/` first. Point `/feature-spec` at the directory explicitly and it uses the contents directly. Or leave it to notice on its own: when your description is thin and `features/tmp` holds something beyond the tracked `README.md`, Claude checks with you first before treating it as input, so leftovers from an aborted run can't silently join the wrong spec. `README.md` itself is never read as input.

  Markdown or plain-text material — even a couple hundred lines of it — is copied inline into `## Requirements`, exactly as issue content is. Only genuinely un-inlinable artefacts (Word documents, screenshots, other binaries) are instead copied into `features/plans/<slug>/` and linked from `## Requirements`. Either way, once the material is captured it is deleted from `features/tmp` (`README.md` stays): the plan becomes the only durable copy, since `features/tmp` is a hand-off channel into the spec, not a place to track requirements.

This adds an entry to `features/PENDING.md` with a slug (e.g. `[improve-error-messages]`) and creates the plan file `features/plans/<slug>.md`, whose `## Requirements` section holds the captured specification so you never need to re-open the issue.

As part of specifying, Claude proposes a **sign-off strategy** — the quality bar for each of the five sign-off categories (testing, documentation, code review, docs review, user review) across the whole feature. Docs review is deliberately its own category, separate from writing the documentation: like code review it is a check of what was done, and it is the sign-off most routinely missed. The canonical statement of the model — categories, checkbox convention, auditability — lives in the `### Sign-off criteria` section of `features/FEATUREMODEL.md`, which your project gains from `/feature-init`. For example: 100% test coverage versus basic tests versus none; full production docs versus internal notes only. It is recorded in the plan file's `## Sign-off strategy` section. Skipping a category is fine, but it is a deliberate choice made here where you can comment on it — not something that quietly slips. This is the moment to set the standard the feature will be held to.

Those five categories are the usual set, not a fixed list: if a feature needs it, the strategy can split one (say, separate unit-test and manual-test sign-offs at different stages) or add a specific sign-off of another kind (e.g. "agent X has confirmed the output"). Whatever the criteria, each is worded to be **auditable** — there is a clear yes/no at the point a sub-task finishes. "Have some tests" is not auditable; "unit tests written to the agreed quality bar" or "enough tests that you confirm coverage is sufficient" are. Review sign-offs — code review, docs review, or otherwise — always say **who performs them**: an agent (naming the skill or agent, e.g. `/review-branch`) or you, so a "code review" box is never ambiguous about whether you are expected to do it.

Before the spec reaches you, the `feature-spec-reviewer` agent reads it — see [Review before you read it](#review-before-you-read-it) below.

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

Each sub-task is given its own **sign-off criteria** — checkboxes for the categories that apply to it (the relevant subset of testing / documentation / code review / docs review / user review), derived from the sign-off strategy agreed at spec time. These appear under the sub-task in the plan file, e.g.:

```
3. **Add the parser** — handle the new config format
   - [ ] Testing: unit tests for the parser, passing
   - [ ] Code review (agent): /review-component the parser
   - [ ] Docs review (agent): docs-structure-reviewer over the updated config docs
   - [ ] User review: user confirms the config syntax
```

`- [ ]` is pending and `- [x]` is satisfied; the sub-task is complete only once every box is `[x]`.

Where the sign-off strategy defines any end-of-feature gate — a single `/review-branch` before the feature closes, one `docs-structure-reviewer` pass, a final user review — Claude adds it as a last sub-task, **"Final sign-off criteria"**, one checkbox per gate. This only happens when such gates actually exist; a feature whose sign-offs are all satisfied within earlier sub-tasks gets no final sub-task. A box that `/feature-end` performs itself (typically the docs-review box, since `/feature-end` runs that review as it closes the feature) is marked "(performed at `/feature-end`)" — the one box expected to stay unticked until then.

Before the design reaches you, the `feature-design-reviewer` agent reads it — see [Review before you read it](#review-before-you-read-it) below.

**Review the design before approving it.** The design, the sub-task plan, and each sub-task's sign-off criteria are presented to you before any implementation begins. This is the moment to correct the approach, adjust scope, add constraints, or change what each sub-task must satisfy before it counts as done. Implementation does not start until you confirm.

---

## Review before you read it

Both `/feature-spec` and `/feature-design` hand their output to a review agent before showing it to you — `feature-spec-reviewer` and `feature-design-reviewer` respectively. The point is that your attention goes on judgement calls rather than on catching vagueness, so that reviewing a spec or design is quicker and needs less back-and-forth.

Each agent checks that the artefact is complete and clear, that its delivery criteria are explicit and auditable, and that anything blocking the next stage is surfaced. It ends with a one-line verdict: `READY FOR USER REVIEW` or `NEEDS WORK`.

What happens to a finding depends on how it is marked, not on how severe it is:

- **`[rewrite]`** — Claude fixes it before you see the artefact. Vague wording, a criterion with no clear yes/no, a requirement no sub-task covers.
- **`[decision]`** — it comes to you as a question. Claude will not resolve it by choosing: a plausible guess is worse than an open question, because nobody knows it was made.

You are told what the review changed, any questions it raised, and the verdict.

### The three modes

- **Reviewed (default).** The agent reviews, Claude fixes what it can, and the artefact is presented to you with the questions and the verdict. You still sign off.
- **Skipped.** Add an explicit instruction — `--no-review`, or "skip review" — and no agent runs. The report says so plainly.
- **Unattended.** Tell Claude to run without checking in ("don't stop for me", "run it unattended"), and the verdict stands in for your sign-off. It proceeds **only** on `READY FOR USER REVIEW` with no `[decision]` finding; a `NEEDS WORK` verdict or a single question stops it and asks you regardless. Asking to skip the review *cancels* unattended mode rather than combining with it — with nothing checked, there is no verdict to stand in for your judgement.

In practice unattended runs stop more often at the spec stage than at the design stage, because a spec written from a description usually leaves at least one thing worth asking.

### The review record

Every run appends a line to the plan file's `## Review record`, whatever happened:

```
## Review record

- 2026-06-11 — Spec reviewed by `feature-spec-reviewer`: VERDICT: READY FOR USER REVIEW. Presented to the user for sign-off.
- 2026-06-12 — Design review: N/A — skipped on the user's instruction. Presented to the user for sign-off, unreviewed.
```

The line is written even when nothing was checked, which is what makes the section worth trusting: a missing line means the stage has not run, not that someone forgot to record it. When an artefact is accepted unattended, the line says so explicitly — "no human has read this design" — and for a design the Handoff section says it too, so a session resuming later does not have to go looking.

---

## Implement: work through sub-tasks

Implementation has no slash command of its own — once the design is approved, ask Claude to implement the sub-tasks one at a time.

- Work a sub-task until each of its sign-off boxes is satisfied, then tick it. A sub-task is **not done** while any box is unticked: that is the mechanism that stops testing, docs, review, or your confirmation being skipped under time pressure.

- After each one completes, review whatever Claude did (and provide feedback or fix it); `git diff` or the VSCode git plugin are ideal for this. (Where a sub-task has a *user review* box, this review is itself the sign-off — tick it once you are content.)

- When you are content and all the sub-task's boxes are ticked, run `/feature-checkpoint` to mark the completed sub-task, advance the `▶ NEXT:` marker, and update the Handoff section so the session state is always recorded. Claude will often run this automatically; you can also run it explicitly at any point — including mid-sub-task, where it records which boxes are done and which remain without marking the sub-task complete.

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

- Run `/feature-end` to tell Claude that the feature is done. This will run a full checkpoint, verifying all sub-tasks are marked complete with every sign-off box ticked — except a "Final sign-off criteria" box marked "(performed at `/feature-end`)", which is expected to still be open at this point, since this step is what performs and ticks it — and move the feature entry from `features/CURRENT.md` to `features/COMPLETED.md` with the completion date. The plan file is kept as a record. It also triggers an intensive docs review over all docs in the project — the same review that ticks the annotated docs-review box, so there is only ever one close-out docs review.

- Commit the final state changes to git, squash commits as required, and push and merge the feature branch.

---

## Keep internal docs tidy

`CLAUDE.md`, `NOTES.md`, and `.claude/rules/*.md` accumulate drift over time — status entries that duplicate `features/COMPLETED.md`, stale notes, judgment calls nobody revisited. Run `/internal-docs-prune` periodically — e.g. after a batch of completed features, or whenever one of these files starts to feel bloated — to clear it out. See [capabilities.md](capabilities.md#internal-docs-hygiene) for what it does and how it gates findings by class.

