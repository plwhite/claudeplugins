---
name: feature-spec
description: Create a new feature and write its specification
argument-hint: <feature description>
---

Create a new feature and capture its specification. This is the first step of
the feature lifecycle (`feature-spec` → `feature-design` → implement →
`feature-end`): it sets up the feature's tracking entry, records *what* the
feature must do, and agrees the feature's **sign-off strategy** (the quality bar
for testing, docs, code review, and user review), leaving *how* to
`/feature-design`.

Before proceeding, check that CLAUDE.md contains a Feature Model section.
If it doesn't, tell the user to run /feature-init first and stop.

The user has described the feature as: $ARGUMENTS

A review-control token in `$ARGUMENTS` — `--no-review`, "skip review", "no spec review" and the like — selects the review mode in step 7 and is **not part of the feature**. Strip it before using `$ARGUMENTS` as a description: it must not reach the feature title, the slug, the `features/PENDING.md` entry, or the spec.

Steps:
1. If $ARGUMENTS looks like a GitHub issue reference — e.g. "issue 6", "issue #6", "#6", or natural language such as "the issue about improving error handling" — resolve it before proceeding:
   a. Run `git remote -v` and parse the owner/repo from the fetch URL (handles both HTTPS `https://github.com/owner/repo.git` and SSH `git@github.com:owner/repo.git`).
   b. For a numeric reference: run `gh issue view N --repo owner/repo --comments` to fetch the title, body, and comments.
   c. For a natural-language description: run `gh issue list --repo owner/repo --search "keywords" --limit 10 --json number,title,body` and select the best match, then fetch its comments with `gh issue view N --repo owner/repo --comments`.
   d. Use the issue title as the feature title. Write one or two sentences summarising what the issue covers for the `features/PENDING.md` entry — do not put the full issue body there. Include the issue number as a reference (e.g. `See #6.`). The full content goes into the spec (step 5).
   e. If `gh` is not available or the lookup fails, tell the user and ask them to provide the description manually.

2. Read `features/PENDING.md` and `features/CURRENT.md` to understand existing features and avoid duplication.
3. Derive a short, descriptive slug for the feature (e.g. `add-french-divisions`, `deploy-visualisation`). Use lowercase-hyphenated format. Put that at the end of the feature title in square brackets as a tag (e.g. `[add-french-divisions]`).
4. Add a new entry at the top of `features/PENDING.md` (below its header blurb) with the format:

```
### <Feature title> [tag]

<One or two sentences describing what the feature covers and why.> Detail in [features/plans/<slug>.md](plans/<slug>.md).
```

Keep this entry concise — no implementation detail, no sub-tasks. The full specification goes in the plan file.

5. Always create the plan file `features/plans/<slug>.md` with a `## Requirements` section holding the specification, a `## Sign-off strategy` section (see step 6), and a `## Design` placeholder that `/feature-design` will flesh out:

```markdown
# <Feature title> — Feature Plan

## Requirements

<specification content — see below>

## Sign-off strategy

<the quality bar per sign-off category — see step 6>

## Design

*To be fleshed out by `/feature-design`.*

## Review record

<Written by step 7f/8 — one line recording what review happened at this stage.>
```

   (No `## Handoff` section yet — `/feature-design` adds it when it takes the feature into progress.)

   Populate the `## Requirements` section — the specification of *what* the feature must do — as follows:
   - **If the feature came from a GitHub issue:** copy the **entire** issue description verbatim (nothing in it should be assumed irrelevant), then add any comment that bears on design or requirements (e.g. "we should use tool X", "we must ensure Y holds"). Omit comments that are mere reactions or scheduling chatter ("great idea", "let's wait until next month"). Attribute the issue (e.g. "From issue #14 (verbatim):"). The objective is that a later session can pick up the feature from this file alone, without re-reading the issue.
   - **If the user supplied detailed requirements directly:** record them here verbatim or lightly tidied.
   - **If there is nothing beyond the one-or-two-sentence PENDING.md entry:** write `*No requirements beyond the summary in `features/PENDING.md`; design to be determined by `/feature-design`.*`

6. Populate the `## Sign-off strategy` section — the quality bar the feature will be held to, which `/feature-design` later turns into per-sub-task sign-off criteria. The four categories below are the most likely sign-offs; cover each of them, proposing a sensible default for *this* feature and its risk:

   - **Testing** — e.g. "full automated coverage of new logic", "basic happy-path tests", or "none (prose-only change)".
   - **Documentation** — e.g. "full production docs, updated as we go", or "internal `NOTES.md` only".
   - **Code review** — e.g. "per-sub-task light agent review", "a single `/review-branch` before `/feature-end`", or "none".
   - **User review** — e.g. "user confirms each sub-task", or "user reviews only at feature end".

   These four are the usual set, not a closed list. If the feature genuinely needs it, split a category into separate sign-offs (e.g. unit tests and manual tests confirmed at different stages) or add a specific sign-off of another kind (e.g. "agent X has confirmed the output"). Do not invent sign-offs for their own sake.

   Word every entry so it is **auditable** — there must be a clear yes/no at the point a sub-task finishes. "Have some tests" is not auditable; "unit tests written to the agreed quality bar" or "enough tests that the user confirms coverage is sufficient" are.

   Choosing *not* to do a category is legitimate, but state it explicitly as "None — <reason>" so the choice is visible and the user can comment on it. Base the proposal on the feature: higher-risk or user-facing work warrants stronger testing and review than a small internal change.

> Step 7 below is near-identical in `feature-spec` and `feature-design`. If you change the review invocation, the finding-handling rules, the two-invocation cap, the unattended-mode gate, or the `## Review record` format, update both — a silent divergence in the unattended gate is the worst case, since it governs when human sign-off is bypassed. If you add or remove a finding marker, update both agents' `## Output Format` too: the markers are the contract between them.

7. **Have the spec reviewed before the user sees it.** The point is that the user spends their attention on judgement calls, not on catching vagueness an agent can catch.

   a. **Skip only on an explicit instruction.** Check `$ARGUMENTS` for a skip instruction — `--no-review`, "skip review", "no spec review" or similar — and honour the user declining if they raise it while the skill is running. If the review is skipped, go straight to step 8 and say plainly there that it did not run. Absent such an instruction, the review happens.

   b. Call @feature-spec-reviewer with the path of the plan file.

   c. **Act on the findings by their marking, not their severity.** Each finding is marked `[rewrite]` or `[decision]`:
      - `[rewrite]` — fix it yourself in the plan file. These are writing-quality faults: a sign-off criterion that is not auditable, a requirement that defers to the source issue instead of capturing it, implementation detail that belongs in the design.
      - `[decision]` — **do not resolve it by choosing.** Carry it to step 8 as a question for the user. An unresolved question, a contradiction between requirements, or an unstated dependency needs an answer, and a plausible-looking guess is worse than an open question because nobody knows it was made.
      - MINOR and SUGGESTION findings: apply the ones that are clearly right, and mention the rest rather than acting on them. Where one carries a `[decision]` marking, frame it to the user as an observation worth their answer rather than a blocking objection — but note that it still stops an unattended run under 7f, because the gate does not grade questions by severity. A small question is still a question.

      If a finding marked `[decision]` turns out to rest on a fact you can establish rather than a judgement the user must make — the reviewer asks whether there was a source issue and you know there was not, or asks whether a command exists and you can grep for it — establish it and say you did. Do not manufacture a question you can answer. The distinction is judgement versus lookup, not who noticed it.

   d. If your rewrites went beyond minor wording — you restructured a requirement, rewrote a sign-off criterion, or added or removed a section — call the agent once more. **Two invocations per run is the cap** — stop after the second whatever it says, and report anything still outstanding to the user in step 8. Do not spend the second pass when every outstanding finding is `[decision]` and waiting on the user: re-reviewing unchanged questions cannot change the verdict, and the user is the one who has to answer.

   e. Note the final verdict (`READY FOR USER REVIEW` or `NEEDS WORK`) to report in step 8. If the agent fails, returns nothing, or returns findings with no verdict line, treat the result as `NEEDS WORK` and say in step 8 that the review did not complete and why — an absent verdict is not a pass.

   f. **Unattended mode.** If the user has told you to run without checking in — "don't stop for me", "run it unattended", or an autonomy boundary agreed with `dev-process-manager` that covers this stage — then the agent's verdict stands in for their sign-off, but only where it is unambiguous:

      - **Proceed without pausing only if** the final verdict is `READY FOR USER REVIEW` **and** no finding was marked `[decision]`. A finding counts here if the *agent* marked it `[decision]`, even where you settled it by lookup under 7c: establishing a fact records what was true, it does not overturn the reviewer's judgement that the artefact needed an answer. Where every blocking `[decision]` was settled that way, say so plainly when you stop: what you established, that there is nothing for the user to decide, and that you stopped because the reviewer's doubt about the artefact stands.
      - **Otherwise stop and ask**, exactly as step 8 describes. `NEEDS WORK`, or any `[decision]` finding, overrides the instruction to keep going. An autonomy boundary is permission to skip a *routine confirmation*; it is not permission to answer a question that is the user's to answer.
      - **A skipped review cancels unattended mode**: with no review there is no verdict to stand in for the user's judgement, so stop and ask. The two instructions do not compound into "proceed with nothing checked".
      - When you do proceed, say so in your report and on whose instruction, and use the unattended form of the `## Review record` line in step 8.

   If the reviewer contradicts something the user has already settled, say so rather than quietly re-opening it: the user's decision stands, and the finding is worth a sentence, not a rewrite.

   Note that a feature specified from a bare one-line description will not reach `READY FOR USER REVIEW`: with no requirements beyond the summary, the reviewer is right to rate it blocked. Unattended mode will therefore stop and ask, which is the intended behaviour — do not water down the spec to manufacture a passing verdict.

8. Confirm the new feature and its spec to the user, and **present the proposed sign-off strategy for them to agree or adjust** — this is the user's chance to raise or relax the quality bar before design. Update the `## Sign-off strategy` section to match what they settle on.

   *In unattended mode (step 7f), where the verdict permitted you to proceed, still produce this report — the user reads it after the fact rather than before. What changes is that you do not wait for a reply; what does not change is that they are told everything they would have been told.*

   Include with that confirmation:
   - what the review changed, in a line or two — not a transcript of its findings;
   - every `[decision]` finding, as a question they need to answer;
   - any question *you* could not settle from the description or issue, whether or not the review raised it — a skipped review does not mean there is nothing to ask;
   - any MINOR or SUGGESTION finding you did not apply, in brief — enough that the user knows it was raised, not a transcript;
   - the verdict, or a plain statement that the review was skipped and on whose instruction.

   **Record what happened in the plan file, in every case.** Append one line to a `## Review record` section at the end of the plan file, creating the section if it is absent. Write the line whether the review ran, was skipped, or accepted the spec unattended: the section is the durable evidence of what has and has not been checked, and a record that exists only when something happened cannot be trusted to show that nothing did. One line per lifecycle stage, so `/feature-design` appends its own beneath yours.

   ```
   ## Review record

   - 2026-07-20 — Spec reviewed by `feature-spec-reviewer`: VERDICT: READY FOR USER REVIEW. Presented to the user for sign-off.
   - 2026-07-20 — Spec review: N/A — skipped on the user's instruction. Presented to the user for sign-off, unreviewed.
   - 2026-07-20 — Spec reviewed by `feature-spec-reviewer`: VERDICT: READY FOR USER REVIEW. Accepted unattended; no human has read this spec.
   ```

   (Those are the three forms, not three lines to write — use the one that describes this run. The first form carries whichever verdict the review returned; a `VERDICT: NEEDS WORK` run is recorded the same way, adding what remains open — "Presented to the user for sign-off, with 2 open questions.")

   Do not ask if they want to design it now (using `/feature-design`).
