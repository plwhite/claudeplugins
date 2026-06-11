# Split FEATURES.md into separate files to save tokens [split-features-md]

## Requirements

From issue #14 (verbatim):

> `FEATURES.md` is a single file, which means that it needs to be read in its entirety.
>
> Better to have a directory `features/` with four files in it: CURRENT.md, PENDING.md, BLOCKED.md and COMPLETED.md. Over time, COMPLETED.md may get large, but that will not have to be read into the context window all the time.
>
> Full set of changes for this fix involves changing the skills relating to features as follows
> - The `notes` directory is a bad name. Rename to `features`
> - Move the `FEATURES.md` file into the `features` directory, and split it into `CURRENT.md`, `PENDING.md`, `BLOCKED.md` and `COMPLETED.md`
> - Tweak `/feature-create` such that it always creates a slug file and copies the relevant content from the issue into that slug file.
> - Tweak `/feature-init` for all of the above, including the change that if there is a `notes` directory it should be renamed; if there is a `FEATURES.md` file, it should be split up; `CLAUDE.md` should be updated etc.

Additional requirement from the feature request: `/feature-create` must copy the **whole content** of the issue description into the slug file (not just a summary), together with any relevant information from the comments on the issue.

## Design

*To be fleshed out when the feature starts (`/feature-start`).*
