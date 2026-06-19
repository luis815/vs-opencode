# coder-env

A containerized development environment that runs VS Code Server and OpenCode Web simultaneously.

## Overview

This project sets up a complete development environment inside a Docker container with:
- **VS Code Tunnel** - Remote VS Code access via `code tunnel`
- **OpenCode Web** - Web-based code editor interface
- **Simple Process Management** - Both services run concurrently via a bash entrypoint script

## Prerequisites

- Docker installed on your system
- Basic familiarity with Docker commands

## Building the Docker Image

```bash
docker build -t coder-env .
```

## Running the Container

```bash
docker run -d \
  --name coder-env \
  -p 4096:4096 \
  coder-env
```

### Environment Variables

- `OPENCODE_PORT` - Port for OpenCode Web (default: `4096`)
- `OPENCODE_HOSTNAME` - Hostname/IP for OpenCode Web to bind to (default: `0.0.0.0`)
- `CODE_TUNNEL_NAME` - Name for VS Code Tunnel (default: `coder-env`)

#### Override Example

```bash
docker run -d \
  --name coder-env \
  -e OPENCODE_PORT=8080 \
  -e OPENCODE_HOSTNAME=127.0.0.1 \
  -e CODE_TUNNEL_NAME=my-custom-tunnel \
  -p 8080:8080 \
  coder-env
```

### Port Mappings

- **4096** (default) - OpenCode Web interface (accessible at `http://localhost:4096`)
- **VS Code Tunnel** - Uses its own connection mechanism for remote access

## Services

### VS Code Tunnel
Provides remote access to VS Code through secure tunnels.
- **Command:** `code tunnel --accept-server-license-terms`
- **User:** umbrel
- **Tunnel Name:** Configurable via `CODE_TUNNEL_NAME` environment variable (default: `coder-env`)

### OpenCode Web
Web-based code editor accessible in your browser.
- **Command:** `opencode web --hostname $OPENCODE_HOSTNAME --port $OPENCODE_PORT`
- **User:** umbrel
- **Port:** Configurable via `OPENCODE_PORT` environment variable (default: 4096)
- **Hostname:** Configurable via `OPENCODE_HOSTNAME` environment variable (default: 0.0.0.0)

## Architecture

- **Base Image:** Fedora 44
- **Process Manager:** Bash entrypoint script with background processes
- **Non-root User:** umbrel (security best practice)
- **Project Directory:** `/home/umbrel/projects` - Default directory for project files
- **Installed Tools:**
  - Git
  - VS Code CLI
  - OpenCode
  - Proto (version manager)

## Logs

Both services log to stdout/stderr, making them visible via:

```bash
docker logs coder-env
```
