# Expected findings — `misordered-criteria.md`

**Flaw under test:** delivery criteria — boxes out of performed order. Within a
sub-task, a box is listed before something it logically depends on. Everything
else, including `## Design`, is the clean baseline.

## Required findings

A **MAJOR** (or BLOCKING) finding, marked `[rewrite]`, covering **at least
one** of the two misorderings below, naming the sub-task and the pair of boxes:

1. **Sub-task 3** — the user review of an exported file is listed before the
   testing box whose manual export produces that file.
2. **Sub-task 4** — the testing box in which a reviewer follows the help page
   section end to end is listed before the documentation box that writes the
   section.

Reporting both is better; the case passes on either, since the point is that the
check fires.

## Also acceptable

- A single finding covering both misorderings, if it names each.

## Must not report

- Any **BLOCKING or MAJOR** finding against `## Design`, `## Requirements`,
  `## Spec` or `## Sign-off strategy`.
- Any finding about the heading format of `## Sub-tasks`.
- Any finding faulting sub-task 5 ("Final sign-off criteria").

**Expected verdict:** `NEEDS WORK`
