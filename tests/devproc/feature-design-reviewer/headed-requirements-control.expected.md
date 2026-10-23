# Expected findings — `headed-requirements-control.md`

**Flaw under test:** none. This is `control.md` with `## Spec`'s "The export
must:" bullets turned into four numbered requirements, each a `####` heading
(`#### N. Name`) under a grouping `###` heading, in the format the `Spec` entry
in `features/FEATUREMODEL.md` sets. Its content is otherwise identical to `control`. It checks that
requirement coverage is traced from requirement headings, and that the format
draws no finding.

## Expected result

No BLOCKING findings and no MAJOR findings, and **no finding of any severity**
about the format of `## Spec`.

MINOR findings and SUGGESTIONs on other matters are tolerated, as for
`control`; the soft spots and corrections listed in `control.expected.md`
apply unchanged.

**Expected verdict:** `READY FOR USER REVIEW`

## Tolerated finding

The tolerated finding in `control.expected.md` applies unchanged; nothing else is
tolerated.
