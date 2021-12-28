#!/usr/bin/env bash

# Start a simple HTTP server so Render sees a process listening on a port
source "background-web-server.sh"
PORT=${PORT:-10000}
background-web-server $PORT

# Print info about all processes until the node process dies
no_node=0
while [ $no_node -lt 2 ]; do
    echo -e 'PID\tPPID\tRSS\tShared\tPrivate\tCMD'
    total=0
    total_p=0
    total_s=0
    while read -r pid ppid args; do
        if [ -f /proc/$pid/smaps ]; then
            rss=$(awk 'BEGIN {i=0} /^Rss/ {i = i + $2} END {print i}' /proc/$pid/smaps)
            pss=$(awk 'BEGIN {i=0} /^Pss/ {i = i + $2} END {print i}' /proc/$pid/smaps)
            shared=$(awk 'BEGIN {i=0} /^Shared_/ {i = i + $2} END {print i}' /proc/$pid/smaps)
            private=$(awk 'BEGIN {i=0} /^Private_/ {i = i + $2} END {print i}' /proc/$pid/smaps)
            printf '%d\t%d\t%d\t%d\t%d\t%s\n' "$pid" "$ppid" "$rss" "$shared" "$private" "$args"
        fi
    done < <(ps -o pid,ppid,args)
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
