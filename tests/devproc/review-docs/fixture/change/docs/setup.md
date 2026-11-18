# Setup

This page explains how to install greeter.

## Steps

1. Run `make install PREFIX=$HOME/.local` to copy the scripts to
   `$HOME/.local/bin`. Use a `PREFIX` under your home directory so that no
   root access is needed.
2. Run `greet.sh --user Test` to check the installation.
3. Before you start, make sure bash 4 or later and make are installed; the
   commands above fail without them.

## Installation prefix

`PREFIX` sets where the scripts are installed. It defaults to `/usr/local`,
which only root can write to, and the scripts go in `$PREFIX/bin`. The
directory is created by `make install` if it does not exist. The scripts run by name
only if `$PREFIX/bin` is on your `PATH`; the default `/usr/local/bin` normally
already is.

## The greet skill

The `greet` skill runs `bin/greet.sh --name <name>` and shows the output,
keeping any extra commentary to one sentence. It follows four rules. If you
give no name, it asks for one before running anything. It passes the name
exactly as you give it, never shortening or changing its spelling. If
`bin/greet.sh` fails, it shows the error text unchanged and stops. It never
runs `bin/cleanup.sh` as part of a greeting.

If something goes wrong, see [troubleshooting](troubleshooting.md).
