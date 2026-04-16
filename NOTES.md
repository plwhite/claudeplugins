# Notes

Non-obvious findings. Do not record things derivable from reading the code.

---

## gh CLI and sandbox

`gh issue view` and `gh api` time out in sandbox mode even when `WebFetch(domain:api.github.com)` is listed in project permissions. The `WebFetch(...)` permission only covers Claude's WebFetch tool — it has no effect on outbound network access from Bash processes. The sandbox blocks Bash network independently.

Both calls work when `dangerouslyDisableSandbox: true` is set. The correct fix is to add a sandbox network allowlist entry for `api.github.com` (and `github.com`) in settings.json. The exact config key needs investigation — see Sub-task 1 of the `docs-usability-issue6` feature.
