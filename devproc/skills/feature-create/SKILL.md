---
name: feature-create
description: Create a new feature entry in features/PENDING.md
argument-hint: <feature description>
---

Create a new feature in the project.

Before proceeding, check that CLAUDE.md contains a Feature Model section.
If it doesn't, tell the user to run /feature-init first and stop.

The user has described the feature as: $ARGUMENTS

Steps:
1. If $ARGUMENTS looks like a GitHub issue reference — e.g. "issue 6", "issue #6", "#6", or natural language such as "the issue about improving error handling" — resolve it before proceeding:
   a. Run `git remote -v` and parse the owner/repo from the fetch URL (handles both HTTPS `https://github.com/owner/repo.git` and SSH `git@github.com:owner/repo.git`).
   b. For a numeric reference: run `gh issue view N --repo owner/repo --comments` to fetch the title, body, and comments.
   c. For a natural-language description: run `gh issue list --repo owner/repo --search "keywords" --limit 10 --json number,title,body` and select the best match, then fetch its comments with `gh issue view N --repo owner/repo --comments`.
   d. Use the issue title as the feature title. Write one or two sentences summarising what the issue covers for the `features/PENDING.md` entry — do not put the full issue body there. Include the issue number as a reference (e.g. `See #6.`). The full content goes into the slug file (step 5).
   e. If `gh` is not available or the lookup fails, tell the user and ask them to provide the description manually.

2. Read `features/PENDING.md` and `features/CURRENT.md` to understand existing features and avoid duplication.
3. Derive a short, descriptive slug for the feature (e.g. `add-french-divisions`, `deploy-visualisation`). Use lowercase-hyphenated format. Put that at the end of the feature title in square brackets as a tag (e.g. `[add-french-divisions]`).
4. Add a new entry at the top of `features/PENDING.md` (below its header blurb) with the format:

```
### <Feature title> [tag]

<One or two sentences describing what the feature covers and why.> Detail in [features/plans/<slug>.md](plans/<slug>.md).
```

Keep the description concise — no implementation detail, no sub-tasks. Those belong in the slug file.

5. Always create the slug file `features/plans/<slug>.md` with a `## Requirements` section, and a `## Design` placeholder that `/feature-start` will flesh out:

```markdown
# <Feature title> — Feature Plan

## Requirements

<requirements content — see below>

## Design

*To be fleshed out when the feature starts (`/feature-start`).*
```

   Populate the `## Requirements` section as follows:
   - **If the feature came from a GitHub issue:** copy the **entire** issue description verbatim (nothing in it should be assumed irrelevant), then add any comment that bears on design or requirements (e.g. "we should use tool X", "we must ensure Y holds"). Omit comments that are mere reactions or scheduling chatter ("great idea", "let's wait until next month"). Attribute the issue (e.g. "From issue #14 (verbatim):"). The objective is that a later session can pick up the feature from this file alone, without re-reading the issue.
   - **If the user supplied detailed requirements directly:** record them here verbatim or lightly tidied.
   - **If there is nothing beyond the one-or-two-sentence PENDING.md entry:** write `*No requirements beyond the summary in `features/PENDING.md`; design to be determined at `/feature-start`.*`

6. Confirm the new entry to the user as ready to proceed. Do not ask if they want to start the feature now (using `/feature-start`).
