---
name: feature-start
description: Begin implementing a pending feature — move to In Progress and create a plan file
argument-hint: [feature name or slug]
---

Start implementing a feature.

Before proceeding, check that CLAUDE.md contains a Feature Model section.
If it doesn't, tell the user to run /feature-init first and stop.

The user has identified the feature as: $ARGUMENTS

Steps:

1. Read `FEATURES.md` and identify the feature to start.
   - Match `$ARGUMENTS` against pending feature names and slugs.
   - If `$ARGUMENTS` is blank and there is exactly one entry in `## Pending`, use that.
   - If no match is found, tell the user the feature is not in `FEATURES.md` and ask them to run `/feature-create` first. Do not proceed.
   - If ambiguous, ask the user to clarify.

   Then, if the matched feature entry references a GitHub issue (e.g. contains `#6` or `Closes #6`), fetch the issue to use as additional context when writing the design:
   a. Run `git remote -v` and parse the owner/repo from the fetch URL (handles both HTTPS `https://github.com/owner/repo.git` and SSH `git@github.com:owner/repo.git`).
   b. Run `gh issue view N --repo owner/repo` to retrieve the full issue title and body.
   c. Use this content to inform the Design section and sub-task breakdown.
   d. If the `git` or `gh` commands fail (not installed, auth error, repo not found, etc.), do not proceed. Tell the user what was attempted, what failed, and ask them how to continue — e.g. "This feature references issue #6 but I was unable to fetch it (`gh` returned: …). Please either fix the `gh` setup or paste the issue content here."

2. Move the feature entry from `## Pending` to `## In progress` in `FEATURES.md`. Update the In Progress entry to reference the plan file: add a line like `Sub-task detail in [plans/<slug>.md](plans/<slug>.md).`

3. Decide whether to use deep planning mode:
   - Use `/plan` if: the feature is complex (multiple systems touched, significant unknowns, non-trivial architecture decisions), OR the user has asked for deeper thinking or planning (e.g. "use plan mode" or "this is a complex change").
   - Skip `/plan` for straightforward features where the sub-tasks are obvious from the description.
   - If using `/plan`: invoke it now before proceeding. The plan output will inform the sub-task breakdown.

4. Before creating the plan file, do enough research to produce a realistic sub-task breakdown:
   - Read relevant existing code and data files.
   - If the feature involves external services, APIs, or unfamiliar areas of the codebase, do reconnaissance before drafting sub-tasks.
   - If requirements are unclear, ask the user before writing the plan.

5. Create `plans/<slug>.md` with this structure:

```markdown
# <Feature title> — Feature Plan

## Handoff

**Last updated:** YYYY-MM-DD
**Session summary:** Feature plan created. Implementation not yet started.
**Sub-task in progress:** None
**First action next session:** Begin Sub-task 1
**Open questions / decisions pending:** None
**Dead ends to avoid:** None

## Design

<The output of the planning process goes here. For a simple feature this may be
a short paragraph. For a complex feature it may be several pages covering
architectural decisions, data layouts, component interactions, and open
questions resolved during planning. This section is the written record of
what was decided and why — enough detail that the user can review it inline
and provide corrections before implementation begins.>

## Sub-tasks

1. **<Sub-task name>** — <brief description of what success looks like>
2. **<Sub-task name>** — ...
...

**▶ NEXT:** Sub-task 1

> Run `/feature-checkpoint` after each sub-task completes.
```

Keep sub-task descriptions to one line. Implementation detail goes in `NOTES.md` as you discover it, not here. The Design section is the exception: it should capture the key decisions and rationale from the planning process.

6. Summarise the plan to the user and confirm you are ready to begin sub-task 1. *Do not start implementation without user confirmation.*
