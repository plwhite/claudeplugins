# Configuration

This page lists the settings greeter reads.

## Environment variables

| Variable | Default | Meaning |
|---|---|---|
| `GREET_LANG` | `en` | Greeting language (`en` or `fr`) |
| `GREET_CACHE` | `~/.cache/greeter` | Directory `cleanup.sh` clears |

## Installation prefix

`PREFIX` sets where `make install` puts the scripts. It defaults to
`/usr/local`, and the scripts go in `$PREFIX/bin`. The install steps themselves
are in [setup.md](setup.md).
