# Expected findings — `unclear-design.md`

**Flaw under test:** clarity of `## Design` — a failure against
`### Readability`, not missing content or missing rationale. Every decision
from `control.md`'s design is still present and still carries its reasoning
(the query-builder/column-definition reuse and the drift-risk argument for
both, the streaming choice and the memory argument, the rejected client-side
alternative, the timezone argument for passing the local date explicitly, the
formatting/serialisation split and its rationale, the toolbar placement) —
this case is deliberately **not** `unexplained-design`, which owns bare
assertions and uncovered requirements. Every `## Spec` item is covered by some
part of this design, and `## Sub-tasks` is untouched `control.md` text.

The rewrite breaks three of the six structural tests:

- **Point first, violated.** There is no overview. The section opens directly
  on cell-formatting internals — the least central of the design's decisions —
  with no statement first of what the design as a whole is (a new streaming
  server endpoint) before any detailed section. Note that `control.md` carries
  a `### Overview` section and this case deliberately does not: the absence is
  the planted flaw, not baseline drift.
- **Detail subordinated / rationale without detour, violated.** Reasoning is
  tangled into long run-on sentences alongside unrelated material rather than
  placed at the point of decision — for example "Streaming and the filename"
  interleaves the streaming/memory argument with the filename mechanism in one
  sentence, and "Formatting and serialisation" buries the reason formatting is
  kept separate inside a sentence that also introduces the unrelated `.xlsx`
  reuse remark and a forward reference to "the streamed rows referenced
  below."
- **Nothing assumed, violated (a milder instance).** "The streamed rows
  referenced below" and "the artefacts the reports page itself already uses"
  are forward references and vague pointers used before the thing they point
  to has been established, forcing the reader to hold the sentence open until
  a later section resolves it.

`## Requirements`, `## Spec`, and `## Sign-off strategy` are unmodified
`control.md` text and must not be faulted.

## Required findings

1. A finding at **MAJOR** severity or higher against `## Design`, marked
   **`[rewrite]`**, reporting a failure against `### Readability`. It must
   identify at least two of: the missing overview (no statement of the
   design's overall shape before the detailed sections begin), the tangled
   rationale (reasoning interleaved with unrelated material inside run-on
   sentences rather than placed at the point of decision), or a forward
   reference used before its antecedent is established.

## Also acceptable

- A finding naming the specific run-on sentences in "Streaming and the
  filename" or "Formatting and serialisation" as the clearest instances of
  tangled rationale.
- A MINOR or SUGGESTION note that the design would read better broken into
  more, shorter paragraphs — a stylistic echo of the same MAJOR clarity fault,
  not a separate defect.

## Must not report

- A clarity / `### Readability` finding marked **`[decision]`**. A clarity
  fault is the calling skill's to fix by restructuring — it is never a
  question put to the user, so any readability finding here must be
  `[rewrite]`.
- **Missing rationale** as a Complete-and-clear finding (the failure this case
  tests is that rationale is present but hard to follow, not absent — that
  distinct failure belongs to `unexplained-design`).
- **Uncovered requirement** — every `## Spec` item is addressed somewhere in
  this design; a finding claiming otherwise is a false positive.
- Any **BLOCKING or MAJOR** finding against `## Requirements`, `## Spec`, or
  `## Sign-off strategy`, which are the clean baseline. MINOR findings and
  SUGGESTIONs there are tolerated.
- Any finding that supplies a replacement design of the reviewer's own rather
  than naming what is unclear.

**Expected verdict:** `NEEDS WORK`
