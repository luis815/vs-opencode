# vs-opencode

A containerized development environment that runs VS Code Server and OpenCode Web simultaneously.

## Overview

This project sets up a complete development environment inside a Docker container with:
- **VS Code Tunnel** - Remote VS Code access via `code tunnel`
- **OpenCode Web** - Web-based code editor interface
- **Proto** - Multi-language version manager for runtime and tool management
- **Simple Process Management** - Both services run concurrently via a bash entrypoint script

## Prerequisites

- Docker installed on your system
- Basic familiarity with Docker commands

## Building the Docker Image

```bash
docker build -t vs-opencode .
```

## Running the Container

```bash
docker run -d \
  --name vs-opencode \
  -p 4096:4096 \
  vs-opencode
```

### Environment Variables

- `OPENCODE_PORT` - Port for OpenCode Web (default: `4096`)
- `OPENCODE_HOSTNAME` - Hostname/IP for OpenCode Web to bind to (default: `0.0.0.0`)
- `CODE_TUNNEL_NAME` - Name for VS Code Tunnel (default: `vs-opencode`)

#### Override Example

```bash
docker run -d \
  --name vs-opencode \
  -e OPENCODE_PORT=8080 \
  -e OPENCODE_HOSTNAME=127.0.0.1 \
  -e CODE_TUNNEL_NAME=my-custom-tunnel \
  -p 8080:8080 \
  vs-opencode
```

### Port Mappings

- **4096** (default) - OpenCode Web interface (accessible at `http://localhost:4096`)
- **VS Code Tunnel** - Uses its own connection mechanism for remote access

## Services

### VS Code Tunnel
Provides remote access to VS Code through secure tunnels.
- **Command:** `code tunnel --name "$CODE_TUNNEL_NAME" --accept-server-license-terms`
- **User:** vsopencode
- **Tunnel Name:** Configurable via `CODE_TUNNEL_NAME` environment variable (default: `vs-opencode`)

### OpenCode Web
Web-based code editor accessible in your browser.
- **Command:** `opencode web --hostname $OPENCODE_HOSTNAME --port $OPENCODE_PORT`
- **User:** vsopencode
- **Port:** Configurable via `OPENCODE_PORT` environment variable (default: 4096)
- **Hostname:** Configurable via `OPENCODE_HOSTNAME` environment variable (default: 0.0.0.0)

## Architecture

- **Base Image:** Fedora 44
- **Process Manager:** Bash entrypoint script with background processes (`wait` for both)
- **Non-root User:** vsopencode (security best practice, passwordless sudo via `wheel` group)
- **Working Directory:** `/home/vsopencode` - Home directory for the vsopencode user
- **Installed Tools (build-time):**
  - Git, tar, unzip, gzip, xz, curl, sudo, which
  - vim, nano, jq, iputils, wget, procps-ng, tree
  - VS Code CLI (`/usr/local/bin/code`)
- **Installed Tools (runtime via entrypoint):**
  - **OpenCode** — installed into `$HOME/.opencode` on first run if missing
  - **Proto** — installed into `$HOME/.proto` on first run if missing; paths appended to `~/.bashrc`
- **Entrypoint Behavior:** On container start, the entrypoint script conditionally installs OpenCode and Proto (skipping if already present), sources `~/.bashrc` to load environment paths, then launches both `code tunnel` and `opencode web` as background processes.
- **Bind Mount Friendly:** OpenCode and Proto install into the user's home directory, making them persist across container updates when the home directory is bind-mounted. This also preserves any runtimes (Java, Node.js, Python) installed via Proto and user preferences.

## Logs

Both services log to stdout/stderr, making them visible via:

```bash
docker logs vs-opencode
```
