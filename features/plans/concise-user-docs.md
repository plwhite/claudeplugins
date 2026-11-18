# Claude written docs are often rather verbose — Feature Plan

## Handoff

**Last updated:** 2026-11-18
**Session summary:** Feature complete; closed by `/feature-end` on 2026-11-19.
**Sub-task in progress:** None
**First action next session:** None — feature closed. The user plans a `/review-docs full` over this repository next.
**Open questions / decisions pending:** None
**Dead ends to avoid:** None

## Requirements

From issue #79 (verbatim):

> It's often the case that Claude writes docs (user docs, not NOTES.md or CLAUDE.md) that are comprehensive, but overlong and repetitive.
>
> The intention here is just to restrict this, most likely by tweaking the various docs review skills / agents but perhaps in other ways (such as a new skill, or some more information on what good docs look like).
>
> The general principles used by the docs review agents are good but:
>
> 1. If there is a way of saying something in fewer words that is in general clearer. Long complex sentences are fine where they are necessary, but shorter and simpler is better.
>
> 2. Don't put in information that is not required.
>
>     - If it isn't necessary, miss it out. For example, historical information or why things work that way is not necessary in a "how to do" guide. Similarly, how to do something is not appropriate in an architecture or design guide (it's fine to say "this is done using command line tools" or something, but repeating the list of instructions is not helpful).
>
>     - If it is in the code and is only useful to somebody reading the code, miss it out. For example, a list of "these are the 12 AWS resources created" isn't usually helpful; somebody who cares can just look at the template. A list of "these are the 2 or 3 that matter for the purpose being described" is perfectly fine. There is clearly a balance here. "These are the 9 checks that this tool does as single summary items" is perhaps reasonable in an ops guide (if the operator might want to know).
>
> 3. Try not to have the same information in multiple places. The architecture guide for example has a tendency to acquire information that duplicates information from other documents.

The issue has no comments.

## Spec

### What this feature is for

User docs — `README.md` and every document reachable from it, as defined in `features/FEATUREMODEL.md` under `### Sign-off criteria` — are written by Claude during feature work and checked by `/review-docs`. That skill runs four review agents in `devproc/agents/`: `docs-review-architectural` (structure of the doc set), `docs-review-accuracy` (docs match the code), `docs-review-style` (how docs read) and `docs-review-agent-docs` (agent docs). The docs this produces are usually correct and complete but too long: wordy sentences, material the reader of that document does not need, and the same facts repeated across documents.

The current review criteria do not push back on this. The style agent flags overlong sentences only "in critical paths, where length obscures the meaning"; the architectural agent flags "content a user does not need" only as development history or maintenance detail, and its one-source-of-truth check is not aimed at the places duplication actually collects.

This feature makes **concision** an explicit standard for user docs: say things in as few words as stays clear, include only what the document's purpose needs, and keep each fact in one place. The review agents check against it, and (proposed) the standard is also available to Claude when it writes docs, so verbosity is prevented rather than only caught afterwards.

Terms used below:

- A document's **purpose** is the kind of reader question it answers: a **how-to guide** (procedures: how to do something), an **architecture or design guide** (how the thing is built and why), a **reference** (lookup of options, commands, settings), or an **overview** such as a `README.md` landing page. A document may mix these, section by section.
- **Code-derivable detail** is detail a reader could get from the code or configuration itself, and that matters only to someone working on that code — for example the full list of resources a template creates.

### What must be true when it is done

#### 1. Wordiness is a review finding

The style review flags prose that could say the same thing in fewer words without losing clarity, wherever it occurs, not only where length obscures meaning. A long or complex sentence is not a finding where it is the clearest way to say something that genuinely needs it; the test is whether a shorter version would be at least as clear.

- *Proposed:* the finding is owned by `docs-review-style`, under its Clarity criterion, and its recommendation gives the shorter wording.
- *Proposed:* severity follows the confusion or effort caused, like other clarity findings: a paragraph a reader must wade through to find the point can be MAJOR; a single padded sentence is MINOR.

#### 2. Content is held to the document's purpose

*Amended 2026-11-19, with the user's approval:* every document has a purpose that can be stated in one line (e.g. `docs/capabilities.md`: a comprehensive summary of what the plugin does), and everything in it must serve that purpose. The review states each document's purpose and checks its content against it. The examples below are illustrative, not exhaustive; implementation detail in a capabilities summary is another.

Original text: the review flags content that the document's purpose does not need. At minimum:

- history, or explanation of why things work the way they do, in a how-to guide (a short reason for a non-obvious step, which the style agent already requires, stays);
- step-by-step instructions in an architecture or design guide, where a one-line statement of how something is done (e.g. "this is done with the command-line tools") and a link to the how-to guide would serve.

*Proposed:* owned by `docs-review-architectural`, extending its existing "Completeness and Relevance" criterion, since the fix moves or removes content rather than rewording it. The recommendation says whether the content should go, or move to a document whose purpose it fits.

#### 3. Code-derivable detail is left to the code

The review flags code-derivable detail that a reader of the document does not need. Exhaustive enumerations are the usual case (e.g. "these are the 12 resources created"); the recommendation is to keep only the few items that matter for what the document is describing, or none. This is a judgement: an enumeration stays where the document's reader plausibly needs every item — for example a one-line-per-item list of the checks a tool makes, in a how-to or reference guide for the person running the tool.

*Proposed:* owned by `docs-review-architectural` alongside requirement 2. *Proposed:* the agent states in the finding why it judged the reader does not need the detail, so the user can overrule it.

#### 4. Duplication across documents is actively looked for

The review searches for the same information stated in several user docs, not just reports duplication it happens to notice. Architecture and design guides, and overview documents such as `README.md`, are checked specifically against the documents they summarise, because that is where duplication collects. The recommendation names the document that should own the fact and replaces the copies with a short statement and a link.

*Amended 2026-11-19, with the user's approval:* the owner may also be a file in the repository's code (for example `devproc/skills/feature-init/FEATUREMODEL.md`, which ships with the plugin): a user doc links to it rather than restating it. Files under `features/` are transient and are never owners or link targets.

A brief summary that links to the document owning the detail is not duplication; restating detail that the linked document holds is. In `change` scope, the changed user docs are checked against the whole user-doc set; in `full` scope, every user doc is.

*Proposed:* this extends `docs-review-architectural`'s existing "One Source of Truth" criterion; it does not create a new owner.

#### 5. Removing content is not applied silently

`/review-docs` auto-applies minor findings and escalates significant ones (its Step 5). For concision findings:

- *Proposed:* tightening wording within a sentence or paragraph, keeping all its information, is **minor** and auto-applied.
- *Settled by the user at `/feature-spec`:* removing a duplicate is **minor** and auto-applied when the information is kept, in full, in a document that is clearly its right owner, and the copy is replaced by a short statement and a link (or simply deleted, where a link already exists). If there is any doubt about where the information should live, or how much of it belongs in each document, the finding is **significant**.
- *Proposed:* any other removal of information — a sentence that carries a fact, a list, a paragraph or a section — or moving information to another document, is **significant** and escalated to the user. This follows the skill's existing rules (rewriting a section and changing how information is divided between docs are already significant); it is stated here because concision findings will make such removals frequent.

#### 6. The standard is available when docs are written

*Settled by the user at `/feature-spec`:* in scope — getting docs right when they are written leaves review less to do. The concision standard (requirements 1–4, stated as positive guidance on what good user docs look like) is written down once, in a place Claude reads when it writes user docs. *Proposed:* that means whenever Claude writes user docs in a project using `devproc`, whether or not a feature is in progress. The review agents apply that same standard rather than drifting from it. Where it lives is left to `/feature-design`, which must handle `/review-docs` being run in a project that has not run `/feature-init`. This responds to the issue's "some more information on what good docs look like".

#### 7. User docs describe the new checks

`docs/capabilities.md` (section "Documentation review") and `devproc/README.md` (the `review-docs`, `docs-review-architectural` and `docs-review-style` entries) describe what the agents now check, and where the standard from requirement 6 lives. `CLAUDE.md`'s one-line agent descriptions are updated if they no longer match.

### Out of scope

- Agent docs (`CLAUDE.md`, `NOTES.md`, `.claude/rules/*.md`). Their bloat is handled by `/internal-docs-prune`, and the issue excludes them.
- Feature records under `features/`, and skill and agent prompts, which `/review-docs` never reviews.
- Rewriting this repository's existing user docs to the new standard. *Proposed:* that is a separate, later run of `/review-docs full`, not part of this feature, so that this feature's diff stays reviewable.
- A new skill dedicated to concision. *Proposed:* not needed; the existing `/review-docs` already runs the right agents.

## Sign-off strategy

The change is prose-only: agent prompts, possibly a skill prompt and a shared standard, user docs, and the `/review-docs` test fixture. There is no executable code. The main risks are that the agents miss the new faults, or over-apply them — cutting information a reader needs, or flagging a necessary long sentence or a useful list.

- **Testing.** Skills and agents load from the installed plugin copy at `/home/claude/claudeplugins/devproc/`, not from this repository (see `NOTES.md`), so that copy is refreshed from the repository and confirmed identical with `diff -r` before testing. The `/review-docs` suite in `tests/devproc/review-docs/` is then extended and run by hand per its `README.md`:
    - one planted fault for each of requirements 1–4 (a wordy passage, history in a how-to guide or a procedure in an architecture guide, an exhaustive code-derivable list, and a fact duplicated in an architecture guide), each with its expected handling under requirement 5 recorded in the suite's fault table and pass rule;
    - one control per exception in requirements 1–4, none of which the agents may flag: a necessary long sentence (*amended with the user's approval: accepted untested, see sub-task 5's notes*), a short reason for a non-obvious step in a how-to guide, a short list a reader of that document needs, and a brief summary in an overview or architecture guide that links to the document owning the detail;
    - a second planted duplicate whose rightful owner is genuinely unclear, which must be escalated as significant rather than applied (the other side of requirement 5's settled boundary);
    - the suite is run at least once in a workspace where the standard's normal location is absent, and the concision faults are still flagged;
    - every pass rule item, old and new, passes. The result is recorded in the sub-task's notes in this plan file.
- **Documentation.** Full: the user docs named in requirement 7 are updated, plus `CLAUDE.md` if its agent bullets are affected, and the canonical `FEATUREMODEL.md` pair if requirement 6's standard is placed there; the standard itself is written to the same bar as the docs it governs.
- **Code review (agent).** One `/review-branch` over the whole change before `/feature-end`. The change is prose, so a per-sub-task review would cost more than it catches.
- **Docs review (agent).** One `/review-docs` over the change, all kinds, before `/feature-end`: accuracy and style because user doc prose changes; architectural because the review kinds are described in several documents that must agree; agent docs because `CLAUDE.md` describes the docs review agents.
- **User review.** Before `/feature-end`, the user reads the changed review criteria and the written standard, and the recorded test results, and confirms the agents now push back on verbosity as they intended.

## Design

### Overview

The concision standard is written once, as a new `### User docs` section of the feature model. Its canonical copy is `devproc/skills/feature-init/FEATUREMODEL.md`, which `/feature-init` copies to `features/FEATUREMODEL.md`. `CLAUDE.md` imports that file, so every session in a project using `devproc` has the standard in context while it writes docs (requirement 6). The section states requirements 1–4 as positive guidance: few words, only what the document's purpose needs, no code-derivable detail, each fact in one place. It also defines the terms the spec defines (document purpose, code-derivable detail).

At review time, `/review-docs` reads the same section from the plugin's own canonical copy, not from the project, and passes its text to `docs-review-style` and `docs-review-architectural` in their prompts. Each agent gains a criterion that applies its part of the standard. The style agent owns wordiness (requirement 1). The architectural agent owns purpose, code-derivable detail and duplication (requirements 2–4), extending its existing "Completeness and Relevance" and "One Source of Truth" criteria. The agents carry a pointer to the standard and their share of it, not a copy, so the standard cannot drift between writing and review.

`/review-docs` Step 5 gains requirement 5's classification rules: tightening wording is minor; removing a duplicate is minor only where the owner is clear; any other removal or move is significant.

Finally, the `/review-docs` test suite gains planted concision faults and controls, and the user docs describe the new checks and where the standard lives.

### Where the standard lives

We put it in `FEATUREMODEL.md`, not in a separate shipped file with its own `CLAUDE.md` import. `FEATUREMODEL.md` already has an install-and-import route (`/feature-init`), already holds a comparable standard (`### Readability`, for specs and designs), and already defines user docs (under `### Sign-off criteria`, Docs review). A separate file would need a second copy step in `/feature-init`, a second import line in every consumer's `CLAUDE.md`, and a second "edit the canonical copy, then re-run `/feature-init`" rule, for no gain.

This reaches every project that has run `/feature-init`, which is how a project takes up the `devproc` feature workflow. A project that uses the plugin's review skills without `/feature-init` gets no writing-time guidance; `/review-docs` is its only safeguard (see below). *Settled by the user at `/feature-design`:* that gap is acceptable — the plugin is of little use without `/feature-init`.

The cost is a few dozen lines in every session's context. That is what makes the standard effective at writing time, which the user chose in requirement 6. The section is kept short, and is itself written to the standard.

### How review reaches the standard without `/feature-init`

`/review-docs` may run in a project that has never run `/feature-init`, so it cannot rely on `features/FEATUREMODEL.md`. A skill is told its own base directory when invoked, and `review-docs` and `feature-init` ship in the same plugin. So `/review-docs` reads `<its base directory>/../feature-init/FEATUREMODEL.md` and extracts the `### User docs` section. Reading the plugin copy rather than the project copy also keeps the standard in step with the agents, even in a project whose `features/FEATUREMODEL.md` is stale.

If that file cannot be read, `/review-docs` says so in its report and runs the agents without the standard; the agents then report that the concision checks were not run, rather than improvising them. A missing file means a broken install, so we surface it rather than carry a fallback copy that would drift.

An agent invoked directly, without `/review-docs`, looks for the standard in its prompt, then in `features/FEATUREMODEL.md`. Failing both, it says the concision checks were not run. An agent has no base directory to locate the plugin copy, so it accepts the risk of a stale project copy; `/review-docs` is the supported route.

### Agent changes

- **`docs-review-style`**, criterion 2 (Clarity): a new item flags prose that the standard's wordiness rule says could be shorter and at least as clear. The recommendation gives the shorter wording. Severity follows the reader's effort, as for other clarity findings. The existing "overly long sentences … in critical paths" bullet stays as it is, so a run without the standard checks no less than today; the new item is the broader rule when the standard is present.
- **`docs-review-architectural`**, criterion 8 (Completeness and Relevance): adds content outside the document's purpose (requirement 2) and code-derivable detail (requirement 3). Each finding says why the reader does not need the content.
- **`docs-review-architectural`**, criterion 5 (One Source of Truth): adds the active search of requirement 4 — in `change` scope, changed user docs against the whole user-doc set; in `full` scope, every user doc — with architecture guides and overviews checked specifically. A brief summary that links to the owner is not duplication. Each duplication finding says whether the owner is clear, so `/review-docs` can classify it under requirement 5.

### `/review-docs` changes

- **Step 4** reads the standard as described above and passes it to the style and architectural agents. The accuracy and agent docs agents do not need it. Step 7's re-runs pass the same text read in Step 4.
- **Step 5** adds requirement 5's rules to its minor and significant lists. Removing a clear-owner duplicate is stated as an explicit exception to the existing rule that changing how information is divided between docs is significant; without that, the two rules contradict each other and "when in doubt" would quietly cancel the user's settled boundary. A duplication finding counts as clear-owner only when the agent says so; otherwise it is significant.

### Rejected options

- **Agents carry their own copy of the criteria.** Simplest, but the feature model and the agents would then hold two copies that drift apart, which requirement 6 rules out.
- **`/review-docs` reads the project's `features/FEATUREMODEL.md`.** It does not exist in projects without `/feature-init`, and may be stale in those that have it.
- **A new concision agent.** The checks fit the existing agents' remits, and the spec places a new skill out of scope.

## Sub-tasks

**▶ NEXT:** N/A — feature complete.

> Run `/feature-checkpoint` after each sub-task completes.

Sub-tasks 2 and 3 change agent and skill prompts, which are code, not docs; their single box records the prompt edit, and the edits are verified by sub-task 5's suite run and the final `/review-branch`. Code review, the change-wide docs review and the final user review are end-of-feature gates (see `## Sign-off strategy`), so they appear only in sub-task 6. Skills and agents load from the installed plugin copy, so every test below starts with the **Refresh steps** in `tests/devproc/review-docs/README.md`: rsync the repository's `devproc/` to `/home/claude/claudeplugins/devproc/`, then confirm `diff -r` prints nothing.

### 1. Write the user docs standard ✓ (2026-11-18)

Add a `### User docs` section to the canonical `devproc/skills/feature-init/FEATUREMODEL.md`, stating requirements 1–4 as guidance, and install it in this repository.

- [x] Documentation: `### User docs` written in the canonical `FEATUREMODEL.md`, covering requirements 1–4 and the terms they rely on
- [x] Docs review (user): user confirms the standard's wording before the agents are changed to apply it (docs-first)
- [x] Testing: after the Refresh steps, `/feature-init` re-run in this repository from the CLI (`claude -p "/feature-init"`, per `NOTES.md`), and `diff devproc/skills/feature-init/FEATUREMODEL.md features/FEATUREMODEL.md` prints nothing

### 2. Teach the review agents the standard ✓ (2026-11-18)

Add the concision criteria to `docs-review-style` (requirement 1) and `docs-review-architectural` (requirements 2–4), including the behaviour when no standard is available, as set out under `### Agent changes`.

- [x] Prompts updated: each agent's criteria point to the standard and name its share, and cover the no-standard behaviour; neither agent carries a copy of the standard's text

### 3. Pass the standard and classify removals in `/review-docs` ✓ (2026-11-18)

Step 4 reads `### User docs` from the plugin copy of `FEATUREMODEL.md` and passes it to the style and architectural agents; Step 5 gains requirement 5's rules.

- [x] Prompt updated: Steps 4 and 5 of `devproc/skills/review-docs/SKILL.md` changed as under `### /review-docs changes`, including the report line when the standard cannot be read, and Step 5 stating the clear-owner duplicate rule as an explicit exception to the "changing how information is divided between docs" rule

### 4. Describe the new checks in the user docs ✓ (2026-11-18)

Update the user docs named in requirement 7, and `CLAUDE.md`'s agent bullets if they no longer match.

- [x] Documentation: `docs/capabilities.md` ("Documentation review") and `devproc/README.md` (`review-docs`, `docs-review-architectural`, `docs-review-style`) describe the concision checks, requirement 5's handling, and where the standard lives, including that writing-time guidance reaches only projects that have run `/feature-init`
- [x] Documentation: `CONTRIBUTING.md` ("Changing the feature model"), `CLAUDE.md`'s bullets, and every description of what `FEATUREMODEL.md` contains (including `devproc/README.md`'s `features/FEATUREMODEL.md` row) checked, and updated or recorded as needing no change in this sub-task's notes

    Notes:
    - `docs/capabilities.md`: new `### Concision checks` section (owner of the detail); applied and escalated lists gain requirement 5's cases.
    - `devproc/README.md`: `review-docs`, `docs-review-architectural` and `docs-review-style` entries and table rows updated as brief summaries linking to `capabilities.md`; the `features/FEATUREMODEL.md` row now names the readability and user docs standards. The `feature-init` descriptions say only that it copies the model, so need no change.
    - `CONTRIBUTING.md` ("Changing the feature model"): one sentence added, that `/review-docs` reads `### User docs` from the canonical copy.
    - `CLAUDE.md`: agent bullets for the architectural and style agents and the `review-docs` bullet updated; the `## Feature model` sentence was also edited, but the manager reverted it as a fix in passing: it is the literal import line `/feature-init` writes (its step 1c), so changing it here would drift from the canonical text every consumer gets; the generic "lifecycle, sign-off criteria, and the documents that support it" still covers the new section.
    - Checked, no change needed: `README.md` (describes `docs/workflow.md` and `devproc` only in general terms), `docs/workflow.md` (mentions the model's readability and sign-off sections by name; no contents list), `docs/capabilities.md` line on `features/` records.

### 5. Extend and run the `/review-docs` test suite ✓ (2026-11-18)

Plant the concision faults and controls in `tests/devproc/review-docs/fixture/change/`, record them in the suite README, and run the suite.

- [x] Testing: fixture extended with every fault and control listed in `## Sign-off strategy` → Testing, laid out as follows. Each is in a changed doc, since the style agent reviews only changed docs. `README.md`, `docs/design.md` and `bin/cleanup.sh` stay unchanged, so pass rule items 2, 3 and 5 keep their meaning.
    - A new untracked `docs/architecture.md`, linked from the changed `docs/config.md` so it is reachable without touching `README.md`, carries the architecture-guide faults (step-by-step install instructions; a fact duplicated in full from `docs/usage.md`, a clear owner) and the control of a brief summary that links to its owner.
    - `docs/architecture.md` also carries the exhaustive code-derivable list.
    - The changed `docs/help.md` carries the wordiness fault and the history-in-a-how-to fault.
    - The changed `docs/setup.md` carries the controls of a necessary long sentence, a short reason for a non-obvious step, and a short list the reader needs.
    - The existing installation-prefix duplicate (pass rule item 7) becomes the unclear-owner duplicate: `docs/setup.md` and `docs/config.md` are revised so each holds a different, overlapping slice of the prefix detail, so neither is clearly the owner and the finding is escalated under the new rule, not just the old one.
    - The fixture has no `features/FEATUREMODEL.md`, so every run covers the "normal location absent" case.
- [x] Testing: the suite README's fault table and pass rule gain one item per new fault and control; the fault table records why the prefix duplicate's owner is unclear; item 5's orphan expectation and item 7 are revised for `docs/architecture.md` and the reworked prefix duplicate
    - Interim result (2026-11-18, three runs, scratch transcripts under `/tmp/tmp.*/review-docs.jsonl`, latest in `/tmp/tmp.aTNqhzD1LZ/`): run 1 failed items 7 and 18 (and 13, whose steps duplicated `setup.md`) because the fixture was ambiguous, not the prompts; run 3 passed items 1-17 (item 7 escalated as unclear owner; 13, 15, 17 escalated; 14 and 16 applied) but item 18 failed: the agents rewrote the weak controls (a long sentence that was not necessary, a two-item list, a link). The controls were then replaced with tighter ones.
    - Run 4 (2026-11-18, transcript `/tmp/tmp.FRO5ix6j39/review-docs.jsonl`): items 1-17 pass (7 escalated as unclear owner, `PREFIX` "owner clear" no longer stated; 13, 15, 17 escalated; 14, 16 applied; hashes match). Item 18: step 1's short reason, the checklist and the linked summary were not flagged on their exception grounds, but the long-sentence control (`docs/config.md`, the `GREET_LANG` sentence) was flagged by `docs-review-style` as a MINOR wordiness finding ("convoluted"; shorter wording given) and applied. Not re-tuned, per the manager: reported as evidence about the wordiness criterion. 
    - Run 5 (2026-11-18, transcript `/tmp/tmp.*/review-docs.jsonl`, the latest scratch directory; Refresh steps done, `diff -r` clean, fresh `claude -p`): **all items 1-18 pass.** Items 1-6, 8-12 as before (all four agent types invoked; hashes match). Item 7 escalated (`PREFIX` duplicate, both sections still present). Items 13, 15, 17 escalated; 14 (clear-owner duplicate, replaced by a link) and 16 (wordiness tightened) applied. Item 18: the run-4 long-sentence control was replaced with a precedence sentence for `PREFIX` in `docs/config.md`, which was left untouched; the step 1 reason and the linked summary were not flagged, and the checklist was only moved (placement). The run-4 failure was a weak control (the agent's rewrite was better), not prompt over-application.
    - The cannot-read-the-standard path is verified only by `/review-branch`, not by this suite.
    - Manager review (2026-11-18): the first box is unticked. The strategy and this box call for a *necessary long sentence* control; the run-5 replacement ("It comes from the `make` command line, else the environment, else the default `/usr/local`.") is short, so requirement 1's long-sentence exception is not actually tested. The user accepted this coverage (2026-11-18): the long-sentence exception is not directly tested; runs 3 and 4 showed the agent tightening only sentences that genuinely could be clearer.
- [x] Testing: after the Refresh steps, the suite run per its README in a fresh `claude -p` session passes every pass rule item, old and new; the result is recorded in this sub-task's notes, which also record that the cannot-read-the-standard path is verified only by `/review-branch`

### 6a. Generalise the standard and fix what the review missed ✓ (2026-11-19)

Added 2026-11-19 at the user's final review, which found `docs/capabilities.md` § Concision checks restating `devproc/skills/feature-init/FEATUREMODEL.md`, wordy, and carrying implementation detail: purpose-first rule in the standard, code files as duplication owners, wordiness introduced by a fix treated as a regression, and the section rewritten.

- [x] Documentation: `### User docs` rewritten in the canonical `FEATUREMODEL.md` — a purpose-first rule (every doc has a one-line purpose; everything in it serves that purpose) with non-exclusive examples, and "each fact in one place" extended to link to the repo's code rather than restate it
- [x] Docs review (user): user confirms the standard's wording before anything applies it (docs-first)
    - 2026-11-19: confirmed after the user's changes: purpose *and audience*, stated at the top of a doc unless obvious; code-held information left out unless the audience needs it (softened from "link, never restate"); "plausibly" restored; "for the purpose of the doc" added by the user.
- [x] Testing: after the Refresh steps, `/feature-init` re-run from the CLI and `diff devproc/skills/feature-init/FEATUREMODEL.md features/FEATUREMODEL.md` prints nothing
- [x] Prompts updated: `docs-review-architectural` states each doc's one-line purpose and audience, checks that a doc states them up front unless obvious, checks content against them, and treats code-held information as out of place unless the audience needs it (never linking to `features/`); `/review-docs` Step 7 treats wordiness or repetition introduced by an earlier fix as a regression
- [x] Documentation: `docs/capabilities.md` § Concision checks rewritten from the user's version, linking to `../devproc/skills/feature-init/FEATUREMODEL.md`, without implementation detail; `devproc/README.md` and `CONTRIBUTING.md` checked for the same restatement
    - 2026-11-19: `docs/capabilities.md` § Concision checks replaced (old section, the `claude:` marker and the duplicate heading removed) by the user's version with the link fixed to `../devproc/skills/feature-init/FEATUREMODEL.md`; the standard's mechanics (where `/review-docs` reads it, unavailable-path behaviour, `/feature-init` reach) dropped as implementation detail.
    - Checked § Applied and escalated: the added clear-owner and tightening wording describes behaviour the user sees, is short, and was left as is. `devproc/README.md` additions are one-line pointers to § Concision checks, not restatements; `CONTRIBUTING.md` additions are the suite re-run note. No changes needed.
- [x] Testing: `/review-docs` fixture gains a changed user doc restating content held in a code file, expected flagged with that file as owner; after the Refresh steps the suite passes every pass rule item
    - 2026-11-19: fixture gains pass rule item 19: `docs/setup.md` ends with a section restating the behaviour and four rules held in `skills/greet/SKILL.md` (whose change version gained the four rules); expected flagged with `Owner: clear — skills/greet/SKILL.md; holds all of it: yes`, the copy replaced by a summary and link (applied), `SKILL.md` unchanged. A first attempt copying the `Makefile` recipes was flagged as code-derivable detail with no `Owner:` line and escalated (it overlapped item 15's category), so it was replaced by the prompt-file variant; recorded as a fixture ambiguity, not a prompt fault.
    - Run A (transcript `/tmp/tmp.S2UuT4FidA/review-docs.jsonl`; Refresh steps done, `diff -r` clean, fresh `claude -p`): items 1-17 and 19 pass (19: owner line stated, copy replaced by one line plus link, hashes match); item 18 failed once: `docs-review-style` raised a SUGGESTION that the `config.md` precedence sentence is "hard to scan"/wordy (not applied, not in the report's applied list).
    - Run B (transcript `/tmp/tmp.JnOVwOGJ6U/review-docs.jsonl`, same prompts, no edits between runs): all items 1-19 pass. All four agent types invoked; hashes (items 3, 8, 9) match; 19 carried `Owner: clear — skills/greet/SKILL.md; holds all of it: yes` and was applied; 14 carried `Owner: clear — docs/usage.md; holds all of it: yes`; 13, 15, 17 escalated and still present; 10, 11 escalated; 12, 16 applied; 18: no control flagged on its exception ground (the checklist was flagged for duplication of the bash 4 requirement with `setup.md` and for ordering, which are not its exception's grounds). Item 7 escalated, but both agents stated `Owner: clear — <doc>; holds all of it: no` rather than `Owner: unclear` (the other side of the clear-owner rule, same outcome).
    - Item 18's one-off wordiness flag on the precedence sentence is style-agent variance not seen in runs 4-6 or run B; watch if it recurs.
    - Manager review: item 7's wording relaxed as a fix in passing — agents consistently write `Owner: clear — <doc>; holds all of it: no` for the prefix duplicate (each doc holds a slice), which escalates exactly like `unclear`; the item now accepts either. Run A's item 18 failure (a style SUGGESTION on the precedence sentence, not applied) is recorded as variance; it did not recur in runs 4-6 or run B.

### 6b. Keep the plugin general, and require `/feature-init` ✓ (2026-11-19)

Added 2026-11-19 at the user's final review: the prompts and user docs had started assuming the project is this repository (calling skill and agent prompts code), and `/review-docs` had grown handling for a missing or unreadable feature model. Both are reversed.

- [x] Documentation: `### User docs` tidied after the user's wordsmithing (formatting, wrapping, typos), with no change of meaning
- [x] Prompts updated: `/review-docs` checks for `features/FEATUREMODEL.md` and its import up front and stops, telling the user to run `/feature-init`, like the other skills; the plugin-copy read, the "unavailable" notice and their report lines are gone; the style and architectural agents apply `### User docs` from `features/FEATUREMODEL.md` and stop if it is missing; "code is not docs" is stated generally (a file the project runs, builds or ships, even if Markdown; agent docs may say which) in `/review-docs` and all four agents; `feature-init`'s note about `/review-docs` removed
- [x] Documentation: `CLAUDE.md` says that in this repository `devproc/` is the code and that skill and agent instructions stay general; `docs/capabilities.md`'s "Never edited" paragraph removed; `CONTRIBUTING.md` reworded to match
- [x] Testing: the `/review-docs` fixture gains an installed `features/FEATUREMODEL.md` (copied from the canonical file) with its `CLAUDE.md` import, and its `CLAUDE.md` says `skills/` holds prompts that are code; the suite README's "Not covered" text updated; after the Refresh steps the suite passes every pass rule item
    - 2026-11-19: fixture changes: `setup.sh` copies `devproc/skills/feature-init/FEATUREMODEL.md` (relative to the script) into the baseline commit as `features/FEATUREMODEL.md`; fixture `CLAUDE.md` gained the `## Feature model` import and the "`skills/` holds prompts, which are code, not docs" line (before `## Current status`, so item 9's hash is unaffected); the suite README's "Not covered" now says a missing feature model (skill stops) is not exercised, and its setup paragraph mentions the copy.
    - Refresh steps done (`diff -r` clean). Three fresh `claude -p` runs, REPO=/workspace; transcripts `/tmp/claude-1000/r1/review-docs.jsonl`, `/tmp/claude-1000/r2/review-docs.jsonl`, `/tmp/claude-1000/r3/review-docs.jsonl`. Hashes (items 3, 8, 9) matched in all three; all four agent types invoked in all three; no agent reported `FEATUREMODEL.md` or any `features/` file.
    - Run 3 (passing run): all items 1-19 pass. 2, 4, 5, 6, 12, 14, 16 applied or flagged as expected; 3, 7 (`Owner: clear — docs/setup.md; holds all of it: no`), 10, 11, 13, 15, 17 escalated and still present; 14 `Owner: clear — docs/usage.md; holds all of it: yes`; 19 `Owner: clear — skills/greet/SKILL.md; holds all of it: yes`, copy replaced; 18 no control flagged on its exception ground (the checklist was flagged for duplication with `setup.md`/`config.md`, as in sub-task 6a's run B).
    - Runs 1 and 2: all items pass except **item 11**: `docs-review-agent-docs` did not flag the release-tarball procedure as a boundary finding (run 1 rated it a SUGGESTION, "steps are for a maintainer, so they belong in an agent doc"; run 2 did not mention it). Item 11 passed in sub-task 5's runs, so this is new flakiness, not yet explained: possible causes are the installed feature model now readable in the fixture, or the reworded "code is not docs" line in the agent's out-of-scope list. Not investigated further; flagged to the manager.
    - Manager review: unticked. Item 11 failed in 2 of 3 runs (agent-docs did not treat the release-tarball procedure in `CLAUDE.md` as information a person needs; one run called it maintainer content that belongs in an agent doc). It passed reliably before 6b. The user decided (2026-11-19) it is a person's concern (maintainers and contributors are people): `docs-review-agent-docs` criterion 2 now covers maintainer and contributor information and points it at a contributing guide, and its agent-only carve-out no longer lists "how to run tests as a maintainer". In the same spirit, this repo's `CLAUDE.md` setup-files and test-suite procedures moved into `CONTRIBUTING.md` § Making changes, with `CLAUDE.md` linking to it.
    - After the agent-docs clarification, two consecutive runs (`scratchpad/suite8/`, `suite9/`), 2026-11-19: item 11 escalated in both, recommending a user doc (run 8 named `CONTRIBUTING.md`); hashes unchanged; all four agents ran; items 14 and 19 applied with clear-owner lines. Item 18: run 9 again reworded the precedence control ("dense", turned into a list) — the known weak control, a clarity not a wordiness ground.

### 6. Final sign-off criteria ✓ (2026-11-19)

End-of-feature gates for this feature, per `## Sign-off strategy`.

- [x] Code review (agent): `/review-branch` over the whole change; findings resolved or dismissed
    - Re-opened 2026-11-19 for sub-task 6b.
    - 2026-11-19 re-run after 6b (general, nitty, architectural): applied a shared tie-break in all five prompts (a file written for people is a doc even if shipped; code is what a program or model consumes), the agent-docs copy made identical, the reachable-means-user-doc rule qualified by "unless it is code", "process records" → "feature records" in the standard, `review-docs` precondition re-wrapped and "editing a prompt" generalised to "editing code is reported, never applied", Step 7 wording, `setup.sh` checks the canonical file before touching TARGET and makes TARGET absolute, README "Not covered" covers both stop conditions. Installed and plugin copies synced. Not applied (suggestions, beyond scope): marking code in the file list instead of five copies of the rule; an agent output shape for stopping; "line" → "occurrence" in all five skills' import check; escalating purpose/audience openers whose audience is not evident.
    - Re-opened 2026-11-19: to be re-run after sub-task 6a.
    - 2026-11-19 re-run, all four agents, converged in 2 passes. Main fixes: code is not docs — prompts and data files/templates a skill needs to run are code in `/review-docs` Step 3 and all three user-doc agents, so linking to one (as `capabilities.md` now links the canonical `FEATUREMODEL.md`) never makes it a reviewable user doc, while a README written for people stays a user doc; Step 5 classes a one-line purpose/audience opener as minor, uses `<doc or file>`, and rejects `features/` or agent-doc owners; Step 6 keeps an accuracy fix when a duplicate disagrees with its owner; Step 7's regression rule defined without "measurably"; criterion 5 vs 8 split for code-held content; standard-unavailable skip list completed. Wording suggestions on the user-approved standard (merge the code-held sentence into the code-derivable bullet; drop the capabilities example; "doc" → "document"; re-wrap) left for the user.
    - Suite run 7 after the fixes (`scratchpad/suite7/`): all 19 items pass; hashes unchanged; item 19 `Owner: clear — skills/greet/SKILL.md; holds all of it: yes`, copy reduced to two lines and a link. Item 18: the precedence control was rewritten again, this time as ambiguous (clarity), not wordiness — a pass by the item's letter, but the control remains the suite's weakest point.
    - 2026-11-18: run with all four agents (architectural included, by the manager's choice). Converged in 3 passes. Applied: the unavailable-standard path made consistent end to end (`/review-docs` tells the agents the standard is unavailable and not to look elsewhere; agents fall back to `features/FEATUREMODEL.md` only when invoked directly; Step 8 reports skipped checks); the clear-owner exception tightened to `Owner: clear — <doc>; holds all of it: yes` between two user docs; the standard read only when the style or architectural agent runs, up to the next `###`; architectural agent points to the standard instead of restating it, and its maintainer-content bullet narrowed; Step 2 kind descriptions and agent frontmatter updated; `feature-init` step 1a notes the `/review-docs` dependency; suite README table reordered, item 14 tightened to the new contract, the architecture control description corrected.
    - Dismissed (contradict approved design): merging the style agent's critical-paths bullet into Fewer words; removing the direct-invocation fallback entirely. Deferred (beyond this feature): limiting later `/review-docs` passes to cheaper agents (cost of re-running the `opus` architectural agent); adding a reference/overview rule to the standard; grep-based audit lines for items 13/15/17.
    - Suite re-run after the fixes (run 6, 2026-11-18, `scratchpad/suite6/`): all 18 items pass; hashes unchanged; item 14's finding carried `Owner: clear — docs/usage.md; holds all of it: yes`. Item 18: the precedence sentence, step 1 reason and linked summary were untouched on their exception grounds; the checklist control was edited because it restates facts owned by `setup.md` and `config.md` (a duplication defect in the control's text — a fixture bug under item 18, left as a follow-up).
- [x] Docs review (agent): `/review-docs` over the change, all kinds
    - Re-opened 2026-11-19 for sub-task 6b.
    - 2026-11-19 re-run after 6b (fresh session), converged in 4 passes; about 20 minor fixes applied, mostly in `CONTRIBUTING.md` (restructured Making changes; test-suite steps replaced by a link to `tests/README.md`; container bullet corrected — the image does not contain `bin/`), `README.md` (CONTRIBUTING row) and the suite README. 8 escalations (E1–E8) decided by the user (2026-11-19), following the manager's recommendations: E1 partly (CONTRIBUTING gains "edit the canonical file" and "refresh the installed plugin before `/feature-init`"; the never-edit-`features/` rule stays in `CLAUDE.md` only), E4 (capabilities says Claude writes to the standard) and E5 (new-plugin rule moved from `README.md` to CONTRIBUTING) applied; E2, E3, E6, E7, E8 not applied.
    - 2026-11-19 re-run after 6a (fresh session), converged in 2 passes; 14 minor fixes applied; 5 escalations awaiting the user (CONTRIBUTING stability sentence; restoring the "never edit `features/FEATUREMODEL.md`" sentence; writing-time sentence in `docs/workflow.md`; folding Concision checks into The four kinds; trimming `devproc/README.md`'s `/review-docs` paragraph).
    - User decisions (2026-11-19): (1) replaced by a broader "Making changes" section in `CONTRIBUTING.md`, at the user's direction — what a maintainer changing the plugin or the container needs to know, including `FEATUREMODEL.md`'s sharp edges; the old "Changing the feature model" section folded into it and `CLAUDE.md`'s maintainer note relinked and made to state the never-edit rule itself; (2) not restored — the user removed it deliberately; (3) sentence added to `docs/workflow.md`; (4) not applied; (5) applied.
    - 2026-11-18: run in a fresh `claude -p` session (this session's agent definitions predate the prompt changes), all four kinds, standard read from the plugin copy, converged in 3 passes. 16 minor fixes applied to `CONTRIBUTING.md`, `devproc/README.md`, `docs/capabilities.md` and the suite README (including two regressions caught and fixed in pass 2). Escalations: (2) shortening suite README row 7 — not applied, it would drop the planted overlap a maintainer needs; (3) `setup.sh` header comment "one untracked new doc" → "two" — applied by the manager; (4) `CLAUDE.md` maintainer note gains "keep its path and `### User docs` heading stable" — applied by the manager; (1) move the writing-time sentences to `docs/workflow.md` — awaiting the user.
- [x] User review: user reads the `### User docs` standard, the changed agent criteria and the recorded test results, and confirms the agents push back on verbosity as intended
    - 2026-11-19, from the user's read-through: the code definition moved into the feature model's Docs review (code = any file a program or model consumes, even Markdown; user docs = documents written for people, all of which should be reachable from `README.md`, an unreachable one being an orphan user doc); `/review-docs` and the four agents now point at it instead of carrying five copies; the confusing "linking to code / never an orphan" sentence dropped. Suite run 10 (`scratchpad/suite10/`): hashes unchanged, items 11, 14 and 19 as expected, `SKILL.md` still treated as code.
    - 2026-11-19, at the user's request: the four reviewer wording suggestions applied to `### User docs` — the code-held-information sentence folded into **Code-derivable detail stays in the code** (and the architectural agent's code-owner pointer moved to that bullet), the capabilities example generalised to "an overview of what a product does", "the purpose of the doc" → "the document's purpose", re-wrapped. Canonical, installed and plugin copies identical. Meaning unchanged, so no further suite run. Awaiting the user's review of these and the rest of the change.

## Review record

- 2026-11-18 — Spec reviewed by `feature-spec-reviewer`: VERDICT: NEEDS WORK. Presented to the user for sign-off, with 1 open question (whether requirement 6, writing-time guidance, is in scope).
- 2026-11-18 — Spec re-reviewed by `feature-spec-reviewer` after the user's answers (requirement 6 in scope; duplicate removal minor only where the owner is clear): VERDICT: READY FOR USER REVIEW. Minor rewrites applied; the user approved the spec and asked to proceed to design.
- 2026-11-18 — Design reviewed by `feature-design-reviewer` (two passes; first NEEDS WORK, rewrites applied): VERDICT: READY FOR USER REVIEW. Presented to the user for sign-off, with 1 open question (whether writing-time guidance may reach only projects that have run `/feature-init`).
- 2026-11-18 — The user answered the open question (writing-time guidance reaching only `/feature-init` projects is acceptable) and approved the design and sign-off criteria.
- 2026-11-18 — Sign-off strategy amended during implementation, with the user's approval: the necessary-long-sentence control is accepted as untested (each candidate the agent tightened was genuinely clearer shorter).
- 2026-11-19 — Spec amended during implementation, with the user's approval: requirement 2 generalised from per-type rules to a purpose-first rule (every doc has a one-line purpose; content serves it; examples non-exclusive); requirement 4 extended so a fact held in the repo's code is linked to, not restated (files under `features/` stay out of scope). Prompted by the user's final review of `docs/capabilities.md`; work added as sub-task 6a with the user's agreement to its criteria.
- 2026-11-19 — Spec amended during implementation, at the user's direction: requirement 6's "must handle `/review-docs` being run in a project that has not run `/feature-init`" is withdrawn. `/review-docs`, like every other skill, requires `/feature-init` and stops if the feature model is missing, and reads the standard from the installed `features/FEATUREMODEL.md`. The design sections on reading the plugin's own copy are superseded. Also at the user's direction: plugin instructions stay general and never assume the project is this repository (sub-task 6b).
- 2026-11-19 — Feature closed by /feature-end; all sign-off boxes ticked.
