#!/usr/bin/env bash

# Start a simple HTTP server to run this as a web service
while true; do
    printf 'HTTP/1.1 200 OK\r\n' | nc -l ${PORT} > /dev/null;
done &

no_node=0
while [ $no_node -lt 2 ]; do
    echo "Processes currently running:"
    ps --no-headers --format "etime pid %cpu %mem rss cmd";
    sleep 1;

    # increment no_node if no node process is running
    pgrep node > /dev/null
    retVal=$?
    if [ $retVal -ne 0 ]; then
        ((no_node++))
    fi

done &

# this process will get oom killed
node leak-memory.js
echo "==> Node process exit code: $?"
