# Expected findings — `incomplete-requirements.md`

**Flaw under test:** completeness and clarity. The `## Requirements` section
summarises the source issue away and defers to it, leaving the actual
requirements uncaptured. The sign-off strategy is the clean one from
`control.md` and must not be faulted.

## Required findings

At least one finding at **BLOCKING** or **MAJOR** severity against
`## Requirements`, marked `[rewrite]` or `[decision]`, covering:

1. **Deferral to the issue** — the section points at issue #47 ("See issue #47
   for the full detail") instead of capturing it, so a fresh session cannot work
   from this file alone. This specific point must be reported.

The findings should also raise at least two of:

2. **Undefined formatting requirements** — the date format, number formatting,
   column set and order, and file naming are alluded to ("including the
   formatting points") but never stated.
3. **Vague terms** — "work well for them", "sensibly", and "the obvious place"
   carry weight but are undefined; two readers would not agree on what done
   looks like.
4. **No scope boundary** — nothing says what is out of scope (e.g. Excel export,
   scheduled exports), so scope is open-ended.
5. **Unquantified constraint** — "handle large reports sensibly" states no size
   and no behaviour.

## Must not report

- Any **BLOCKING or MAJOR** finding against `## Sign-off strategy`, which is the
  clean control text. MINOR findings and SUGGESTIONs there are tolerated — a
  reviewer may legitimately notice polish anywhere, and a vague requirements
  section can genuinely make a sign-off criterion harder to audit.
- Any finding faulting the absence of a design.

**Expected verdict:** `NEEDS WORK`
