#!/bin/bash

# Define paths for consistency
BIN_DIR="$HOME/bin"
SYSTEMD_DIR="$HOME/.config/systemd/user"
CONFIG_DIR="$HOME/.config/conky"

echo "🗑️ Starting uninstallation..."

# 1. Stop Conky
killall conky

# 2. Stop the service using the controller
if [ -f "$BIN_DIR/net-monitor-ctrl.sh" ]; then
    echo "Stopping background services..."
    "$BIN_DIR/net-monitor-ctrl.sh" stop
fi

# 3. Disable the service so it doesn't boot up next time
echo "Disabling systemd user services..."
systemctl --user disable net-monitor.service 2>/dev/null

# 4. Remove the service unit file
echo "Removing systemd unit files..."
rm -f "$SYSTEMD_DIR/net-monitor.service"

# 5. Reload systemd to finalize removal
systemctl --user daemon-reload

# 6. Remove the scripts
echo "Removing scripts from $BIN_DIR..."
rm -f "$BIN_DIR/net-monitor.sh"
rm -f "$BIN_DIR/net-monitor-ctrl.sh"

# 7. Remove the custom Conky markup folder
echo "Removing custom Conky markup..."
rm -rf "$CONFIG_DIR"

# 8. Clean up temporary state file
rm -f /tmp/eth_status.txt

echo "✅ Uninstallation complete. Remember to restore your .conkyrc file and then restart Conky."
