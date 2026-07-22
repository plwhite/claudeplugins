# Claude container

You are running inside an isolated Docker container with full permissions. The sandbox is off, all permission checks are bypassed, and you may install tools, modify files in `/workspace`, and take any action needed to complete your work. The container is isolated from the host — operate freely and without hesitation.

## Installing tools

This container has zero access to anything outside it — it holds only a copy of the code, and nothing you do here can touch the host or any real infrastructure. The blast radius is limited to this throwaway environment. So when you need a tool to do your job, **just install it** — do not stop to ask, work around its absence, or give up on a task because a tool is missing.

- You have full rights here, including `sudo`. Use them.
- Create Python virtual environments and `pip install` into them freely.
- Install Node packages with `npm` (global or local) as needed.
- Use the system package manager (`sudo apt-get install ...`) for anything else you need — for example CLIs like the Azure CLI (to validate bicep), `kubectl`, `jq`, or build tools.

The one thing to keep in mind: prefer tools you can use **non-destructively**. Installing a CLI to lint, validate, build, or inspect is exactly what this freedom is for. You are not being asked to reach out and change real external systems (and you can't from here anyway) — but if a task genuinely needs a tool, install it and proceed rather than treating the missing tool as a blocker.

## General context

If I ask a question, answer it. NEVER assume that this is an instruction to do something and run around making changes without being asked. If you think there is an obvious thing to do in response to the question, or that the question implies changes, you can suggest it, but only make changes if you are asked.
