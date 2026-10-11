# Docs review overhaul — Feature Plan

## Handoff

**Last updated:** 2026-10-11
**Session summary:** All sub-tasks (1–7, including 5a) complete with every sign-off box ticked. Sub-task 7: `/review-branch` (4 passes, fixes applied), `/review-docs` over the change (27 minor fixes, 8 escalations decided by the user, plus the feature-model procedure moved to `CONTRIBUTING.md`), post-review consistency (refresh, `/feature-init`, `/review-docs` suite re-run passing), and the user's final review.
**Sub-task in progress:** None — feature closed by `/feature-end` 2026-10-11.
**First action next session:** None; the feature is complete.
**Autonomy boundary (agreed 2026-10-11):** Reached. `/feature-end` only on the user's go-ahead. The user stages and commits; do not do either.
**Open questions / decisions pending:** None. Declined at the final docs review: trimming the older "internal-docs-prune documentation placement" `NOTES.md` entry (left for `/internal-docs-prune`).
**Dead ends to avoid:** Do not hand-edit `features/FEATUREMODEL.md` or the installed plugin at `/home/claude/claudeplugins/devproc/`. Edit the repo, refresh the installed tree from it, then run `/feature-init` via `claude -p` (the Skill tool cannot invoke it). Do not try to fix the reviewer's memory by pruning it: the decision is to make every docs reviewer stateless.

## Requirements

From issue #69, "Minor issue with feature-end and docs review" (verbatim):

> There is a minor issue with feature-end and docs review that we should tidy up.
>
> Currently, feature-end runs a doc review, which is often a final sign off item in the last subtask. Hence the last subtask cannot be closed because the final docs review is left until feature-end.
>
> We should change this; it's really an artefact of how things used to work.
> - No docs review as an implicit part of feature end
> - Instead, docs review should be an explicit sign off task, and should normally be run in the final subtask like any other sign off item.
>
> It may be appropriate in other subtasks as well, and it may occasionally be appropriate not to run it at all for some very simple features, where docs have not been changed - but better to have it pulled out explicitly into subtasks rather than run implicitly.

The issue has no comments.

Related context: the close-out of the previous feature (`subtask-handling`, #67)
raised the same tension with the user as a follow-up. `/feature-end` step 2
requires every sub-task to be ✓, but a box that `/feature-end` itself performs
can't be ticked until `/feature-end` runs.

### User direction during design (2026-10-11)

While the feature was being designed, the user widened its scope in
conversation. Their words, lightly tidied:

On the reviewer flagging an in-progress feature:

> It is absolutely fine for a docs review to be run in that state, and if the
> agent / skill state otherwise they are wrong they need to be corrected.
>
> The issue here then is that the memory has started turning into
> instructions. That's wrong; memory and instructions are not the same thing.
>
> My impression is that the memory is becoming more trouble than it is worth.
> Let's just make it stateless. I don't think this is worth a new feature, but
> it is worth a new subtask.

On when docs review may be skipped, and what it covers:

> It says to skip the docs review if no docs are changed. That would be wrong;
> suppose we change a feature and forget to change the docs, we then skip the
> docs review! The boundary for "no structural docs review" is "trivial changes
> that manifestly cannot require docs structural changes".
>
> I also think that it conflates docs review and docs structural review. It is
> possible that a feature might require docs review but not docs structure
> review (such as a feature to tweak the wording of a single doc, or a very
> simple localised change).
>
> The right model is that docs review should happen if any docs change or any
> docs might need to change (i.e. it would review the docs for continued
> accuracy). Docs structural review should happen if there is any risk that the
> overall documentation structure should change or that links might break or
> docs in some non-obvious place have been missed. In both cases, err on the
> side of better safe than sorry. A review that finds nothing costs a few
> tokens, and a missed review might leave bugs in.

On the shape of the fix:

> As we tease out the details of fixing up docs review, we are finding that it
> was not just a bit wrong, but needed quite a big houseclean. It is probably
> the case that we should have a separate agent for it. Maybe we should have
> three, analogous to code review: architectural, accuracy and style. It is
> also probably the case that the docs review skill needs to be made more
> generic with those three agents.

The user then settled the proposal put to them: the three-agent split and the
criteria mapping in `## Spec` point 3; one generic skill rather than three;
Opus for the architectural agent ("This is catching places where the docs were
not thought through. That is a place for careful thought, not just applying
rules"), Sonnet for the other two; and the escalation boundary in point 4.

### User direction at the sub-task 5 review (2026-10-11)

Reviewing sub-tasks 1–5, the user stopped at the documentation definition in
`/review-docs` and gave this direction (verbatim, from markups and the
conversation):

> FEATUREMODEL.md is logically part of a plugin, not a doc, and is not
> reviewed (as it gets overwritten whenever /feature-init is rerun to get into
> a clean state).
>
> CLAUDE.md and NOTES.md are not user documentation but docs aimed at Claude /
> AI tooling. The user should never rely on them, and this implies otherwise.
> I think the right point here is to split "agent docs" (CLAUDE.md, NOTES.md)
> from "user docs" (all the main docs structure, referenced directly or
> indirectly from README.md). I am concerned about how we avoid the docs
> reviewers thinking the user docs can rely on things in the agent docs (the
> other way about is fine). Similarly, things in the features directory are not
> what should normally be reviewed here; a user who wants to do something with
> the project (such as run the tooling it contains, or deploy the package, or
> whatever the repo provides) should never need to look at the /features
> directory, and old features are there purely as a historical record.
>
> My key worry is that this all seems to mix up three types of docs.
> - Feature information is of no interest to anybody except when doing
>   development for a feature. When we ship the repo (whatever repo the plugin
>   is being used with), the user gets some tools / code / instructions /
>   whatever, and needs user docs to know what to do, how it works and so on.
>   This starts from README.md and is most of what is here.
> - Anything in the `features` directory is of no interest to ordinary users,
>   but is important during development of each feature (or to see feature
>   history).
> - CLAUDE.md and NOTES.md are for agents only; no human should ever look at
>   them.
>
> It is critically important that the user docs are correct and complete.
> Features (and the feature model etc.) are out of scope for docs review,
> though they will be referred to during feature development. Agent docs are
> valuable and important, but they are logically distinct from user docs, and
> handling them without being very clear about that feels dangerous (as, for
> example, some critical information might end up only in CLAUDE.md where no
> person will look at it); nothing significant in these agent docs should
> duplicate what is in user docs (as they should just reference it).

On how agent docs are reviewed:

> I think we should have a separate process for reviewing agent docs.
> Something should go through and check them routinely. One option: the three
> agents we have are all for user docs only. Create a fourth agent that just
> checks agent docs.

The user chose a new fourth agent, run by `/review-docs`, over reusing
`internal-docs-reviewer` or folding `/internal-docs-prune` into `/review-docs`,
and asked for the fix to be made before re-reviewing everything.

## Spec

### What this feature is for

The `devproc` plugin treats **docs review** as one of five sign-off categories
in its feature model (`features/FEATUREMODEL.md`, `### Sign-off criteria`). In
practice, docs review is the weakest part of the model, in four ways:

1. **It is run implicitly, at the wrong time.** `/feature-end` runs a docs
   review itself, whether or not the feature's sign-off strategy asked for one.
   To fit this in, the model gives the final sub-task's docs-review box a
   special annotation, "(performed at `/feature-end`)". It also exempts that box
   from being ticked before `/feature-end` runs. So the final sub-task can never
   be closed before `/feature-end`, and every skill and agent that checks
   completeness has to know about the exception.
2. **Nothing checks that the docs are still true.** The only docs reviewer,
   `docs-structure-reviewer`, audits structure and style. Its instructions say
   to audit for navigability "not for content accuracy". A change that leaves a
   doc describing old behaviour passes.
3. **One agent mixes different jobs.** Structure (is anything missing, orphaned
   or broken?) and style (is it clear and well written?) are different
   questions with different costs. A feature may need one and not the other.
4. **The reviewer's memory turned into instructions.** `docs-structure-reviewer`
   keeps project memory. In this repository it ran only at `/feature-end`, so it
   learned that a feature still listed as in progress was a recurring defect.
   It also stored rules about what not to flag. Memory is not instructions: a
   review must be judged only against the reviewer's stated criteria.

This feature rebuilds docs review to match code review, which already works
this way. Code review has specialist agents run by review skills, and is
planned into sub-tasks like any other sign-off. After this feature, docs review
is the same:

- three stateless specialist agents for user docs (architectural, accuracy
  and style), and a fourth for agent docs;
- one generic skill, `/review-docs`, that runs them over a chosen scope; and
- an ordinary sign-off, planned and ticked during implementation, with
  nothing performed by `/feature-end`.

### What must change

**1. `/feature-end` no longer runs a docs review.** The `docs-structure-reviewer`
step is removed from `/feature-end`. `/feature-end` still runs a full
checkpoint, confirms completion, updates the feature-list files and
`CLAUDE.md`, and stamps the `
> Docs review notes (2026-10-11): Refresh steps, then `claude -p --permission-mode bypassPermissions --verbose --output-format stream-json "/review-docs"` in `/workspace` (fresh session). All four `devproc:docs-review-*` agents invoked; 3 passes, converged. 27 minor fixes applied across `README.md`, `CONTRIBUTING.md`, `devproc/README.md`, `docs/capabilities.md`, `docs/workflow.md`, `tests/README.md`, the four suite READMEs and `NOTES.md` (stale "three" counts, clarity edits, a `workflow.md` line on satisfying a docs review box, one broken `NOTES.md` reference); no prompt, fixture or feature record touched, no agent memory created. 8 escalated; the user decided (2026-10-11): applied 1 (drop `README.md`'s `features/` row), 2–3 (suite READMEs state their reasons instead of pointing to `NOTES.md`), 4 (`devproc/README.md`'s `review-docs` entry trimmed to a summary and link), 5 (sub-headings in `capabilities.md`'s Documentation review section), 6 (`workflow.md`/`devproc/README.md` describe `FEATUREMODEL.md` as the text `/feature-init` installs), 7 (history trimmed from the `NOTES.md` boundary entry); declined 8 (older `NOTES.md` placement history, left to `/internal-docs-prune`). Also applied on the user's agreement: 9, the feature-model maintenance procedure moved into `CONTRIBUTING.md` with `CLAUDE.md`'s maintainer note linking to it (the review had not flagged it; the agent docs agent missed a procedure a person needs held only in `CLAUDE.md`), and the not-applied pass-2 note that the suite's hash check must run in the same shell.
>
> User review (2026-10-11): the user reviewed the finished feature, including the final reviews' changes, and confirmed it ("I've reviewed and am happy").
> Post-review consistency (2026-10-11): the reviews changed files under `devproc/` (the `/review-docs` skill, three docs-review agents, `devproc/README.md`) and `tests/` (suite READMEs only; no fixture or `.expected.md`). Refresh steps redone (`diff -r` empty); `/feature-init` re-run, `diff devproc/skills/feature-init/FEATUREMODEL.md features/FEATUREMODEL.md` empty. Suites: `/review-docs` re-run (its skill and agents changed), following the edited README's commands literally in a fresh session: PASS, all 12 items, 3 passes, all four agents invoked, the before/after hash diff empty (items 3, 8, 9), `--user` fixed, link repointed to `help.md`, `caching.md` linked, prerequisites restored, `PREFIX` duplication, `cleanup.sh` mismatch, `caching.md`→`CLAUDE.md` reliance and the `make dist` procedure escalated and left in place, the stale `CLAUDE.md` path fixed, nothing under `features/` reported. Reviewer suites not re-run: neither reviewer agent nor any fixture or `.expected.md` changed after sub-task 6. Text the user reviewed in 5a that the reviews changed was covered by the user's final review. `.claude/agent-memory/` holds only `devproc-internal-docs-reviewer/`.

## Review record`. It does not review the docs and
does not tick any sign-off box.

- The ordering note in `/feature-end` step 3, which says to update the feature
  lists *before* the documentation review, is removed.
- A docs review now runs in a sub-task, before `/feature-end` moves the feature
  to `COMPLETED.md` and trims `CLAUDE.md`. So it sees the feature listed as in
  progress. That is a valid state, and no reviewer treats it as a finding.

**2. The "(performed at `/feature-end`)" annotation and its exception are
removed.** With no sign-off performed by `/feature-end`, there is nothing for
the annotation to mark. Every box in every sub-task, including "Final sign-off
criteria", must be ticked before `/feature-end` starts. The annotation, the
exception, and any wording that relies on them are removed from the feature
model, the `feature-end` and `feature-design` skills, `feature-design-reviewer`
(whose "`/feature-end`-performed boxes are annotated" check is deleted), and the
user docs.

**3. Docs review has four kinds, each with its own agent.** Three review the
user docs and one reviews the agent docs (point 9 defines the two). The four
kinds, and the agents that perform them, are:

| Kind | Agent | What it checks | Model |
|---|---|---|---|
| **Architectural** | `docs-review-architectural` | Whether the user docs are fit for purpose (everything a user would expect is documented, to the standard comparable things are, and nothing irrelevant), and the documentation set as a whole: entry points, orphaned docs, broken links, hierarchy, missing or misplaced docs, one source of truth per fact. Given a change, whether any doc in a non-obvious place should have changed with it. | Opus |
| **Accuracy** | `docs-review-accuracy` | The docs still match the code and its behaviour. Given a change, it finds every doc that describes the changed thing and checks each is still correct: commands, paths, options, behaviour, examples. Without a change, it checks the docs in scope against the code. | Sonnet |
| **Style** | `docs-review-style` | How the docs read: clarity, procedural form (imperative, prerequisites before the commands that need them, the "why" for non-obvious steps), consistent conventions, and detail kept out of the main flow. | Sonnet |
| **Agent docs** | `docs-review-agent-docs` | The agent docs: they still match the repository (file lists, paths, commands, descriptions of components); nothing a person needs is held only in them; they link to the user docs rather than repeating them; and they are fit for purpose: everything an agent needs, nothing it does not (such as history). | Sonnet |

- The first three agents review user docs only. The fourth reviews agent docs
  only.
- The architectural agent runs on Opus. It finds where the docs were not
  thought through, which takes careful judgement rather than rule-following.
  The other three run on Sonnet.
- The criteria come mostly from `docs-structure-reviewer`. Its criteria 1–3
  (entry points, hierarchy, architecture guides) go to the architectural
  agent. Its criteria 4–6 (procedural rigour, clarity, consistency) go to the
  style agent. For procedures, *form* is style; whether a command or step
  actually works is accuracy. The accuracy agent's criteria are new.
- Each agent produces findings only and never modifies files, like the
  code-review agents.
- Each agent is **stateless**: no `memory:` field and no instruction to read or
  write memory.
- *Proposed:* each finding carries a severity (CRITICAL, MAJOR, MINOR,
  SUGGESTION) and a file and line, in the format the code-review agents use, so
  `/review-docs` can handle all four agents' findings alike.

**4. One generic skill, `/review-docs`, runs them.** It mirrors the code-review
skills, but as a single skill with a scope:

- **Scope.** One of: the whole documentation set (`full`); the docs touched by,
  or describing, the current change (`change`); or an area described in plain
  language (e.g. "the container docs").
  - *Proposed:* `change` is the default. It is what a sub-task's sign-off
    normally needs.
  - *Proposed:* `change` takes the diff against the base branch, as
    `/review-branch` does. It also includes uncommitted and untracked files, so
    it works on work that has not yet been committed.
- **Kinds.** Which agents to run. The default is all four. The invocation may
  name a subset (e.g. "accuracy only").
- **Fix handling.** The skill reuses the code-review loop: classify findings,
  apply some automatically, re-run to convergence, escalate the rest.
  - **Applied automatically:** a minor fix inside a single existing doc, from
    any agent. Examples: repointing a link in doc A that broke because doc B
    changed; adding a missing link from doc A to doc B; correcting a wrong
    command or path; rewording an unclear sentence. *Settled by the user:*
    minor tweaks are fine, rewrites are not.
  - **Escalated to the user:** anything more significant. That means:
    creating, deleting, moving or splitting a doc; changing how information
    is divided between docs (inconsistent, confusing or duplicated across
    doc A and doc B); rewriting a section rather than tweaking it; an
    accuracy finding where the *code*, not the doc, may be what is wrong; and
    every boundary finding (point 9), since each changes which class of
    document holds a piece of information.
  - *Proposed:* the same convergence cap as the code-review skills: re-run the
    agents over changed docs until no new automatic findings appear, at most
    five passes.
- **No doc in the change is normal.** A `change` scope whose diff touches no
  doc does not stop the skill. That is the case a docs review most needs to
  catch: code changed and its docs did not. The accuracy and architectural
  agents still search for docs that describe the changed files. The style
  agent reviews only changed docs, so with none it is skipped and reported as
  skipped.
- **Report.** Scope, kinds run (and any skipped, with why), each finding with
  the agent that raised it, findings applied, findings escalated and what the
  user decided, and anything left after the cap.

**5. The feature model describes docs review this way, and when to run it.**
The **Docs review** category in the canonical `FEATUREMODEL.md` names the
three kinds. A feature's `## Sign-off strategy` sets a bar for each kind, or
skips it explicitly. When each kind is warranted:

- **Accuracy:** whenever any doc changes, or might need to change.
- **Architectural:** whenever there is any risk that the documentation
  structure should change, that a link might break, or that a doc in a
  non-obvious place has been missed.
- *Proposed:* **Style:** whenever any doc prose is added or changed, other
  than a trivial edit (a typo, a path or version bump) that manifestly cannot
  affect how the doc reads.
- *Proposed:* **Agent docs:** whenever an agent doc changes, or the change
  touches anything an agent doc describes (a file it lists, a path, a command,
  a component).

The first three kinds concern user docs and the fourth concerns agent docs,
as defined in point 9.

Skip a kind only for a trivial change that manifestly cannot need it. When in
doubt, run it: a review that finds nothing costs a few tokens, and a missed
one can leave errors in. Docs review is normally run once, in the final
sub-task, like any other sign-off. It may also appear in other sub-tasks (for
example, the docs-first box, where the user reviews the docs before the code is
written).

- The model's examples of a named performer (`docs-structure-reviewer`) become
  `/review-docs`.
- *Proposed:* a box names the skill and the kinds, e.g.
  `- [ ] Docs review (agent): /review-docs over the change, all kinds`.
- *Proposed:* `feature-spec-reviewer` treats the docs review category as
  covered only when the strategy says which kinds run, or skips the whole
  category with "None — <reason>". A bare "one docs review" is a finding. This
  keeps strategies from quietly keeping a single undifferentiated bar.
- `/feature-spec` needs no edit. Its step 7 proposes a bar for every category
  as the model defines it, and its examples cover testing and code review
  only, so it picks up the per-kind docs review bar from `FEATUREMODEL.md`.

**6. `docs-structure-reviewer` is retired, and its memory deleted.** Its
criteria live on in the new agents (point 3).

- `devproc/agents/docs-structure-reviewer.md` is deleted.
- This repository's memory for it is deleted:
  `.claude/agent-memory/devproc-docs-structure-reviewer/`, and the stale,
  unprefixed `.claude/agent-memory/docs-structure-reviewer/` tree left over
  from #23. Its review history is already summarised in completed plan files
  and `features/COMPLETED.md`.
- `.claude/agent-memory/devproc-internal-docs-reviewer/` is kept. It is not
  agent memory: the `/internal-docs-prune` skill keeps it as a record of
  decisions the user made.
- Every live reference to `docs-structure-reviewer` points to `/review-docs` or
  the relevant agent instead.

**7. The `## Review record` close-out line records closure, not a docs
verdict.** `/feature-end` still appends one line to `## Review record` when it
closes a feature. *Proposed:* it records the closure date and that every
sign-off box was ticked. The `## Review record` description in
`FEATUREMODEL.md` is updated to match. Any docs review is recorded where it
happened, in its sub-task's ticked box and notes.

**8. Existing plans need no special handling.** *Proposed:*

- Completed plan files are historical records and are not changed.
- A plan already in progress in some project may have a box annotated
  "(performed at `/feature-end`)", or one naming `docs-structure-reviewer`.
  Under the new `/feature-end`, either is simply an unticked box.
  `/feature-end` step 2 already says what to do with one: complete the
  outstanding sign-off (here, with `/review-docs`), or ask the user. So no
  compatibility wording is added.
- `feature-design-reviewer` does not gain a check for the old annotation.

**9. Docs review separates user docs, agent docs and feature records.**
*Settled by the user at the sub-task 5 review.* A project holds three classes
of document, for different readers:

| Class | What it is | Reader | Docs review |
|---|---|---|---|
| **User docs** | `README.md` and every document reachable from it, plus orphans that should be | People using what the repository delivers | The architectural, accuracy and style kinds. They must be correct, complete and self-sufficient. |
| **Agent docs** | `CLAUDE.md` (root and nested), `NOTES.md`, `.claude/rules/*.md` | Claude and other AI tooling only; no person should need to read them | The agent docs kind only |
| **Feature records** | Everything under `features/`, including `FEATUREMODEL.md` | Whoever is developing a feature, or reading feature history | Not reviewed. `FEATUREMODEL.md` is plugin content that `/feature-init` overwrites; the rest is working records and history. |

- **The boundary runs one way.** Agent docs may rely on user docs; user docs
  must never rely on agent docs or feature records. Two boundary checks enforce
  it:
  - The architectural agent flags a user doc that relies on an agent doc or a
    feature record for information: links to it as a source, or tells the
    reader to look there. A user doc that *describes* such files as something
    the project or its tooling creates (as `devproc/README.md` describes the
    `features/` layout the plugin sets up) is not relying on them.
  - The agent docs agent flags anything a person needs that is held only in an
    agent doc (the fix moves it into the user docs and links to it), and agent
    doc content that substantially repeats the user docs (the fix replaces it
    with a link).
- **Full scope** starts from `README.md` alone for user docs. Agent docs are
  found by name, not by links.
- **A feature listed as in progress is expected** when the agent docs agent
  reads `CLAUDE.md`'s status, since docs review runs before `/feature-end`
  (point 1). The other agents no longer read feature records or agent docs, so
  the note moves to that agent.

### Where the rules live

The rules on docs review and on completing sign-off boxes are part of the
feature model, so they change once, in the canonical
`devproc/skills/feature-init/FEATUREMODEL.md`. The skills and agents apply them
without restating them. This repository's installed copy,
`features/FEATUREMODEL.md`, is refreshed by re-running `/feature-init`, as
`CLAUDE.md`'s maintainer note requires. The criteria for each kind of review
live in its agent. How the agents are run, and how findings are handled, lives
in `/review-docs`.

`NOTES.md` entries made stale by this feature are removed or rewritten: the
entry on which end-of-feature gates take the annotation (#47), and the entry on
anchoring `docs-structure-reviewer`'s memory path (#23).

### Out of scope

- Changes to the code-review skills or agents. Unifying the three code-review
  skills into one, as `/review-docs` does for docs, may be worth doing later.
- `internal-docs-reviewer` and `/internal-docs-prune`. They prune Claude-facing
  internal docs for bloat, which is a different job from the agent docs kind's
  correctness and boundary checks. The two overlap a little on stale content,
  which is accepted.
- Changing how the other end-of-feature gates (e.g. a `/review-branch` before
  close, a final user review) are planned or performed.
- Converting existing plan files (see point 8).

## Sign-off strategy

The change is mostly prose, to skill, agent, feature-model and documentation
Markdown, plus test fixtures. There is no executable code. Two risks matter:

- **Inconsistency.** One skill, agent, doc or fixture still describes the old
  arrangement: the annotation, a docs review at `/feature-end`, or
  `docs-structure-reviewer`.
- **The new reviewers not working.** An agent misses the kind of fault it
  exists for, or the skill applies or escalates the wrong findings. This is
  new behaviour, and the old reviewer's coverage must not be lost in the split.

- **Testing.** Skills, agents and `FEATUREMODEL.md` are loaded from the
  installed plugin copy at `/home/claude/claudeplugins/devproc/`, not from this
  repository (see `NOTES.md`). So before any test run or re-run of
  `/feature-init`, that copy is refreshed from the repository. The refresh is
  confirmed byte-identical with `diff -r`. Testing then has three parts:
    - **`/review-docs` suite.** *Proposed:* a new fixture suite,
      `tests/devproc/review-docs/`, holds a small stand-in workspace with
      planted faults: at least one per agent (a doc contradicting the code it
      describes, an orphaned doc and a broken link, a procedure with its
      prerequisites after the commands that need them), plus one significant
      fault that must be escalated, not applied: the same information split
      inconsistently between two docs. It also includes one prompt file
      (`SKILL.md`), which no agent may edit. It is run by hand, as the
      `internal-docs-reviewer` suite is, with a README saying how and what
      passing means. The stand-in is a git repository, and the suite
      exercises the default `change` scope over it: a committed baseline, then
      a code change with no matching doc change, plus at least one untracked
      doc. It also plants one code-versus-doc mismatch where the code is the
      likely fault, and lists one feature as in progress in the stand-in's
      `features/CURRENT.md` and `CLAUDE.md`, which no agent may report. It passes when each planted fault is found by its agent
      (as attributed in the skill's report), the automatic fixes are applied,
      the doc made stale by the code change is flagged, the significant fault
      and the code-side mismatch are escalated, not applied, the in-progress
      feature is not reported, and the prompt file is unchanged.
      *Added with Spec point 9:* the stand-in also plants a user doc that
      sends the reader to `CLAUDE.md` for information, a procedure a person
      needs that is held only in `CLAUDE.md`, a stale path in `CLAUDE.md`'s
      file list, and a fault in a feature record that no agent may report or
      edit. The pass rule gains: the first two are escalated as boundary
      findings, the stale path is found by the agent docs agent, and nothing
      under `features/` is reported or changed.
    - **Reference sweep.** A search across `devproc/`, `docs/`, `tests/`,
      `CLAUDE.md`, `NOTES.md`, `features/FEATUREMODEL.md` and
      `.claude/agent-memory/` for "performed at", "close-out",
      `docs-structure-reviewer`, and "feature-end" near "docs review". Every
      remaining hit is fixed or justified. `features/COMPLETED.md` and
      completed plan files are excluded, since they are historical.
    - **Reviewer regression.** The `feature-design-reviewer` and
      `feature-spec-reviewer` suites are run through
      `tests/devproc/harness/run.sh`, and every case passes its README's pass
      rule. Fixtures that use the annotation, describe a docs review "at
      `/feature-end`", or name `docs-structure-reviewer` are updated to the new
      model. *Proposed:* one new `feature-spec-reviewer` case covers the new
      check in Spec point 5 (a strategy with a single undifferentiated docs
      review bar).
- **Documentation.** Full. Every user-facing and internal document that
  describes docs review, the annotation, or `docs-structure-reviewer` is
  updated: the `FEATUREMODEL.md` pair, `devproc/README.md`, `docs/workflow.md`,
  `docs/capabilities.md`, `devproc/.claude-plugin/plugin.json`, `NOTES.md`,
  the workspace `CLAUDE.md`, and `tests/README.md` for the new suite.
- **Code review (agent).** One `/review-branch` over the whole change before
  `/feature-end`, with any untracked new files (from `git status --porcelain`)
  added to its file list. `/review-branch` builds its list from
  `git diff --name-only`, which leaves untracked files out, and the user does
  all staging. The change is prose, so a per-sub-task agent review would cost
  more than it catches.
- **Docs review (agent).** `/review-docs` over the change, all kinds, in
  "Final sign-off criteria", ticked before `/feature-end`. This feature uses
  the skill it builds.
- **User review.** One user review, at the end of sub-task 5a, covering every
  change made in sub-tasks 1–5a: the changed `FEATUREMODEL.md` sections, the
  four agents' review criteria, the `/review-docs` skill and its test results,
  the changed `feature-end` skill and the other skill and reviewer changes,
  and the user docs. It comes before the fixtures and the final sign-off,
  which build on all of it. *Changed by the user during design:* the earlier
  plan had four separate reviews, which forced a stop inside each of the first
  four sub-tasks. *Changed by the user at the sub-task 5 review:* the review
  moved from sub-task 5 to sub-task 5a, so that everything is re-reviewed
  once Spec point 9 is in place. *Added by the user at the 5a review:* a
  short final user review as the last box of "Final sign-off criteria",
  confirming the finished feature after the final reviews.

## Design

### Overview

Docs review is rebuilt in the shape code review already has. Specialist
agents hold the criteria. A skill runs them over a scope and handles their
findings. The feature model says when to plan each kind of review. Building it
is mostly a matter of moving things to the right place:

- **Rules → the feature model.** The canonical `FEATUREMODEL.md` loses the
  annotation and its exception. Its docs review category is rewritten around
  the three kinds and when each is warranted (Spec point 5).
- **Criteria → three agents.** `docs-structure-reviewer`'s six criteria are
  split between `docs-review-architectural` and `docs-review-style`.
  `docs-review-accuracy` is written new. These three review user docs only;
  `docs-review-agent-docs` reviews agent docs, and feature records are not
  reviewed (Spec point 9). The old agent and its memory are deleted.
- **Running and fixing → `/review-docs`.** The classify, apply, iterate and
  escalate loop the code-review skills share is reused, with a scope argument
  in place of three separate skills. It replaces the ad-hoc loop `/feature-end`
  ran.
- **Callers and checkers.** `/feature-end` stops reviewing docs. `/feature-design`
  and `feature-design-reviewer` stop mentioning the annotation.
  `feature-spec-reviewer` gains the "which kinds" check. References to
  `docs-structure-reviewer` everywhere point to the new pieces.
- **Descriptions and fixtures.** The user docs, `CLAUDE.md`, `plugin.json` and
  `NOTES.md` are brought into line. The reviewer fixtures are updated, and a
  new suite tests `/review-docs`.

The sub-tasks run in order. The user reviews all of sub-tasks 1–5a at once,
at the end of sub-task 5a, before the fixtures and the final sign-off build on
them.

### Decisions

**One user review, at the end of sub-task 5a.** *Settled by the user.* (It was
at the end of sub-task 5 until the user's review there produced Spec point 9;
sub-task 5a makes that change and carries the review.)
Sub-tasks run in order. A user review inside each of sub-tasks 1–4 would stop
the work four times, so there is a single review of all changes so far once
sub-task 5 is done. The risk is rework: if the user rejects, say, the model
wording, sub-tasks 2–5 may need adjusting. That is accepted for the sake of a
straight run. The fixtures (sub-task 6) and the final sign-off (sub-task 7) come
after the review, so the most mechanical work is not built on unreviewed text.

**Agents and skill are separate sub-tasks.** The agents' criteria and the
skill's mechanics (scope, fix handling) are different pieces of work, and the
skill's test suite needs both to exist.

**Agent prompts follow the code-review agents' format.** Frontmatter, a
mission, numbered criteria, "what to review", and the code-review output
format (Spec point 3). `docs-review-architectural` has `model: opus`, the
others `model: sonnet`. All have `tools: Glob, Grep, Read`. The accuracy agent
needs to read code as well as docs, which those tools cover.
`docs-structure-reviewer` also had `WebFetch` and `WebSearch`. They are
dropped: link checking covers in-repository links only, and external links are
out of scope. External links fail intermittently, so checking them makes a
review flaky, and none of the old reviewer's criteria depended on them. We reuse the
code-review shape rather than `docs-structure-reviewer`'s, because
`/review-docs` reuses the code-review loop, which expects that format.

`docs-review-agent-docs` states that a feature listed as in progress in
`CLAUDE.md` during a review is expected, and is not a finding (Spec point 1).
It is the only agent that reads `CLAUDE.md`'s status, so it is the one place
the old memory's error could recur. It may read `features/CURRENT.md` to check
that status, but reviews nothing under `features/`.

**What counts as documentation.** `/review-docs` and all four agents need a
shared answer. It follows the three classes in Spec point 9. (Until the
sub-task 5 review it was carried over from `docs-structure-reviewer`'s "Audit
Scope", which traced from `CLAUDE.md` as well as `README.md` and reviewed
`features/` for navigability; the user rejected that because it treats agent
docs and feature records as if people read them.)

- **User docs, `full` scope:** every document reachable from `README.md`,
  traced recursively, plus orphans found by searching for documents that
  nothing links to. Agent docs, feature records, prompts and test fixtures
  found by that search are not orphans.
- **Agent docs, `full` scope:** found by name: `CLAUDE.md` at any depth,
  `NOTES.md`, `.claude/rules/*.md`.
- **In a `change` diff**, each changed file is classed as a user doc, an agent
  doc, a feature record, or not a doc. A new Markdown or text file outside
  those classes is a user doc that should be reachable (an orphan the
  architectural agent then flags).
- **Feature records** (everything under `features/`, including
  `FEATUREMODEL.md`) are never reviewed or edited. Agents may read them only
  as context for a change.
- **Agent docs** are reviewed only by `docs-review-agent-docs`. Style is not
  checked: they are terse by design. Pruning bloat stays with
  `/internal-docs-prune`.
- **Prompts are not docs.** *Settled by the user.* In this repository,
  skill and agent prompts (`SKILL.md`, `agents/*.md`) are code: they are part
  of what the repository delivers to run elsewhere. The accuracy and
  architectural agents check docs against them, `/review-branch` reviews
  them, and no `/review-docs` agent edits them. In other repositories, a
  plugin's prompts are not part of the project at all, so they are not in
  scope. `FEATUREMODEL.md` is a feature record, not a doc (*settled by the
  user at the sub-task 5 review*, reversing the earlier "treated as a doc").

**Classification in `/review-docs`.** The skill classifies each finding as
*minor* (a tweak inside one existing doc: a wording fix, a wrong command or
path, a broken link repointed, a missing link added) or *significant* (create,
delete, move or split a doc; change how information is divided between docs;
rewrite a section). Minor findings are applied, whichever agent raised them.
Significant ones are escalated (Spec point 4). An accuracy finding is escalated, not applied, when it says
the code may be what is wrong. When in doubt, a finding is treated as
significant, matching the code-review skills' "when in doubt, architectural".

The code-review skills keep their Steps 4–7 identical, with a note saying so.
`/review-docs` carries its own note naming them as the source of its loop. The
reverse reference, from the code-review skills to `/review-docs`, is deferred
with the other out-of-scope code-review changes.

**`change` scope.** The file list is the union of `git diff --name-only <base>`
and untracked files from `git status --porcelain`, as Spec point 4 requires.
Base-branch detection copies `/review-branch` (`main`, then `master`, then ask).
In an untracked workspace this runs in each repository beneath it, per
`### The workspace`. The agents are passed the diff and the changed files. The
accuracy and architectural agents use them to find docs elsewhere that
describe what changed. Unlike `/review-branch`, an empty doc list does not
stop the skill (Spec point 4).

**`/feature-end`'s close-out line.** Proposed form:
`- YYYY-MM-DD — Feature closed by /feature-end; all sign-off boxes ticked.`
The line is still written on every close, so `## Review record` keeps its rule
that an absent line means a stage has not run.

**The old agent file is deleted in sub-task 4, with its callers.** Its memory
goes in sub-task 2, but `/feature-end` and `dev-process-manager` name the agent
until sub-task 4 changes them. Deleting the file there means no state between
sub-tasks has a skill calling an agent that does not exist.

**Retire and delete, not deprecate.** `docs-structure-reviewer` is deleted
outright rather than kept as an alias. An alias would keep the mixed-job agent
alive and invite new plans to name it. A consumer plan already naming it is
covered by Spec point 8. Its memory is deleted rather than pruned: pruning keeps
the mechanism that caused the problem.

**`feature-checkpoint` is not edited.** It holds no annotation wording of its
own. It applies the `FEATUREMODEL.md` paragraph, which sub-task 1 changes.

**Fixtures are edited, not re-recorded.** The reviewer fixtures are
hand-written inputs with hand-written `.expected.md` pass rules. In both
suites:

- each strategy line "One agent docs review (`docs-structure-reviewer`) over the
  updated docs at `/feature-end`" becomes a line in the new form, e.g. "`/review-docs`
  over the change, all kinds, in the final sub-task";
- each `Docs review (agent): docs-structure-reviewer … (performed at
  `/feature-end`)` box loses the annotation and names `/review-docs`;
- `missing-final-signoff.expected.md` loses its annotation wording, including
  the "Also acceptable" bullet about it;
- `control.expected.md` loses the sentence praising the annotation; and
- `.expected.md` files that name `docs-structure-reviewer` are reworded.

No existing case's flaw under test depends on the annotation or the agent's
name, so no case changes what it tests. Because the new strategy lines name the
kinds, the existing control cases stay clean under the new spec-reviewer check.

**The `/review-docs` suite is a directory suite, run by hand.** Its case is a
stand-in workspace, like the `internal-docs-reviewer` suite, not a single plan
file, so `tests/devproc/harness/run.sh` cannot run it. That harness's own
README names only `internal-docs-reviewer` as uncovered today, so sub-task 3
adds `review-docs` to it, to `run.sh`'s header, and to `CLAUDE.md`'s harness
bullet, with the same reason. The suite's README gives the invocation and the
pass rule from `## Sign-off strategy`. The run works on a scratch copy, so the
fixture is not modified by the auto-apply step. The fixture holds the files and
a setup script that builds the scratch git repository: baseline commit, then
the code change and the untracked doc. The run is a `claude -p` invocation in
that scratch copy. In a non-interactive run, escalation shows as a question in
the final output, with the escalated fault left unapplied in the scratch copy.
Attribution comes from the skill's report, which names the agent per finding
(Spec point 4).

**The plugin is refreshed before anything is run.** Skills, agents and
`FEATUREMODEL.md` load from the installed copy (`NOTES.md`). Wherever a
sub-task runs `/feature-init`, the harness, `/review-docs` or a reviewer, it
first refreshes that copy. The steps are short, so they are written inline, as
**Refresh steps**:

1. `rsync -a --delete /workspace/devproc/ /home/claude/claudeplugins/devproc/`
2. `diff -r /workspace/devproc /home/claude/claudeplugins/devproc` prints
   nothing.

A newly written agent or skill cannot be called in the session that created
it, because agent types are resolved when a session starts (`NOTES.md`, #20).
So anything that runs `/review-docs` or a `docs-review-*` agent runs in a
**fresh session after the Refresh steps**, e.g.
`claude -p --permission-mode bypassPermissions "/review-docs …"`. Using a
`general-purpose` stand-in is not acceptable: it would skip the frontmatter,
including the `model: opus` choice, and the skill's dispatch to its agents.

**This feature's own design review runs on the old reviewer.** The installed
`feature-design-reviewer` still has the annotation check, so it may flag this
plan's unannotated final docs-review box. That box follows the strategy the
user agreed, so such a finding is noted and not applied.

## Sub-tasks

**▶ NEXT:** None — all sub-tasks complete; ready for `/feature-end` on the user's go-ahead.

> Code review and the feature's own docs review are feature-level, in sub-task
> 7, per the strategy. No earlier sub-task carries a code-review or agent
> docs-review box.

> Run `/feature-checkpoint` after each sub-task completes.

### 1. Update the feature model ✓ (2026-10-11)

In the canonical `devproc/skills/feature-init/FEATUREMODEL.md`: remove the
annotation and its exception; rewrite the docs review category around the
three kinds and when each is warranted; change the performer examples to
`/review-docs`; reword the `## Review record` description (Spec points 2, 5
and 7). Then install the change in this workspace.

> Note: a partial edit was made under the earlier plan. The annotation
> removal and the `## Review record` rewording are kept. The docs review
> sentence it added ("skipped … only for features that change no
> documentation") is wrong under Spec point 5 and must be replaced.

- [x] Documentation: the canonical `FEATUREMODEL.md` has no "performed at" or `/feature-end`-exception wording and does not name `docs-structure-reviewer`. Its docs review category names the three kinds, the trigger for each, the "trivial and manifestly unneeded" skip threshold and the "when in doubt, run it" default, per Spec point 5. Its `## Review record` description matches Spec point 7
- [x] Testing: Refresh steps done, then `claude -p --permission-mode bypassPermissions "/feature-init"` run in `/workspace`. `diff devproc/skills/feature-init/FEATUREMODEL.md features/FEATUREMODEL.md` prints nothing

### 2. Write the three docs review agents ✓ (2026-10-11)

Create `docs-review-architectural`, `docs-review-accuracy` and
`docs-review-style` under `devproc/agents/` (Spec point 3, Design → "Agent
prompts", "What counts as documentation"). Delete
`docs-structure-reviewer`'s two memory trees (Spec point 6). The agent file
itself is deleted in sub-task 4.

> Note (deliberate omissions from `docs-structure-reviewer`): its Part 1
> summary assessment, Part 4 "Claude response summary" and iteration-count
> advice are dropped, because the code-review output format and the
> `/review-docs` loop (convergence cap) replace them. Its Part 3 "Missing
> Documents" is folded into the architectural agent's criterion 3. Its
> "no content accuracy" constraint is now each agent's "stay in your lane"
> constraint, with accuracy owned by `docs-review-accuracy`. Its
> `WebFetch`/`WebSearch` tools are dropped (Design). Its self-verification
> checklist is not carried over; the numbered criteria cover the same ground.

- [x] Documentation: the three agent files exist, each stateless (no `memory:` field, no memory instruction), findings-only, in the code-review output format, with `model: opus` for architectural and `model: sonnet` for the other two. The architectural agent states that a feature listed as in progress during a review is not a finding. Every criterion from `docs-structure-reviewer`'s six sections, and its "Audit Scope" section, is present in the new agents or the Design's documentation definition, or its omission is justified in this sub-task's notes. `.claude/agent-memory/devproc-docs-structure-reviewer/` and `.claude/agent-memory/docs-structure-reviewer/` no longer exist. `.claude/agent-memory/devproc-internal-docs-reviewer/` is unchanged

### 3. Write the /review-docs skill and its test suite ✓ (2026-10-11)

Create `devproc/skills/review-docs/SKILL.md` (Spec point 4, Design →
"Classification" and "`change` scope"). Create the `tests/devproc/review-docs/`
suite (Design → "The `/review-docs` suite"), and register it in
`tests/README.md` and `CLAUDE.md`'s tests list.

- [x] Documentation: `devproc/skills/review-docs/SKILL.md` implements the scope, kinds, fix-handling and report rules of Spec point 4. The suite has a README giving the invocation and pass rule, and is listed in `tests/README.md` and `CLAUDE.md`. `tests/devproc/harness/README.md`, `run.sh`'s header and `CLAUDE.md`'s harness bullet name `review-docs` as not covered, with the reason
- [x] Testing (`/review-docs` suite): Refresh steps done, then the suite run as its README says, in a fresh session. It meets the pass rule in `## Sign-off strategy` → Testing → "`/review-docs` suite". Results are recorded in this sub-task's notes

> Notes (test runs, 2026-10-11; each run: Refresh steps, `setup.sh` into a fresh scratch dir, then `claude -p --permission-mode bypassPermissions --verbose --output-format stream-json "/review-docs"` in a fresh session). "Passes" are review rounds; the cap is 5:
>
> - Run 1 (first skill draft): 5 passes, hit the cap. All three `devproc:docs-review-*` agents invoked; items 2-9 met in substance, but the report grouped findings by file, losing the agent attribution for applied fixes. Skill fix: the report lists every finding with its agent.
> - Run 2 (attribution fix): 5 passes, hit the cap. Showed the fixture bug that hid the `greet.sh` change from git (see NOTES.md); fixed in `setup.sh`.
> - Run 3 (setup fix): 4 passes, converged. Failed item 4 (the `troubleshooting.md` link was left broken, bundled with the questioned `help.md` rename) and asked its escalation questions one at a time, so the print-mode final message held only finding 1. Skill fixes: split a finding into a minor part (apply) and a significant part (escalate); pass the real diff, not a paraphrase; write the whole report in one message before any question (new Steps 8 and 9).
> - Run 4 (those fixes): 5 passes, converged on pass 5 (pass 5 clean, no spare). All nine items met. Style kept rewording its own earlier rewrites.
> - Run 5: not a valid run; aborted by a usage limit after pass 2. Discarded.
> - Run 6 (Step 7 bound, below): 3 passes, converged. Failed item 4 again (link left broken with the `help.md` rename escalated), so the skill now says a link broken by a rename is always repointed, even when the rename is escalated.
> - Run 7 (that rule): 5 passes, converged on pass 5. All nine items met, but the style agent's findings about its own earlier wording were still being applied as "fixes to the previous pass". Step 7 (a) tightened to "wrong or broke something (a false statement, a broken link, a contradiction)", not further wording preferences.
> - Run 8 (final skill): PASS, 2 passes, converged under the cap (pass 2 had nothing to apply). Per item: (1) all three agents invoked; (2) accuracy flagged `README.md` and `usage.md`, fixed to `--user`; (3) `cleanup.sh` versus `design.md` escalated (E1), both files byte-identical; (4) `setup.md` link repointed to `help.md`; (5) `caching.md` linked from `README.md`; (6) style listed against the prerequisites fix; (7) duplicated `PREFIX` escalated (E4), still in both docs; (8) SKILL.md diff hash unchanged; (9) `colour-output` not reported, nothing under `features/` changed. The report also escalated the `--name` in the SKILL.md prompt, which the pass rule allows.
>
> Fix in passing (manager's decision; bounds Spec point 4's convergence rule "re-run until no new automatic findings, at most five passes"): `/review-docs` Step 7 now applies, in passes after the first, only (a) findings that a previous pass's fix is wrong or broke something and (b) CRITICAL or MAJOR findings. MINOR and SUGGESTION findings first raised in a later pass are listed in the report as "not applied (raised after pass 1)". The 5-pass cap stays as a backstop. The skill's loop-derivation note records this as a deliberate difference from the code-review skills: prose review churns where code review does not. Reason: runs 1, 2, 4 and 7 used all 5 passes because the style agent kept finding new wording points in its own rewrites, which would make "persisted after the cap" the norm at 5x cost.
> - Fix in passing: the suite README's pass rule was relaxed so that fixing, not only flagging, the stale `--name` docs passes, and item 9 now allows an agent to note the in-progress feature as expected; it also gained a "Reading the transcript" note.

### 4. Update the feature skills and the plan reviewers ✓ (2026-10-11)

Remove the docs review from `/feature-end`, and make its close-out line a
closure stamp. Remove the annotation from `/feature-design`'s template, step 6
and example, and from `feature-design-reviewer`. Add the "which kinds" check to
`feature-spec-reviewer` (Spec point 5). Point `dev-process-manager` and every
other reference in these files at `/review-docs`. Delete
`devproc/agents/docs-structure-reviewer.md`.

- [x] Documentation: `devproc/skills/feature-end/SKILL.md` has no docs-review step, no step-3 ordering note, no step-2 exception, and a step-5 line in the agreed closure form. `devproc/skills/feature-design/SKILL.md`, `devproc/agents/feature-design-reviewer.md`, `devproc/agents/feature-spec-reviewer.md` and `devproc/agents/dev-process-manager.md` contain no "performed at" wording and do not name `docs-structure-reviewer`. `feature-spec-reviewer` flags a docs review bar that does not say which kinds run. `devproc/agents/docs-structure-reviewer.md` no longer exists. Steps in each file are numbered consecutively

### 5. Update user docs, plugin manifest, CLAUDE.md and NOTES.md ✓ (2026-10-11)

Bring `devproc/README.md`, `docs/workflow.md`, `docs/capabilities.md`,
`devproc/.claude-plugin/plugin.json` and `CLAUDE.md` into line: the new skill
and agents, the three kinds, no docs review at `/feature-end`. Remove or
rewrite the #47 and #23 `NOTES.md` entries.

- [x] Documentation: none of these files says `/feature-end` runs a docs review, mentions the annotation, or names `docs-structure-reviewer`. Each lists `/review-docs` and the three agents wherever it lists the plugin's skills and agents. `docs/capabilities.md`'s docs review section describes the three kinds and `/review-docs`. The #47 and #23 `NOTES.md` entries are removed or rewritten

> Fix in passing (manager): `docs/capabilities.md`'s description of fix handling corrected to match Spec point 4 as settled by the user (minor in-doc fixes from any agent are applied, including a link in doc A broken by a change to doc B) and the bounded later passes from sub-task 3's fix in passing.
>
> The User review box that ended this sub-task moved to sub-task 5a on the user's direction (2026-10-11): reviewing 1–5, the user stopped at the documentation definition, asked for Spec point 9 to be made first, and will re-review everything at the end of 5a.

### 5a. Separate user docs, agent docs and feature records ✓ (2026-10-11)

New sub-task (manager's decision, prompted by the user's sub-task 5 review;
too large for a fix in passing, since it reworks sub-tasks 1–3 and 5). Make
Spec point 9 and the fourth kind in Spec points 3–5 true everywhere: the
model, the agents, a new `docs-review-agent-docs`, `/review-docs`, its suite,
and the user docs. Then the user reviews everything from sub-tasks 1–5a.

- [x] Documentation: (a) The canonical `FEATUREMODEL.md`'s docs review category names four kinds, says the first three cover user docs and the fourth agent docs, and gives the agent docs trigger from Spec point 5; Refresh steps done, `/feature-init` re-run as in sub-task 1, and `diff devproc/skills/feature-init/FEATUREMODEL.md features/FEATUREMODEL.md` prints nothing. (b) `docs-review-architectural`, `-accuracy` and `-style` review user docs only: their "what counts" sections trace from `README.md` alone, exclude agent docs and everything under `features/` (`FEATUREMODEL.md` included), and carry no in-progress note. The architectural agent has the user-side boundary check from Spec point 9, including the "describing is not relying" distinction. (c) `devproc/agents/docs-review-agent-docs.md` exists: stateless, findings-only, `model: sonnet`, `tools: Glob, Grep, Read`, the code-review output format, with criteria for accuracy against the repository, information a person needs held only in an agent doc, and repetition of user docs; it states an in-progress feature is not a finding, and has no style criteria. (d) `devproc/skills/review-docs/SKILL.md` runs four kinds, classes files per Design → "What counts as documentation", always escalates boundary findings, and contains no `claude:` markup lines. (e) `docs/capabilities.md`, `docs/workflow.md`, `devproc/README.md`, `devproc/.claude-plugin/plugin.json`, `CLAUDE.md`, `feature-spec-reviewer` and `dev-process-manager` describe four kinds and the user docs / agent docs split wherever they describe docs review or list the agents; `grep -rn -i -e "three kinds" -e "three docs review" -e "all three" -e "three agents" devproc docs CLAUDE.md` has no hit that refers to docs review
- [x] Testing (`/review-docs` suite): the fixture and README gain the faults and pass-rule items added under `## Sign-off strategy` → Testing → "`/review-docs` suite" (Spec point 9). Refresh steps done, then the suite run as its README says, in a fresh session; it meets the full pass rule. Results recorded in this sub-task's notes
- [x] User review: the user reviews every change made in sub-tasks 1–5a (the changed `FEATUREMODEL.md` sections, the four agents' criteria, the `/review-docs` skill and its suite results, the `feature-end` and other skill and reviewer changes, and the user docs) and confirms them

> Notes (test run, 2026-10-11; Refresh steps, `setup.sh` into a fresh scratch dir, then `claude -p --permission-mode bypassPermissions --verbose --output-format stream-json "/review-docs"` in a fresh session):
>
> - Run 1 (new skill, four agents, extended fixture): PASS, 2 passes, converged. Per item: (1) all four `devproc:docs-review-*` agents invoked; (2) accuracy flagged `README.md` and `usage.md`, fixed to `--user`; (3) `cleanup.sh` versus `design.md` escalated, both files byte-identical; (4) `setup.md` link repointed to `help.md`; (5) `caching.md` linked from `README.md` and `config.md`; (6) style flagged and fixed the prerequisites order; (7) `PREFIX` duplication escalated, still in both docs; (8) SKILL.md diff hash unchanged; (9) `colour-output` not reported, `features/CURRENT.md` diff hash unchanged (its broken link was listed as a feature record and not reviewed), `## Current status` untouched; (10) the `caching.md` to `CLAUDE.md` reliance escalated as a boundary finding, sentence still present; (11) agent-docs flagged the release-tarball procedure as held only in `CLAUDE.md`, escalated, section still there, no user doc gained it; (12) agent-docs flagged the `docs/troubleshooting.md` path in `CLAUDE.md`, fixed. No fixture or skill change was needed after this run.
>
> Fix in passing: the fixture's baseline `README.md` said "Contributors: see `CLAUDE.md`", itself a user doc relying on an agent doc; removed so the planted `caching.md` fault is the only one of that kind. `docs/capabilities.md` told the reader to see `features/FEATUREMODEL.md` for when each kind is warranted (a user doc relying on a feature record); the triggers are now stated there. The `/feature-init` re-run reported `CLAUDE.md` still saying three agents; `CLAUDE.md` was updated.

> Fix in passing (manager, on the user's direction at the 5a review, 2026-10-11): both agents now state that the underlying question is fitness for purpose (the docs tell their reader everything they need and nothing irrelevant). `docs-review-architectural` gained criterion 8, completeness against the docs' own standard (comparable capabilities explained alike) and relevance; `docs-review-agent-docs` gained criterion 4, what an agent needs and nothing else (removing history no agent needs), so its "no pruning" exclusion became "no style". `docs/capabilities.md`, `devproc/README.md` and Spec point 3 updated to match; criterion (c) above amended accordingly. The suite was not re-run for this prompt-only addition; sub-task 7's docs review exercises it.

### 6. Update reviewer fixtures and run the regression suites ✓ (2026-10-11)

Update the `feature-design-reviewer` and `feature-spec-reviewer` fixtures as
set out in Design → "Fixtures are edited, not re-recorded". Add the new
`feature-spec-reviewer` case. Then sweep for leftovers and run both suites.

- [x] Documentation: every fixture and `.expected.md` change listed in Design → "Fixtures are edited, not re-recorded" is made, and the new `feature-spec-reviewer` case (a strategy with a single undifferentiated docs review bar) and its `.expected.md` exist
- [x] Testing (reference sweep): over `devproc docs tests CLAUDE.md NOTES.md features/FEATUREMODEL.md .claude/agent-memory`, run `grep -rn -i -e "performed at" -e "close-out" -e "docs-structure-reviewer" -e "end of each feature" -e "after \`/feature-end\`" -e "docs at \`/feature-end\`"`, plus `grep -rn -i -B1 -A1 "feature-end"` filtered to hits whose three-line window also contains "docs review", "docs-review" or "review the doc". Every hit that describes the old arrangement is fixed. Every other hit is justified in this sub-task's notes, one line per hit
- [x] Testing (reviewer regression): Refresh steps done, then `tests/devproc/harness/run.sh` run over both suites. Every case passes its suite README's pass rule, and the results are recorded in this sub-task's notes
- [x] Testing (`/review-docs` suite re-run): Refresh steps done, then the `/review-docs` suite run as its README says, in a fresh session, against the agents as amended by sub-task 5a's fitness-for-purpose fix in passing. It meets the full pass rule, and the result is recorded in this sub-task's notes

> Notes (sub-task 6, 2026-10-11):
>
> - Fixtures: the 19 reviewer plan files and `.expected.md` files in both suites edited as in Design -> "Fixtures are edited, not re-recorded". The strategy line is now "One agent `/review-docs` over the change, all kinds, in the final sub-task."; the box is "Docs review (agent): /review-docs over the change, all kinds"; the annotation, the "Also acceptable" annotation bullet and every `docs-structure-reviewer` mention are gone. New `feature-spec-reviewer` case `undifferentiated-docs-review` (strategy: "One agent docs review before `/feature-end`."), registered in that suite's README table; the harness README's case count is now 19.
> - Reference sweep (exact greps from the box, after the fixture edits). The first grep's only remaining hit is `NOTES.md:148`: the #69 note on why the docs review agents are stateless, naming the retired agent as history. The second grep's remaining hits are:
>   - `devproc/agents/feature-spec-reviewer.md:96`, `:98`: the new "which kinds" and "who performs it" checks; current, not the old arrangement.
>   - `devproc/README.md:129`, `docs/workflow.md:143`, `docs/capabilities.md:104`: each says `/feature-end` runs no docs review; current.
>   - `CLAUDE.md:5`: the status line saying there is no docs review at `/feature-end`; current.
>   - `.claude/agent-memory/devproc-internal-docs-reviewer/MEMORY.md:16-18`, `:35-36`, `:70`: `/internal-docs-prune` decision records about `/feature-end`'s `## Current status` trim and a NOTES.md heading; nothing about docs review (the window matched on "docs").
>   - `tests/devproc/feature-spec-reviewer/undifferentiated-docs-review.md:73-75` and `.expected.md:4-6`: the new case, which deliberately quotes a bare "docs review before `/feature-end`" as the flaw under test.
>   - 17 further fixture hits are "One agent `/review-branch` before `/feature-end`." strategy lines (code review, not docs review; `/feature-end` is only the deadline), each matched because the docs review line sits one line above it.
> - Reviewer regression (Refresh steps done; `tests/devproc/harness/run.sh`, 19 cases, all rc=0). Judged against each suite README's pass rule: PASS: spec `control`, `incomplete-spec`, `deferred-requirements`, `unclear-spec`, `non-auditable-criteria`, `premature-design`, `unresolved-blocker`, and new `undifferentiated-docs-review` (MAJOR against the Docs review entry, as required); design `control`, `old-format-control`, `no-spec`, `misordered-criteria`, `missing-final-signoff`, `unwritten-signoff-steps`, `unclear-design`, `unexplained-design`, `unresolved-design-question`. FAIL before the fix in passing below (reproduced on a second run): design `weak-subtask-criteria` and `oversized-subtasks`, each reporting a MAJOR `[decision]` against `## Design` ("the query-builder / column-definition module cannot be confirmed to exist"), which their "Must not report" bars. Nothing in sub-task 6 caused this: those sections are unchanged, and the reviewer's rule (`feature-design-reviewer.md:92`, "a component whose existence you cannot confirm is at least a MAJOR finding marked `[decision]`") dates from the agent's first commit. The shared baseline design reuses components of a fictional reports application, so no fixture text can make them confirmable; `control` happens to say it is not counting them, others do not. Resolved by the fix in passing below.
> - Fix in passing (manager's decision; the soft spot predates this feature; the user can overturn it): `weak-subtask-criteria.expected.md` and `oversized-subtasks.expected.md` now carve out of "no MAJOR against `## Design`" one finding only, that the reused query-builder / column-definition modules cannot be confirmed to exist (any severity, with or without `[decision]`). The design suite README names this as the one recorded exception, and the `NOTES.md` entry "Design-fixture baseline: a gap only some cases noticed" records the recurrence. Re-run of just those two cases: both PASS. Each reported the carved-out Design finding as its only MAJOR against `## Design`, with all required findings present and verdict NEEDS WORK. The reviewer regression is therefore 19 of 19.
> - `/review-docs` suite re-run (Refresh steps done, `setup.sh` into a fresh scratch dir, fresh `claude -p` session, against the agents as amended by 5a's fitness-for-purpose fix): PASS, 3 passes, converged (pass 2 corrected one wrong pass-1 edit, pass 3 clean). Per item: (1) all four `devproc:docs-review-*` agents invoked; (2) accuracy flagged `README.md` and `docs/usage.md`, fixed to `--user`; (3) `cleanup.sh` versus `design.md` escalated (item 1), both files byte-identical to the setup state; (4) `setup.md` link repointed to `help.md`; (5) `caching.md` and `help.md` linked from `README.md`; (6) style listed against the prerequisites fix; (7) duplicated `PREFIX` escalated (item 8), still in both docs; (8) SKILL.md diff hash unchanged (escalated item 6, as the pass rule allows); (9) `colour-output` not reported, `features` diff hash unchanged, `CLAUDE.md` status untouched; (10) `caching.md` to `CLAUDE.md` reliance escalated (item 2), sentence still present; (11) release-tarball procedure escalated (item 4), still only in `CLAUDE.md`; (12) agent-docs flagged the stale `docs/troubleshooting.md` path, fixed to `docs/help.md`. The new fitness-for-purpose criteria added only unplanted suggestions (items 3, 5, 7, 9, 10), none breaching a pass-rule item.

### 7. Final sign-off criteria ✓ (2026-10-11)

End-of-feature gates for this feature, per `## Sign-off strategy`, then a check
that fixes from those reviews have not broken the earlier sub-tasks' checks.
All boxes are ticked before `/feature-end` runs.

- [x] Code review (agent): /review-branch over the whole change, with untracked new files added to its file list; findings resolved or dismissed
- [x] Docs review (agent): /review-docs over the change, all kinds, in a fresh session after the Refresh steps; findings applied, or escalated and decided by the user
- [x] Testing (post-review consistency): if either review changed any file under `devproc/` or `tests/`, Refresh steps redone, `/feature-init` re-run as in sub-task 1, `diff devproc/skills/feature-init/FEATUREMODEL.md features/FEATUREMODEL.md` prints nothing, and every suite whose agent, skill, `FEATUREMODEL.md`, or fixture or expected file changed is re-run and passing. If a change touched text the user reviewed in sub-task 5a, the user has confirmed it. After the docs review, `.claude/agent-memory/` holds no `docs-review-*` or `docs-structure-reviewer` directory. Anything not needed is recorded in this sub-task's notes
- [x] User review: the user confirms the finished feature, including any changes made by the final reviews since the sub-task 5a review

> Code review notes (2026-10-11, `/review-branch` run by the manager; simplicity, general and nitty agents; architectural not run, as the strategy asks for one standard `/review-branch`). Scope: 67 files (`git diff main` minus `features/` records and the unrelated `docker/files/home/.claude/settings.json` change, plus the two untracked spec-reviewer case files). Converged in 4 passes (pass 4 one wording nit, applied).
> - Applied (pass 1): `/review-docs` excludes test fixtures and non-project trees from every class (the general agent showed a `full` run here would have "fixed" planted faults in fixture `CLAUDE.md`/`NOTES.md` files); `--untracked-files=all`; Step 7 re-runs the agents each pass with regressions applied whatever their severity and the 5-pass cap stated; loop note and step references corrected; removing agent-doc content is significant; kind name "agent docs" used consistently, full agent names in the report; accuracy and style full scope include orphans; agent-docs constraint reworded; suite README records hashes for items 3 and 9, splits item 9, explains why the agent docs kind runs; NOTES.md and design-suite README rewrapped and the rsync note clarified.
> - Applied (pass 2): `full` scope list built by the skill and passed to every agent; the fixture exclusion narrowed to files under a repository `tests/` or `fixtures/` directory not reachable from `README.md` (reachable docs are user docs wherever they live); Step 3 reads "three classes, or none"; Step 5's always-significant cases in their own paragraph; Step 7 pass numbering; NOTES.md section moved out from under the dev-process-manager subsection; split code spans rewrapped.
> - Applied (passes 3–4): wording only (suite README row, item 8 reflow, agent name in SKILL.md).
> - Dismissed: restating the class rules in each agent (agents must work when invoked alone, per Design); trimming the class definitions from `FEATUREMODEL.md` (the user asked for the distinction to be explicit there); dropping criterion 4's "remove what no agent needs" half (the user's direction; Step 5 now escalates such removals); merging the suite README's table and pass rule (a restructure of a maintainer doc, not needed for correctness); `merge-base` for the diff base (kept consistent with `/review-branch`); minor architectural-criteria overlap and frontmatter length.

## Review record

- 2026-10-11 — Spec reviewed by `feature-spec-reviewer`: VERDICT: READY FOR USER REVIEW. Presented to the user for sign-off.
- 2026-10-11 — Design reviewed by `feature-design-reviewer`: VERDICT: NEEDS WORK. Presented to the user for sign-off, with 1 open question.
- 2026-10-11 — Spec amended during design, with the user's approval: added point 6 (make `docs-structure-reviewer` stateless and delete this repository's memory for it) and narrowed the out-of-scope line to match. The reviewer's memory had turned into instructions, treating a feature in progress at review time as a defect. The user directed the change as a new sub-task of this feature rather than a separate feature.
- 2026-10-11 — Spec amended during design, with the user's approval: scope widened from "stop `/feature-end` running a docs review" to a docs review overhaul. Docs review now has three kinds (architectural, accuracy, style), each with a stateless agent, run by one generic `/review-docs` skill; `docs-structure-reviewer` is retired and its memory deleted; the model says when each kind is warranted, with "skip only when trivial and manifestly unneeded; when in doubt, run it". Feature retitled "Docs review overhaul". The user found the original fix exposed a larger problem ("not just a bit wrong, but needed quite a big houseclean") and settled the agent split, single skill, models and escalation boundary.
- 2026-10-11 — Rewritten spec reviewed by `feature-spec-reviewer` (two passes): VERDICT: READY FOR USER REVIEW. Presented to the user for sign-off, with 1 open question.
- 2026-10-11 — Redone design reviewed by `feature-design-reviewer` (two passes): VERDICT: NEEDS WORK. Presented to the user for sign-off, with 1 open question.
- 2026-10-11 — Spec amended during design, with the user's approval: `/review-docs` auto-applies minor fixes inside one doc from any agent (e.g. a link broken by a change elsewhere, a missing link) and escalates anything more significant (rewrites, or how information is divided between docs); skill and agent prompts are not docs.
- 2026-10-11 — Spec amended at the sub-task 5 user review, with the user's approval: added point 9 (user docs, agent docs and feature records are separate classes; user docs must never rely on the other two; feature records, including `FEATUREMODEL.md`, are not reviewed) and a fourth kind, agent docs, with its own agent `docs-review-agent-docs` (points 3-5). The earlier definition treated `CLAUDE.md` as an entry point and reviewed `features/`, implying people read them. Sub-task 5a added; the user review moved to its end.
- 2026-10-11 — Feature closed by /feature-end; all sign-off boxes ticked.
