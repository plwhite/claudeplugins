# Setup guide

This guide walks through configuring Claude Code for a productive development workflow:

- Set up strong sandbox security so that Claude cannot access files or paths outside your repo.

- Lock down git access so that Claude can only view git status, not push to git.

- Install the plugin.

None of these steps are required; this is "how to configure your system in the right way for me", which you may wish to tweak appropriately.

## Detailed steps

To set everything up, follow the stages below.

1. Check that you satisfy the [prerequisites](#prerequisites) below.

2. Configure Claude code to [run sandboxed](#sandbox-configuration).

3. Install and authenticate [the GitHub CLI](#install-and-authenticate-github-cli).

4. Make the [`devproc` plugin available](#make-the-devproc-plugin-available-locally).

5. Initialise the [`devproc` plugin for each repo](#initialise-devproc-in-each-repo-for-which-you-want-to-use-it).

### Prerequisites

- Linux (WSL should work fine, as should macOS, but only Linux has been tested)

- [Claude Code](https://claude.ai/code) installed, ideally as the vscode extension.

- Various command line tools including `jq`, `bash`, `git`

- Optionally `gh` installed for GitHub access

### Sandbox configuration

Set up Claude Code so that it runs sandboxed on your box, with limited network access and no git write access. *If you want to allow Claude Code to make git changes directly, do not create the hooks file or hooks section.*

- Edit `~/.claude/settings.json`. Create it if it does not exist. Add or merge the following:

  ```json
  {
    "sandbox": {
      "enabled": true,
      "network": {
        "allowedDomains": ["github.com", "api.github.com"]
      }
    },
    "hooks": {
      "PreToolUse": [
        {
          "matcher": "Bash",
          "hooks": [
            {
              "type": "command",
              "command": "bash ~/.claude/hooks/block-git-writes.sh"
            }
          ]
        }
      ]
    }
  }
  ```

- Configure git write protection as referenced in the script above.

  ```bash
  mkdir -p ~/.claude/hooks
  cat > ~/.claude/hooks/block-git-writes.sh << 'EOF'
  #!/bin/bash
  INPUT=$(cat)
  COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

  # Only care about git commands
  echo "$COMMAND" | grep -qE '\bgit\b' || exit 0

  # Block write operations
  if echo "$COMMAND" | grep -qE '\bgit\s+(commit|add|push|fetch|pull|merge|rebase|reset|stash|tag|branch -d|branch -D)\b'; then
    echo "BLOCKED: '$COMMAND' — git write operations are reserved for the developer." >&2
    exit 2
  fi

  exit 0
  EOF
  chmod +x ~/.claude/hooks/block-git-writes.sh
  ```

  With this in place, Claude can run read-only commands (`git status`, `git diff`, `git log`, `git show`, `git blame`) freely. Attempts to commit, push, merge, reset, or otherwise modify git state are blocked and must be run manually.

### Install and authenticate GitHub CLI

The GitHub CLI allows Claude Code to read issues, which is very useful if you wish to have it design and implement them. Follow the instructions below to install it in a restricted way that ensures Claude only has limited access.

- Install the GitHub CLI `gh`, following the instructions at <https://cli.github.com/>.

- On the [GitHub website](https://www.github.com), create a PAT with read only access to issues (only). Since this is so restricted in what it can do, I normally let it have no expiry time.

- Authenticate using that GitHub PAT.

  ```bash
  gh auth login --with-token <<< "github_pat_yourtoken..."
  ```

- Check that it all works as expected.

  ~~~bash
  gh issue list
  ~~~

### Make the devproc plugin available locally

The `devproc` plugin is the heart of this repository, with skills and agents to support the development workflow.

- Clone this repository to a stable location on your machine:

  ```bash
  git clone https://github.com/plwhite/claudeplugins /some/path/claudeplugins
  ```

- Add the following to `~/.claude/settings.json`, replacing the path with wherever you cloned the repo:

  ```json
  {
    "extraKnownMarketplaces": {
      "local-plugins": {
        "source": {
          "source": "directory",
          "path": "/some/path/claudeplugins"
        }
      }
    },
    "enabledPlugins": {
      "devproc@local-plugins": true
    }
  }
  ```

  *Note that this enables the plugin for every repo globally. If that is not what you want to do, and you want to enable it only for some repos, then you should add the `enabledPlugins` stanza to `.claude/settings.local.json` for those repos.*

### Initialise devproc in each repo for which you want to use it

Before you use the `devproc` plugins features, it needs certain files and instructions set up. To do this, start Claude in your project either from the CLI or in the IDE, and enter

~~~
/feature-init
~~~

This is idempotent, and ensures that feature development skills work. If you fail to do this, attempts to use any of these features returns an error.

## What's next

See [workflow.md](workflow.md) for a task-oriented guide to daily use, and [capabilities.md](capabilities.md) for code review and documentation review.
