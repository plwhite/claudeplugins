![devproc](images/devproc_wide.png)

# Claude Code setup and workflows

This repository contains descriptions and tooling for a set of best practices using Claude Code. It includes the following.

- Documentation for how to set up and configure your Claude environment so as to be secure and managed.

- A documented development workflow based around developing features with regular spec / design / review / sign off iterations.

- The `devproc` plugin, containing skills and agents to support and enforce the workflow via Claude slash commands.

- A Docker container that runs Claude with full permissions, for when you want Claude to work autonomously without sandbox restrictions. The container itself is restricted: no git credentials are configured, and writes on the host are limited to the mounted project directory.

Start with [docs/setup.md](docs/setup.md). The table below lists all the documentation.

## Documentation

| Document | What it covers |
|----------|---------------|
| [docs/setup.md](docs/setup.md) | Environment setup: sandbox, git hook, sensitive-file deny-list, `gh`, devproc install, `.claudeignore`, and updating when the plugin changes |
| [docs/workflow.md](docs/workflow.md) | Task-oriented guide: managing features from backlog to completion, including per-feature sign-off criteria and automated spec/design review |
| [docs/capabilities.md](docs/capabilities.md) | Semi-autonomous workflow management, code review, documentation review, and internal docs hygiene |
| [docs/container.md](docs/container.md) | Container mode: running Claude with full permissions in a restricted Docker container |
| [devproc/README.md](devproc/README.md) | devproc plugin reference: all skills, agents, and configuration |
| [setup-files/README.md](setup-files/README.md) | Files copied into place during setup (`.claudeignore`, git-write hook): destination and purpose |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Proposing changes, and what a change to the plugin, container, setup files or tests must also update |
| [tests/README.md](tests/README.md) | Maintainer-only test fixtures and a regression harness for the `devproc` reviewer agents and `/review-docs`; not shipped with the plugin |

## Plugins

| Plugin | Description |
|--------|-------------|
| [devproc](devproc/README.md) | Feature lifecycle, workflow orchestration, code review, documentation review, and internal docs hygiene: spec, design, implement, review, and close features |

Plugins are registered in [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json), which names each plugin and points to its source directory. See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.
