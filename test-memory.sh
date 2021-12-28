#!/usr/bin/env bash

# Start a simple HTTP server so Render sees a process listening on a port
source "background-web-server.sh"
PORT=${PORT:-10000}
background-web-server $PORT

# Print info about all processes until the node process dies
no_node=0
while [ $no_node -lt 2 ]; do
    source "print-process-memory.sh"
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
