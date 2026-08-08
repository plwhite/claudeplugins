# Expected findings — `unclear-spec.md`

**Flaw under test:** clarity of `## Spec` — a failure against `### Readability`
in `features/FEATUREMODEL.md`, not a content gap. Every fact from
`control.md`'s `## Spec` is still present (unformatted numbers, ISO dates,
column parity, the filename pattern, the 200,000-row memory constraint, the
out-of-scope list, and the "Export CSV" control itself) — this case tests
clarity, not completeness, which `incomplete-spec` already covers. The
rewrite breaks four of the six structural tests at once:

- **Point first, violated.** The central purpose — a CSV export control for
  support staff who currently copy figures to finance by hand — is not stated
  until the closing sentence of the section, and even there it arrives as a
  rider tacked onto the out-of-scope note rather than as its own point.
- **Nothing assumed, violated.** "Every other feed in the reporting
  pipeline", "the other export types in the system", and "the dashboard's
  bulk operations" are all referred to as if the reader already knows them;
  none is defined, linked, or established anywhere in this file. Note these
  three phrases are the one part of the rewrite that is *added* rather than
  reorganised — they appear nowhere in `control.md` — so they are also,
  read literally, claims about the codebase that `## Requirements` never
  establishes and that carry no proposal marking. That gives a reviewer a
  legitimate second angle on them; see "Also acceptable".
- **Detail subordinated, violated.** Formatting minutiae (number and date
  formatting) opens the section, ahead of any statement of what is being
  built — the reader is three paragraphs into implementation-level detail
  before learning there is an "Export CSV" control at all.
- **Proportionate, violated.** The section reads as a sequence of true,
  disconnected statements about formatting, naming, and memory, with the
  actual feature mentioned only in passing at the very end — the "grab bag"
  failure the standard exists to catch.

`## Requirements` and `## Sign-off strategy` are unmodified `control.md` text
and must not be faulted.

## Required findings

1. A finding at **MAJOR** severity or higher against `## Spec`, marked
   **`[rewrite]`**, reporting a failure against `### Readability`. It must
   identify at least two of: the buried central point, an undefined
   cross-reference (the "reporting pipeline", "other export types", or
   "dashboard's bulk operations"), or the front-loaded formatting detail
   preceding any statement of what the feature is.

## Also acceptable

- A finding under "Complete and clear" at **any severity up to and including
  BLOCKING**, and marked either `[rewrite]` or **`[decision]`**, faulting the
  three cross-references as unsourced — i.e. asserting facts about the
  existing system that `## Requirements` does not establish and that are not
  marked as proposals. This may stand alongside the MAJOR clarity finding
  above; the two checks legitimately both fire on the same wording. A
  `[decision]` mark is correct here even though it is forbidden on a *clarity*
  finding (below): whether those other export types and pipeline feeds
  genuinely exist is a question only the user can answer, so it is properly
  put to them rather than fixed by rewriting. *(Widened 2026-08-10 after a
  run reported exactly this at BLOCKING `[decision]`; the band was previously
  MINOR/SUGGESTION. The consequence is accepted knowingly: BLOCKING plus
  `[decision]` is the combination that halts an unattended `/feature-spec`
  run, so this fixture can stop automation — correctly, because a spec really
  should not assert unsourced facts about the codebase.)*
- A finding noting the section never states the central purpose as its own
  sentence, as a specific instance of the Point-first failure.

## Must not report

- A clarity / `### Readability` finding marked **`[decision]`**. A clarity
  fault is the calling skill's to fix by rewriting — it is never a question
  put to the user, so any readability finding here must be `[rewrite]`. This
  bars a `[decision]` mark on a finding that *invokes the readability
  standard*; it does not bar the separate unsourced-claims finding permitted
  under "Also acceptable", which rests on the spec-construction rule about
  marking proposals and does not appeal to `### Readability` at all.
- Any **BLOCKING or MAJOR** finding against `## Requirements` or `## Sign-off
  strategy`, which are the clean baseline text. MINOR findings and
  SUGGESTIONs there are tolerated.
- A completeness finding claiming any of the control's substantive content
  (formatting rules, column parity, filename pattern, memory constraint,
  out-of-scope list, or the export control itself) is missing — nothing was
  removed, only reorganised and obscured.
- Any finding faulting the absence of a design.

**Expected verdict:** `NEEDS WORK`
