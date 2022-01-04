# memory-pressure-test

Use this memory to test the memory limit of different plans.

Deploy this repository as a Web Service using the following **build** and
**start** commands:

- **build**: `:` (just a
  [single colon](https://tldp.org/LDP/abs/html/special-chars.html#NULLREF))
- **start**: `./test-memory.sh`

## Troubleshooting

If the node process is crashing before using up all expected available memory,
you may need to add a `NODE_OPTIONS` environment variable with value
`--max-old-space-size=500`. Replace `500` with the amount of memory (in MB) you
expect to be available. This instructs the node process to use up to the
specified amount of memory. Otherwise node tries to guess (sometimes
inaccurately) the amount of memory available to it.

## Alternative use

You may need to monitor memory use of an existing Web Service at the process
level -- a level of granularity not available in the Render Dashboard.

To monitor memory use by process, prepend the Web Service's **start** command
with the following command. Ensure you include a space after the final ampersand
(before your process's start command). This will output memory use by process
once every second to stdout. Resident set size, private memory, and shared
memory are reported. All values are in kilobytes.

```
curl -o mem.sh -L https://git.io/Jyamu; while true; do bash mem.sh; sleep 1; done &
```

The URL https://git.io/Jyamu is a short link to the `print-process-memory.sh`
file in this repository.

## How it reports memory for each process

RSS, or Resident Set Size, includes _both_ a processes private and shared memory
use. Summing RSS across all processes provides an innaccurate measure of memory
use because multiple processes might be sharing the same memory. Unfortunately,
the `ps` command does not provide any visibility into a process's private vs.
shared memory use. More granular memory use for a process can be found at
`/proc/PID/smaps`, where `PID` is the process ID.

`print-process-memory.sh` to gets the PIDs of all currently running processes,
determines each process's private and shared memory use, and prints these out
along with some other information. The `curl` command and `while` loop above
grabs this file and runs it every one second so you can see how your service's
process(es) are using memory.
