#!/bin/bash
set -e

# If PUID and PGID are provided, remap the container user to match the host IDs.
# This avoids permission issues when bind-mounting a host directory over $HOME,
# since the host user (e.g., umbrel) may have a different UID/GID than vsopencode.
# Only remap if $HOME is currently owned by root (i.e., not a bind mount with
# proper ownership already).
if [ -n "$PUID" ] && [ -n "$PGID" ] && [ "$(stat -c '%u' "$HOME")" = "0" ]; then
    echo "Remapping container user to PUID=$PUID, PGID=$PGID..."
    sudo usermod -u "$PUID" vsopencode
    sudo groupmod -g "$PGID" vsopencode

    # Populate home from /etc/skel if key dotfiles are missing
    # This is needed when a host directory is bind-mounted over $HOME,
    # since bind mounts start empty and lack .bashrc, .bash_profile, etc.
    if [ ! -f "$HOME/.bashrc" ] || [ ! -f "$HOME/.bash_profile" ]; then
        echo "Populating home directory from /etc/skel..."
        sudo cp -rn /etc/skel/. "$HOME"
    fi

    sudo chown -R "$PUID:$PGID" "$HOME"
fi

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
code tunnel --name "$CODE_TUNNEL_NAME" --accept-server-license-terms 2>&1 | tee >(grep --line-buffered 'login/device' > "$HOME/tunnel-code.txt") &
opencode web --hostname "$OPENCODE_HOSTNAME" --port "$OPENCODE_PORT" &

# Wait for all background processes
wait
