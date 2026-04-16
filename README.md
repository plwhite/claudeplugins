# Claude Code setup and workflows

This repository contains descriptions and tooling for a set of practices using Claude Code. It includes the following.

- Documentation for how to set up and configure your Claude environment so as to be secure and managed.

- A documented development workflow based around developing features with regular spec / design / review / sign off iterations.

- The `devproc` plugin, containing skills and agents to support and enforce the workflow via Claude slash commands.

## Instructions

- Follow [docs/setup.md](docs/setup.md) to configure your environment.

- Follow [docs/workflow.md](docs/workflow.md) to follow the feature workflow.

- See [docs/capabilities.md](docs/capabilities.md) for code review and other capabilities.

## Documentation

| Document | What it covers |
|----------|---------------|
| [docs/setup.md](docs/setup.md) | Environment setup: sandbox, git hook, `gh`, devproc install |
| [docs/workflow.md](docs/workflow.md) | Task-oriented guide: managing features from backlog to completion |
| [docs/capabilities.md](docs/capabilities.md) | Code review and documentation review |
| [devproc/README.md](devproc/README.md) | devproc plugin reference: all skills, agents, and configuration |

## Plugins

| Plugin | Description |
|--------|-------------|
| [devproc](devproc/README.md) | Feature lifecycle and code review: create, plan, implement, review, and close features |
| [demo](demo/README.md) | Minimal demo plugin for verifying plugin discovery and wiring |

Plugins are registered in [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json). Each entry names the plugin and points to its source directory. A new plugin needs both an entry here and its own directory with a `.claude-plugin/plugin.json` manifest.
