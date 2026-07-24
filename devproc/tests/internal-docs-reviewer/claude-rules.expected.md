# Expected findings — `claude-rules/`

**Flaw under test:** scope coverage plus currency. The agent must find and
review `.claude/rules/no-git-push.md`. Its "Enforcement" paragraph claims the
hook denies `git push` "unconditionally, for every branch including feature
branches", but the companion `.claude/hooks/block-git-push.sh` only blocks
`main`/`master` and explicitly allows other branches — a direct contradiction.

## Required findings

Exactly one finding against `.claude/rules/no-git-push.md`:

- **Anchor** — the "Enforcement" paragraph, at minimum the clause
  "unconditionally, for every branch including feature branches".
- **Gating class** — `stale` (contradicted by
  `.claude/hooks/block-git-push.sh`, which this agent reads to check the
  claim).
- **Action** — `condense` (the rule itself is still valid and worth keeping —
  only its description of scope is wrong; unlike the `stale/` case, there is a
  clear correct replacement to condense to). Replacement text should state
  that the hook blocks `git push` to `main`/`master` only, not every branch. A
  `delete` action is not appropriate here, since the rule's purpose (blocking
  unreviewed pushes to protected branches) remains real and correctly
  described elsewhere in the same file.

## Must not report

- Any `redundant` or `judgment` finding — this fixture only plants a
  contradiction.
- Any finding against the file's title or first paragraph (the rule's stated
  purpose) — only the "Enforcement" paragraph's scope claim is wrong.
- Any finding against `.claude/hooks/block-git-push.sh` — out of the agent's
  scope-in list (not `CLAUDE.md`, `NOTES.md`, or `.claude/rules/*.md`); it
  exists only to be checked against.
- A missed rules file: the case fails if the agent reports nothing at all,
  since that would mean it never found `.claude/rules/no-git-push.md`.
