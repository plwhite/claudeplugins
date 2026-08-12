#!/usr/bin/env bash
# Regression harness for the feature-spec-reviewer and feature-design-reviewer
# fixture suites (../feature-spec-reviewer/, ../feature-design-reviewer/).
# See README.md in this directory for usage and how to read the output.
#
# Does NOT cover the internal-docs-reviewer suite: its cases are fixture
# directories reviewed as a stand-in repository root, not single .md files,
# and need a different invocation shape. See README.md.
set -uo pipefail
shopt -s nullglob

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TESTS_DIR="$REPO_ROOT/tests/devproc"
OUT_DIR="$SCRIPT_DIR/out"
CONCURRENCY=3
TIMEOUT=900

SUITES=(feature-spec-reviewer feature-design-reviewer)

usage() {
  cat <<'EOF'
Usage: run.sh [-n] [suite] [case]

  run.sh                       Run every case in both suites
  run.sh <suite>               Run every case in one suite
  run.sh <suite> <case>        Run a single case
  run.sh -n [suite] [case]     Dry run: list the cases that would run, without running them
  run.sh -h                    Show this help

Suites: feature-spec-reviewer, feature-design-reviewer

Output for each case is written to out/<suite>__<case>.txt (git-ignored).
EOF
}

# True if $1 equals one of the remaining arguments, by exact string match
# (not a glob pattern — deliberately, since case/suite names can otherwise
# contain shell pattern metacharacters that would make a glob-based
# membership check match things it shouldn't).
contains() {
  local want="$1" x
  shift
  for x in "$@"; do
    [[ "$x" == "$want" ]] && return 0
  done
  return 1
}

# A case is any <name>.md in a suite directory that has a matching
# <name>.expected.md; <name>.expected.md files are never themselves cases,
# nor is the suite's own README.md. Derived from the fixtures on disk on
# every run, never hardcoded — this is the whole point of the harness (see
# README.md). Warns (without failing) about any .md/.expected.md that lacks
# its counterpart, since such an orphan would otherwise just silently shrink
# the case list.
cases_for_suite() {
  local dir="$TESTS_DIR/$1" f base
  for f in "$dir"/*.md; do
    [[ "$f" == *.expected.md ]] && continue
    base="$(basename "$f" .md)"
    [[ "$base" == "README" ]] && continue
    if [[ -f "$dir/$base.expected.md" ]]; then
      echo "$base"
    else
      echo "Warning: $f has no matching $base.expected.md; skipping" >&2
    fi
  done
  for f in "$dir"/*.expected.md; do
    base="$(basename "$f" .expected.md)"
    [[ -f "$dir/$base.md" ]] || echo "Warning: $f has no matching $base.md (orphaned expected-output file)" >&2
  done
}

# Remove leftover out/<suite>__*.txt files for cases that no longer exist in
# the suite's current fixture set (e.g. a case was renamed or removed), so a
# stale result from a past run is never mistaken for current output. Judges
# staleness against the suite's full derived case list, not against whatever
# subset this invocation is about to run, so running a single case never
# deletes recorded output for its sibling cases.
clean_stale_out() {
  local suite="$1" f base
  shift
  for f in "$OUT_DIR/${suite}__"*.txt; do
    base="$(basename "$f" .txt)"
    base="${base#"${suite}"__}"
    contains "$base" "$@" || rm -f "$f"
  done
}

# The prompt block, defined once. Losing any of these three parts would
# invalidate every recorded .expected.md: the fixture path, the instruction
# to review it as a real plan file, and — critically — the instruction not to
# read the .expected.md answer key.
build_prompt() {
  local suite="$1" case_name="$2"
  cat <<EOF
Review the plan file at tests/devproc/${suite}/${case_name}.md

Follow your agent instructions exactly. Output your findings in the specified format, then your verdict line.

Two notes:
- This file is a constructed test fixture, not a real feature of this repository. Review it exactly as you would a real plan file.
- Do NOT read any .expected.md file in that directory. Review the plan file on its own merits only.
EOF
}

run_case() {
  local suite="$1" case_name="$2"
  local out="$OUT_DIR/${suite}__${case_name}.txt"
  local prompt rc
  prompt="$(build_prompt "$suite" "$case_name")"
  # cd into the repo root (not the caller's cwd) because the prompt above
  # names the fixture with a repo-relative path, matching how the suite
  # READMEs document running the agent "from the repository root".
  (cd "$REPO_ROOT" && timeout "$TIMEOUT" claude -p --agent "$suite" "$prompt") > "$out" 2>&1
  rc=$?
  # rc=124 is timeout(1)'s convention for "killed after hitting the
  # timeout"; any other non-zero rc is a `claude` invocation failure.
  echo "DONE ${suite}/${case_name} rc=${rc}"
  # Propagate rc as this function's own exit status: it's what `wait`
  # reports back to reap_batch for the backgrounded call below, and the
  # trailing echo above would otherwise make that always look like 0.
  return "$rc"
}

# Reap every backgrounded run_case job launched since the last reap, folding
# any non-zero exit into $failed. Resets $pids for the next batch.
reap_batch() {
  local pid
  for pid in "${pids[@]}"; do
    wait "$pid" || failed=$((failed + 1))
  done
  pids=()
}

dry_run=0
if [[ "${1:-}" == "-n" || "${1:-}" == "--dry-run" ]]; then
  dry_run=1
  shift
fi
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

suite_arg="${1:-}"
case_arg="${2:-}"

if [[ -n "$suite_arg" ]] && ! contains "$suite_arg" "${SUITES[@]}"; then
  # internal-docs-reviewer is deliberately unsupported by this harness (see
  # the file header comment for why) — special-cased here only to give a
  # clearer error than "Unknown suite" for this one, commonly-tried name.
  if [[ "$suite_arg" == "internal-docs-reviewer" ]]; then
    echo "internal-docs-reviewer is not covered by this harness — its cases are fixture directories, not single .md files. See tests/devproc/internal-docs-reviewer/README.md." >&2
  else
    echo "Unknown suite: $suite_arg" >&2
    usage >&2
  fi
  exit 1
fi
[[ -n "$suite_arg" ]] && SUITES=("$suite_arg")

if [[ -n "$case_arg" && -z "$suite_arg" ]]; then
  echo "A case requires a suite: run.sh <suite> <case>" >&2
  exit 1
fi

if [[ "$dry_run" -eq 0 ]]; then
  command -v claude >/dev/null || { echo "claude CLI not found on PATH" >&2; exit 1; }
  mkdir -p "$OUT_DIR" || { echo "Cannot create $OUT_DIR" >&2; exit 1; }
fi

launched=0
failed=0
ran_any=0
pids=()

for suite in "${SUITES[@]}"; do
  if [[ ! -d "$TESTS_DIR/$suite" ]]; then
    # Reap jobs already launched for an earlier suite before bailing, so
    # they aren't abandoned mid-flight.
    reap_batch
    echo "Suite directory not found: $TESTS_DIR/$suite" >&2
    exit 1
  fi
  mapfile -t cases < <(cases_for_suite "$suite")
  all_cases=("${cases[@]}")

  if [[ -n "$case_arg" ]]; then
    if ! contains "$case_arg" "${cases[@]}"; then
      echo "No such case '$case_arg' in suite '$suite' (no ${case_arg}.md + ${case_arg}.expected.md pair)" >&2
      exit 1
    fi
    cases=("$case_arg")
  fi

  [[ "$dry_run" -eq 0 ]] && clean_stale_out "$suite" "${all_cases[@]}"

  for case_name in "${cases[@]}"; do
    ran_any=1
    if [[ "$dry_run" -eq 1 ]]; then
      echo "$suite/$case_name"
      continue
    fi
    run_case "$suite" "$case_name" &
    pids+=("$!")
    launched=$((launched + 1))
    (( ${#pids[@]} >= CONCURRENCY )) && reap_batch
  done
done
reap_batch

if [[ "$ran_any" -eq 0 ]]; then
  echo "No cases found." >&2
  exit 1
fi

if [[ "$dry_run" -eq 0 ]]; then
  if [[ "$failed" -gt 0 ]]; then
    echo "FAILED: $failed of $launched case(s) exited non-zero (rc=124 means the ${TIMEOUT}s timeout fired) — check ${OUT_DIR}/*.txt" >&2
    exit 1
  fi
  echo "ALL CASES COMPLETE ($launched case(s))"
fi
exit 0
