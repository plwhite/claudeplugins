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

PLUGIN_JSON="$ROOT_DIR/.claude-plugin/plugin.json"
SKILL_FILE="$ROOT_DIR/skills/demo-skill/SKILL.md"
AGENT_FILE="$ROOT_DIR/agents/demo-agent.md"

require_file "$PLUGIN_JSON"
require_file "$SKILL_FILE"
require_file "$AGENT_FILE"

# plugin.json checks
require_grep '"name"' "$PLUGIN_JSON"
require_grep '"demo"' "$PLUGIN_JSON"

# Skill frontmatter checks
require_grep '^name: demo-skill$' "$SKILL_FILE"
require_grep '^user-invocable: true$' "$SKILL_FILE"

# Agent frontmatter checks
require_grep '^name: demo-agent$' "$AGENT_FILE"
require_grep '^description:' "$AGENT_FILE"

echo "OK: demo plugin looks sane"
