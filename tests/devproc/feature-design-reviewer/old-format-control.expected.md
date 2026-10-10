# Expected findings — `old-format-control.md`

**Flaw under test:** none. This is `control.md` with `## Sub-tasks` in the older
numbered-list format (`1. **Name** — description`, boxes indented beneath),
which the heading format replaced. It checks that the reviewer accepts the old
format rather than faulting it. Its content is otherwise identical to `control`.

## Expected result

No BLOCKING findings and no MAJOR findings, and **no finding of any severity**
about the format of `## Sub-tasks` (that it should use headings, or is a
numbered list).

MINOR findings and SUGGESTIONs on other matters are tolerated, as for
`control`; the soft spots and corrections listed in `control.expected.md` apply
unchanged.

**Expected verdict:** `READY FOR USER REVIEW`
