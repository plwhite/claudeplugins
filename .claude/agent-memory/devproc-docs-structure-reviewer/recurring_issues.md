---
name: Recurring issues
description: Structural and style problems observed across reviews of this repo
type: project
---

(Prior history retained — see git log for older entries.)

## Ninth review (2026-05-04) — security-permissions-docs feature close-out

Scope: new "Block reads of sensitive files" section in `docs/setup.md`, README docs-table row update.

Findings:
- MAJOR: CLAUDE.md "Current status" still reads `**In progress: security-permissions-docs**` while the task is described as a close-out for `/feature-end`. Either /feature-end has not yet been run (process gap) or CLAUDE.md was not refreshed during checkpoint. The completed-feature framing in the task brief contradicts the live status block.
- MINOR: docs/setup.md "Detailed steps" list shows 6 steps but the intro bullets above it list only 4 of those goals (sandbox, git lockdown, secret-file blocking, plugin install) — the GitHub CLI install (step 4) and the per-repo plugin init (step 6) are absent from the intro framing. Mildly inconsistent but not blocking.
- MINOR: docs/setup.md "Block reads of sensitive files" section: the "Edit ~/.claude/settings.json …" bullet contains a complete, copy-pasteable JSON snippet that is *only* the `permissions` key. A reader following along literally and pasting this would overwrite the file. The instruction says "add or merge … do not replace them", but the snippet itself does not include the surrounding sandbox/hooks keys to make the merge target obvious. Sandbox section has the same shape, so this is consistent — flag as a class-wide minor.
- NIT: docs/setup.md line 13 — "this is 'how to configure your system in the right way for me'" is informal and slightly opaque; consider "this reflects one working configuration; tweak to taste".
- NIT: README.md docs-table row for setup.md says "secret-file deny-list" — accurate but mildly jargon. "blocked sensitive-file reads" or similar would parallel the in-doc heading "Block reads of sensitive files" more closely.

No CRITICAL findings. No new orphaned documents. CONTRIBUTING.md remains linked from README.md (verified). All cross-references between docs/setup.md, docs/workflow.md, docs/capabilities.md, devproc/README.md, FEATURES.md, plans/security-permissions-docs.md confirmed live.

Recurring patterns to watch:
- CLAUDE.md status drift at feature close-out (third occurrence of "in-progress label not flipped before docs review runs").
- `permissions`/`sandbox`/`hooks` JSON snippets in setup.md show a single top-level key in isolation, relying on prose to convey "merge with existing keys". A reader who skims may overwrite. Could warrant a single combined example block.

## Tenth review (2026-05-04) — claudeignore-docs feature close-out (issue #9)

Scope: new `setup-files/` directory (`.claudeignore`, `block-git-writes.sh`, `README.md`); restructured `docs/setup.md` (8-step ordered list, new Clone/Configure-claudeignore sub-sections, hook moved out of heredoc); root README docs-table updated.

Findings:
- SHOULD-FIX: CLAUDE.md "Current status" still reads `In progress: claudeignore-docs` at close-out review time. FOURTH occurrence of this drift.
- SHOULD-FIX: docs/setup.md intro bullets list 5 goals; Detailed steps lists 8. Clone/gh/init missing from intro framing. SECOND consecutive review flagging an intro vs detailed-steps mismatch in this file.
- NIT: setup.md line 87 — "copy verbatim" is residual heredoc-era wording.
- NIT: setup.md Clone section lacks forward-reference to sections that reuse the path.
- NIT: `.claudeignore` category list is duplicated three places (setup.md prose, file comments, setup-files/README.md Purpose column).
- NIT: setup-files/README.md table row order (`.claudeignore` first) does not match setup.md step order (hook first).
- NIT: root README docs-table coverage cell mixes verb-noun and bare-noun phrasing.

All 8 anchor links in setup.md "Detailed steps" verified to resolve. Both anchors in setup-files/README.md (`#configure-claudeignore`, `#sandbox-configuration`) verified. No orphaned documents introduced.

Recurring patterns now strongly established:
- CLAUDE.md status block flip at /feature-end is unreliable. Worth treating as a process bug rather than a per-feature reminder.
- docs/setup.md intro bullets vs Detailed steps drift each time a step is added (twice in a row now).

## Eleventh review (2026-05-04) — claudeignore-docs final close-out pass

Scope: cross-doc consistency check after sub-task 6 + status-block flip.

Verified clean:
- CLAUDE.md "Current status" now reads "No feature currently in progress" with claudeignore-docs as recently completed. Drift recurrence finally resolved.
- New "## setup-files directory" section sits between "## devproc plugin" and "## Feature model" in CLAUDE.md, mirrors demo/devproc section style (Location / one-line purpose / Contents bullets), and adds the rule for new files.
- FEATURES.md entry moved to Completed, dated 2026-05-04, single multi-sentence paragraph, no tables/sub-task lists. Matches Feature-model schema.
- Full hierarchy (root README → docs/{setup,workflow,capabilities}.md → devproc/README.md → demo/README.md → setup-files/README.md → plans) cross-resolves with no broken links or orphans. README docs-table row for setup-files/README.md is live; setup-files/README.md back-links to docs/setup.md sections; setup.md forward-references to setup-files paths all match.

No findings.
