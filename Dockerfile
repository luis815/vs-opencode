FROM fedora:44

# Install system dependencies
RUN dnf install -y \
    git \
    tar \
    unzip \
    gzip \
    xz \
    curl \
    && dnf clean all

# Create non-root user "umbrel" with home directory
RUN useradd -m -s /bin/bash umbrel

# Set environment paths globally
ENV PATH="/home/umbrel/.opencode/bin:/home/umbrel/.proto/bin:${PATH}"

# Set default port for OpenCode
ENV OPENCODE_PORT=4096

# Set default hostname for OpenCode
ENV OPENCODE_HOSTNAME=0.0.0.0

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
# Install OpenCode and proto as the umbrel user
# ============================================================================
USER umbrel
WORKDIR /home/umbrel

# Install OpenCode via install script
RUN curl -fsSL https://opencode.ai/install | bash

# Install proto via install script (non-interactive mode)
RUN bash <(curl -fsSL https://moonrepo.dev/install/proto.sh) --yes

CMD ["/usr/local/bin/entrypoint.sh"]
