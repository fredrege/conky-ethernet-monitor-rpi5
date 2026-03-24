#!/bin/bash

# Define paths for consistency
BIN_DIR="$HOME/bin"
SYSTEMD_DIR="$HOME/.config/systemd/user"
CONFIG_DIR="$HOME/.config/conky"

echo "🗑️ Starting uninstallation..."

# 1. Stop the service using the controller
if [ -f "$BIN_DIR/net-monitor-ctrl.sh" ]; then
    echo "Stopping background services..."
    "$BIN_DIR/net-monitor-ctrl.sh" stop
fi

# 2. Disable the service so it doesn't boot up next time
echo "Disabling systemd user services..."
systemctl --user disable net-monitor.service 2>/dev/null

# 3. Remove the service unit file
echo "Removing systemd unit files..."
rm -f "$SYSTEMD_DIR/net-monitor.service"

# 4. Reload systemd to finalize removal
systemctl --user daemon-reload

# 5. Remove the scripts
echo "Removing scripts from $BIN_DIR..."
rm -f "$BIN_DIR/net-monitor.sh"
rm -f "$BIN_DIR/net-monitor-ctrl.sh"

# 6. Remove the custom Conky markup folder
echo "Removing custom Conky markup..."
rm -rf "$CONFIG_DIR"

# 7. Clean up temporary state file
rm -f /tmp/eth_status.txt

echo "✅ Uninstallation complete. Remember to restore your .conkyrc file!"
