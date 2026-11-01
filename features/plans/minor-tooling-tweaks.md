# Minor tooling tweaks — Feature Plan

## Handoff

**Last updated:** 2026-11-01
**Session summary:** All sub-tasks done and signed off, including the user review. Feature closed.
**Sub-task in progress:** None
**First action next session:** None; the feature is closed.
**Open questions / decisions pending:** None
**Dead ends to avoid:** None

## Requirements

From issue #77, "Minor tooling tweaks" (verbatim):

> Couple of minor things to fix up.
> - CLAUDE.md in the container says the container is "isolated". This was taken by at least one Claude session to mean having no outside access. It has no outside credentials, but it can read from the web. Worth clarifying the wording here.
> - When `claude-start` fails with credential errors, the error could say something useful, like "Run claude on your PC, do /login, then close claude and try again".

The issue has no comments.

## Spec

This feature makes small corrections to container mode (see `docs/container.md`), so that neither Claude inside the container nor the person starting it is misled or left stuck. Claude's instructions and the user docs should describe what the container can actually reach, and a failed login check on the host should tell the person how to fix it.

Issue #77 refers to a `claude-start` script, which does not exist. The script that starts a container is `bin/claude-run`, and this spec reads the issue as meaning that script.

### 1. The container's CLAUDE.md describes its access accurately

`docker/files/home/.claude/CLAUDE.md` is the global instructions file baked into the container image. It currently says the container is "isolated", and that it "has zero access to anything outside it". At least one session took this to mean it could not reach the web, which is false: the container has ordinary outbound network access.

The file must be reworded so that a Claude session reading it understands all of the following:

- It can read from the web, for example to fetch documentation or install packages.
- *Proposed:* it holds a limited set of credentials: the Claude login, and `GH_TOKEN` when one was supplied, which is there for reading GitHub issues. It holds no git remote credentials, and no credentials for cloud or other infrastructure.
- *Proposed:* it must still not try to change external systems. The existing instruction not to do so stays, but no longer claims that it could not do so anyway.

*Proposed:* the same file's statements that the container "holds only a copy of the code", that nothing done in it can touch the host, that it "is isolated from the host", and that the blast radius is limited to "this throwaway environment" are corrected as part of this. `/workspace` is the host's project directory mounted read-write, not a copy, so changes to it are real changes on the host. The freedom to act inside the container, and the instruction to install tools rather than stop for lack of them, are otherwise unchanged.

### 2. A failed login check says what to do

`bin/claude-run` checks the host's Claude login by running `claude -p hello --model haiku` before it starts a container. On failure it prints "Failed" and that command's output, then exits with status 1. The output alone does not tell the person how to recover.

After that output, a failed check must also print a recovery instruction, in substance: run `claude` on the host machine, use `/login`, exit `claude`, and run the same command again.

The instruction is printed on every failure of the check and worded conditionally ("If this is a login or credentials error, ..."). The check can fail for other reasons, such as usage limits, and matching on the text of Claude's error would break when that text changes.

*Proposed:* `bin/claude-creds-refresh` gets the same instruction. It runs the same check, and fails in the same way when the host's login has expired.

The exit status and the existing output are unchanged, and a successful check prints no new text.

### 3. The user docs match

`docs/container.md` must agree with requirements 1 and 2:

- *Proposed:* its list of what the container does gains a statement that the container has outbound network access.
- *Proposed:* it mentions the recovery step for a failed login check.

### 4. User docs stop calling the container "isolated"

"Isolated" wrongly suggests the container has no outside access, so `README.md` and `docs/container.md` must stop using it to describe the container. Each use becomes "restricted", with a short clarification of what is restricted where the sentence would otherwise be unclear. For example, the opening of `docs/container.md` can say that Claude has no git remote credentials but can reach the web and change the mounted project directory.

### Out of scope

- Changing what the container can actually reach: no network restrictions are added and no credentials are removed.
- Restructuring the login check, or diagnosing the cause of a failure.

## Sign-off strategy

A small change: one prose file, a few lines in two shell scripts, and a doc update. The main risk is wording that still misleads, or a claim about the container's access that is not true.

- **Testing.** Manual, by a scripted check with stub `claude` and `docker` commands placed on `PATH`, since a real login failure cannot be produced from inside the container. It passes when, for each of `bin/claude-run` and `bin/claude-creds-refresh`: a failing stub prints Claude's output and the recovery instruction, and exits with status 1; a succeeding stub prints no recovery instruction. The result is recorded in the sub-task's notes. No automated tests are added, because the repository has no test suite for `bin/`. The reworded `CLAUDE.md` has no test; the user review below covers it.
- **Documentation.** `docs/container.md` updated as in requirements 3 and 4. `README.md` updated as in requirement 4. A search of `docs/`, `README.md`, `setup-files/` and the root `CLAUDE.md` for "isolated" and other claims about the container's access is done, and each hit is fixed or justified in the sub-task's notes.
- **Code review (agent).** One `/review-branch` over the whole change before `/feature-end`.
- **Docs review (agent).** One `/review-docs` over the change, all kinds (accuracy, architectural, style, agent docs), before `/feature-end`.
- **User review.** Before `/feature-end`, the user reads the reworded `CLAUDE.md` and the recovery message, and confirms both.

## Design

### Overview

The feature is three independent small edits, with no new components. Sub-task 1 rewords the container's `CLAUDE.md` in place. Sub-task 2 adds one line of output to the failure branch of the login check in each of `bin/claude-run` and `bin/claude-creds-refresh`. Sub-task 3 brings the user docs into line, including replacing "isolated" with "restricted". The reworded `CLAUDE.md` reaches a container only once the image is rebuilt with `claude-build`, because it is baked in. New containers get the text after a rebuild. An existing container keeps the old text until it is recreated with `claude-stop` and `claude-run`, and no migration is attempted.

### Container `CLAUDE.md` wording

Only the sentences that make false claims change. The intended wording, which implementation may polish:

- **Opening paragraph:** "You are running inside a Docker container with full permissions. [Sandbox and permissions sentence unchanged.] `/workspace` is the host's project directory mounted read-write, so changes there are real changes on the host; everything else in the container is disposable. Operate freely and without hesitation."
- **Start of `## Installing and using tools`:** "You can read from the web, for example to fetch documentation or download packages. The container holds limited credentials: the Claude login and, if one was supplied, a `GH_TOKEN` for reading GitHub issues. It has no git remote credentials and no credentials for cloud or other infrastructure. So when you need a tool to do your job, **just install it** ..."
- **Closing paragraph of that section:** "You are not being asked to reach out and change real external systems, so do not try to", replacing "(and you can't from here anyway)".

The git-writes exception and the instruction to install tools stay exactly as they are.

This file drops the adjective rather than using "restricted" as the user docs do. Beside "full permissions" and "the sandbox is off", an unqualified "restricted" could again suggest no outside access, and requirement 1 has this file state the specifics instead.

### Recovery message

Both scripts print the same line straight after `cat "$check_output"`, before `exit 1`:

```
If this is a login or credentials error, run claude on this machine (not in a container), use /login, exit claude, and run this command again.
```

- **Duplicated line, not a shared helper.** The whole check is already duplicated in the two scripts, and the scripts can be run through symlinks (see `docs/container.md`), so a sourced file would need path resolution added to `claude-creds-refresh` for the sake of one line.
- **Stdout, not stderr.** "Failed" and Claude's output both go to stdout, so using stdout keeps the three in order when output is redirected.
- **"On this machine", not "on your PC".** The scripts always run on the host, which may not be a PC, and the bracket guards against someone trying `/login` inside the container, whose credentials are a copy.

### User docs

`docs/container.md` gets the network bullet and the recovery step. The step goes in `## Run the container`, the first place a person meets the check, and `## Refresh credentials mid-session` links to it rather than repeating it. "Isolated" becomes "restricted" at `README.md` lines 13 and 32 and `docs/container.md` lines 3 and 75. Line 3, and `README.md` line 13, also say what is restricted: no git remote credentials, and changes on the host limited to the mounted project directory. On line 3 this replaces the existing "the blast radius is limited to the mounted project directory" clause, which could be read as saying nothing outside the project can be affected. The other two are short references, where the word alone reads clearly.

The root `CLAUDE.md` says "Docker-based isolation mode" at line 95. It is not named in requirement 4, but it carries the same misleading word, so it is reworded to "Docker-based mode" under the Documentation search.

## Sub-tasks

**▶ NEXT:** None; all sub-tasks are complete.

> Run `/feature-checkpoint` after each sub-task completes.

Sub-tasks 1–3 carry no review boxes: code review, docs review and user review are all single end-of-feature gates in the strategy, held in sub-task 4.

### 1. Reword the container's CLAUDE.md ✓ (2026-11-01)

Correct `docker/files/home/.claude/CLAUDE.md` as in spec requirement 1, so it states what the container can reach and holds.

- [x] Documentation: the file states that the container can read from the web, lists the credentials it holds and those it lacks, says not to try to change external systems, and says `/workspace` is the host's directory mounted read-write
- [x] Documentation: a search of the file finds none of "isolated", "zero access", "only a copy", "throwaway", "blast radius", "touch the host", or "you can't from here"

### 2. Add the recovery message to the login check ✓ (2026-11-01)

Print the recovery line on a failed check in `bin/claude-run` and `bin/claude-creds-refresh`, as in spec requirement 2.

- [x] Testing: the stub check below passes for both scripts, with the result recorded in this sub-task's notes

Steps, run in a scratch directory with `claude` and `docker` stubs first on `PATH` and `HOME` set to a scratch directory holding a `.gitconfig` with a user name and email:

1. The `docker` stub exits 0, except that `docker inspect` prints `No such object` and exits 1 for `claude-run`, and is not consulted by `claude-creds-refresh` before the check.
2. With a `claude` stub that prints `STUB ERROR` and exits 1, run each script against a scratch project directory. Each must print `Failed`, `STUB ERROR` and the recovery line in that order, and exit with status 1.
3. With a `claude` stub that prints `hello` and exits 0, run each script again. Each must exit with status 0 and print neither `Failed` nor the recovery line.

Notes: stub check run on 2026-11-01 for both scripts. With the failing stub, each printed `Failed`, `STUB ERROR` and the recovery line in order and exited 1. With the succeeding stub, each exited 0 and printed neither `Failed` nor the recovery line.

### 3. Update the user docs ✓ (2026-11-01)

Make `docs/container.md`, `README.md` and the root `CLAUDE.md` match, as in spec requirements 3 and 4 and `## Design`.

- [x] Documentation: `docs/container.md` states that the container has outbound network access and gives the recovery step for a failed login check in `## Run the container`, and `## Refresh credentials mid-session` links to it
- [x] Documentation: `README.md` and `docs/container.md` no longer call the container "isolated", and use "restricted" with the clarifications set out in `## Design`
- [x] Documentation: a search of `docs/`, `README.md`, `setup-files/` and the root `CLAUDE.md` for "isolat", "zero access", "throwaway", "blast radius" and "copy of the code" is done, and each hit about the container is fixed or justified in this sub-task's notes

Notes: the search hits were `README.md` lines 13 and 32, `docs/container.md` lines 3 and 75, and the root `CLAUDE.md` line 95, all fixed. One remaining hit, in the resume section of `docs/container.md`, is not about the container's access, so it stays. The recovery step has its own `### If the login check fails` heading under `## Run the container`, giving the link a stable target.

### 4. Final sign-off criteria ✓ (2026-11-01)

End-of-feature gates for this feature, per `## Sign-off strategy`.

- [x] Code review (agent): /review-branch over all changed files; findings resolved or dismissed
- [x] Docs review (agent): /review-docs over the change, all kinds
- [x] User review: user reads the reworded container `CLAUDE.md` and the recovery message, and confirms both

Notes: `/review-branch` (no architectural review, on the user's choice) converged in two passes. Applied: `GH_TOKEN` described as intended for issues, "no git credentials configured" in place of "no git remote credentials", "writes" in place of "changes" on the host, a sync comment on the recovery line, and web access stated in the opening of `docs/container.md`. Dismissed: removing that web access statement as duplication, since stating it beside "restricted" is the point of #77. Noticed, not changed: `bin/claude-creds-refresh` leaves its `mktemp` file behind, which predates this feature.

`/review-docs` (all four kinds) converged in two passes, with five findings applied and none escalated. Not applied: trimming the access limits from `README.md` line 13, because a bare "restricted" could mislead on the landing page.

## Review record

- 2026-11-01 — Spec reviewed by `feature-spec-reviewer`: VERDICT: READY FOR USER REVIEW. Presented to the user for sign-off.
- 2026-11-01 — Design reviewed by `feature-design-reviewer`: VERDICT: READY FOR USER REVIEW. Presented to the user for sign-off.
- 2026-11-01 — Feature closed by /feature-end; all sign-off boxes ticked.
