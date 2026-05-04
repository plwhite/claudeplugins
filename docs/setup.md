# Setup guide

This guide walks through configuring Claude Code for a productive development workflow. The detailed steps below cover the full configuration; at a high level, you will:

- Set up strong sandbox security so that Claude cannot access files or paths outside your repo.

- Lock down git access so that Claude can only view git status, not push to git.

- Block reads of files that conventionally hold secrets (`.env`, private keys, credentials).

- Install the plugin.

- Drop a recommended `.claudeignore` into each project to suppress speculative scans of high-noise paths.

None of these steps are required; this is "how to configure your system in the right way for me", which you may wish to tweak appropriately.

## Detailed steps

To set everything up, follow the stages below.

1. Check that you satisfy the [prerequisites](#prerequisites) below.

2. [Clone this repository](#clone-this-repository) to a stable location — subsequent steps copy files out of it.

3. Configure Claude code to [run sandboxed](#sandbox-configuration).

4. [Block reads of sensitive files](#block-reads-of-sensitive-files).

5. Install and authenticate [the GitHub CLI](#install-and-authenticate-github-cli).

6. [Enable the `devproc` plugin](#enable-the-devproc-plugin).

7. [Configure `.claudeignore`](#configure-claudeignore) for each repo where you use Claude.

8. Initialise the [`devproc` plugin for each repo](#initialise-devproc-in-each-repo-for-which-you-want-to-use-it).

### Prerequisites

- Linux (WSL should work fine, as should macOS, but only Linux has been tested)

- [Claude Code](https://claude.ai/code) installed, ideally as the vscode extension.

- Various command line tools including `jq`, `bash`, `git`

- Optionally `gh` installed for GitHub access

### Clone this repository

Several later steps copy files out of this repo (the git-write hook, the `.claudeignore` template) and the plugin install also points at it. Clone it once to a stable location:

```bash
git clone https://github.com/plwhite/claudeplugins /some/path/claudeplugins
```

Subsequent instructions assume `/some/path/claudeplugins`; substitute your chosen path throughout. The path is reused under [Sandbox configuration](#sandbox-configuration), [Enable the devproc plugin](#enable-the-devproc-plugin), and [Configure .claudeignore](#configure-claudeignore), so a stable location matters.

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

- Copy the git-write hook from this repo into `~/.claude/hooks/` and make it executable. The script source lives at [`setup-files/block-git-writes.sh`](../setup-files/block-git-writes.sh):

  ```bash
  mkdir -p ~/.claude/hooks
  cp /some/path/claudeplugins/setup-files/block-git-writes.sh ~/.claude/hooks/block-git-writes.sh
  chmod +x ~/.claude/hooks/block-git-writes.sh
  ```

  With this in place, Claude can run read-only commands (`git status`, `git diff`, `git log`, `git show`, `git blame`) freely. Attempts to commit, push, merge, reset, or otherwise modify git state are blocked and must be run manually.

### Block reads of sensitive files

The sandbox restricts where Claude can write, but reads inside the project directory and other allowed paths are unrestricted. A `.env` file, an SSH key checked into the wrong place, or a stray `credentials.json` is therefore visible to Claude — and from there it can leak into tool output, summaries, commit messages, or generated artefacts. Claude Code has a `permissions.deny` mechanism that refuses specific tool actions outright; the configuration below blocks reads of the file patterns that most commonly hold secrets, regardless of where they appear in the tree.

- Edit `~/.claude/settings.json` and add or merge the following with the existing top-level keys (`sandbox`, `hooks`, etc.) — do not replace them:

  ```json
  {
    "permissions": {
      "deny": [
        "Read(.env)",
        "Read(.env.*)",
        "Read(**/.env)",
        "Read(**/.env.*)",
        "Read(**/secrets.*)",
        "Read(**/*.pem)",
        "Read(**/*.key)",
        "Read(**/*.p12)",
        "Read(**/id_rsa)",
        "Read(**/id_ed25519)",
        "Read(**/credentials.json)"
      ]
    }
  }
  ```

Each entry covers a category of secret material:

- **`.env` files** (`.env`, `.env.*`, `**/.env`, `**/.env.*`) — application configuration files that conventionally hold API keys, database URLs, and other credentials. Both top-level and nested forms are covered.
- **Generic secrets files** (`**/secrets.*`) — files named `secrets.json`, `secrets.yaml`, `secrets.toml`, etc. that hold credentials in projects that follow that convention.
- **Cryptographic key material** (`**/*.pem`, `**/*.key`, `**/*.p12`) — private keys and certificate bundles.
- **SSH private keys** (`**/id_rsa`, `**/id_ed25519`) — the standard filenames for SSH private keys, which are sometimes inadvertently checked into a repo or left in an adjacent path.
- **GCP-style credentials** (`**/credentials.json`) — the conventional filename for Google Cloud service-account credentials and similar.

This is defence in depth, not a substitute for keeping secrets out of the working tree in the first place. Adapt the list to your own conventions: if your project uses different filenames for secret material, add them.

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

### Enable the devproc plugin

The `devproc` plugin is the heart of this repository, with skills and agents to support the development workflow. The repo was cloned earlier under [Clone this repository](#clone-this-repository); now register it as a local plugin marketplace and enable the plugin.

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

### Configure .claudeignore

Claude Code respects a `.claudeignore` file at the project root, which excludes the matching paths from speculative directory scans. Without it, Claude can spend tokens and time grepping through `node_modules/`, build output, lockfiles, large data files, and other high-noise / low-value paths.

A recommended template lives at [`setup-files/.claudeignore`](../setup-files/.claudeignore); the file's section comments document what each pattern group covers. Drop it into each project root:

```bash
cp /some/path/claudeplugins/setup-files/.claudeignore .
```

Adapt the patterns to your project as needed — the file is intended as a sensible default, not a fixed list.

### Initialise devproc in each repo for which you want to use it

Before you use the `devproc` plugins features, it needs certain files and instructions set up. To do this, start Claude in your project either from the CLI or in the IDE, and enter

~~~
/feature-init
~~~

This is idempotent, and ensures that feature development skills work. If you fail to do this, attempts to use any of these features returns an error.

## What's next

See [workflow.md](workflow.md) for a task-oriented guide to daily use, and [capabilities.md](capabilities.md) for code review and documentation review.
