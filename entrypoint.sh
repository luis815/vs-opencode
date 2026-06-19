#!/bin/bash
set -e

# Run both processes in background
/usr/local/bin/code tunnel --name "$CODE_TUNNEL_NAME" --accept-server-license-terms &
/home/umbrel/.opencode/bin/opencode web --hostname "$OPENCODE_HOSTNAME" --port "$OPENCODE_PORT" &

# Wait for all background processes
wait
