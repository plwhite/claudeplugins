# Setup files

Files referenced by [`docs/setup.md`](../docs/setup.md) that are meant to be copied into place rather than edited here. After cloning this repo, copy each file to the location indicated below; see the corresponding section of `docs/setup.md` for the full context and the surrounding configuration each one fits into.

| File | Copy to | Purpose | Documented in |
|------|---------|---------|---------------|
| [`block-git-writes.sh`](block-git-writes.sh) | `~/.claude/hooks/block-git-writes.sh` (`chmod +x` after copying) | `PreToolUse` hook that blocks `Bash` invocations matching git write commands (`commit`, `push`, `merge`, `reset`, etc.) so git state changes stay with the developer. | [Sandbox configuration](../docs/setup.md#sandbox-configuration) |
| [`.claudeignore`](.claudeignore) | The root of each project where you use Claude Code | Suppresses speculative scans of high-noise / low-value paths (dependencies, build output, lockfiles, large data, IDE cruft). | [Configure .claudeignore](../docs/setup.md#configure-claudeignore) |
