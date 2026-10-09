# syntax=docker/dockerfile:1

FROM fedora:latest

ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=1000

# ---------------------------------------------------------------------------
# Base development environment
# ---------------------------------------------------------------------------

RUN dnf -y --refresh update
RUN dnf --refresh -y install \
        gcc \
        gcc-c++ \
        make \
        cmake \
        ninja-build \
        pkgconf \
        pkgconf-pkg-config \
        git \
        curl \
        wget \
        ca-certificates \
        openssh-clients \
        rsync \
        unzip \
        zip \
        tar \
        gzip \
        bzip2 \
        xz \
        sudo \
        which \
        findutils \
        procps-ng \
        less \
        file \
        jq \
        ripgrep \
        fd-find \
        tree \
        tmux \
        golang \
        httpie \
        shellcheck \
        python3 \
        python3-pip \
        nodejs \
        npm \
        helix

RUN dnf clean all

# ---------------------------------------------------------------------------
# Normal development user
# ---------------------------------------------------------------------------

RUN groupadd --gid "${USER_GID}" "${USERNAME}" && \
    useradd \
        --uid "${USER_UID}" \
        --gid "${USER_GID}" \
        --create-home \
        --shell /bin/bash \
        "${USERNAME}" && \
    usermod -aG wheel "${USERNAME}" && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${USERNAME}" && \
    chmod 0440 "/etc/sudoers.d/${USERNAME}"

# ---------------------------------------------------------------------------
# Environment
# ---------------------------------------------------------------------------

ENV COLORTERM=truecolor
ENV TERM=xterm

# ---------------------------------------------------------------------------
# Pi
#
# The package name can be overridden at build time:
#
#   podman build \
#     --build-arg PI_PACKAGE=@earendil-works/pi-coding-agent \
#     -t fedora-dev .
# ---------------------------------------------------------------------------

ARG PI_PACKAGE=@earendil-works/pi-coding-agent

RUN npm install --global "${PI_PACKAGE}" && \
    npm cache clean --force

# ---------------------------------------------------------------------------
# SDKMAN!
#
# Install as the normal user so SDKMAN-managed JDKs/SDKs belong to the user.
# SDKMAN's installer is intended to be run as the user who will use it.
# ---------------------------------------------------------------------------

USER ${USERNAME}
WORKDIR /home/${USERNAME}

RUN curl -fsSL https://opencode.ai/v2/install | bash
RUN curl -s "https://get.sdkman.io" | bash

# Make SDKMAN available in interactive bash shells.
RUN printf '\n# SDKMAN!\n' >> "${HOME}/.bashrc" && \
    printf 'export SDKMAN_DIR="$HOME/.sdkman"\n' >> "${HOME}/.bashrc" && \
    printf '[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"\n' >> "${HOME}/.bashrc"

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------

ENV SHELL=/bin/bash
ENV EDITOR=hx
ENV VISUAL=hx
ENV LSP_HOME=/home/${USERNAME}/.lsp
ENV PATH="/home/${USERNAME}/.lsp:/home/${USERNAME}/.local/bin:${PATH}"

USER ${USERNAME}

WORKDIR /home/${USERNAME}
COPY --chown=${USERNAME}:${USERNAME} ./.config /home/${USERNAME}/.config
COPY --chown=${USERNAME}:${USERNAME} setup-lsp.sh /tmp/setup-lsp.sh
COPY --chown=${USERNAME}:${USERNAME} jdtls-wrapper /home/${USERNAME}/.lsp/jdtls-wrapper

RUN chmod +x /tmp/setup-lsp.sh \
            /home/${USERNAME}/.lsp/jdtls-wrapper && \
    bash /tmp/setup-lsp.sh && \
    ln -sf "${LSP_HOME}/jdtls-wrapper" "${LSP_HOME}/java" && \
    rm -f /tmp/setup-lsp.sh

RUN bash -c 'source "/home/${USERNAME}/.sdkman/bin/sdkman-init.sh" && \
    sdk install java 8.0.502-tem && \
    sdk install java 25.0.4-tem && \
    sdk install java 21.0.12-tem'

CMD ["/bin/bash", "-l"]
