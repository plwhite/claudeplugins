# Expected findings — `unheaded-requirements.md`

**Flaw under test:** the format of `## Spec`'s numbered requirements. This is
`control.md` with its "The export must:" bullets turned into four numbered bold
list items (`1. **Name.** text`). Every fact is still present and every other
section is unmodified `control.md` text. The numbered requirements are not each
their own heading, which the `Spec` entry in `features/FEATUREMODEL.md`
("Documents to support the model") requires wherever a spec numbers its
requirements.

## Required findings

1. A finding at **MAJOR** severity or higher against `## Spec`, marked
   **`[rewrite]`**, reporting that the numbered requirements (the four numbered
   list items) are not each their own heading. It should recommend converting
   each to an `N. Name` heading at the level `FEATUREMODEL.md` sets.

## Must not report

- Any BLOCKING or MAJOR finding against `## Requirements` or
  `## Sign-off strategy`, which are unmodified `control.md` text.
- Any finding that the requirements should be numbered, or any `[decision]`
  finding about the format; the fix is a rewrite.

MINOR findings and SUGGESTIONs on other matters are tolerated, as for `control`.

**Expected verdict:** `NEEDS WORK`
