# Setup files

Files that [`docs/setup.md`](../docs/setup.md) has you copy into place. Do not edit them here; the linked setup.md section gives the surrounding configuration.

| File | Copy to | Purpose | Documented in |
|------|---------|---------|---------------|
| [`block-git-writes.sh`](block-git-writes.sh) | `~/.claude/hooks/block-git-writes.sh` (`chmod +x` after copying) | `PreToolUse` hook that allows only read-only git commands in `Bash` (`status`, `diff`, `log`, …) and blocks the rest, so git state changes stay with the developer. | [Sandbox configuration](../docs/setup.md#sandbox-configuration) |
| [`.claudeignore`](.claudeignore) | The root of each workspace where you use Claude Code | Suppresses speculative scans of high-noise / low-value paths (dependencies, build output, lockfiles, large data, IDE cruft). | [Configure .claudeignore](../docs/setup.md#configure-claudeignore) |
