# Add design and spec review agents — Feature Plan

## Handoff

**Last updated:** 2026-07-21
**Session summary:** Feature complete. All five sub-tasks done and user-confirmed; both feature-level sign-offs done — the `/review-branch` (four agents, two convergence iterations, findings applied down to MINOR/SUGGESTION) and the self-application dogfood (recorded in `NOTES.md`, not retro-applied). Two bugs found late and fixed: the `feature-design` step 5 template would have dropped the spec-stage `## Review record` (now preserved), and step 6 taught the un-tickable `- [ ] X: none` placeholder box (now corrected in the skill, root `CLAUDE.md`, and the `feature-init` template). Test fixtures moved to `devproc/tests/<agent>/`.
**Sub-task in progress:** None — closing via `/feature-end`.
**First action next session:** Feature is complete; nothing outstanding.
**Open questions / decisions pending:** None. (System-test items noted in `NOTES.md`: whether unattended `/feature-spec` proceeds usefully in a real repo, and the `[decision]`-blocks-unattended sensitivity.)
**Dead ends to avoid:**
- Do not expect a newly written agent to be invocable as an agent type in the session that created it — see `NOTES.md`. Both agents *are* registered now, so sub-task 3 onwards can invoke them directly.
- Do not expect fixture sections to be fully independent: the first round of expectations forbade *any* finding against the untargeted section, and three of five cases failed on findings that were correct. See `NOTES.md`.
- Do not have the reviewer assert that a named dependency is *absent* when it merely cannot be found: the fixtures describe a product that is not this repository, so absence there proves nothing.

## Requirements

From issue #20, "Add design and spec review agents" (verbatim):

> The feature-spec and feature-design skills generally work quite well, though require careful user review.
>
> This issue covers adding agents to review both spec and design, that should be run at the end of the process, unless the user explicitly skips them. These agents should ensure that:
> - The spec / design is complete and clear
> - The spec makes it clear what the delivery criteria of the design are
> - The spec / design flags any blocking issues that need resolution
>
> The intention is to provide a second pair of "eyes" to catch issues before the human reviewer catches them, allowing either proceeding without human review or a quicker simpler process with less need for human intervention.

The issue has no comments.

## Sign-off strategy

- **Testing** — Manual, against committed test fixtures. Writing the fixtures is part of the work, not a precondition of it: for each new review agent, its sub-task includes authoring a set of test plan files under
  `features/plans/spec-design-review-agents/tests/<agent>/` — one deliberately flawed plan per check the agent makes (completeness/clarity, delivery criteria explicit, blocking issues flagged) plus one clean control — with the findings each fixture should produce recorded up front alongside it. The sub-task passes when the agent reports the recorded findings on each flawed fixture and reports none on the control. Fixtures are committed so the agents stay re-testable when their wording is later changed. No automated test harness — this repository packages prose agent/skill definitions and has none.
- **Documentation** — Full production docs, updated as we go: `devproc/README.md`, the root `CLAUDE.md` plugin contents list, and any `docs/` page describing the feature lifecycle must describe the new agents and the review step in the spec/design flow, including how to skip them.
- **Code review** — A single `/review-branch` before `/feature-end`; no per-sub-task agent review, as the changes are small prose files.
- **User review** — The user reviews and confirms each new agent definition and each skill edit before the sub-task is marked complete, since the wording *is* the deliverable.
- **Self-application** — The new spec-review agent is run against this feature's own plan file, and its findings addressed, before `/feature-end`.

## Design

### Two agents, not one

Add two sub-agents to the `devproc` plugin, following the existing reviewer
pattern (`docs-structure-reviewer`, `code-review-*`): findings only, no file
modification.

- `feature-spec-reviewer` — reviews a plan file's `## Requirements` and
  `## Sign-off strategy` sections.
- `feature-design-reviewer` — reviews the same file's `## Design` and
  `## Sub-tasks` sections (reading Requirements and Sign-off strategy as
  context, but not re-reviewing them).

A single parameterised agent was considered and rejected: the two artefacts are
checked against genuinely different criteria, and every existing reviewer in
this plugin is narrow and single-purpose. Two focused prompts stay sharper than
one prompt with a mode switch, at the cost of some duplicated boilerplate.

Naming follows the artefact each reviews (`feature-spec-reviewer` pairs with the
`feature-spec` skill), matching `docs-structure-reviewer`'s "what it reviews"
convention.

Configuration for both: `tools: Glob, Grep, Read` (the design reviewer needs to
read the codebase to judge feasibility, and both need to read the plan file);
`model: inherit`, as `docs-structure-reviewer` does, so a manager-driven Opus
session gets Opus-quality review; no agent memory (the review is about a single
artefact, not accumulated project knowledge).

### What each agent checks

Both derive from the three checks in the issue — complete and clear, delivery
criteria explicit, blocking issues flagged.

`feature-spec-reviewer`:

- **Complete and clear** — is it unambiguous what the feature must do? Are
  requirements captured from the source issue rather than summarised away? Would
  a fresh session be able to work from this file alone?
- **Delivery criteria** — does the sign-off strategy cover every category, is
  each entry *auditable* (a clear yes/no at sub-task end), and is every skipped
  category explicitly justified rather than silently absent?
- **Blocking issues** — are there unresolved questions, contradictions, or
  unstated dependencies that must be settled before design can start? These are
  the findings the human most needs surfaced.
- **Scope discipline** — does the spec state *what* without prematurely fixing
  *how*?

`feature-design-reviewer`:

- **Complete and clear** — does the design address every requirement (an
  explicit requirement-to-sub-task trace), and record the key decisions *and
  their rationale*, not just the outcome?
- **Delivery criteria** — does every sub-task carry sign-off criteria derived
  from the agreed strategy, is each criterion auditable, and does the set of
  sub-tasks actually deliver the feature when all are ticked?
- **Blocking issues** — unresolved design questions, infeasible steps, missing
  dependencies, or sub-tasks that cannot be completed in the stated order.
- **Sub-task quality** — right granularity, correct ordering, no sub-task that
  is really three.

### Output format and verdict

Both follow the house findings format (`**[SEVERITY]** location` / Issue /
Detail / Recommendation), with severities tuned to the artefact:

- **BLOCKING** — must be resolved before the next lifecycle stage begins.
- **MAJOR** — will cause rework or confusion if unaddressed.
- **MINOR** — worth fixing but not obstructive.
- **SUGGESTION** — improvement, not a defect.

Each agent ends with an explicit one-line verdict — `READY FOR USER REVIEW` or
`NEEDS WORK` — so the calling skill has an unambiguous signal to report, which
is what makes "proceed with lighter human review" a decision rather than a
guess.

### Where the review runs in the flow

The issue asks for the review "at the end of the process". It runs after the
artefact is written but *before* it is presented to the user — that is what
delivers the stated intention of catching issues before the human does.

- `/feature-spec`: new step between writing the sign-off strategy (current step
  6) and presenting to the user (current step 7).
- `/feature-design`: new step between writing the sub-task criteria (current
  step 6) and presenting to the user (current step 7).

The calling skill addresses BLOCKING and MAJOR findings itself where they are a
matter of writing quality (vagueness, non-auditable criteria, a missing trace),
then presents the artefact to the user together with a short summary of what the
review changed and any finding that needs a *decision* rather than a rewrite.
Findings that require user input are surfaced as questions, not silently
resolved.

One re-review pass is allowed if the changes were substantial, giving a hard cap
of two reviewer invocations per skill run. After the second pass the skill stops
regardless of what the review says, reporting any remaining findings to the
user. This is deliberately simpler than the `docs-structure-reviewer` loop in
`/feature-end`, which keeps calling the agent and compares finding counts
between rounds to check it is converging: an artefact this small does not
warrant that, and a fixed cap is cheaper and more predictable.

### Review and human-review modes

There are three modes, not an on/off switch. The issue asks for both "a quicker
simpler process" *and* "proceeding without human review", which are different
things: the first keeps the human in the loop over a cleaner artefact, the
second uses the agent review in place of the human's.

- **Reviewed (default)** — the agent reviews, the skill addresses what it can,
  and the artefact is presented to the user with a summary of what changed and
  any question the review raised. The user still signs off.
- **Review skipped** — on an explicit instruction (`--no-review`, "skip review",
  "no spec review", or declining when the skill offers), no reviewer runs and
  the artefact goes straight to the user.
- **Unattended** — on an explicit instruction ("don't stop for me", "run the
  full process without checking in", or a `/feature-design` invoked inside an
  agreed autonomy boundary), the agent review *is* the sign-off. The skill
  proceeds to the next stage without pausing **only** if the final verdict is
  `READY FOR USER REVIEW` and no finding requires a user decision. On
  `NEEDS WORK`, or on any finding that is a genuine question rather than a
  writing fix, the skill stops and asks regardless of the instruction — the
  autonomy boundary never overrides a blocking finding.

Unattended mode is where the verdict line earns its keep: it is the criterion
that decides whether the run may continue, so it must be unambiguous.

Whichever mode ran is stated plainly in the skill's final report, so a skipped
or agent-only review is as visible as a skipped sign-off category. In
unattended mode the plan file also records that the artefact was accepted on an
agent verdict without human sign-off, so a later session (or a later
`/feature-checkpoint`) can see which artefacts a human has actually read.

This lives in the skills rather than only in `dev-process-manager`, so it works
when the user drives the workflow directly. The manager's autonomy boundary then
composes with it naturally: "work through the feature unattended" implies
unattended mode for the skills it invokes, and the manager's existing rule of
pausing at requirement/design decisions is exactly the `NEEDS WORK` case. The
`dev-process-manager` definition is updated to say so rather than leaving it
implicit.

### Test fixtures

Fixtures live under `devproc/tests/<agent>/`, one directory per agent (moved
there at `/feature-end` from `features/plans/spec-design-review-agents/tests/`,
on the branch code review's recommendation — they are durable assets of the
agents, not of this feature, and `features/plans/` is the flat plan-file
namespace). Each test case is a pair:

- `<case>.md` — a plan file exhibiting exactly one deliberate flaw (or none, for
  the control).
- `<case>.expected.md` — the findings the agent must report on it, with
  severities.

Cases per agent: one per check (completeness/clarity, delivery criteria,
blocking issues) plus a `control` case that is clean. A case passes when the
agent reports its recorded findings and the control produces none at BLOCKING or
MAJOR severity. Fixtures are committed so the agents remain re-testable when
their wording is later changed.

Note the fixtures sit in a *subdirectory* of `features/plans/`, so they are not
picked up by the flat `features/plans/<slug>.md` convention; each fixture file
also carries a header line marking it as a test fixture, so it cannot be
mistaken for a real feature plan.

### Documentation

`devproc/README.md` gains a row and an agent-reference section per agent, and
its `feature-spec` / `feature-design` entries note the review step.
`docs/workflow.md` describes the review in the Specify and Design sections, and
the three modes above. The root `CLAUDE.md` plugin contents list gains both
agents. The `dev-process-manager` agent definition is updated so a
manager-driven session knows the reviews happen inside the skills it invokes and
that an agreed autonomy boundary selects unattended mode.

## Sub-tasks

1. ✓ **Write the `feature-spec-reviewer` agent** (2026-07-20) — agent definition plus its test fixtures, establishing the fixture layout that sub-task 2 follows
   - [x] Testing: fixture set written under `features/plans/spec-design-review-agents/tests/feature-spec-reviewer/` (one flawed case per check, plus a clean control, each with a recorded `.expected.md`); agent run against every fixture reports the recorded findings and reports no BLOCKING or MAJOR finding on the control
   - [x] Documentation: `devproc/README.md` contents row and agent-reference section added for this agent
   - [x] User review: user has read and confirmed the agent definition
2. ✓ **Write the `feature-design-reviewer` agent** (2026-07-20) — agent definition plus its test fixtures, following the layout from sub-task 1
   - [x] Testing: fixture set written under `features/plans/spec-design-review-agents/tests/feature-design-reviewer/` on the same terms; agent run against every fixture reports the recorded findings and reports no BLOCKING or MAJOR finding on the control
   - [x] Documentation: `devproc/README.md` contents row and agent-reference section added for this agent
   - [x] User review: user has read and confirmed the agent definition
3. ✓ **Wire the review step into the skills** (2026-07-20) — add the review invocation, the finding-handling rules, and the skip instruction to `feature-spec` and `feature-design` (reviewed and skipped modes; the human still signs off in both)
   - [x] Testing: both modes verified by invoking each skill — reviewed (reviewer runs, findings are addressed or surfaced, artefact is presented to the user) and skipped (no reviewer runs, and the report says the review was skipped)
   - [x] Documentation: `devproc/README.md` `feature-spec` and `feature-design` reference entries updated to describe the review step
   - [x] User review: user has read and confirmed both `SKILL.md` diffs
4. ✓ **Add unattended mode** (2026-07-20) — verdict-gated auto-proceed in both skills, plus the plan-file record of an artefact accepted without human sign-off
   - [x] Testing: verified on both skills that unattended mode proceeds without pausing on `READY FOR USER REVIEW`, stops and asks on `NEEDS WORK` and on any finding needing a decision, and records the absence of human sign-off in the plan file
     - Nine runs. Design proceeded on READY with zero `[decision]` findings and wrote the record correctly; both skills stopped on `NEEDS WORK`; both stopped on a `[decision]` despite a READY verdict; skip+unattended stopped; and the always-write `## Review record` change was verified on the skipped-spec and attended-design paths.
     - One clause is verified by shared rule text rather than observation: **proceed-on-READY for `/feature-spec`**. Two attempts with deliberately thorough descriptions both reached READY but each carried one legitimate `[decision]`, so the proceed branch was never taken. The user accepted this on 2026-07-20, to be settled in system test.
   - [x] Documentation: `devproc/README.md` entries updated to describe unattended mode and its verdict gate
   - [x] User review: user has read and confirmed both `SKILL.md` diffs
5. ✓ **Cross-cutting documentation** (2026-07-20) — `docs/workflow.md` Specify and Design sections, root `CLAUDE.md` contents list, and the `dev-process-manager` agent definition
   - [x] Documentation: workflow guide describes the review and all three modes; root `CLAUDE.md` lists both agents; `dev-process-manager` notes the reviews run inside the skills it invokes and that an agreed autonomy boundary selects unattended mode
   - [x] User review: user has read and confirmed the documentation changes

**▶ NEXT:** All sub-tasks complete — feature-level sign-offs, then `/feature-end`.

> Run `/feature-checkpoint` after each sub-task completes.

## Review record

This plan predates the skills that write this section, so its lines are added by
hand. The feature-level reviews were run at `/feature-end` rather than per stage.

- 2026-07-21 — Spec self-application (dogfood): `feature-spec-reviewer` run over this plan. VERDICT: NEEDS WORK — findings recorded in `NOTES.md` ("Dogfooding: run the reviewers at spec/design time") rather than retro-applied, as the spec is already shipped. This *was* the sign-off, not a task to fix.
- 2026-07-21 — Branch code review (`/review-branch`, feature-level): simplicity, general, nitty and architectural agents over the whole branch, two convergence iterations; code-level findings applied, converging to MINOR/SUGGESTION. Architectural finding to relocate the test fixtures to `devproc/tests/<agent>/` accepted and applied.
