#!/bin/bash
echo "📡 Starting Desktop Monitor..."
systemctl --user start net-monitor.service
echo "✅ Service started. Check Conky for updates."
