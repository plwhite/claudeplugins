---
name: feature-design
description: Design and plan a feature — move it to in progress and write its design and sub-task plan
argument-hint: [feature name or slug]
---

Design a specified feature: decide *how* it will be built and break the work
into sub-tasks, each with its own **sign-off criteria**. This is the second step
of the feature lifecycle (`feature-spec` → `feature-design` → implement →
`feature-end`). It assumes the feature has already been specified by
`/feature-spec` (which agreed the sign-off strategy); it produces the design and
plan, but does **not** begin implementation.

Before proceeding, check that CLAUDE.md contains a Feature Model section.
If it doesn't, tell the user to run /feature-init first and stop.

The user has identified the feature as: $ARGUMENTS

Steps:

1. Read `features/PENDING.md` and identify the feature to design.
   - Match `$ARGUMENTS` against pending feature names and slugs.
   - If `$ARGUMENTS` is blank and there is exactly one entry in `features/PENDING.md`, use that.
   - If no match is found, tell the user the feature is not in `features/PENDING.md` and ask them to run `/feature-spec` first. Do not proceed.
   - If ambiguous, ask the user to clarify.

   Then gather the specification to inform the design:
   a. Read the feature's plan file `features/plans/<slug>.md`. `/feature-spec` normally captures the full source-issue content in its `## Requirements` section — prefer this over re-fetching the issue.
   b. If the plan file is missing or has no usable `## Requirements`, and the feature entry references a GitHub issue (e.g. contains `#6` or `Closes #6`), fetch it: run `git remote -v` to parse owner/repo from the fetch URL (HTTPS `https://github.com/owner/repo.git` or SSH `git@github.com:owner/repo.git`), then `gh issue view N --repo owner/repo --comments`.
   c. If a fetch is needed but the `git`/`gh` commands fail (not installed, auth error, repo not found, etc.), do not proceed. Tell the user what was attempted, what failed, and ask them how to continue — e.g. "This feature references issue #6 but I was unable to fetch it (`gh` returned: …). Please either fix the `gh` setup or paste the issue content here."

2. Move the feature entry from `features/PENDING.md` to `features/CURRENT.md`. Update the entry's detail link if needed so it points at `features/plans/<slug>.md` (the link is relative to `features/CURRENT.md`, so written `[features/plans/<slug>.md](plans/<slug>.md)`).

3. Decide whether to use deep planning mode:
   - Use `/plan` if: the feature is complex (multiple systems touched, significant unknowns, non-trivial architecture decisions), OR the user has asked for deeper thinking or planning (e.g. "use plan mode" or "this is a complex change").
   - Skip `/plan` for straightforward features where the sub-tasks are obvious from the specification.
   - If using `/plan`: invoke it now before proceeding. The plan output will inform the sub-task breakdown.

4. Before writing the design, do enough research to produce a realistic sub-task breakdown:
   - Read relevant existing code and data files.
   - If the feature involves external services, APIs, or unfamiliar areas of the codebase, do reconnaissance before drafting sub-tasks.
   - If the specification is unclear, ask the user before writing the design.

5. Flesh out the plan file `features/plans/<slug>.md`. It normally already exists (created by `/feature-spec`) with a `## Requirements` section, a `## Sign-off strategy` section, and a `## Design` placeholder. **Preserve the `## Requirements` and `## Sign-off strategy` sections**, prepend a `## Handoff` section, replace the Design placeholder with the real design, and add a `## Sub-tasks` section. If the file does not exist, create it with all sections. Target structure:

```markdown
# <Feature title> — Feature Plan

## Handoff

**Last updated:** YYYY-MM-DD
**Session summary:** Design and plan created. Implementation not yet started.
**Sub-task in progress:** None
**First action next session:** Begin Sub-task 1
**Open questions / decisions pending:** None
**Dead ends to avoid:** None

## Requirements

<Preserved from /feature-spec. If absent and there are no requirements beyond
the features/PENDING.md summary, this section may be omitted.>

## Sign-off strategy

<Preserved from /feature-spec — the quality bar per sign-off category that the
per-sub-task criteria below are derived from.>

## Design

<The output of the planning process goes here. For a simple feature this may be
a short paragraph. For a complex feature it may be several pages covering
architectural decisions, data layouts, component interactions, and open
questions resolved during planning. This section is the written record of
what was decided and why — enough detail that the user can review it inline
and provide corrections before implementation begins.>

## Sub-tasks

1. **<Sub-task name>** — <brief description of what success looks like>
   - [ ] <sign-off criterion>   (see step 6)
2. **<Sub-task name>** — ...
...

**▶ NEXT:** Sub-task 1

> Run `/feature-checkpoint` after each sub-task completes.
```

Keep sub-task descriptions to one line. Implementation detail goes in `NOTES.md` as you discover it, not here. The Design section is the exception: it should capture the key decisions and rationale from the planning process.

6. Give each sub-task its **sign-off criteria**, derived from the `## Sign-off strategy` agreed at `/feature-spec`. Under each sub-task, add a checkbox for every sign-off that applies to it:

   - Start from the four standard categories (testing, docs, code review, user review), plus any feature-specific sign-offs the strategy defined (e.g. a separate manual-test sign-off, or "agent X confirms the output"). List only the categories that genuinely apply to that sub-task — a small internal sub-task may need only one, a risky one may need all of them.
   - Word each criterion so it is **auditable** — there must be a clear yes/no when the sub-task finishes. "Add tests" is not auditable; "unit tests for the parser, passing" or "user confirms the config syntax" are.
   - Follow the checkbox convention in the project `CLAUDE.md` (`### Sign-off criteria`): `- [ ]` is pending and `- [x]` is satisfied; a sub-task is complete only when all its boxes are `[x]`. If a sub-task deliberately omits a category the strategy generally requires, note why inline. Feature-level sign-offs (e.g. a single end-of-feature `/review-branch`) belong in `## Sign-off strategy`, not duplicated onto every sub-task.

   Example:
   ```
   3. **Add the config parser** — handle the new format
      - [ ] Testing: unit tests for the parser, passing
      - [ ] Code review: /review-component the parser
      - [ ] User review: user confirms the config syntax
   ```

7. Summarise the design and sub-task plan to the user, and **present each sub-task's sign-off criteria for them to agree or adjust** — this is where the user signs off on what each sub-task must satisfy before it counts as done. Update the criteria to match what they settle on. Implementation is a separate step with no slash command of its own — *do not start implementing without user confirmation.*
