#!/bin/sh

SETTINGS_FILE="/opt/app-root/src/.node-red/settings.js"

if [ ! -f "$SETTINGS_FILE" ]; then
    echo "Starting Node-RED on port 3001..."
    exec node-red -p 3001
    sed -i 's/port: 1880/port: 3001/g' "$SETTINGS_FILE"
else
    echo "Starting Node-RED..."
    exec node-red
fi
