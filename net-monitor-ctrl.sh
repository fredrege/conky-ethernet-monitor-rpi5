#!/bin/bash

# Controller for the Conky Network Monitor
# Usage: ./monitor-ctrl.sh [start|stop|restart|status]

ACTION=$1
SERVICE_NAME="net-monitor.service"

case "$ACTION" in
    start)
        echo "📡 Starting Network Monitor..."
        systemctl --user start "$SERVICE_NAME"
        echo "✅ Service is running."
        ;;
    stop)
        echo "🛑 Stopping Network Monitor..."
        systemctl --user stop "$SERVICE_NAME"
        # Clean up the UI state file to avoid "stale" data in Conky
        rm -f /tmp/eth_status.txt
        echo "✅ Service stopped and temporary files cleared."
        ;;
    restart)
        echo "🔄 Restarting..."
        $0 stop
        sleep 1
        $0 start
        ;;
    status)
        echo "📊 Service Status:"
        systemctl --user status "$SERVICE_NAME"
        ;;
    *)
        echo "Usage: $(basename "$0") {start|stop|restart|status}"
        exit 1
        ;;
esac
