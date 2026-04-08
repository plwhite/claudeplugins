---
name: feature-create
description: Create a new feature entry in FEATURES.md
argument-hint: <feature description>
---

Create a new feature in the project.

The user has described the feature as: $ARGUMENTS

Steps:
1. Read `FEATURES.md` to understand existing features and avoid duplication.
2. Derive a short, descriptive slug for the feature (e.g. `add-french-divisions`, `deploy-visualisation`). Use lowercase-hyphenated format.
3. Determine which components are affected: `[data]`, `[divisionfinder]`, `[visualisation]` — include all that apply.
4. Add a new entry at the top of the `## Pending` section in `FEATURES.md` with the format:

```
### <Feature title> [tags]

<One or two sentences describing what the feature covers and why.>
```

Keep the description concise — no implementation detail, no sub-tasks. Those belong in a plan file created when the feature starts.

5. Confirm the new entry to the user as ready to proceed. Do not ask if they want to start the feature now (using `/feature-start`).
