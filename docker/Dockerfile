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

COPY --chown=claude:claude docker/files/home /home/claude
COPY --chown=claude:claude .claude-plugin /home/claude/claudeplugins/.claude-plugin
COPY --chown=claude:claude devproc /home/claude/claudeplugins/devproc
RUN chmod +x /home/claude/entrypoint.sh

USER claude
ENTRYPOINT ["/home/claude/entrypoint.sh"]
