#!/bin/bash
# Start Claude in a detached tmux session that survives Claude exiting.
# The keep-alive loop lives in run-claude.sh.
tmux new-session -d -s claude 'bash /home/claude/run-claude.sh'
exec tail -f /dev/null
