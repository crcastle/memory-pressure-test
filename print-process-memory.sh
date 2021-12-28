#!/usr/bin/env bash

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
