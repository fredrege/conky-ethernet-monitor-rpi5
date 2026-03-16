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

# 2. Copy the listener script and make it executable
cp net-monitor.sh "$BIN_DIR/"
chmod +x "$BIN_DIR/net-monitor.sh"

# 3. Copy the conky markup content
cp eth-markup.txt "$CONFIG_DIR/"

# 4. Copy service file and update the path dynamically
# This uses 'sed' to replace a placeholder with the user's actual home path
for service in net-monitor.service; do
    cp "$service" "$SYSTEMD_DIR/"
    sed -i "s|ExecStart=.*|ExecStart=$BIN_DIR/${service%.service}.sh|" "$SYSTEMD_DIR/$service"
done

echo "Files copied..."

# 5. Reload systemd and enable the service
echo "Reloading systemd user daemon..."
systemctl --user daemon-reload
systemctl --user enable net-monitor.service
systemctl --user start net-monitor.service

echo "Installation complete!"
echo "Don't forget to modify your .conkyrc file.\nRefer to the README.md file for details."
