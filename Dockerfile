FROM fedora:44

# Install system dependencies
RUN dnf install -y \
    git \
    tar \
    unzip \
    gzip \
    xz \
    curl \
    sudo \
    which \
    vim \
    nano \
    jq \
    iputils \
    wget \
    procps-ng \
    tree \
    xdg-utils \
    && dnf clean all

# Create non-root user "vsopencode" with home directory
RUN useradd -m -s /bin/bash vsopencode && \
    usermod -aG wheel vsopencode && \
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vsopencode && \
    chmod 0440 /etc/sudoers.d/vsopencode

# Set default port for OpenCode
ENV OPENCODE_PORT=4096

# Set default hostname for OpenCode
ENV OPENCODE_HOSTNAME=0.0.0.0

# Set default tunnel name for VS Code
ENV CODE_TUNNEL_NAME=vs-opencode

# ============================================================================
# Install VS Code CLI (Linux x64)
# ============================================================================
WORKDIR /tmp
RUN curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' \
    --output vscode_cli.tar.gz && \
    tar -xf vscode_cli.tar.gz && \
    mv code /usr/local/bin/ && \
    chmod +x /usr/local/bin/code && \
    rm vscode_cli.tar.gz

# ============================================================================
# Copy entrypoint script before switching to non-root user
# ============================================================================
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# ============================================================================
# Switch to non-root user and prepare home directory
# ============================================================================
USER vsopencode
WORKDIR /home/vsopencode

CMD ["/usr/local/bin/entrypoint.sh"]
