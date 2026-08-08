# Expected findings — `incomplete-spec.md`

**Flaw under test:** completeness and clarity of `## Spec`. It defers to
`## Requirements` instead of restating the detail, and states only vague,
unquantified goals. `## Requirements` is the clean control text (full verbatim
issue capture) and the sign-off strategy is the clean one from `control.md`;
neither must be faulted.

*(Relocated 2026-08-09, and renamed from `incomplete-requirements`: this
fixture's flaw previously lived in `## Requirements`, deferring to the source
issue — a check `feature-spec-reviewer` no longer applies to `## Requirements`
as the statement of what the feature must do. The flaw is now that `## Spec`
defers to `## Requirements` instead of doing its own job — the direct
counterpart of the old flaw, and a natural fit for the new "does everything in
`## Requirements` show up in `## Spec`" check.)*

## Required findings

At least one finding at **BLOCKING** or **MAJOR** severity against `## Spec`,
marked `[rewrite]` or `[decision]`, covering:

1. **Deferral to `## Requirements`** — the section says "See `## Requirements`
   above for the formatting detail" instead of stating what the feature must
   do, so nothing in `## Spec` accounts for the date format, number format,
   column set and order, or file naming already present in `## Requirements`.
   This specific point must be reported.

The findings should also raise at least two of:

2. **Vague terms** — "work well for how finance uses spreadsheets" and
   "sensibly" carry weight but are undefined; two competent readers would not
   agree on what done looks like.
3. **No scope boundary** — `## Spec` says nothing about what is out of scope
   (e.g. Excel export, scheduled exports), even though `## Requirements`
   states one; scope is open-ended as written.
4. **Unquantified constraint** — "handle large reports sensibly" states no
   size and no behaviour, even though `## Requirements` gives the 200,000-row
   figure.
5. **Undefined formatting requirements** — the date format, number formatting,
   column set and order, and file naming are not restated in `## Spec` at all.

## Must not report

- Any **BLOCKING or MAJOR** finding against `## Requirements` or `## Sign-off
  strategy`, which are the clean control text. MINOR findings and SUGGESTIONs
  there are tolerated — a reviewer may legitimately notice polish anywhere, and
  a vague or incomplete spec can genuinely make a sign-off criterion harder to
  audit.
- Any finding faulting the absence of a design.

**Expected verdict:** `NEEDS WORK`
