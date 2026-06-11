# Document security permissions in settings.json — Feature Plan

## Handoff

**Last updated:** 2026-05-04
**Session summary:** All sub-tasks complete. Docs-structure review surfaced four findings (two should-fix, two nits) — all addressed and verified clean on a re-review pass.
**Sub-task in progress:** None
**First action next session:** Run `/feature-end` to close out the feature.
**Open questions / decisions pending:** None
**Dead ends to avoid:** None

## Design

Issue #10 asks for documentation of a `permissions.deny` stanza in the global `settings.json`. The stanza prevents Claude from reading common sensitive files: `.env` files (top-level and nested), generic secrets files, PEM/key/p12 material, SSH private keys (`id_rsa`, `id_ed25519`), and `credentials.json`.

The natural home for this is `docs/setup.md`, which already covers sandbox configuration, git write protection, and the GitHub CLI setup. A new sub-section under "Sandbox configuration" (or as a sibling section directly after it) introduces the `permissions.deny` stanza, shows the JSON to merge, and explains the rationale: even within a sandbox, Claude may have legitimate read access to the project directory and adjacent paths, and these patterns provide a defence-in-depth block against accidental leakage of secrets in tool output, summaries, or generated artefacts.

The list of detailed steps at the top of `setup.md` should be updated so the new section is discoverable. The setup intro paragraph should also mention the secrets-blocking permissions alongside the other configuration goals.

The existing settings.json stanza shown in the doc already uses a top-level keys (`sandbox`, `hooks`); the new `permissions` key sits at the same level. The doc should make clear this is a merge, not a replacement.

No code changes are needed — this is documentation only.

## Sub-tasks

1. ✓ **Add permissions section to setup.md** — write a new section covering the `permissions.deny` stanza, with the JSON to merge and a one-paragraph rationale per pattern group (env files, generic secrets, keys, credentials). *(2026-05-04)*
2. ✓ **Wire the new section into setup.md navigation** — update the intro bullets and the "Detailed steps" list at the top of `setup.md` so the new section is linked and ordered correctly. *(2026-05-04)*
3. ✓ **Docs structure review** — run the docs-structure-reviewer agent over the changed file and address findings. *(2026-05-04)*
   - ✓ Converted prose into an imperative bullet for the "Edit `~/.claude/settings.json`" step.
   - ✓ Reworded intro bullet to verb-first form parallel with siblings.
   - ✓ Replaced "stanza" phrasing in the new section with the existing "add or merge the following" wording.
   - ✓ Updated the README docs-table row to mention the secret-file deny-list.
   - ✓ Re-reviewed: all findings verified resolved, no new issues.

**▶ NEXT:** Run `/feature-end`

> Run `/feature-checkpoint` after each sub-task completes.
