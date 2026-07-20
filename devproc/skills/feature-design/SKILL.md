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

A review-control token in `$ARGUMENTS` — `--no-review`, "skip review", "no design review" and the like — selects the review mode in step 7 and is **not part of the feature's name**. Strip it before matching `$ARGUMENTS` against pending features in step 1, or the match will fail.

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

5. Flesh out the plan file `features/plans/<slug>.md`. It normally already exists (created by `/feature-spec`) with a `## Requirements` section, a `## Sign-off strategy` section, a `## Design` placeholder, and a `## Review record` section. **Preserve the `## Requirements`, `## Sign-off strategy` and `## Review record` sections** — the review record is the feature's review history and must survive this rewrite intact — then prepend a `## Handoff` section, replace the Design placeholder with the real design, and add a `## Sub-tasks` section. Insert `## Sub-tasks` after `## Design`, leaving `## Review record` as the last section of the file. If the file does not exist, create it with all sections. Target structure:

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

## Review record

<Preserved from /feature-spec, and appended to in step 8. Always the last
section of the file.>
```

Keep sub-task descriptions to one line. Implementation detail goes in `NOTES.md` as you discover it, not here. The Design section is the exception: it should capture the key decisions and rationale from the planning process.

6. Give each sub-task its **sign-off criteria**, derived from the `## Sign-off strategy` agreed at `/feature-spec`. Under each sub-task, add a checkbox for every sign-off that applies to it:

   - Start from the four standard categories (testing, docs, code review, user review), plus any feature-specific sign-offs the strategy defined (e.g. a separate manual-test sign-off, or "agent X confirms the output"). List only the categories that genuinely apply to that sub-task — a small internal sub-task may need only one, a risky one may need all of them.
   - Word each criterion so it is **auditable** — there must be a clear yes/no when the sub-task finishes. "Add tests" is not auditable; "unit tests for the parser, passing" or "user confirms the config syntax" are.
   - Follow the checkbox convention in the project `CLAUDE.md` (`### Sign-off criteria`): `- [ ]` is pending and `- [x]` is satisfied; a sub-task is complete only when all its boxes are `[x]`. When a category does not apply to a sub-task, **leave it out** — do not write a placeholder box such as `- [ ] User review: none`, which can never legitimately be ticked and so blocks the sub-task from ever completing. If the omission is one a reader might question, justify it once where it belongs: a feature-wide skip in `## Sign-off strategy`, or a note beneath the sub-task list for a case that recurs across several sub-tasks (e.g. "sub-tasks 1–2 carry no user review — no user-visible surface until sub-task 3"). Feature-level sign-offs (e.g. a single end-of-feature `/review-branch`) live in `## Sign-off strategy`, not duplicated onto every sub-task.

   Example:
   ```
   3. **Add the config parser** — handle the new format
      - [ ] Testing: unit tests for the parser, passing
      - [ ] Code review: /review-component the parser
      - [ ] User review: user confirms the config syntax
   ```

> Step 7 below is near-identical in `feature-spec` and `feature-design`. If you change the review invocation, the finding-handling rules, the two-invocation cap, the unattended-mode gate, or the `## Review record` format, update both — a silent divergence in the unattended gate is the worst case, since it governs when human sign-off is bypassed. If you add or remove a finding marker, update both agents' `## Output Format` too: the markers are the contract between them.

7. **Have the design reviewed before the user sees it.** The point is that the user spends their attention on judgement calls, not on catching gaps an agent can catch.

   a. **Skip only on an explicit instruction.** Check `$ARGUMENTS` for a skip instruction — `--no-review`, "skip review", "no design review" or similar — and honour the user declining if they raise it while the skill is running. If the review is skipped, go straight to step 8 and say plainly there that it did not run. Absent such an instruction, the review happens.

   b. Call @feature-design-reviewer with the path of the plan file.

   c. **Act on the findings by their marking, not their severity.** Each finding is marked `[rewrite]` or `[decision]`:
      - `[rewrite]` — fix it yourself in the plan file. These are writing-quality faults: a decision recorded without its reasoning, a criterion that is not auditable, a requirement no sub-task covers, a sub-task that is really three.
      - `[decision]` — **do not resolve it by choosing.** Carry it to step 8 as a question for the user. Guessing here is precisely the failure the review exists to prevent, and a plausible-looking guess is worse than an open question because nobody knows it was made.
      - MINOR and SUGGESTION findings: apply the ones that are clearly right, and mention the rest rather than acting on them. Where one carries a `[decision]` marking, frame it to the user as an observation worth their answer rather than a blocking objection — but note that it still stops an unattended run under 7f, because the gate does not grade questions by severity. A small question is still a question.

      If a finding marked `[decision]` turns out to rest on a fact you can establish rather than a judgement the user must make — the reviewer asks whether a component exists, and you can read the code and see — establish it and say you did. Do not manufacture a question you can answer. The distinction is judgement versus lookup, not who noticed it.

   d. If your rewrites went beyond minor wording — you restructured the design, rewrote a sub-task or its criteria, or reordered the breakdown — call the agent once more. **Two invocations per run is the cap** — stop after the second whatever it says, and report anything still outstanding to the user in step 8. Do not spend the second pass when every outstanding finding is `[decision]` and waiting on the user: re-reviewing unchanged questions cannot change the verdict, and the user is the one who has to answer.

   e. Note the final verdict (`READY FOR USER REVIEW` or `NEEDS WORK`) to report in step 8. If the agent fails, returns nothing, or returns findings with no verdict line, treat the result as `NEEDS WORK` and say in step 8 that the review did not complete and why — an absent verdict is not a pass.

   f. **Unattended mode.** If the user has told you to run without checking in — "don't stop for me", "work through the feature unattended", or an autonomy boundary agreed with `dev-process-manager` that covers this stage — then the agent's verdict stands in for their sign-off, but only where it is unambiguous:

      - **Proceed without pausing only if** the final verdict is `READY FOR USER REVIEW` **and** no finding was marked `[decision]`. A finding counts here if the *agent* marked it `[decision]`, even where you settled it by lookup under 7c: establishing a fact records what was true, it does not overturn the reviewer's judgement that the artefact needed an answer. Where every blocking `[decision]` was settled that way, say so plainly when you stop: what you established, that there is nothing for the user to decide, and that you stopped because the reviewer's doubt about the artefact stands.
      - **Otherwise stop and ask**, exactly as step 8 describes. `NEEDS WORK`, or any `[decision]` finding, overrides the instruction to keep going. An autonomy boundary is permission to skip a *routine confirmation*; it is not permission to answer a question that is the user's to answer.
      - **A skipped review cancels unattended mode**: with no review there is no verdict to stand in for the user's judgement, so stop and ask. The two instructions do not compound into "proceed with nothing checked".
      - **Proceeding here means implementation may begin** without the user having seen the design. Use the unattended form of the `## Review record` line in step 8, *also* note it in the `## Handoff` section's session summary so a resuming session knows the design is unreviewed by a human without having to look for the record, and say in your report that you proceeded unattended and on whose instruction.

   If the reviewer contradicts something the user has already settled, say so rather than quietly re-opening it: the user's decision stands, and the finding is worth a sentence, not a rewrite.

8. Summarise the design and sub-task plan to the user, and **present each sub-task's sign-off criteria for them to agree or adjust** — this is where the user signs off on what each sub-task must satisfy before it counts as done. Update the criteria to match what they settle on.

   *In unattended mode (step 7f), where the verdict permitted you to proceed, still produce this report — the user reads it after the fact rather than before. What changes is that you do not wait for a reply; what does not change is that they are told everything they would have been told. The sign-off criteria are frozen as the reviewer saw them, and the unattended form of the `## Review record` line is what tells a resuming session that no human adjusted them.*

   Include with that summary:
   - what the review changed, in a line or two — not a transcript of its findings;
   - every `[decision]` finding, as a question they need to answer;
   - any question *you* could not settle from the requirements, whether or not the review raised it, recorded in the plan file's Handoff section as well — a skipped review does not mean there is nothing to ask;
   - any MINOR or SUGGESTION finding you did not apply, in brief — enough that the user knows it was raised, not a transcript;
   - the verdict, or a plain statement that the review was skipped and on whose instruction.

   **Record what happened in the plan file, in every case.** Append one line to the `## Review record` section at the end of the plan file, creating the section if `/feature-spec` did not. Write the line whether the review ran, was skipped, or accepted the design unattended: the section is the durable evidence of what has and has not been checked, and a record that exists only when something happened cannot be trusted to show that nothing did. Append beneath the spec-stage line rather than replacing it — the record is the feature's review history, not its current state.

   ```
   - 2026-07-20 — Design reviewed by `feature-design-reviewer`: VERDICT: NEEDS WORK. Presented to the user for sign-off, with 2 open questions.
   - 2026-07-20 — Design review: N/A — skipped on the user's instruction. Presented to the user for sign-off, unreviewed.
   - 2026-07-20 — Design reviewed by `feature-design-reviewer`: VERDICT: READY FOR USER REVIEW. Accepted unattended; no human has read this design.
   ```

   (Those are the three forms, not three lines to write — use the one that describes this run. The first form carries whichever verdict the review returned; a `VERDICT: READY FOR USER REVIEW` run is recorded the same way, without the trailing count of open questions.)

   Implementation is a separate step with no slash command of its own — *do not start implementing without user confirmation*, unless step 7f's unattended gate was satisfied and the agreed autonomy boundary covers implementation as well as design. Passing the gate is permission to proceed *without waiting*; it is not permission to exceed the boundary the user set.
