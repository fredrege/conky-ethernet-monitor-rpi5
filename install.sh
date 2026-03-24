#!/bin/bash

# Define paths
BIN_DIR="$HOME/bin"
SYSTEMD_DIR="$HOME/.config/systemd/user"
CONFIG_DIR="$HOME/.config/conky"

echo "Starting installation..."

# 1. Create directories if they don't exist
mkdir -p "$BIN_DIR"
mkdir -p "$SYSTEMD_DIR"
mkdir -p "$CONFIG_DIR"

echo "Directories created..."

# 2. Copy the listener and controller scripts, and make them executable
cp net-monitor.sh "$BIN_DIR/"
cp net-monitor-ctrl.sh "$BIN_DIR/"
chmod +x "$BIN_DIR/net-monitor.sh"
chmod +x "$BIN_DIR/net-monitor-ctrl.sh"

# 3. Copy the conky markup content
cp eth-markup.txt "$CONFIG_DIR/"

# 4. Copy service file and update the path dynamically
# This uses 'sed' to replace a placeholder with the user's actual home path
for service in net-monitor.service; do
    cp "$service" "$SYSTEMD_DIR/"
    sed -i "s|ExecStart=.*|ExecStart=$BIN_DIR/${service%.service}.sh|" "$SYSTEMD_DIR/$service"
done

# 5. add a tmp file owned by the current user
touch /tmp/eth_status.txt
chown $USER:$USER /tmp/eth_status.txt

echo "Files copied..."

# 6. Reload systemd and enable the service for boot
echo "🔄 Reloading systemd user daemon..."
systemctl --user daemon-reload
systemctl --user enable net-monitor.service

# 7. Start the service using the controller
"$BIN_DIR/net-monitor-ctrl.sh" start

echo "✅ Installation complete!"
echo "👉 Don't forget to modify your .conkyrc file."
echo "👉 Refer to the README.md file for details."
