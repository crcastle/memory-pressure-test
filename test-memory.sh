#!/usr/bin/env bash

# Start a simple HTTP server to run this repo as a private service
RESPONSE="HTTP/1.1 200 OK\r\nConnection: keep-alive\r\n\r\nOK}\r\n"
while { echo -en "$RESPONSE"; } | nc -l 10000; do
    # bash no-op
    :
done &

no_node=0
while [ $no_node -lt 2 ]; do
    echo "Processes currently running"
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
