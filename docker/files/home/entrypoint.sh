#!/bin/bash
# Just start Claude and off we go
cd /workspace
tmux new-session -d -s claude claude --dangerously-skip-permissions
exec tail -f /dev/null