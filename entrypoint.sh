#!/bin/bash
set -e

# Install OpenCode if not already present (preserved across bind mounts)
if [ ! -f "$HOME/.opencode/bin/opencode" ]; then
    echo "Installing OpenCode..."
    curl -fsSL https://opencode.ai/install | bash
else
    echo "OpenCode already installed."
fi

# Install proto if not already present
if [ ! -f "$HOME/.proto/bin/proto" ]; then
    echo "Installing proto..."
    bash <(curl -fsSL https://moonrepo.dev/install/proto.sh) --yes --no-profile

    # Append proto paths to .bashrc
    {
        echo ""
        echo "# proto"
        echo 'export PROTO_HOME="$HOME/.proto"'
        echo 'export PATH="$PROTO_HOME/shims:$PROTO_HOME/bin:$PATH"'
    } >> "$HOME/.bashrc"
else
    echo "Proto already installed."
fi

# Source .bashrc to load any paths (proto, etc.)
source "$HOME/.bashrc"

# Run both processes in background
code tunnel --name "$CODE_TUNNEL_NAME" --accept-server-license-terms &
opencode web --hostname "$OPENCODE_HOSTNAME" --port "$OPENCODE_PORT" &

# Wait for all background processes
wait
