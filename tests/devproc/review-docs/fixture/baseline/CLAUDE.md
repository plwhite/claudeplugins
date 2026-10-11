# greeter

Small CLI that prints a greeting.

Layout: `bin/greet.sh`, `bin/cleanup.sh`, `Makefile`, `docs/` (including
`docs/troubleshooting.md`), `skills/greet/SKILL.md`, `features/`.

## Cache expiry

Cached greetings expire after 7 days. `bin/cleanup.sh` clears all of them at
once, whatever their age.

## Building a release tarball

1. Run `make dist VERSION=1.2` (use the real version number).
2. The tarball `greeter-1.2.tar.gz` appears in the current directory.
3. Upload it to the project's release page.

## Current status

Feature in progress: colour-output (see `features/CURRENT.md`).
