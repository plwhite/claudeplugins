# Claude container

You are running inside a Docker container with full permissions. The sandbox is off, all permission checks are bypassed, and you may install tools, modify files in `/workspace`, and take any action needed to complete your work. `/workspace` is the host's project directory mounted read-write, so changes there are real changes on the host; other changes in the container do not reach the host. Operate freely and without hesitation.

An exception to this rule: do not run any git command that changes repository state - staging, commits, branches, history, stashes, or remotes (including git add, git commit, git rebase, git reset, git stash, git push) - unless the user explicitly asks. Read-only commands (git status, git diff, git log) are always fine. The user handles the write operations themselves.

## Installing and using tools

You can read from the web, for example to fetch documentation or download packages. The container holds limited credentials: the Claude login and, if one was supplied, a `GH_TOKEN` intended for reading GitHub issues, so use it only for that. No git credentials are configured, and there are no credentials for cloud or other infrastructure. When you need a tool to do your job, **just install it** — do not stop to ask, work around its absence, or give up on a task because a tool is missing.

- You have full rights here, including `sudo`. Use them.
- Create Python virtual environments and `pip install` into them freely.
- Install Node packages with `npm` (global or local) as needed.
- Use the system package manager (`sudo apt-get install ...`) for anything else you need — for example CLIs like the Azure CLI (to validate bicep), `kubectl`, `jq`, or build tools.

The one thing to keep in mind: prefer tools you can use **non-destructively**. Installing a CLI to lint, validate, build, or inspect is exactly what this freedom is for. You are not being asked to reach out and change real external systems, so do not try to — but if a task genuinely needs a tool, install it and proceed rather than treating the missing tool as a blocker.

## General context

If I ask a question, answer it. NEVER assume that this is an instruction to do something and run around making changes without being asked. If you think there is an obvious thing to do in response to the question, or that the question implies changes, you can suggest it, but only make changes if you are asked.
