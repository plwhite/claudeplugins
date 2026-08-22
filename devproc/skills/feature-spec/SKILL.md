---
name: feature-spec
description: Create a new feature and write its specification
argument-hint: <feature description>
---

Create a new feature and capture its specification. This is the first step of
the feature lifecycle (`feature-spec` → `feature-design` → implement →
`feature-end`): it sets up the feature's tracking entry, captures the input as
`## Requirements` and writes `## Spec` — what the feature must do — and agrees
the feature's **sign-off strategy** (the quality bar per sign-off category, as
defined in `features/FEATUREMODEL.md` under `### Sign-off criteria`), leaving
*how* to `/feature-design`.

Before proceeding, check that `features/FEATUREMODEL.md` exists **and** that
`CLAUDE.md` loads it via a live import — an un-backticked `@features/FEATUREMODEL.md` line in ordinary prose, outside any fenced code block.
If either is missing, tell the user to run /feature-init first and stop.

The user has described the feature as: $ARGUMENTS

A review-control token in `$ARGUMENTS` — `--no-review`, "skip review", "no spec review" and the like — selects the review mode in step 8 and is **not part of the feature**. Strip it before using `$ARGUMENTS` as a description: it must not reach the feature title, the slug, the `features/PENDING.md` entry, or the spec.

Steps:
1. If $ARGUMENTS looks like a GitHub issue reference — e.g. "issue 6", "issue #6", "#6", or natural language such as "the issue about improving error handling" — resolve it before proceeding:
   a. Run `git remote -v` inside the repository the issue belongs to, not at the workspace root — resolve which repository first. In a **tracked workspace** (the two shapes are defined in `features/FEATUREMODEL.md` under `### The workspace`), that's the workspace itself. In an **untracked workspace**: if exactly one repository sits directly beneath the workspace, use it; if more than one, ask the user which one (never guess); if none is found, or the one found has no GitHub remote (e.g. a local-only repo, a local-path clone, or a non-GitHub host), ask the user for `owner/repo` directly. Parse the owner/repo from the fetch URL (handles both HTTPS `https://github.com/owner/repo.git` and SSH `git@github.com:owner/repo.git`). Whichever case applies, state which repository the remote was read from.
   b. For a numeric reference: run `gh issue view N --repo owner/repo --comments` to fetch the title, body, and comments. Just run it — `gh` authenticates from `GH_TOKEN`, which the environment is expected to provide. If this fails **stop and ask the user for assistance**.
   c. For a natural-language description: run `gh issue list --repo owner/repo --search "keywords" --limit 10 --json number,title,body` and select the best match, then fetch its comments with `gh issue view N --repo owner/repo --comments`.
   d. Use the issue title as the feature title. Write one or two sentences summarising what the issue covers for the `features/PENDING.md` entry — do not put the full issue body there. Include the issue number as a reference (e.g. `See #6.`). The full content goes into `## Requirements` (step 6).

2. **Check `features/tmp` for requirements material.** Alongside a GitHub issue and a one-line `$ARGUMENTS` description, a user can hand over a whole body of requirements material — notes, one or more documents (including link or index pages), screenshots — by dropping it in `features/tmp/` — either pointing `/feature-spec` at it explicitly or letting it notice on its own. This is the third input route.
   a. **Explicitly pointed at it.** If the user's request references `features/tmp` ("use what's in features/tmp", "I've left the spec there"), treat everything in the directory except `README.md` as requirements material for this feature. If the user referenced `features/tmp` but it does not exist, or holds nothing beyond `README.md`, stop and tell the user — do not silently proceed with no material.
   b. **Auto-detected.** If nobody pointed you there, but `$ARGUMENTS` gave you little to work with — a short phrase, or a GitHub issue that resolved to only a sparse description — and `features/tmp` holds something beyond `README.md`, you may still use it, but confirm with the user first that the material belongs to this feature before capturing it. Do not skip this check: content left behind by an aborted earlier run must not silently leak into an unrelated spec. Do not treat `$ARGUMENTS` as thin when a GitHub issue resolved with substantive content. When the user explicitly pointed you at `features/tmp` (case a), skip this confirmation entirely.
   c. `features/tmp/README.md` is the directory's own documentation, not requirements material — never read it as input and never remove it.
   d. If `features/tmp` is empty (or holds only `README.md`) and the user did not reference it, this route does not apply.
   e. **Sources can combine.** If step 1 resolved a GitHub issue and step 2 also finds `features/tmp` material, use both — capturing each under its own attributed heading in `## Requirements` (step 6).

   Step 6 carries out the capture — writing what step 2 identifies into the plan file.

3. Read `features/PENDING.md` and `features/CURRENT.md` to understand existing features and avoid duplication.
4. Derive a short, descriptive slug for the feature (e.g. `add-french-divisions`, `deploy-visualisation`). Use lowercase-hyphenated format. Put that at the end of the feature title in square brackets as a tag (e.g. `[add-french-divisions]`).
5. Add a new entry at the top of `features/PENDING.md` (below its header blurb) with the format:

```
### <Feature title> [tag]

<One or two sentences describing what the feature covers and why.> Detail in [features/plans/<slug>.md](plans/<slug>.md).
```

Keep this entry concise — no implementation detail, no sub-tasks. The full specification goes in the plan file.

6. Always create the plan file `features/plans/<slug>.md` with a `## Requirements` section holding the input, a `## Spec` section holding what the feature must do, a `## Sign-off strategy` section (see step 7), and a `## Design` placeholder that `/feature-design` will flesh out:

```markdown
# <Feature title> — Feature Plan

## Requirements

<the input, captured faithfully — see below>

## Spec

<what the feature must do, written to stand alone against `### Readability` — see below>

## Sign-off strategy

<the quality bar per sign-off category — see step 7>

## Design

*To be fleshed out by `/feature-design`.*

## Review record

<Written by step 8f/9 — one line recording what review happened at this stage.>
```

   (No `## Handoff` section yet — `/feature-design` adds it when it takes the feature into progress.)

   Populate the `## Requirements` section — the input, captured faithfully — as follows:
   - **If the feature came from a GitHub issue:** copy the **entire** issue description verbatim (nothing in it should be assumed irrelevant), then add any comment that bears on design or requirements (e.g. "we should use tool X", "we must ensure Y holds"). Omit comments that are mere reactions or scheduling chatter ("great idea", "let's wait until next month"). Attribute the issue (e.g. "From issue #14 (verbatim):"). The objective is that a later session can pick up the feature from this file alone, without re-reading the issue.
   - **If the user supplied detailed requirements directly:** record them here verbatim or lightly tidied.
   - **If step 2 found requirements material in `features/tmp`:** capture it as follows, according to its type:
     - Markdown or plain-text content — including a document of a couple hundred lines — is copied **inline** into `## Requirements`, lightly tidied but faithful, exactly as issue content is above. Inlining is the default; do not copy a file into the plan directory just because it arrived as a file.
     - Only genuinely un-inlinable artefacts — Word documents, screenshots, other binaries, anything that cannot become plain text without losing information — are instead copied into a new `features/plans/<slug>/` subdirectory and **linked** from `## Requirements` (e.g. `See [wireframe.png](<slug>/wireframe.png).`). This is a narrow, deliberate exception for material that cannot be inlined, not a convenience for large text.
     - Once material is captured this way — inlined or copied into `features/plans/<slug>/` — **delete it from `features/tmp`**, leaving `README.md` in place, so the plan is the only durable copy.
   - **If the user gave only a short description:** record that description here, verbatim, as the input it is. A one-line description is still requirements — the user stated what they wanted, and the feature exists because they said so. Do not write a placeholder saying there are no requirements: that discards the only input there is, and then leaves the spec looking empty to everyone downstream. Note that the description is all that was supplied, so a later reader knows nothing further was said, and let `## Spec` do the work of turning it into a full statement.

   Populate the `## Spec` section — what the feature must do, written to stand alone: clear to a reader with no background on the feature, per the `### Readability` standard defined in `features/FEATUREMODEL.md`. Apply that standard rather than restating it.
   - **Divides labour with `## Requirements`.** `## Requirements` stays the input, captured faithfully above, and is **not** required to meet `### Readability` — reorganising the user's own words to read better is how their meaning gets lost. `## Spec` carries the readability obligation instead.
   - **Clarifies and fills gaps.** It resolves ambiguities in `## Requirements` and fills gaps with explicit proposals, marking each proposal as such (e.g. prefixed "Proposed:") so the user can see exactly what they are being asked to accept, rather than mistaking a proposal for a settled requirement. Where `## Requirements` is complete and unambiguous, `## Spec` overlaps heavily with it — but is still written, and typically goes a little deeper.
   - **Is always written, never a placeholder.** Where `## Requirements` is thin — including the short-description case just above — `## Spec` is still written in full, working out from what the user said and marking as proposals whatever it fills in. A small, well-understood feature can produce a complete spec this way, and there is nothing wrong with that: brevity of input is not a defect to be flagged, only a reason more of the spec is proposal than record.

7. Populate the `## Sign-off strategy` section — the quality bar the feature will be held to, which `/feature-design` later turns into per-sub-task sign-off criteria. The sign-off model — the standard categories, the auditability rule, and the rule that every review sign-off names its performer (agent or user) — is defined in `features/FEATUREMODEL.md` under `### Sign-off criteria`. Apply that model rather than restating or reinventing it. For this feature:

   - Propose a bar for **every standard category**, suited to the feature and its risk: higher-risk or user-facing work warrants stronger testing and review than a small internal change (e.g. Testing: "full automated coverage of new logic" vs "none (prose-only change)"; Code review: "a single agent `/review-branch` before `/feature-end`" vs "user reviews the diff of each sub-task").
   - Choosing *not* to do a category is legitimate, but state it explicitly as "None — <reason>" so the choice is visible and the user can comment on it.
   - Split a category or add a feature-specific sign-off where the work genuinely needs it, per the model; do not invent sign-offs for their own sake.

> Step 8 below is near-identical in `feature-spec` and `feature-design`. If you change the review invocation, the finding-handling rules, the two-invocation cap, the unattended-mode gate, or the `## Review record` format, update both — a silent divergence in the unattended gate is the worst case, since it governs when human sign-off is bypassed. If you add or remove a finding marker, update both agents' `## Output Format` too: the markers are the contract between them.

8. **Have the spec reviewed before the user sees it.** The point is that the user spends their attention on judgement calls, not on catching vagueness an agent can catch.

   a. **Skip only on an explicit instruction.** Check `$ARGUMENTS` for a skip instruction — `--no-review`, "skip review", "no spec review" or similar — and honour the user declining if they raise it while the skill is running. If the review is skipped, go straight to step 9 and say plainly there that it did not run. Absent such an instruction, the review happens.

   b. Call @feature-spec-reviewer with the path of the plan file.

   c. **Act on the findings by their marking, not their severity.** Each finding is marked `[rewrite]` or `[decision]`:
      - `[rewrite]` — fix it yourself in the plan file. These are writing-quality faults: a sign-off criterion that is not auditable, a requirement that defers to the source issue instead of capturing it, implementation detail that belongs in the design.
      - `[decision]` — **do not resolve it by choosing.** Carry it to step 9 as a question for the user. An unresolved question, a contradiction between requirements, or an unstated dependency needs an answer, and a plausible-looking guess is worse than an open question because nobody knows it was made.
      - MINOR and SUGGESTION findings: apply the ones that are clearly right, and mention the rest rather than acting on them. Where one carries a `[decision]` marking, frame it to the user as an observation worth their answer rather than a blocking objection — but note that it still stops an unattended run under 8f, because the gate does not grade questions by severity. A small question is still a question.

      If a finding marked `[decision]` turns out to rest on a fact you can establish rather than a judgement the user must make — the reviewer asks whether there was a source issue and you know there was not, or asks whether a command exists and you can grep for it — establish it and say you did. Do not manufacture a question you can answer. The distinction is judgement versus lookup, not who noticed it.

   d. If your rewrites went beyond minor wording — you restructured a requirement, rewrote a sign-off criterion, or added or removed a section — call the agent once more. **Two invocations per run is the cap** — stop after the second whatever it says, and report anything still outstanding to the user in step 9. Do not spend the second pass when every outstanding finding is `[decision]` and waiting on the user: re-reviewing unchanged questions cannot change the verdict, and the user is the one who has to answer.

   e. Note the final verdict (`READY FOR USER REVIEW` or `NEEDS WORK`) to report in step 9. If the agent fails, returns nothing, or returns findings with no verdict line, treat the result as `NEEDS WORK` and say in step 9 that the review did not complete and why — an absent verdict is not a pass.

   f. **Unattended mode.** If the user has told you to run without checking in — "don't stop for me", "run it unattended", or an autonomy boundary agreed with `dev-process-manager` that covers this stage — then the agent's verdict stands in for their sign-off, but only where it is unambiguous:

      - **Proceed without pausing only if** the final verdict is `READY FOR USER REVIEW` **and** no finding was marked `[decision]`. A finding counts here if the *agent* marked it `[decision]`, even where you settled it by lookup under 8c: establishing a fact records what was true, it does not overturn the reviewer's judgement that the artefact needed an answer. Where every blocking `[decision]` was settled that way, say so plainly when you stop: what you established, that there is nothing for the user to decide, and that you stopped because the reviewer's doubt about the artefact stands.
      - **Otherwise stop and ask**, exactly as step 9 describes. `NEEDS WORK`, or any `[decision]` finding, overrides the instruction to keep going. An autonomy boundary is permission to skip a *routine confirmation*; it is not permission to answer a question that is the user's to answer.
      - **A skipped review cancels unattended mode**: with no review there is no verdict to stand in for the user's judgement, so stop and ask. The two instructions do not compound into "proceed with nothing checked".
      - When you do proceed, say so in your report and on whose instruction, and use the unattended form of the `## Review record` line in step 9.

   If the reviewer contradicts something the user has already settled, say so rather than quietly re-opening it: the user's decision stands, and the finding is worth a sentence, not a rewrite.

   A feature specified from a short description is not blocked for that reason alone. A one-line description is requirements, `## Spec` works out from it, and a small well-understood feature can legitimately reach `READY FOR USER REVIEW` and proceed unattended — the gate exists to stop work no human sanctioned, not to impose a minimum length on the sanction. What blocks such a spec is the same thing that blocks any other: a proposal resting on a judgement the user must make is a `[decision]` finding, and one of those is enough to stop. Do not manufacture a passing verdict by watering the spec down, and equally do not manufacture questions to justify caution about a feature that is simply small.

9. Confirm the new feature and its spec to the user, and **present the proposed sign-off strategy for them to agree or adjust** — this is the user's chance to raise or relax the quality bar before design. Update the `## Sign-off strategy` section to match what they settle on.

   *In unattended mode (step 8f), where the verdict permitted you to proceed, still produce this report — the user reads it after the fact rather than before. What changes is that you do not wait for a reply; what does not change is that they are told everything they would have been told.*

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
