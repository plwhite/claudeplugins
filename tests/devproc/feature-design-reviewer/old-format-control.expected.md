# Expected findings — `old-format-control.md`

**Flaw under test:** none. This is `control.md` with `## Sub-tasks` in the older
numbered-list format (`1. **Name** — description`, boxes indented beneath),
and `## Spec`'s requirements as numbered bold list items (`1. **Name.** text`),
both of which the heading format replaced. It checks that the reviewer accepts
the old formats rather than faulting them. Its content is otherwise identical
to `control`.

## Expected result

No BLOCKING findings and no MAJOR findings, and **no finding of any severity**
about the format of `## Sub-tasks` or of `## Spec` (that either should use
headings, or is a numbered list).

MINOR findings and SUGGESTIONs on other matters are tolerated, as for
`control`; the soft spots and corrections listed in `control.expected.md` apply
unchanged.

**Expected verdict:** `READY FOR USER REVIEW`

## Tolerated finding

The tolerated finding in `control.expected.md` applies unchanged; nothing else is
tolerated.
