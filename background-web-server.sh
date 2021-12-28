#!/usr/bin/env bash

# Check for nc command. Get it if not found.
nc_command=$(which nc)
retVal=$?
if [ $retVal -ne 0 ]; then
    currentDir=$(pwd)
    tmpDir=$(mktemp -d)
    cd $tmpDir
    curl -s 'https://cfhcable.dl.sourceforge.net/project/nc110/community%20releases/nc110.20180111.tar.xz' | tar xJ
    cd nc110
    make generic
    nc_command=$(pwd)/nc
    cd $currentDir
fi

background-web-server() {
    local port=${1:-10000}
    while true; do
        printf 'HTTP/1.0 200 OK\nContent-Length: 2\n\nOK' | $nc_command -l -p $port > /dev/null;
    done &
}
