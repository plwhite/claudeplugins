# Upgrade to latest gh — Feature Plan

## Handoff

**Last updated:** 2026-10-11
**Session summary:** Ran both final sign-off gates after a container restart. `/review-branch` converged in 3 passes, with two wording fixes to `/feature-spec` steps 1b and 1c. `/review-docs` (accuracy, agent docs) found nothing to apply. Every sub-task is complete.
**Sub-task in progress:** None. The feature was closed by `/feature-end` on 2026-10-11.
**First action next session:** None. The feature is complete.
**Open questions / decisions pending:** None.
**Dead ends to avoid:** Docker is not available inside the development container, so the image cannot be built there.

## Requirements

From issue #70, "Upgrade to latest gh" (verbatim):

> The tooling uses gh that it gets from ubuntu. Unfortunately, the ubuntu version is out of date, even on ubuntu latest; better to set up the apt repository from GitHub itself and download that.

The issue has no comments.

Observed while specifying this feature (2026-10-11, inside the container): `ubuntu:latest` is currently Ubuntu 26.04, and its `gh` package is `2.46.0`. Running `gh issue view 70 --repo plwhite/claudeplugins --comments` with that version fails with:

```
GraphQL: Projects (classic) is being deprecated in favor of the new Projects experience, see: https://github.blog/changelog/2024-05-23-sunset-notice-projects-classic/. (repository.issue.projectCards)
```

The same issue was read successfully with `gh issue view 70 --json number,title,body,comments,state,labels`. The default `gh issue view` asks GitHub for a field that GitHub has retired, and asking for named `--json` fields avoids it. This is the command `/feature-spec` runs to read an issue, so the outdated package breaks the issue-reading route in container mode.

Found during implementation (2026-10-11): with the current `gh` (2.102.0) installed, `gh issue view N --comments` succeeds, but when stdout is not a terminal it prints only the comments, with no title or body. Claude's Bash tool never has a terminal, so `/feature-spec` would read an empty issue. In a terminal the same command prints the whole issue. The user decided (verbatim): "if you are not in a terminal it sounds like it does not do what we want. In that case, you should change the instructions (in the plugin and docs, not just NOTES.md) to say the correct format that does work in a non-terminal. Please make that change - it's logically a spec change, but comes out of a bug fix, and so you can make the spec and design change and apply it all at once."

## Spec

### Purpose

Container mode runs Claude inside a Docker image built from `docker/Dockerfile` (see [docs/container.md](../../docs/container.md)). The image installs the GitHub CLI, `gh`, which skills such as `/feature-spec` use to read GitHub issues. Today `gh` comes from Ubuntu's own package archive through `apt-get install gh`. That package lags well behind GitHub's releases, even on `ubuntu:latest`, and the version it ships (2.46.0) can no longer run `gh issue view N --comments` (see the error under `## Requirements`).

This feature makes the image install `gh` from GitHub's official apt repository, so the install step fetches the current release whenever it runs. Docker's layer cache affects when it runs (see item 2).

### What must be true when it is done

1. **`gh` comes from GitHub's apt repository.** `docker/Dockerfile` registers GitHub's official `gh` apt repository, with its signing key, following the Debian/Ubuntu instructions GitHub publishes for `gh` at <https://github.com/cli/cli/blob/trunk/docs/install_linux.md>. It installs `gh` from that repository. The image no longer installs `gh` from Ubuntu's archive.
2. **A build gets the latest release.** The version is not pinned: whenever the build runs the `gh` install step, it installs whatever release is current in GitHub's repository. This matches how the image already installs Claude Code (`npm install -g` with no version). A pinned version would have to be bumped by hand and would go stale, which is the problem this feature fixes. Docker's layer cache limits this. A `claude-build` with an unchanged Dockerfile reuses the cached install step, so it keeps the `gh` installed when that step last ran, exactly as Claude Code does today. Forcing a refresh on every build is out of scope (see below).
3. **Issue reading works in the container.** In a container started from a freshly built image, `gh --version` reports the release listed as latest at <https://github.com/cli/cli/releases>. `gh issue view N --repo owner/repo --comments`, run in a terminal, also prints a real issue without the `projectCards` error. (`/feature-spec` itself reads issues with `--json`; see item 6.)
4. **Nothing else in the image changes.** Apart from the steps and prerequisites needed to register GitHub's repository and install `gh` from it, every other package and step in the Dockerfile stays as it is. The image still builds from `ubuntu:latest`.
5. **The Dockerfile says why `gh` comes from GitHub.** Where the Dockerfile installs `gh`, a comment explains that it comes directly from GitHub's apt repository because Ubuntu's package is out of date. The user docs are not changed: where `gh` comes from is a code-level detail, and [docs/container.md](../../docs/container.md) only says `gh` is "installed in the image", which stays true. Any agent doc that describes the Dockerfile's contents is checked and updated to match. The `NOTES.md` entry on `gh issue view --comments` (#64; originally titled "`gh issue view --comments` fails on this repo; use `--json`") is also revised. It must say that the failure comes from older `gh` releases, such as Ubuntu's 2.46.0, and no longer happens in the container once this change lands. It keeps the `--json` fallback as advice for hosts that run an older `gh`.

6. **`/feature-spec` reads issues in a form that works without a terminal.** Steps 1b and 1c of `devproc/skills/feature-spec/SKILL.md` fetch an issue with `gh issue view N --repo owner/repo --json …` naming the fields they need, not with `--comments`. Run without a terminal, the command returns the issue's title, body and comments. Every other place in the plugin or the docs that tells Claude or a user to read an issue with `--comments` is changed the same way. Added during implementation.

### Out of scope

- *Proposed:* **The host's `gh` install.** [docs/setup.md](../../docs/setup.md) already sends users to <https://cli.github.com/>, which is GitHub's own source, so the host side has no stale-package problem to fix.
- **Refreshing `gh` on every build.** Defeating Docker's layer cache, for example by passing `--no-cache` or a changing build argument from `claude-build`, would also refresh Claude Code and every other package, and slow every build. It is a question for the whole image, not just `gh`. Added during design.

## Sign-off strategy

- **Testing (agent):** For the `/feature-spec` change, run the new commands without a terminal, against an issue with comments and one without, and confirm the title, body and comments all come back.
- **Testing:** A manual test, performed by the user, because it needs Docker on the host and this repository has no automated tests for the image. The user rebuilds the image with `claude-build`, starts a container with `claude-run`, and confirms both checks in Spec item 3: `gh --version` matches the latest release, and `gh issue view N --repo plwhite/claudeplugins --comments` prints the issue without the `projectCards` error.
- **Documentation:** A comment in the Dockerfile and a revised `NOTES.md` entry, as described in Spec item 5. No user docs change, by the user's decision: this is a code-level detail. Update any other agent doc only where it describes the changed install.
- **Code review (agent):** One `/review-branch` before `/feature-end`. The change is a few lines of Dockerfile, so per-sub-task review would add nothing.
- **Docs review (agent):** One `/review-docs` over the change, accuracy and agent docs kinds, before `/feature-end`. Agent docs is needed because `NOTES.md` changes and the agent docs describe the Dockerfile. Accuracy is needed because `docs/container.md` describes the `gh` in the image and must still be true. Architectural and style are skipped: no user doc is added, moved or reworded, so the change cannot affect the structure of the docs or how they read.
- **User review:** None as a separate sign-off. The user-performed manual test already puts the working result in front of the user.

## Design

### Overview

The change is confined to `docker/Dockerfile`, one `NOTES.md` entry and `/feature-spec`'s issue-reading steps. `gh` comes out of the existing `apt-get install` list. A new `RUN` step straight after that list registers GitHub's apt repository and installs `gh` from it. A comment on that step says why `gh` comes from GitHub rather than Ubuntu. `/feature-spec` reads issues with `--json` instead of `--comments`, because the current `gh` gives no title or body for `--comments` without a terminal (see "Reading issues without a terminal"). Nothing else in the image, the `bin/` scripts or the user docs changes. The user then rebuilds the image and checks, inside a container, that `gh` is current and that `gh issue view N --comments` works.

### The install step

The new step follows GitHub's published Debian/Ubuntu instructions (<https://github.com/cli/cli/blob/trunk/docs/install_linux.md>), adapted for a Dockerfile. It does five things:

1. Creates `/etc/apt/keyrings`.
2. Downloads GitHub's keyring, `https://cli.github.com/packages/githubcli-archive-keyring.gpg`, into it, readable by everyone.
3. Writes `/etc/apt/sources.list.d/github-cli.list` pointing at `https://cli.github.com/packages stable main`. The entry is signed by that keyring and uses the build machine's architecture from `dpkg --print-architecture`.
4. Runs `apt-get update` and `apt-get install -y gh`.
5. Removes `/var/lib/apt/lists/*`, as the existing install step does.

Its adaptations to GitHub's instructions, and why:

- **`curl` instead of `wget`.** GitHub's instructions use `wget` and install it if it is missing. `curl` is already in the image's package list, so using it avoids adding a package. That keeps Spec item 4's "nothing else changes" as tight as possible.
- **No `sudo`.** The step runs as root, before the Dockerfile switches to `USER claude`.
- **The implementer checks the published instructions when writing the step.** If GitHub has changed the keyring URL or repository line, the published version wins over the outline above.

### Placement

The step is a separate `RUN` straight after the existing `apt-get install` step. We do this, not add the repository inside that step, because the key download needs `curl`, and the existing step is what installs `curl`. Folding the two together would mean installing `curl` before the main install, which is a larger edit to a step that otherwise stays as it is. A separate step also keeps the `gh` install, and the comment explaining it, in one place.

### Reading issues without a terminal

`/feature-spec` steps 1b and 1c change from `--comments` to `--json`. Step 1b becomes `gh issue view N --repo owner/repo --json number,title,body,comments`, and step 1c fetches the chosen issue's comments with `--json comments`. The skill gives the reason in one clause, so a later editor does not switch back to `--comments`. The user docs need no change: no user doc names the command, and `docs/workflow.md` only says the issue is fetched "via `gh`", which stays true. The `NOTES.md` entry records the behaviour. We do not make `--comments` work by forcing a terminal (for example with `script`), because that output is formatted for people, with ANSI codes and line wrapping, and depends on a utility being installed.

### Rejected options

- **Download the `.deb` from GitHub's releases page.** This pins a version, or needs scripting to find the latest, and gets no signature check through apt. The issue asks for the apt repository.
- **Cache-bust the `gh` step in `claude-build`.** This is out of scope (see `## Spec`).

### Testing

Docker is not available inside the development container, so the image cannot be built there. The manual test is the user's, run on the host, with the steps written inline under the criterion in sub-task 1.

## Sub-tasks

**▶ NEXT:** None. The feature is complete.

> Run `/feature-checkpoint` after each sub-task completes.

### 1. Install `gh` from GitHub's apt repository ✓ (2026-10-11)

Take `gh` out of the existing `apt-get install` list in `docker/Dockerfile`. Add a new `RUN` step after it that installs `gh` from GitHub's apt repository as described in `## Design`, with a comment saying `gh` comes from GitHub because Ubuntu's package is out of date. Then confirm it works in a rebuilt container.

- [x] Testing (user): the user runs these steps on the host, and every check passes:
  1. Run `claude-build`. It completes without error.
  2. Start a container with `claude-run` and attach with `claude-attach`.
  3. In the container, run `gh --version`. It reports the same version as <https://github.com/cli/cli/releases/latest>. GitHub can publish a release there a little before it reaches the apt repository. If the versions differ, run `apt-cache policy gh` instead: the check passes if the installed version is also the candidate, and the candidate comes from `cli.github.com`.
  4. In the container, run `gh issue view 70 --repo plwhite/claudeplugins --comments`. It prints the issue with no `projectCards` error.
- [x] Documentation: the new `gh` install step in `docker/Dockerfile` carries a comment saying `gh` comes from GitHub's apt repository because Ubuntu's package is out of date. The `NOTES.md` entry on `gh issue view --comments` (#64; originally titled "`gh issue view --comments` fails on this repo; use `--json`") is revised as Spec item 5 requires. Every agent doc that describes the Dockerfile's contents (`CLAUDE.md`'s container mode list) has been checked, and updated if it no longer matches.
- The user reported on 2026-10-11 that all host-test steps passed.

### 1a. Read issues with `--json` in `/feature-spec` ✓ (2026-10-11)

Change `/feature-spec` steps 1b and 1c to fetch issues with `gh issue view --json` instead of `--comments`, as described in `## Design`. Added during implementation; the user approved the scope and asked for it to be done straight away.

- [x] Documentation: steps 1b and 1c of `devproc/skills/feature-spec/SKILL.md` use the `--json` form and say why. A search of the plugin and docs (`grep -rn -- '--comments'` outside `features/`) finds no remaining instruction to read an issue with `--comments`.
- [x] Testing (agent): run without a terminal, `gh issue view 70 --repo plwhite/claudeplugins --json number,title,body,comments` returns the title and body, and `gh issue view 38 --repo plwhite/claudeplugins --json number,title,body,comments` returns its body and its comment.

### 2. Final sign-off criteria ✓ (2026-10-11)

End-of-feature gates for this feature, per `## Sign-off strategy`.

- [x] Code review (agent): `/review-branch` over all changed files; findings resolved or dismissed
- [x] Docs review (agent): `/review-docs` over the change, accuracy and agent docs kinds; findings resolved or dismissed
- `/review-branch` (simplicity, general and nitty; no architectural pass) converged in 3 passes. Applied: two wording fixes to `/feature-spec` steps 1b and 1c. Dismissed:
  - dropping the "older `gh` fails" clause, which still matters on hosts;
  - listing `ca-certificates` explicitly, since it arrives with `curl` and adding it would change the tested image;
  - checking the key fingerprint, since the step follows GitHub's documented procedure;
  - `--state all` on the pre-existing `gh issue list` line, which is out of scope and a possible follow-up.
- `/review-docs` converged in 1 pass with nothing applied. One optional suggestion, mentioning the `gh` source in `CLAUDE.md`'s Dockerfile bullet, was not applied because the Dockerfile comment covers it.

## Review record

- 2026-10-11 — Spec reviewed by `feature-spec-reviewer`: VERDICT: READY FOR USER REVIEW. Presented to the user for sign-off.
- 2026-10-11 — Spec amended at the user's sign-off: the Dockerfile comment replaces the `docs/container.md` update; the docs review is narrowed to accuracy and agent docs to match. The user agreed the strategy and both proposals: the version is not pinned, and both out-of-scope items stay out.
- 2026-10-11 — Design reviewed by `feature-design-reviewer`: VERDICT: READY FOR USER REVIEW. Presented to the user for sign-off, with 1 open question (the amendment to Spec item 2).
- 2026-10-11 — Spec amended during design, with the user's approval: item 2 and the Purpose now state that Docker's layer cache keeps a previously installed `gh` on an unchanged rebuild; "Refreshing `gh` on every build" added to Out of scope, because forcing it would rebuild the whole image every time. The user also agreed the design and the sign-off criteria.
- 2026-10-11 — Spec amended during implementation, with the user's approval: item 6 added (`/feature-spec` reads issues with `--json`, not `--comments`, because current `gh` prints only the comments without a terminal) and the out-of-scope bullet on hardening `/feature-spec` removed. The design and sub-task 1a were added for it. The user asked for these to be made and applied at once, and will test and review.
- 2026-10-11 — Feature closed by /feature-end; all sign-off boxes ticked.
