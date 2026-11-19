# Setup guide

This guide is for people setting up Claude Code for the `devproc` workflow. It covers [initial setup](#detailed-steps) and [what to do when the plugin changes](#when-the-plugin-changes).

## Detailed steps

To set everything up, follow the stages below.

1. Check that you satisfy the [prerequisites](#prerequisites) below.

2. [Clone this repository](#clone-this-repository) to a stable location — subsequent steps copy files out of it.

3. Configure Claude Code to [run sandboxed, optionally with the git-write hook](#sandbox-configuration).

4. [Block reads of sensitive files](#block-reads-of-sensitive-files).

5. Install and authenticate [the GitHub CLI](#install-and-authenticate-github-cli).

6. [Enable the `devproc` plugin](#enable-the-devproc-plugin).

7. [Configure `.claudeignore`](#configure-claudeignore) for each workspace where you use Claude.

8. [Initialise `devproc` in each workspace](#initialise-devproc-in-each-workspace).

Steps 1, 2, 6 and 8 are needed for `devproc`; steps 3, 4, 5 and 7 are recommended, so adapt them to your needs.

### Prerequisites

- Linux (WSL should work fine, as should macOS, but only Linux has been tested)

- [Claude Code](https://claude.ai/code) installed (the VS Code extension is the tested route).

- Command-line tools: `bash`, `git` and `jq`.

- Optionally, `gh` for GitHub access (see [below](#install-and-authenticate-github-cli)).

### Clone this repository

Several later steps copy files out of this repo (the git-write hook, the `.claudeignore` template) and the plugin install also points at it. Clone it once to a stable location:

```bash
git clone https://github.com/plwhite/claudeplugins /some/path/claudeplugins
```

Subsequent instructions assume `/some/path/claudeplugins`; substitute your chosen path throughout.

### Sandbox configuration

Run Claude Code sandboxed, with limited network access and no git write access.

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

  *To let Claude make git changes directly, skip this hook step and omit the `hooks` section from the JSON above.*

  With this in place, Claude can run read-only git commands (`git status`, `git diff`, `git log`, `git show`, `git blame` and the like, plus listing forms such as `git branch`, `git tag -l`, `git remote -v`, `git stash list` and `git config --get`) freely. Any other git command — commit, push, checkout, reset, and so on, including aliases — is blocked, and you run it yourself. The hook needs `jq`; without it, nothing is blocked.

### Block reads of sensitive files

The sandbox restricts where Claude can write, but reads inside the project directory and other allowed paths are unrestricted. A `.env` file, SSH key or `credentials.json` inside the project is therefore readable by Claude, and from there can leak into tool output, summaries, commit messages or generated artefacts. Claude Code's `permissions.deny` setting refuses specific tool actions outright; the configuration below blocks reads of the file patterns that most commonly hold secrets, wherever they appear in the tree.

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

The GitHub CLI lets Claude Code read issues, so it can spec and design features from them. Install it with a read-only, issues-only token, so Claude's GitHub access stays limited.

- Install the GitHub CLI `gh`, following the instructions at <https://cli.github.com/>.

- On the [GitHub website](https://www.github.com), create a PAT with read-only access to issues (only). With so little access, it can safely have no expiry.

- Authenticate using that GitHub PAT.

  ```bash
  gh auth login --with-token <<< "github_pat_yourtoken..."
  ```

- Check the login from inside a repository with a GitHub remote: `gh issue list` prints the repository's open issues (or nothing, if there are none). An authentication error means the token is wrong or lacks issue access.

  ~~~bash
  gh issue list
  ~~~

- If you will use [container mode](container.md), also save the token as described in [GitHub access](container.md#github-access): `gh auth login` authenticates the CLI on this machine only, and the container does not copy that login in.

### Enable the devproc plugin

The `devproc` plugin is the heart of this repository, with skills and agents to support the development workflow. Register your clone as a local plugin marketplace and enable the plugin.

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

  *This enables the plugin in every repo. To enable it only in some, put the `enabledPlugins` stanza in `.claude/settings.local.json` in those repos instead.*

### Configure .claudeignore

Claude Code respects a `.claudeignore` file at the workspace root, which excludes the matching paths from speculative directory scans. Without it, Claude can spend tokens and time grepping through `node_modules/`, build output, lockfiles, large data files, and other high-noise / low-value paths.

A recommended template lives at [`setup-files/.claudeignore`](../setup-files/.claudeignore); the file's section comments document what each pattern group covers. Drop it into each workspace root — one copy at the top of the workspace, not one per nested repository, since scans are rooted where Claude starts:

```bash
cp /some/path/claudeplugins/setup-files/.claudeignore .
```

Adapt the patterns to your project as needed — the file is intended as a sensible default, not a fixed list.

### Initialise devproc in each workspace

Before using `devproc`, initialise each **workspace** (the directory holding `CLAUDE.md`, `NOTES.md` and `features/`, usually a git repository). Run `/feature-init` at its top, never inside a nested repository; see [workflow.md](workflow.md#where-the-workspace-is).

To do this, start Claude in your workspace either from the CLI, in the IDE, or using the container, and enter

~~~
/feature-init
~~~

`/feature-init` is safe to re-run. Until you run it in a workspace, the feature skills return an error there.

## When the plugin changes

The steps above are one-off, so they do not pick up later changes to `devproc`. When the plugin changes (you pull a new version of this repository, or edit the plugin yourself):

1. Update the plugin Claude runs:
    - **In [container mode](container.md):** rebuild the image, then replace each project's container:

        ```bash
        bash /some/path/claudeplugins/bin/claude-build
        bash /some/path/claudeplugins/bin/claude-stop /path/to/project   # deletes the container and its conversation
        bash /some/path/claudeplugins/bin/claude-run /path/to/project
        ```

        The container must be replaced because it keeps the image it was created with; see [Edge cases and limits](container.md#edge-cases-and-limits).
    - **Otherwise:** pull the changes into your clone (the plugin loads from it; see [Enable the devproc plugin](#enable-the-devproc-plugin)), then start a new Claude Code session. Skills and agents load only at session start.
2. Re-run `/feature-init` in each workspace, so its installed feature model (`features/FEATUREMODEL.md`) matches the new plugin. It leaves your feature lists and plans in place. In a tracked workspace, `git diff features/FEATUREMODEL.md` then shows what changed.

## What's next

See [workflow.md](workflow.md) for a task-oriented guide to daily use, and [capabilities.md](capabilities.md) for code review and documentation review.
