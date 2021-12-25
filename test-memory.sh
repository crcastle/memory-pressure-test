#!/usr/bin/env bash

# Check for nc command. Get it if not found.
nc_command=$(which nc)
retVal=$?
if [ $retVal -ne 0 ]; then
    curl https://cfhcable.dl.sourceforge.net/project/nc110/community%20releases/nc110.20180111.tar.xz | tar xJ
    cd nc110
    make generic
    nc_command=$(pwd)/nc
    cd ..
fi

# Start a simple HTTP server so Render sees a process listening on a port
while true; do
    printf 'HTTP/1.1 200 OK\r\n' | $nc_command -l ${PORT} > /dev/null;
done &

# Print info about all processes until the node process dies
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
