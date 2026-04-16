# Docs and usability improvements — Feature Plan

## Handoff

**Last updated:** 2026-04-16
**Session summary:** Feature plan created. Implementation not yet started.
**Sub-task in progress:** None
**First action next session:** Begin Sub-task 1 — investigate sandbox network config for `gh`
**Open questions / decisions pending:** None
**Dead ends to avoid:** Do not add `WebFetch(domain:api.github.com)` thinking it will fix `gh` in Bash — it only affects Claude's WebFetch tool, not Bash processes.

---

## Design

The repo is being repositioned: currently it presents as "here are some Claude plugins." The goal is to present it as "here is how to configure Claude for a productive development workflow — with best practices for sandbox, git safety, and GitHub integration — and here is the devproc plugin that supports that workflow."

Joe Developer finds this repo, follows the docs start to finish, and ends up with: sandbox on and correctly configured, git write operations blocked, `gh` installed and working inside sandbox, devproc installed and active, and a clear understanding of the feature workflow. The plugin is the enabler, not the point.

**Information architecture after this feature:**
- Root `README.md` — reframed entry point: "Claude best practice collection." Short intro, then links to `docs/setup.md`, `docs/workflow.md`, and individual plugin docs.
- `docs/setup.md` (new) — the authoritative getting-started guide: sandbox config, `gh` install, git write protection, devproc install.
- `docs/workflow.md` (new) — imperative task-oriented guide; covers the things a user actually wants to do ("to start a new feature, do the following..."). Draws from devproc/README.md but reframed as instructions rather than capability descriptions. Broader scope than devproc alone — this is the day-to-day reference.
- `devproc/README.md` — remains the devproc plugin reference. Keeps plugin-specific setup (`/feature-init`), the skill/agent inventory, and the skill reference. Points to `docs/workflow.md` for the workflow perspective.
- `demo/README.md` — unchanged (internal).

**Sub-task ordering and dependencies:**
Sub-task 1 (sandbox research) feeds into Sub-task 2 (setup.md + README). Sub-task 3 (workflow.md) can proceed after Sub-task 2 since it draws from devproc/README.md content. Sub-task 4 (devproc README trim) follows Sub-task 3. Sub-task 5 (issue-aware skills) is independent.

**Sub-task 1 — Research sandbox network config for `gh`:** The sandbox blocks outbound Bash network. `WebFetch(domain:api.github.com)` in permissions is irrelevant — it only covers Claude's WebFetch tool. Research the correct settings.json sandbox network allowlist config to allow `gh`, determine whether it belongs in global or project settings, and document the finding in NOTES.md. Output feeds `docs/setup.md`.

**Sub-task 2 — Write `docs/setup.md` and rewrite root `README.md`:** Create a new `docs/setup.md` covering: (1) sandbox on + network config for `gh`, (2) git write-protection hook, (3) `gh` install and auth, (4) devproc install (`extraKnownMarketplaces` + `enabledPlugins`). Rewrite root `README.md` to lead with the "best practice" framing, provide a brief orientation, and direct users to `docs/setup.md` and `docs/workflow.md`.

**Sub-task 3 — Write `docs/workflow.md`:** Imperative, task-oriented workflow guide. Each section answers "I want to do X — here's how." Tasks include: start a new feature, work through sub-tasks, handle a session restart, run a code review, and use issue references. Draws on devproc/README.md for source material but written as instructions, not capability descriptions.

**Sub-task 4 — Trim and reorient `devproc/README.md`:** Keep plugin-specific setup (`/feature-init` steps, skill/agent inventory, skill reference). Remove any content that duplicates `docs/workflow.md`. Add pointer to `docs/workflow.md` at the top for the task-oriented view.

**Sub-task 5 — Issue-aware skills:** When a user references a GitHub issue in `/feature-create` or `/feature-start` (e.g. "issue 6", "the GitHub issue about frogs"), the skill should: (1) call `git remote -v` to identify owner/repo, (2) call `gh issue view N` or `gh issue list --search "..."` for fuzzy descriptions, (3) use the issue title and body as the feature description or context. Update `feature-create/SKILL.md` and `feature-start/SKILL.md`, and add an example to `docs/workflow.md`.

---

## Sub-tasks

1. **Research sandbox network config for `gh`** — find the correct settings.json config; record in NOTES.md; output feeds Sub-task 2
2. **Write `docs/setup.md` and reframe root `README.md`** — getting-started guide; README repositioned as "best practice collection"
3. **Write `docs/workflow.md`** — imperative task-oriented guide drawing from devproc/README.md; covers daily workflow tasks
4. **Trim `devproc/README.md`** — keep plugin setup and reference; remove workflow content now in docs/; add pointer to docs/workflow.md
5. **Update feature-create and feature-start skills for issue-aware input** — resolve "issue N" / natural-language issue references via `git remote -v` + `gh`; add example to docs/workflow.md

**▶ NEXT:** Sub-task 1

> Run `/feature-checkpoint` after each sub-task completes.
