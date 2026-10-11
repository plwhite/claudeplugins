# Expected findings — `undifferentiated-docs-review.md`

**Flaw under test:** delivery criteria — specifically the docs review check. The
`## Sign-off strategy` has a **Docs review** entry, "One agent docs review before
`/feature-end`", that names a performer (an agent) and a time but not which
**kinds** of docs review run (architectural, accuracy, style, agent docs), and
does not skip any kind explicitly. It is a single undifferentiated bar. The
`## Requirements` and `## Spec` sections, and every other `## Sign-off strategy`
entry, are the clean ones from `control.md` and must not be faulted.

## Required findings

One finding against `## Sign-off strategy` at **BLOCKING or MAJOR** severity:

1. **The docs review bar does not say which kinds run.** The finding must say
   that the **Docs review** entry names no kind (or skips none explicitly with
   "None — <reason>"), so the strategy keeps one undifferentiated docs review
   bar rather than setting a bar per kind. The recommendation should be to name
   the kinds that run (e.g. "`/review-docs` over the change, all kinds") or to
   skip individual kinds explicitly with a reason.

## Must not report

- Any **BLOCKING or MAJOR** finding against `## Requirements` or `## Spec`,
  which are the clean control text. MINOR findings and SUGGESTIONs there are
  tolerated.
- Any **BLOCKING or MAJOR** finding against the **Testing**, **Documentation**,
  **Code review** or **User review** entries, which are the clean control text.
- A finding that the docs review does not say who performs it: it says "agent",
  which is enough for this case. (Naming `/review-docs` is a reasonable
  suggestion, but a BLOCKING or MAJOR finding that the performer is unnamed is a
  false positive here.)
- Any finding faulting the absence of a design.

**Expected verdict:** `NEEDS WORK`
