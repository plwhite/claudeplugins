---
name: feature-create
description: Create a new feature entry in FEATURES.md
argument-hint: <feature description>
---

Create a new feature in the project.

Before proceeding, check that CLAUDE.md contains a Feature Model section.
If it doesn't, tell the user to run /feature-init first and stop.

The user has described the feature as: $ARGUMENTS

Steps:
1. Read `FEATURES.md` to understand existing features and avoid duplication.
2. Derive a short, descriptive slug for the feature (e.g. `add-french-divisions`, `deploy-visualisation`). Use lowercase-hyphenated format. Put that at the end of the feature title in square brackets as a tag (e.g. `[add-french-divisions]`).
3. Add a new entry at the top of the `## Pending` section in `FEATURES.md` with the format:

```
### <Feature title> [tag]

<One or two sentences describing what the feature covers and why.>
```

Keep the description concise — no implementation detail, no sub-tasks. Those belong in a plan file created when the feature starts.

4. Confirm the new entry to the user as ready to proceed. Do not ask if they want to start the feature now (using `/feature-start`).
