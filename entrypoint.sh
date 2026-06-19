#!/bin/bash
set -e

# Run both processes in background
/usr/local/bin/code tunnel --accept-server-license-terms &
/home/umbrel/.local/bin/opencode web --hostname "$OPENCODE_HOSTNAME" --port "$OPENCODE_PORT" &

# Wait for all background processes
wait
