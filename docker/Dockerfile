FROM ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    tmux \
    nodejs \
    npm \
    locales \
    python3 \
    python3-pip \
    python3-venv \
    shellcheck \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install gh from GitHub's own apt repository rather than Ubuntu's archive.
# Ubuntu's package lags well behind GitHub's releases, even on ubuntu:latest,
# and old versions break `gh issue view --comments`. Follows GitHub's Debian
# instructions (https://github.com/cli/cli/blob/trunk/docs/install_linux.md),
# using the curl installed above instead of wget.
RUN mkdir -p -m 755 /etc/apt/keyrings \
    && curl -fsSL -o /etc/apt/keyrings/githubcli-archive-keyring.gpg \
        https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && mkdir -p -m 755 /etc/apt/sources.list.d \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Setup locale - necessary for Claude to look right
RUN locale-gen en_GB.UTF-8
ENV LANG=en_GB.UTF-8
ENV LANGUAGE=en_GB:en
ENV LC_ALL=en_GB.UTF-8

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Set up user; we repurpose the ubuntu user as claude
ARG UID
ARG GID
RUN usermod -l claude ubuntu \
    && usermod -d /home/claude -m claude \
    && groupmod -n claude ubuntu \
    && usermod -u $UID claude \
    && groupmod -g $GID claude

RUN echo "claude ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/claude \
    && chmod 0440 /etc/sudoers.d/claude

COPY --chown=claude:claude docker/files/home /home/claude
COPY --chown=claude:claude .claude-plugin /home/claude/claudeplugins/.claude-plugin
COPY --chown=claude:claude devproc /home/claude/claudeplugins/devproc
RUN chmod +x /home/claude/entrypoint.sh

USER claude
ENTRYPOINT ["/home/claude/entrypoint.sh"]
