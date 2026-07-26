# Move the feature model out of CLAUDE.md into a referenced file — Feature Plan

## Handoff

**Last updated:** 2026-07-26
**Session summary:** Sub-task 3 complete: added the canonical `devproc/skills/feature-init/FEATUREMODEL.md` (byte-identical copy of `features/FEATUREMODEL.md`), rewrote `feature-init/SKILL.md` step 1 to copy that file into the target project, ensure the un-backticked `@import` in `CLAUDE.md`, and migrate an already-embedded project by lifting the embedded section out. Updated the three stale `devproc/README.md` lines and the `CLAUDE.md` Contents entry that described `feature-init`'s old CLAUDE.md-embedding behaviour. Validated by a traced walkthrough (fresh project, already-embedded project, idempotent re-run, backticked-mention dead end) recorded in `NOTES.md`, plus a `diff` confirming the two `FEATUREMODEL.md` copies are identical.
**Sub-task in progress:** None
**First action next session:** Begin Sub-task 4 (Final sign-off criteria): run `/review-branch` over all changed files, then `docs-structure-reviewer` (performed as part of `/feature-end`) and final user review, per `## Sign-off strategy`.
**Open questions / decisions pending:** None.
**Dead ends to avoid:** Do **not** use a bare Markdown link to the model file — it does not auto-load. The `@import` directive must be un-backticked prose; inside backticks or a code fence it is ignored. Plain `features/…` paths (no `@`) are not imports, so existing path mentions in `CLAUDE.md` are safe. The live plugin copy at `/home/claude/claudeplugins/devproc/` is stale relative to these edits (invoking `devproc:feature-checkpoint` via the Skill tool still shows the old "CLAUDE.md contains a Feature Model section" precondition prose, and lacks Sub-task 3's `feature-init` rewrite) — this is expected per the existing "live plugin copy" NOTES.md entry, not a regression; edits belong only in the git-tracked `/workspace/devproc/` tree.

## Requirements

### From issue #43 (verbatim)

> **Remove feature model from CLAUDE.md**
>
> The feature model is documented in CLAUDE.md. That works, but it feels like it would be far more sensible to have a file features/FEATUREMODEL.md and have CLAUDE.md reference it. This separates the boilerplate text from the "what is currently going on and how this particular repo works" stuff, and so makes CLAUDE.md more readable and the managing of the boilerplate sections easier ("copy in this file" rather than "add these sections").
>
> This only makes sense if every time Claude reads CLAUDE.md it can be made to read that document; this needs verification.
>
> *There is a possibility that this is not worth it - that it actually does not have real benefits. We should investigate and explicitly decide whether this is worth it.*

(Issue has no comments.)

### Investigation carried out during spec (to inform the "should we do this" decision)

The issue asks for two things to be settled before committing: (1) **can** a referenced file be made to load every session, and (2) **is it worth it**. The first is now settled; the second is a judgement left to the user (see the Open decision below).

**1. Verification — yes, a referenced file can be loaded every session.** The Claude Code memory docs (<https://code.claude.com/docs/en/memory>) confirm two mechanisms that both load unconditionally at session launch:

- **`@path` import.** CLAUDE.md may import files with `@path/to/file` syntax: *"Imported files are expanded and loaded into context at launch alongside the CLAUDE.md that references them."* Relative paths resolve against the importing file; recursion is allowed to a depth of four hops. Import parsing **skips Markdown code spans and fenced code blocks**, so the import directive (`@features/FEATUREMODEL.md`) must sit in ordinary prose, not inside backticks. Because the target is in-tree, the external-import approval dialog does **not** apply (that gate is only for paths resolving outside the working directory).
- **`.claude/rules/*.md`.** A rules file with no `paths` frontmatter is *"loaded at launch with the same priority as `.claude/CLAUDE.md`."* This is the platform's documented mechanism for "break instructions into topic-specific files," and is arguably the more idiomatic home for reusable boilerplate. (Which mechanism to use is a design-time choice for `/feature-design`, not settled here.)

  A **bare Markdown link** (e.g. `[the feature model](features/FEATUREMODEL.md)`) would **not** satisfy the requirement — it is not auto-loaded; Claude would have to choose to open it. So the change is only sound if it uses `@import` or a rule, never a plain link.

**2. Benefit is organizational only — there is no context/token saving.** The docs state three times that splitting content out does not reduce what is loaded: *"imported files still load and enter the context window at launch"*; *"Splitting into `@path` imports helps organization but doesn't reduce context, since imported files load at launch."* The full feature-model text is loaded every session either way. The genuine benefits are therefore:

- **Readability of CLAUDE.md.** The feature-model boilerplate is ~120 lines (roughly lines 84–203) of a 203-line file. Extracting it leaves CLAUDE.md at ~85 lines of purely repo-specific content (current status, plugin descriptions, container mode). The docs recommend keeping each CLAUDE.md under 200 lines for adherence; the file is currently just over that at 203.
- **Easier boilerplate management.** Because this repository's purpose is to package reusable plugins, and `feature-init` currently *writes the model into* a project's CLAUDE.md, a standalone file turns setup into "copy this file in and add one import line" rather than "insert these sections," and updates into "replace the file" rather than "edit the embedded sections in place."

**3. Cost — a reference fan-out plus a `feature-init` rewrite.** Roughly ten live references point at the model's current location ("the project CLAUDE.md under `### Sign-off criteria`") and would need repointing at the new file:

- `devproc/skills/feature-spec/SKILL.md`, `.../feature-design/SKILL.md`, `.../feature-checkpoint/SKILL.md`, `.../feature-init/SKILL.md`
- `devproc/agents/feature-spec-reviewer.md`, `.../feature-design-reviewer.md`, `.../dev-process-manager.md`
- `devproc/README.md`, `docs/workflow.md`, `docs/capabilities.md`

  In addition, `feature-init` must change substantively: instead of embedding the model, it must write `features/FEATUREMODEL.md`, add the load directive to CLAUDE.md, and **migrate** an existing project by lifting the embedded section out into the new file. Note that the model text is *already duplicated today* — held by hand in both this repo's CLAUDE.md (`### Sign-off criteria` onward) and the `feature-init` `SKILL.md` template, kept in sync manually. Whether extraction *removes* that duplication (a single canonical `FEATUREMODEL.md` that `feature-init` ships and copies) or merely *relocates* it (the template still embeds the full text) is a design-stage choice that bears directly on the "easier boilerplate management" benefit. (Historical `features/plans/*.md`, `features/COMPLETED.md`, `NOTES.md`, and `.claude/agent-memory/*` also mention the model but describe past work and need no change.) The principal risk is a missed or stale reference after the move — which is why verification includes a grep sweep.

### Go/no-go decision — RESOLVED: proceed (2026-07-26)

**Should this be done at all?** The verification hurdle is cleared, so the decision reduced to a value judgement: the benefit is *readability and boilerplate-management convenience only* (no performance/context gain), set against a *one-time cost* of updating ~10 references and rewriting `feature-init` (including migration), with the standing risk of a stale reference. **The user reviewed this investigation and chose to proceed, modestly scoped.**

### Deliverables (if approved — now confirmed)

1. Create `features/FEATUREMODEL.md` holding the extracted feature-model boilerplate, and make it load into context **every session** via a Claude Code `@import` in `CLAUDE.md` **or** a `.claude/rules/*.md` file — never a bare Markdown link. (Which mechanism: a `/feature-design` decision.)
2. Repoint the ~10 live location references listed in section 3 above from "the project CLAUDE.md under `### Sign-off criteria`" to the new file's location, **and** repoint the "is the model present?" precondition check that opens `feature-spec`, `feature-design`, `feature-checkpoint`, and `feature-end` (currently "check CLAUDE.md contains a Feature Model section, else run `/feature-init`") to check for `features/FEATUREMODEL.md` instead — otherwise those skills, including the `/feature-end` that closes this feature, break.
3. Rewrite `feature-init` to write `features/FEATUREMODEL.md` and the load directive for a fresh project, and to **migrate** an already-initialised project by lifting the embedded section out. Resolve at design time whether the `feature-init` template embeds the full text (duplication relocated) or ships/copies the canonical file (duplication removed).
4. Migrate **this** repository's own `CLAUDE.md` as part of the work, since it is a live initialised project.

## Sign-off strategy

This is a documentation/prompt-content change across Markdown files (skills, agents, docs, and `CLAUDE.md`); there is no application code. The dominant risk is a *stale or missed reference* after the model moves, and the *core assumption to prove* is that the relocated file actually loads every session. The bars are set accordingly.

- **Testing** — Manual verification, to a definite pass/fail: (a) a real session confirms `features/FEATUREMODEL.md` loads into context every session — via `/context` listing it under Memory files, or an equivalent check that the import/rule resolves; and (b) a repository-wide grep confirms **no** reference still points at the old in-CLAUDE.md location and every live reference resolves to the new file. No automated test harness applies to this content.
- **Documentation** — Full update of every user-facing and internal doc that names the model's location (`devproc/README.md`, `docs/workflow.md`, `docs/capabilities.md`, the four feature `SKILL.md` files, the reviewer and manager agent definitions), plus `feature-init` rewritten to create and migrate the new file. Bar: complete — no doc left describing the superseded layout.
- **Code review** — One `/review-branch` (agent) over the full diff before `/feature-end`, to catch inconsistencies and any reference the grep missed. (The "code" here is prompt/Markdown content; `/review-branch` is the right consistency check for it.)
- **Docs review** — One `docs-structure-reviewer` (agent) pass over the restructured documentation before `/feature-end`, confirming the split reads cleanly and discoverability is preserved.
- **User review** — Final user review of the completed change before `/feature-end`. (Distinct from, and in addition to, the up-front go/no-go decision above: the user both authorises starting and confirms the finished result.)

Two feature-wide gates fall out of this — one `/review-branch`, one `docs-structure-reviewer`, and the final user review — which `/feature-design` will materialise as a "Final sign-off criteria" sub-task.

## Design

### Load mechanism — decided: `@import` of `features/FEATUREMODEL.md`

`CLAUDE.md` will gain a single un-backticked prose line that imports the model, e.g.:

```
The feature model for this project — lifecycle, sign-off criteria, and the
documents that support it — is defined in @features/FEATUREMODEL.md and applies
at all times.
```

At session launch Claude Code expands that import in full, so the model is in context every session exactly as it is today (verified against the Claude Code memory docs). Chosen over a `.claude/rules/feature-model.md` file because: (a) issue #43 explicitly names `features/FEATUREMODEL.md`; (b) it keeps the model beside the `features/` directory it governs; (c) it is a one-line, self-evident change to `CLAUDE.md` rather than introducing a `.claude/rules/` mechanism this repo does not otherwise use. Both mechanisms load unconditionally, so the choice is about fit, not capability. **This is a design decision, surfaced for user confirmation.**

Gotchas captured in Handoff/`NOTES.md`: the directive must be un-backticked (backticked or fenced `@paths` are ignored); a bare Markdown link would not load; plain `features/…` mentions without `@` are not imports, so the many existing path references in `CLAUDE.md` are unaffected; the target is in-tree so no external-import approval dialog fires.

### `feature-init` — decided: ship a canonical file and copy it (remove the duplication)

Today the full model text lives in two hand-synced places: this repo's `CLAUDE.md` and the embedded `~~~markdown … ~~~` block in `devproc/skills/feature-init/SKILL.md` (step 1). The design collapses that to **one canonical source shipped with the plugin**: a new `devproc/skills/feature-init/FEATUREMODEL.md`. `feature-init` step 1 becomes:

1. Ensure `features/FEATUREMODEL.md` exists in the target project by copying the plugin's canonical `FEATUREMODEL.md` (the skill knows its own base directory).
2. Ensure `CLAUDE.md` contains the `@import` directive (add it if absent).
3. **Migrate** an already-initialised project: if `CLAUDE.md` still embeds the `## Feature model` section, lift it out into `features/FEATUREMODEL.md` (or overwrite with the canonical copy, which is byte-identical), then replace the embedded section with the import directive.

Chosen over re-embedding the full text in the SKILL because ship-and-copy is what actually delivers issue #43's "copy in this file" benefit and eliminates the hand-sync duplication rather than relocating it. **This is a design decision, surfaced for user confirmation.**

This repo is itself an initialised project, so its own `features/FEATUREMODEL.md` is an installed copy of the shipped canonical file — maintained by `/feature-init` exactly as in any other project, with no special-casing for this repo. The canonical `devproc/skills/feature-init/FEATUREMODEL.md` is the master; `/feature-init` refreshes `features/FEATUREMODEL.md` from it on every run (step 1b overwrites the copy — the model is canonical boilerplate, not project data). So the sync mechanism *is* `/feature-init`: to change the model, edit the master and re-run it. The two diverge only if the master is hand-edited without re-running `/feature-init`. (A symlink and a direct `@import` of the plugin file were both considered and rejected — a direct import would leave this repo with no `features/FEATUREMODEL.md`, which its own skills' precondition checks require, breaking dogfooding.) A build-time `diff` still confirms the two are identical after this feature's work.

### Reference repointing

Two distinct kinds of dependency on the model living in `CLAUDE.md` must be updated:

**(a) Location references.** The ~10 live references currently say "the project `CLAUDE.md` under `### Sign-off criteria`" (or similar). Each is repointed to name `features/FEATUREMODEL.md` as the canonical location instead. The wording change is mechanical but must be exact per file, since some phrase it as "`/feature-init` writes into the project CLAUDE.md" (that clause itself becomes "writes `features/FEATUREMODEL.md`"). Historical plan files, `COMPLETED.md`, `NOTES.md`, and `.claude/agent-memory/*` are left untouched — they narrate past work.

**(b) Precondition checks — decided.** Each feature skill opens by *gating on the model being present in `CLAUDE.md`*: `feature-spec`, `feature-design`, `feature-checkpoint`, and `feature-end` all carry a line of the form "check that `CLAUDE.md` contains a Feature Model section; if it doesn't, tell the user to run `/feature-init` first and stop." Once Sub-task 1 replaces that section with a one-line `@import`, every one of these checks would fail — most acutely the `/feature-end` run that closes *this* feature. The check must therefore be repointed too: each becomes a check that **`features/FEATUREMODEL.md` exists (and is imported by `CLAUDE.md`)**, else run `/feature-init`. This is separate wording from the location references above ("Feature Model section" / "run `/feature-init`", not "under `### Sign-off criteria`"), so the grep in Sub-task 2 must catch both phrasings. `feature-end` SKILL.md carries the precondition check and so is in scope even though it holds no location reference.

### Sequencing rationale

Sub-task 1 does this repo's own extraction **first**, because it simultaneously (a) proves the core assumption — that the imported file loads every session — before any dependent work, and (b) authors the canonical model text that Sub-task 3 will ship. Sub-task 2 (repoint references) and Sub-task 3 (`feature-init`) both depend on the new location existing but are independent of each other.

## Sub-tasks

1. **Extract the model and load it in this repo** ✓ (2026-07-26) — move the `## Feature model` section (and its subsections) out of `CLAUDE.md` into a new `features/FEATUREMODEL.md`, add the `@import` directive to `CLAUDE.md`, and confirm it loads.
   - [x] Testing: a real session confirms `features/FEATUREMODEL.md` appears under `/context` Memory files (or an equivalent check shows the import resolved); and a check confirms `CLAUDE.md` no longer embeds the model, the import directive is present and un-backticked, and no content was lost (the model text in `FEATUREMODEL.md` matches what was removed).
     - Static half (teammate): `diff` confirms `features/FEATUREMODEL.md` is byte-identical to the removed `CLAUDE.md` section; `CLAUDE.md` no longer contains the subsection headings; the `@features/FEATUREMODEL.md` line carries zero backticks and sits outside the file's one (balanced, closed) code fence.
     - Live half (manager, 2026-07-26): a fresh headless `claude -p` session launched in the repo, **with `Read`/`Bash`/`Grep`/`Glob`/`Task`/`WebFetch` disabled**, quoted verbatim the first sentence under `### Sign-off criteria` — text that now exists only in `features/FEATUREMODEL.md`. With all file-reading tools disabled, the only way it could have that text is via the `@import` loading it at launch. Import confirmed live. See `NOTES.md`.
   - [x] Documentation: `CLAUDE.md` reduced to repo-specific content only; `features/FEATUREMODEL.md` holds the complete model verbatim.
2. **Repoint all references and precondition checks to the new location** ✓ (2026-07-26) — update the location references across the feature skills, review agents, manager agent, README, and `docs/`, **and** the "is the model present?" precondition checks that every feature skill runs. (`feature-init` is excluded here — Sub-task 3 rewrites it wholesale.)
   - [x] Testing: a repository-wide grep confirms no live reference or precondition check still points at the model living in `CLAUDE.md` — covering **both** the location phrasing ("under `### Sign-off criteria`" / "the project CLAUDE.md") **and** the precondition phrasing ("contains a Feature Model section" / "run `/feature-init`") — and every updated reference names `features/FEATUREMODEL.md`. Verified with `grep -rn "project CLAUDE\.md under\|the project.s CLAUDE.md\|writes into the project CLAUDE\|contains a Feature Model section\|CLAUDE\.md contains a Feature Model" --include="*.md" devproc docs README.md CLAUDE.md` — zero matches.
   - [x] Documentation: location references in `devproc/README.md`, `docs/workflow.md`, the three feature `SKILL.md` files (`feature-spec`, `feature-design`, `feature-checkpoint`), both reviewer agents, and the manager agent are updated; `docs/capabilities.md` and `docs/setup.md` checked and confirmed to carry no location claim (no change needed). The precondition check in `feature-spec`, `feature-design`, `feature-checkpoint`, and `feature-end` SKILL.md now verifies `features/FEATUREMODEL.md` exists (imported by `CLAUDE.md`) rather than an embedded section. All read correctly in context. (Three `devproc/README.md` lines describing `feature-init`'s own current embedding behaviour were deliberately left for Sub-task 3 — see Handoff and `NOTES.md`.)
3. **Rewrite `feature-init` to create and migrate the file** ✓ (2026-07-26) — added the canonical `devproc/skills/feature-init/FEATUREMODEL.md`, rewrote SKILL.md step 1 to copy it and add the import, and added the migration path for an already-embedded project.
   - [x] Testing: a traced walkthrough of the rewritten `feature-init` on both a fresh project and an already-embedded project confirms it produces `features/FEATUREMODEL.md` plus the import directive and migrates correctly (including idempotent re-run and the backticked-mention dead end); and `diff` confirms this repo's `features/FEATUREMODEL.md` is byte-identical to the shipped canonical file. See `NOTES.md` "Sub-task 3 ... traced walkthrough".
   - [x] Documentation: `feature-init` SKILL.md rewritten (create + migrate steps) with no residual instruction to embed the model in `CLAUDE.md`; the three stale `devproc/README.md` lines describing `feature-init`'s own behaviour, and the `CLAUDE.md` Contents entry, updated to match.
4. **Final sign-off criteria** — end-of-feature gates for this feature, per `## Sign-off strategy`.
   - [x] Code review (agent): `/review-branch` over all changed files; findings resolved or dismissed. (2026-07-26 — all four agents; ~14 code-level fixes applied over two convergence iterations, third pass clean. Caught the shipped-sync-marker bug and prompted the feature-init self-refresh design change.)
   - [x] Docs review (agent, performed at `/feature-end`): `docs-structure-reviewer` over the restructured documentation; findings resolved. (2026-07-26 — two passes, converging 3→1→0: fixed a `devproc/README.md` re-run contradiction I'd introduced, added a self-identifying comment to both `FEATUREMODEL.md` copies, and corrected "canonical" vs "installed copy" terminology.)
   - [x] User review: user confirms the extraction is correct and complete and the feature matches intent. (2026-07-26 — user reviewed and confirmed.)

**▶ COMPLETE** — all sub-tasks done; feature closed via `/feature-end` (2026-07-26). The docs-review box is ticked by that `/feature-end` run.

> Run `/feature-checkpoint` after each sub-task completes.

## Review record

<!-- One line per lifecycle stage; appended by /feature-spec, /feature-design, /feature-end. -->

- 2026-07-26 — Spec reviewed by `feature-spec-reviewer`: VERDICT: NEEDS WORK. The one blocking finding is the intended open go/no-go decision (`[decision]`), not a spec defect; a SUGGESTION (existing CLAUDE.md↔template duplication) was applied. Presented to the user for the go/no-go decision and sign-off.
- 2026-07-26 — Design reviewed by `feature-design-reviewer` (two passes): first pass VERDICT: NEEDS WORK (two MAJOR `[rewrite]` findings — the broken feature-skill precondition checks incl. `feature-end`, and a missing docs-review annotation — plus a MINOR double-listing, all fixed); second pass VERDICT: READY FOR USER REVIEW. One `[decision]` SUGGESTION (the new `diff`-audited sync obligation) carried to the user. Presented to the user for sign-off.
- 2026-07-26 — Code reviewed by `/review-branch` (all four agents, incl. architectural): ~14 code-level findings applied over two convergence iterations, third pass clean; caught a shipped-sync-marker bug and prompted the user-directed `feature-init` self-refresh design change. User performed the final user review and confirmed.
- 2026-07-26 — Feature closed via `/feature-end`. Close-out docs review by `docs-structure-reviewer` (two passes, converging 3→1→0): VERDICT resolved — fixed a `devproc/README.md` re-run contradiction, added a self-identifying comment to both `FEATUREMODEL.md` copies, and corrected canonical-vs-installed terminology. Feature complete.
