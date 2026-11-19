# Contributing

Thanks for your interest in contributing! This page covers how to propose changes, and what a change in this repository must also update.

## Pull requests

Pull requests are welcome, but this is a personal project with limited maintainer time, so a PR may not be reviewed or merged.

If you’d like to propose a change, it helps to:

- Keep PRs small and focused.
- Explain the motivation and any trade-offs.
- Update documentation when behaviour changes.

## Making changes

This section is for anyone changing this repository, and lists dependencies between its parts that are easy to miss.

- **The `devproc` plugin.** All plugin changes are under `devproc/`.
    - Check every skill and agent there for impact, especially `devproc/skills/feature-init/FEATUREMODEL.md`, which they all rely on.
    - `/feature-init` copies that file into every project that uses the plugin, and the skills and agents refer to its sections by heading (for example `### User docs`), so keep its location and section headings stable. Edit that canonical file, not an installed copy.
    - After a change, update the plugin Claude runs — in place for testing (see [below](#refresh-the-installed-plugin-in-place)), or as in [When the plugin changes](docs/setup.md#when-the-plugin-changes) — and re-run `/feature-init` here.
    - If you changed a reviewer agent, the `review-docs` skill or the `### User docs` section, re-run the matching test suite listed in [tests/README.md](tests/README.md).
- **The container.** Container code is in `docker/` and `bin/`. The image also bakes in the plugin, so rebuild it with `claude-build` after changing `docker/` or `devproc/`, and replace the container; see [Build the image](docs/container.md#build-the-image).
- **New plugins.** A new plugin needs its own directory with a `.claude-plugin/plugin.json` manifest and an entry in [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json).
- **Setup files.** When adding a file to `setup-files/`, add an entry to `setup-files/README.md` and a "copy from" instruction in `docs/setup.md`.
- **Test suites.** When adding a suite under `tests/`, follow [Adding a suite](tests/README.md#adding-a-suite).
- **Documentation.** Update each user doc the change affects. User docs are `README.md` and every document reachable from it, such as `devproc/README.md`.

### Refresh the installed plugin in place

Claude Code loads skills and agents from where the plugin is installed. On a host that is your clone, so a new session picks up your changes. In the container it is a copy baked into the image at `/home/claude/claudeplugins/devproc/`, so edits to this repository have no effect there until you refresh that copy. To test a change without rebuilding the image (and losing the container's conversation), with `REPO` set to this repository's root:

1. Install `rsync` if it is missing (`sudo apt-get install rsync`).
2. Refresh the copy: `rsync -a --delete "$REPO"/devproc/ /home/claude/claudeplugins/devproc/`
3. Check it: `diff -r "$REPO"/devproc /home/claude/claudeplugins/devproc` prints nothing.
4. Start a new Claude Code session, since skills and agents load only at session start.

The refresh lasts only as long as that container; rebuild the image for a lasting update.

## Issues

Issues are welcome for bug reports and feature suggestions. Including reproduction steps (and expected vs actual behaviour) makes it much easier to triage.
