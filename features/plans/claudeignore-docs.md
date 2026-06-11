# Add a .claudeignore setup — Feature Plan

## Handoff

**Last updated:** 2026-05-04
**Session summary:** All sub-tasks complete. Docs-structure review surfaced one should-fix (intro/detailed-steps mismatch) and several nits across `docs/setup.md`, `setup-files/README.md`, and root `README.md`; all addressed and verified clean on a re-review pass. CLAUDE.md status drift was deliberately deferred to `/feature-end`.
**Sub-task in progress:** None
**First action next session:** Run `/feature-end` to close out the feature.
**Open questions / decisions pending:** None
**Dead ends to avoid:** None

## Design

Issue #9 asks for a recommended `.claudeignore` to be added at the project root, listing high-noise / low-value paths that Claude should not scan speculatively. The user has expanded the scope: rather than only documenting the file's contents, check the file into the repo and instruct users to copy it into place. The same treatment should be applied to `block-git-writes.sh`, which is currently inlined as a heredoc in `docs/setup.md`.

### New directory: `setup-files/`

Create a new top-level `setup-files/` directory holding files that users copy into their environments during setup. This sits alongside `demo/`, `devproc/`, `docs/`, and `plans/`. Initial contents:

- `setup-files/.claudeignore` — drop into the user's project root.
- `setup-files/block-git-writes.sh` — drop into `~/.claude/hooks/`.
- `setup-files/README.md` — one paragraph plus a one-line summary per file, telling the reader where each file is meant to land.

The user already follows a `git clone https://github.com/plwhite/claudeplugins /some/path/claudeplugins` step (see `docs/setup.md` "Make the devproc plugin available locally"). The files are therefore on disk after that step; the setup instructions can `cp` from the cloned location.

The directory name `setup-files/` is chosen for clarity: it pairs naturally with `docs/setup.md` and reads as "files referenced by setup". Alternatives considered — `templates/` (implies edit-before-use, which most of these don't need), `resources/` (too generic), `dotfiles/` (the script isn't a dotfile) — were rejected.

### `.claudeignore` content

Use the pattern set from issue #9 verbatim, organised by section comments (Dependencies, Build output, Compiled / minified assets, Lockfiles, Test snapshots & coverage, Logs & temp, Large data / binary, IDE & OS cruft). Keep the tree-style header comments from the issue body.

### Refactor of `block-git-writes.sh`

The script body in `docs/setup.md` (lines ~71–87) becomes the contents of `setup-files/block-git-writes.sh`. The setup.md sub-section "Sandbox configuration" then changes from "run this heredoc" to "copy this file into place and `chmod +x` it". The reference to `block-git-writes.sh` from the `settings.json` JSON block above it stays unchanged — the destination path is still `~/.claude/hooks/block-git-writes.sh`.

### Changes to `docs/setup.md`

- Replace the existing heredoc-based instructions for `block-git-writes.sh` with copy-from-repo instructions.
- Add a new sibling sub-section under "Detailed steps", titled "Configure .claudeignore", placed after "Block reads of sensitive files" and before "Install and authenticate GitHub CLI". This section explains what `.claudeignore` does, gives the copy command, and notes that the file should be repeated per project.
- Update the intro bullet list to mention the `.claudeignore` setup.
- Update the "Detailed steps" navigation list to add the new step and renumber.
- Note in the section that the cloned repo path holds the source files (referencing the same path used in the plugin-install step).

### Changes to `README.md`

Update the docs table row for `docs/setup.md` to mention `.claudeignore` setup. Optionally add a short pointer to `setup-files/` in the README — it's a piece of the repo a reader can usefully discover.

### Out of scope

- A script or tool to install `.claudeignore` automatically (issue #9 mentions "or write a script or tool"). The copy-from-repo flow is simpler and consistent with how `block-git-writes.sh` will now be handled. Revisit only if friction emerges.
- Any change to existing in-progress projects to add `.claudeignore` retroactively — this is documentation for future setup, not an audit.

## Sub-tasks

1. ✓ **Create `setup-files/` with `.claudeignore`** — add the new directory and check in `.claudeignore` using the pattern set from issue #9. *(2026-05-04)*
2. ✓ **Move `block-git-writes.sh` into `setup-files/`** — extract the script body from `docs/setup.md` into a checked-in file, preserving the exact contents. *(2026-05-04)*
3. ✓ **Add `setup-files/README.md`** — one paragraph plus a one-line summary per file (where it goes, what it does). *(2026-05-04)*
4. ✓ **Refactor `docs/setup.md`** — replace the heredoc for `block-git-writes.sh` with copy-from-repo instructions; add a new "Configure .claudeignore" sub-section; update intro bullets and the "Detailed steps" navigation list. *(2026-05-04)*
   - ✓ Heredoc replaced with `mkdir -p` / `cp` / `chmod +x`.
   - ✓ Extracted `git clone` step into a new "Clone this repository" sub-section so subsequent `cp` steps have a defined source path. (Scope expansion vs. original plan — recorded in NOTES.md.)
   - ✓ Renamed "Make the devproc plugin available locally" → "Enable the devproc plugin".
   - ✓ Added "Configure .claudeignore" section.
   - ✓ Updated intro bullets and "Detailed steps" list (now 8 entries).
5. ✓ **Update root `README.md`** — refresh the docs-table row for setup.md to mention `.claudeignore`; consider a pointer to `setup-files/`. *(2026-05-04)*
   - ✓ Added `.claudeignore` to the `docs/setup.md` coverage cell.
   - ✓ Added a new row for `setup-files/README.md` so the resource directory is discoverable.
   - ✓ Cleaned up "Documented in" links in `setup-files/README.md` to be plain section-anchor links (per user feedback).
6. ✓ **Docs structure review** — run the docs-structure-reviewer over the changed files and address findings. *(2026-05-04)*
   - ✓ Reframed `docs/setup.md` intro lead-in as "at a high level, you will:" so bullets read as goals rather than enumerated steps.
   - ✓ Removed leftover "copy verbatim" phrasing from the sandbox sub-section.
   - ✓ Added a forward-reference from "Clone this repository" listing the three sections that reuse the path.
   - ✓ Replaced the in-prose category enumeration in the `.claudeignore` section with a pointer to the file's own section comments.
   - ✓ Reordered `setup-files/README.md` rows to match `docs/setup.md` step order.
   - ✓ Normalised the root `README.md` docs-table cell to "sensitive-file deny-list".
   - Re-reviewed: convergence confirmed; no new issues.
   - Deferred to `/feature-end`: CLAUDE.md status block flip.

**▶ NEXT:** Run `/feature-end`

> Run `/feature-checkpoint` after each sub-task completes.
