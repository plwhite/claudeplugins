#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

require_file() {
  [[ -f "$1" ]] || fail "missing file: $1"
}

require_grep() {
  local pattern="$1" file="$2"
  grep -Eq "$pattern" "$file" || fail "pattern not found in $file: $pattern"
}

SKILL_FILE="$ROOT_DIR/skills/demo-skill.md"
AGENT_FILE="$ROOT_DIR/agents/demo-agent.md"

require_file "$SKILL_FILE"
require_file "$AGENT_FILE"

# Minimal frontmatter checks
require_grep '^name: demo-skill$' "$SKILL_FILE"
require_grep '^type: skill$' "$SKILL_FILE"

require_grep '^name: demo-agent$' "$AGENT_FILE"
require_grep '^type: agent$' "$AGENT_FILE"
require_grep '^\s*- demo-skill\s*$' "$AGENT_FILE"

echo "OK: demo plugin looks sane"
