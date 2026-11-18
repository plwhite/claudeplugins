# Contributing

Thanks for your interest in contributing! This page covers how to propose changes, and what a change in this repository must also update.

## Pull requests

Pull requests are welcome. However, this is a personal project and maintainership time is limited, so please don’t assume a PR will be reviewed or merged.

If you’d like to propose a change, it helps to:

- Keep PRs small and focused.
- Explain the motivation and any trade-offs.
- Update documentation when behavior changes.

## Making changes

This section is for anyone changing this repository, and lists dependencies between its parts that are easy to miss.

- **The `devproc` plugin.** All plugin changes are under `devproc/`. Check every skill and agent there for impact, especially `devproc/skills/feature-init/FEATUREMODEL.md`, which they all rely on. `/feature-init` copies that file into every project that uses the plugin, and the skills and agents refer to its sections by heading (for example `### User docs`), so keep its location and section headings stable. Edit that canonical file, not an installed copy. After a change:
    - Refresh the installed plugin from this repository, then re-run `/feature-init` here to apply your changes.
    - If you changed a reviewer agent, the `review-docs` skill or the `### User docs` section, re-run the matching test suite listed in [tests/README.md](tests/README.md).
- **The container.** Container code is in `docker/` and `bin/`. The image also bakes in the plugin, so rebuild it with `claude-build` after changing `docker/` or `devproc/`. A running container keeps its old image until you run `claude-stop`, then `claude-run`. See [docs/container.md](docs/container.md).
- **New plugins.** A new plugin needs its own directory with a `.claude-plugin/plugin.json` manifest and an entry in [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json).
- **Setup files.** When adding a file to `setup-files/`, add an entry to `setup-files/README.md` and a "copy from" instruction in `docs/setup.md`.
- **Test suites.** When adding a suite under `tests/`, follow [Adding a suite](tests/README.md#adding-a-suite).
- **Documentation.** Update each user doc the change affects. User docs are `README.md` and every document reachable from it, such as `devproc/README.md`.

## Issues

Issues are welcome for bug reports and feature suggestions. Including reproduction steps (and expected vs actual behavior) makes it much easier to triage.
