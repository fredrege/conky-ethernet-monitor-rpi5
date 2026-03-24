#!/bin/bash
echo "🛑 Stopping Desktop Monitor..."
systemctl --user stop net-monitor.service

# Clean up the UI state
rm -f /tmp/eth_status.txt

echo "✅ Conky Network Service stopped and temporary files cleared."
