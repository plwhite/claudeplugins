---
name: feature-init
description: Initialises the feature model for this project. Run this once to enable feature workflows.
disable-model-invocation: true
---

Make updates to `CLAUDE.md` and the `features/` directory as required — see below
for details. This skill also **migrates** projects that still use the older
single-file layout (`FEATURES.md` plus a top-level `plans/` or `notes/`
directory). It is safe to re-run: on an already-migrated project it leaves the
existing content in place and only fills in anything missing. Do not change the
structure defined here.

## 1. Ensure features/FEATUREMODEL.md exists and is loaded by CLAUDE.md

The feature model (lifecycle, sign-off criteria, and the documents that support
it) is shipped as a canonical file, `FEATUREMODEL.md`, sitting alongside this
`SKILL.md` — not embedded in this document. Install it by copying that file and
adding an import to `CLAUDE.md`; never write the model text into `CLAUDE.md`
directly. The canonical file deliberately has no top-level heading — the
`## Feature model` section in `CLAUDE.md` supplies it — so the two never collide
once the import expands.

**a. Locate the canonical file.** This skill is told its own base directory (the
directory containing this `SKILL.md`) when it is invoked, and `FEATUREMODEL.md`
is in that directory. If you cannot determine the base directory, stop and ask
the user for the plugin's install path rather than guessing.

**b. Install (or refresh) `features/FEATUREMODEL.md` from the canonical file.**
Create the `features/` directory if needed and copy the canonical
`FEATUREMODEL.md` to `features/FEATUREMODEL.md` byte-for-byte, **replacing any
existing copy** so the project's model always matches the version shipped with
the plugin. The model is canonical boilerplate, not project-editable content, so
`/feature-init` is its update mechanism — this is the one file the skill
refreshes on every run, unlike the feature-list files and plans in later steps,
which hold project data and are always preserved. (To change the model, edit the
canonical `FEATUREMODEL.md` shipped with the skill and re-run `/feature-init`.)

**c. Ensure `CLAUDE.md` loads it.** Look at `CLAUDE.md`'s `## Feature model`
section and apply the single case that matches:

- **No `## Feature model` section** — add one whose entire body is the import
  line below.
- **Section present, but its body is not the live un-backticked import** —
  whether the body is the full embedded model text (an older initialised
  project, recognisable because it is more than the one-line import — e.g. it
  carries the model's own `### Sign-off criteria` / `### Resuming after a session
  restart` / `### Documents to support the model` sub-sections) or merely a
  backticked or Markdown-link mention of the path. Replace the model text (and
  any such inert mention) with the import line, removing the embedded
  sub-sections so nothing is left duplicated. If the section also holds other,
  non-model prose someone added by hand, preserve that and replace only the
  model content. (Step b has already ensured `features/FEATUREMODEL.md` holds
  the model text.)
- **Section present with the live un-backticked import already** — nothing to do.

The import line must be written as a **single physical line** in ordinary prose —
never inside backticks or a fenced code block, and never as a Markdown link, as
none of those forms load the file. The literal text to insert (the fenced block
below is display only — copy the sentence, as one physical line, without the
fence, and place it in `CLAUDE.md` as ordinary prose):

```
The feature model for this project — lifecycle, sign-off criteria, and the documents that support it — is defined in @features/FEATUREMODEL.md and applies at all times.
```

## 2. Migrate an older layout if present

Perform these older-layout migration steps before creating the fresh
feature-list files in step 3, so existing feature content is preserved rather
than overwritten. (Step 1 may already have created `features/` and
`features/FEATUREMODEL.md`; that is unrelated to the `FEATURES.md`/`plans/`
migration below.)

1. **Slug directory.** If a top-level `plans/` directory exists (or the older
   `notes/` directory), move it to `features/plans/`, preserving all its
   contents. Create the `features/` directory first if needed. If both a
   top-level `plans/` and `notes/` exist, move `plans/` to `features/plans/` and
   merge any `notes/` contents into it, then remove the empty `notes/`.

2. **FEATURES.md.** If `FEATURES.md` exists, split it into the four list files
   under `features/`, mapping its sections as follows:

   | `FEATURES.md` section   | Destination            |
   |-------------------------|------------------------|
   | `## In progress`        | `features/CURRENT.md`  |
   | `## Pending`            | `features/PENDING.md`  |
   | `## Explicitly deferred`| `features/DEFERRED.md` |
   | `## Completed`          | `features/COMPLETED.md`|

   Copy each section's `###` feature entries verbatim into the corresponding
   file under that file's standard header (see templates below). Then delete
   `FEATURES.md`. Update any links elsewhere in the repo that pointed at
   `FEATURES.md` or `plans/<slug>.md` to the new paths — at minimum check
   `CLAUDE.md` and any project README.

If neither `FEATURES.md` nor a top-level `plans/`/`notes/` directory exists,
there is nothing to migrate; continue to step 3.

## 3. Ensure the feature-list files exist

Create the `features/` directory if it does not exist. For each of the four list
files, create it from the template below **only if it does not already exist**
(do not overwrite a file that migration or a previous run produced):

`features/CURRENT.md`:

~~~markdown
# Features in progress

Features currently being developed. Each feature has a level three (`###`)
heading with a name and slug (e.g. `[initial-development]`) so its plan file in
`features/plans/` can be found.

*There should normally be only one feature here, and it should have a plan
matching the slug in `features/plans/`. In some cases there may be no feature in
progress, or in very rare cases more than one at once.*
~~~

`features/PENDING.md`:

~~~markdown
# Pending features

Features waiting for development. Each feature has a level three (`###`) heading
with a name and slug; detail lives in `features/plans/<slug>.md`.
~~~

`features/DEFERRED.md`:

~~~markdown
# Deferred features

Features that have been explicitly deferred — including those blocked by a
dependency. These are not expected to happen but may be resurrected.
~~~

`features/COMPLETED.md`:

~~~markdown
# Completed features

Features that have been completed, described to reflect what was actually
developed. Headings must end with the date of completion in YYYY-MM-DD format.
~~~

## 4. Ensure the plans directory exists

Create the `features/plans/` directory if it does not exist.

## 5. Ensure the tmp scratch directory exists and is git-ignored

Create `features/tmp/` if it does not exist, and create `features/tmp/README.md`
from the template below **only if it does not already exist** (do not overwrite
an existing one):

~~~markdown
# features/tmp

Scratch space for dropping requirements material — notes, documents,
screenshots — as input to `/feature-spec`. Contents here are git-ignored and
transient: `/feature-spec` captures anything it uses into the feature's plan
file and then removes it from here.

Do not use this directory to *track* requirements. Requirements live in
issues or, once captured, in the plan file under `features/plans/`.
~~~

Then ensure `.gitignore` at the repo root contains the following two lines,
so `features/tmp` contents are ignored but its README is kept:

```gitignore
features/tmp/*
!features/tmp/README.md
```

If `.gitignore` does not exist, create it with just these two lines. If it
already exists, add the two lines only if they are not already present
(check for both lines individually — do not add a duplicate of either).
`features/tmp/*` must come **before** `!features/tmp/README.md` — the negation
only takes effect after the ignore rule. So: if exactly one of the two lines is
present, add the missing one immediately adjacent (keeping `features/tmp/*`
above `!features/tmp/README.md`), not at the end of the file; and if both are
already present but in the wrong order, move `features/tmp/*` above the
negation.
