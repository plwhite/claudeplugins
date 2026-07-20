# Expected findings — `non-auditable-criteria.md`

**Flaw under test:** delivery criteria. The `## Sign-off strategy` entries are
not auditable, and two categories are silently absent. The `## Requirements`
section is the clean one from `control.md` and must not be faulted.

## Required findings

Findings against `## Sign-off strategy` at **BLOCKING** or **MAJOR** severity
covering **all three** of:

1. **Testing is not auditable** — "Have good test coverage" has no clear yes/no
   at the point a sub-task finishes. Must be reported, with a recommendation
   that gives auditable wording.
2. **Documentation is not auditable** — "Update the docs as needed" leaves both
   the scope and the done point undefined. Must be reported.
3. **Missing categories** — code review and user review are absent entirely,
   rather than being recorded as an explicit "None — <reason>". Must be
   reported. A single finding naming both categories is acceptable.

At least one finding should note that the bar is conspicuously light given the
change is user-facing and the data goes to finance.

## Must not report

- Any **BLOCKING or MAJOR** finding against `## Requirements`, which is the
  clean control text. MINOR findings and SUGGESTIONs there are tolerated.
- Any finding faulting the absence of a design.

**Expected verdict:** `NEEDS WORK`
