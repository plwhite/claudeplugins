#!/bin/bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only care about git commands
echo "$COMMAND" | grep -qE '\bgit\b' || exit 0

# Block write operations
if echo "$COMMAND" | grep -qE '\bgit\s+(commit|add|push|fetch|pull|merge|rebase|reset|stash|tag|branch -d|branch -D)\b'; then
  echo "BLOCKED: '$COMMAND' — git write operations are reserved for the developer." >&2
  exit 2
fi

exit 0
