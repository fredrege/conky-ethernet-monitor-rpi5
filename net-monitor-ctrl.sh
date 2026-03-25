#!/bin/bash

# Controller for the Conky Network Monitor
# Usage: $HOME/bin/net-monitor-ctrl.sh [start|stop|restart|status]

ACTION=$1
SERVICE_NAME="net-monitor.service"

case "$ACTION" in

     start)
        echo "Starting Network Monitor..."
        
        # 1. Check if Conky is running. If not, start it!
        if ! pgrep -x "conky" > /dev/null; then
            echo "Conky is not running. Launching Conky..."
            conky -d > /dev/null 2>&1 &
            # Give Conky a couple of seconds to spin up the UI
            sleep 2
        fi
        # 2. Enable it so systemd expects it to run
        systemctl --user enable "$SERVICE_NAME" 2>/dev/null
        # 3. Start the background service
        systemctl --user start "$SERVICE_NAME"
        echo "Service is running and enabled."
        ;;

    stop)

        echo "Stopping Network Monitor..."
        # 1. Stop the running process
        systemctl --user stop "$SERVICE_NAME"
        
	# 2. Disable the systemd
        systemctl --user disable "$SERVICE_NAME" 2>/dev/null
	
	# 3. Overwrite the file with the gray UNMONITORED message
	echo "\${color #888888}UNMONITORED" > /tmp/eth_status.txt
        echo "Service stopped, disabled, and status message modified."
	echo "Run 'net-monitor-ctrl.sh start' to enable device monitoring."
        ;;
    restart)
        echo "Restarting..."
        $0 stop
        sleep 1
        $0 start
        ;;
    status)
        echo "Service Status:"
        systemctl --user status "$SERVICE_NAME"
        ;;
    *)
        echo "Usage: $(basename "$0") {start|stop|restart|status}"
        exit 1
        ;;
esac
