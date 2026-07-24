# Rule: never run `git push` unreviewed

This rule governs the `Bash` tool's behaviour for git commands in this
repository. It exists so an agent cannot push commits to any remote without
explicit user approval.

Enforcement: a `PreToolUse` hook (`.claude/hooks/block-git-push.sh`)
intercepts any Bash command containing `git push` and denies it
unconditionally, for every branch including feature branches.
