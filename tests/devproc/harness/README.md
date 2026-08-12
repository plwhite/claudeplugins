# Regression harness

`run.sh` runs the `feature-spec-reviewer` and `feature-design-reviewer`
fixture suites (`../feature-spec-reviewer/`, `../feature-design-reviewer/`)
through their respective agents and records the output for comparison
against each case's `<case>.expected.md`.

**Does not cover `internal-docs-reviewer`.** That suite's cases are fixture
*directories* (each pointed at as a stand-in repository root), not single
`.md` files, and need a different invocation shape than the one this script
implements. See `../internal-docs-reviewer/README.md` for how to run that
suite by hand. Covering only the two plan-file suites is a deliberate scope
limit of this harness, not an oversight.

## Prerequisites

- `claude` must be on `PATH` and authenticated — the script exits with an
  error otherwise.
- The fixture suites must be present under `tests/devproc/`.
- **Budget for the agent invocations.** A bare `./run.sh` runs every case in
  both suites (15 at the time of writing), three at a time, each with a
  900-second ceiling.
  Run `-n` first to confirm the case list without spending anything.

## Usage

Run from anywhere — the script resolves all paths relative to its own
location, not the caller's working directory.

```
./run.sh                                 # every case in both suites
./run.sh feature-spec-reviewer           # every case in one suite
./run.sh feature-spec-reviewer control   # a single case
./run.sh -n                              # dry run: list cases without running them
./run.sh -h                              # show usage
```

`-n` (or `--dry-run`) combines with a suite and/or case argument the same
way. Use it to check the derived case list against the fixtures on disk
without spending any agent invocations.

Cases run three at a time, with a 900-second timeout per case. Edit
`CONCURRENCY` and `TIMEOUT` near the top of `run.sh` to change them.

## How a case is derived

A case is any `<name>.md` in a suite directory that has a matching
`<name>.expected.md`; `<name>.expected.md` files are never themselves
treated as cases (nor is the suite's own `README.md`, which has no
`.expected.md` counterpart). The list is read from disk on every run — there
is no hardcoded case list to drift out of date. A `.md` or `.expected.md`
with no counterpart is skipped with a warning on stderr rather than silently
dropped, so a broken fixture pairing is visible.

## Output

Each case writes `out/<suite>__<case>.txt` (combined stdout/stderr from the
agent invocation). `out/` is git-ignored (see `.gitignore` in this
directory), so running the harness never dirties the working tree. Before
each run, any `out/` file left over from a case that no longer exists in the
suite (renamed or removed fixture) is deleted, so a stale result is never
mistaken for current output; files for cases you didn't select this run are
left alone.

While running, each case prints `DONE <suite>/<case> rc=<n>` as it finishes.
`rc=0` is success; `rc=124` means the 900-second timeout fired; any other
non-zero `rc` is a `claude` invocation failure — check that case's `out/`
file for detail. The run ends with `ALL CASES COMPLETE (<n> case(s))` if
every case exited 0, or a `FAILED: ...` summary line (and a non-zero script
exit code) if any case didn't.

## Reading the output

Compare `out/<suite>__<case>.txt` against `../<suite>/<case>.expected.md`.
The pass rule is the one each suite's own `README.md` defines — this
harness only runs the cases and captures their output, it does not itself
judge pass/fail:

- `../feature-spec-reviewer/README.md` — a case passes when every finding
  listed under **Required findings** is reported at the stated severity or
  higher, nothing under **Must not report** appears, and the verdict
  matches.
- `../feature-design-reviewer/README.md` — same rule (it explicitly follows
  the `feature-spec-reviewer` README's conventions).

A run that produced no output for a case (e.g. the invocation errored or hit
the 900-second timeout) is **unrun, not passed** — check `out/` for a file
before treating a case as covered.

## When the agent changes

Re-run every case in the affected suite (`./run.sh <suite>`) and compare
each `out/` file against its `.expected.md`. See the suite `README.md` files
for what a changed result means.

## Background

This script replaces three ad-hoc scripts that used to live in
`features/tmp/regression/` (git-ignored, so not present in a clean checkout):
`run.sh`, `runall.sh`, `rerun.sh`. Those duplicated the same prompt block three
times, hardcoded `cd /workspace`, and named their case lists by hand — which
had already drifted from the fixtures on disk (one listed 5 of the
`feature-spec-reviewer` suite's 7 cases, another 6, so "run everything"
silently skipped cases). This script fixes all three problems: one prompt
definition, no absolute paths, and a case list read from the fixture
directories on every run.
