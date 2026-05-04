# Notes

Non-obvious findings. Do not record things derivable from reading the code.

---

## gh CLI and sandbox

`gh issue view` and `gh api` time out in sandbox mode even when `WebFetch(domain:api.github.com)` is listed in project permissions. The `WebFetch(...)` permission only covers Claude's WebFetch tool — it has no effect on outbound network access from Bash processes. The sandbox blocks Bash network independently.

The correct configuration is `sandbox.network.allowedDomains` in `~/.claude/settings.json` (global, since `gh` is used across projects):

```json
{
  "sandbox": {
    "enabled": true,
    "network": {
      "allowedDomains": ["github.com", "api.github.com"]
    }
  }
}
```

Wildcards are supported (e.g. `*.npmjs.org`). Domain arrays merge across settings scopes, so adding entries globally does not override project-level entries.

On macOS with a MITM proxy and custom CA, Go-based tools like `gh` may additionally need `"enableWeakerNetworkIsolation": true` under `sandbox.network` to reach the system TLS trust service — but this relaxes isolation and should only be used if needed.

---

## setup-files/ as a checked-in resources directory

`setup-files/` (added during `claudeignore-docs`) holds files users copy into their environments rather than recreate from heredocs. The directory name was chosen for direct pairing with `docs/setup.md`. Alternatives considered and rejected: `templates/` (implies edit-before-use, which most files here do not need), `resources/` (too generic), `dotfiles/` (the script isn't a dotfile).

Adding a file to `setup-files/` requires three coordinated edits: the file itself, an entry in `setup-files/README.md`, and a corresponding "copy from `/some/path/claudeplugins/setup-files/...`" instruction in `docs/setup.md`. The setup.md "Clone this repository" sub-section is the prerequisite for all such copy steps; reorder with care if it ever moves.
