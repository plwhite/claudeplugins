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

7. Confirm the new feature and its spec to the user, and **present the proposed sign-off strategy for them to agree or adjust** — this is the user's chance to raise or relax the quality bar before design. Update the `## Sign-off strategy` section to match what they settle on. Do not ask if they want to design it now (using `/feature-design`).
