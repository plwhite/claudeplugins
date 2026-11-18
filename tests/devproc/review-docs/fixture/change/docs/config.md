# Configuration

This page lists the settings greeter reads.

## Environment variables

| Variable | Default | Meaning |
|---|---|---|
| `GREET_LANG` | `en` | Greeting language (`en` or `fr`) |
| `GREET_CACHE` | `~/.cache/greeter` | Directory `cleanup.sh` clears |

## Installation prefix

`PREFIX` sets where `make install` puts the scripts, in `$PREFIX/bin`. It
comes from the `make` command line, else the environment, else the default
`/usr/local`. The scripts run by name only if `$PREFIX/bin` is on your `PATH`.

For how the pieces fit together, see [architecture.md](architecture.md).
