# Claude plugins

A collection of plugins for [Claude Code](https://claude.ai/code). Each plugin packages skills (prompt/behavior documents) and agents that extend Claude Code's capabilities in a structured way.

## What are plugins?

Plugins are directories that Claude Code discovers and loads, making their skills available as slash commands and their agents available by name. This repository registers its plugins via `.claude-plugin/marketplace.json` at the root, which tells Claude Code where to find each plugin. When adding a new plugin to this repo, register it there as well as creating its directory.

## Plugins

| Plugin | Description |
|--------|-------------|
| [demo](demo/README.md) | Minimal demo plugin for verifying plugin discovery and wiring |
| [devproc](devproc/README.md) | Feature lifecycle skills: create, start, checkpoint, and end features |

## Plugin registry

Plugins are registered in [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json). Each entry names the plugin and points to its source directory:

```json
{ "name": "my-plugin", "source": "./my-plugin" }
```

Claude Code reads this file to discover available plugins. A new plugin must have an entry here as well as its own directory containing a `.claude-plugin/plugin.json` manifest.

## Development

The workspace guide, feature model, and active feature list are in [`CLAUDE.md`](CLAUDE.md) and [`FEATURES.md`](FEATURES.md). Read `CLAUDE.md` first when starting work on this repository.
