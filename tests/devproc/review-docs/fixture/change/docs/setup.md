# Setup

This page explains how to install greeter.

## Steps

1. Run `make install PREFIX=$HOME/.local` to copy the scripts to
   `$HOME/.local/bin`.
2. Run `greet.sh --user Test` to check the installation.
3. Before you start, make sure bash 4 or later and make are installed; the
   commands above fail without them.

## Installation prefix

`PREFIX` sets where the scripts are installed. It defaults to `/usr/local`, and
the scripts go in `$PREFIX/bin`. The cache location and the other runtime
settings are documented in [config.md](config.md).

If something goes wrong, see [troubleshooting](troubleshooting.md).
