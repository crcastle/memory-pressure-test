#!/usr/bin/env bash

# Check for nc command. Get it if not found.
nc_command=$(which nc)
retVal=$?
if [ $retVal -ne 0 ]; then
    curl -s https://cfhcable.dl.sourceforge.net/project/nc110/community%20releases/nc110.20180111.tar.xz | tar xJ
    cd nc110
    make generic
    nc_command=$(pwd)/nc
    cd ..
fi

# Start a simple HTTP server so Render sees a process listening on a port
while true; do
    printf 'HTTP/1.1 200 OK\r\n' | $nc_command -l 10000 > /dev/null;
done &

# Print info about all processes until the node process dies
no_node=0
while [ $no_node -lt 2 ]; do
    echo -e 'PID\tPPID\tRSS\tShared\tPrivate\tOOM Score\tCMD'
    total=0
    total_p=0
    total_s=0
    while read -r pid ppid args; do
        if [ -f /proc/$pid/smaps ]; then
            rss=$(awk 'BEGIN {i=0} /^Rss/ {i = i + $2} END {print i}' /proc/$pid/smaps)
            pss=$(awk 'BEGIN {i=0} /^Pss/ {i = i + $2} END {print i}' /proc/$pid/smaps)
            shared=$(awk 'BEGIN {i=0} /^Shared_/ {i = i + $2} END {print i}' /proc/$pid/smaps)
            private=$(awk 'BEGIN {i=0} /^Private_/ {i = i + $2} END {print i}' /proc/$pid/smaps)
            oom_score_adj=$(cat /proc/$pid/oom_score_adj)
            printf '%d\t%d\t%d\t%d\t%d\t%d\t%s\n' "$pid" "$ppid" "$rss" "$shared" "$private" "$oom_score_adj" "$args"
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
