#!/bin/bash

LOG_FILE="/var/log/monitor_sistema.log"

if [ ! -f "$LOG_FILE" ]; then
    echo "TIMESTAMP PID COMMAND %CPU %MEM" > "$LOG_FILE"
fi

while true; do

    TIMESTAMP=$(date "+%Y-%m-%d_%H:%M:%S")
    ps -e -o pid,comm,%cpu,%mem --sort=-%cpu | head -n 6 | tail -n +2 | while read -r line; do
        echo "$TIMESTAMP $line" >> "$LOG_FILE"
    done

    sleep 5
done
