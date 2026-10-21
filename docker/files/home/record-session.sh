#!/bin/bash
# SessionStart hook: record which conversation the container's main Claude
# session is using, so run-claude.sh can resume exactly that conversation after
# the container restarts.
#
# run-claude.sh adds this hook (via `--settings`) to the main session only, so
# the agent warm-up and any `claude` run from Claude's Bash tool never come here.
# Claude Code runs it on every SessionStart (sources startup, resume, clear and
# compact), so after /clear or /resume the file names the new conversation.
#
# Input: the hook's JSON on stdin, which carries `session_id` and
# `transcript_path`.
# Output: ~/.claude/container-session-id (keep in sync with run-claude.sh) —
# the session ID on line 1 and the transcript path on line 2.
# On failure the previous file is left untouched, so run-claude.sh would resume
# the conversation recorded before this one; the error goes to stderr, which
# Claude Code shows as a hook error.
set -euo pipefail

id_file="$HOME/.claude/container-session-id"

# Write to a temporary file in the same directory, then rename: the rename is
# atomic, so a stop mid-write can never leave a half-written file.
tmp_file=$(mktemp "$id_file.XXXXXX")
trap 'rm -f "$tmp_file"' EXIT

# python3 parses the JSON because the image has no jq.
python3 -c '
import json, sys
event = json.load(sys.stdin)
values = [event.get("session_id"), event.get("transcript_path")]
if not all(isinstance(v, str) and v and "\n" not in v for v in values):
    sys.exit("record-session.sh: hook input lacks a usable session_id or transcript_path")
print(values[0])
print(values[1])
' > "$tmp_file"

mv "$tmp_file" "$id_file"
