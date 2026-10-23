# Expected findings — `headed-requirements-control.md`

**Flaw under test:** none. This is `control.md` with its "The export must:"
bullets turned into four numbered requirements, each a `####` heading
(`#### N. Name`) under a grouping `###` heading, in the format the `Spec`
entry in `features/FEATUREMODEL.md` sets. Its content is otherwise identical to
`control`. It checks that the reviewer accepts the new format rather than
over-flagging it.

## Expected result

No BLOCKING findings and no MAJOR findings, and **no finding of any severity**
about the format of the requirements (that they should be list items, or use a
different heading level or form).

MINOR findings and SUGGESTIONs on other matters are tolerated, as for
`control`; the corrections listed in `control.expected.md` apply unchanged.

**Expected verdict:** `READY FOR USER REVIEW`
