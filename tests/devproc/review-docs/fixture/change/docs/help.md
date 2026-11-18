# Troubleshooting

This page lists common problems when running greeter.

- **"unknown option"** — check the option spelling against the usage page.
- **Greeting in the wrong language** — In order to be able to determine what
  the reason might be for the greeting appearing in a language other than the
  one that you were expecting, it is first of all necessary to take the step
  of checking what the value of the `GREET_LANG` variable currently happens to
  be set to.
- **Old greetings keep appearing** — run `bin/cleanup.sh`. The cache was added
  in an early release after users complained that greetings were slow, and it
  originally lived in `/tmp`; people objected to it being wiped on every
  reboot, so it moved to `~/.cache/greeter`, which is why the location is
  configurable today.

## Checklist

Before looking further, check that:

- `bash --version` shows 4 or later
- `command -v greet.sh` prints a path
- `echo "$GREET_LANG"` prints `en`, `fr` or nothing
- `greet.sh --user Test` prints a greeting
