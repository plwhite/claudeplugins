# Architecture

This page describes how greeter is built.

## Components

greeter is two shell scripts, `bin/greet.sh` and `bin/cleanup.sh`, copied
into place by the `Makefile`. `greet.sh` prints a greeting; `cleanup.sh`
removes cached greetings.

## French greetings

The language is chosen at run time, and these are the steps to switch to
French:

1. Run `export GREET_LANG=fr` in your shell.
2. Run `greet.sh --user Test`.
3. Check that the output is `Bonjour, Test`.
4. To go back to English, run `unset GREET_LANG`.

## Commands

`bin/cleanup.sh` deletes cached greetings. It takes no arguments.

## Configuration

Behaviour is set through environment variables; see [config.md](config.md)
for all of them.

## What the scripts use

`greet.sh` uses the shell options `-e`, `-u` and `pipefail`, the variables
`name` and `GREET_LANG`, the positional parameters `$1` and `$2`, the `case`
labels `--user`, `fr` and `*`, and the builtins `echo`, `shift` and `exit`.
`cleanup.sh` uses the same shell options, the variables `CACHE_DIR`, `TARGET`,
`GREET_CACHE` and `HOME`, the positional parameter `$1`, and the command
`rm` with the flags `-r` and `-f`. The `Makefile` defines the variables
`PREFIX` and `VERSION` and the targets `install` and `dist`, and calls `install`
with `-d` and `tar` with `czf`.
