#!/bin/sh

SETTINGS_FILE="/opt/app-root/src/.node-red/settings.js"

case "$1" in
    start)
        if [ -f "$SETTINGS_FILE" ]; then
            echo "Updating Node-RED port to 3001 in settings.js..."
            sed -i 's/1880/3001/g' "$SETTINGS_FILE"
            echo "Starting Node-RED..."
            exec node-red            
        else
            echo "Starting Node-RED..."
            exec node-red -p 3001       
        fi
        ;;
    stop)
        echo "Stopping Node-RED..."
        kill -SIGTERM 1
        ;;
    restart)
        echo "Restarting Node-RED..."
        kill -SIGTERM 1
        sleep 2
        exec node-red
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac
