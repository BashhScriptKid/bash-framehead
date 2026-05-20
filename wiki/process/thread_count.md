# `process::thread_count`

Get number of threads for a PID

## Source

```bash
process::thread_count() {
    if [[ -f "/proc/$1/status" ]]; then
        awk '/^Threads:/{print $2}' "/proc/$1/status"
    else
        ps -o nlwp= -p "$1" 2>/dev/null | tr -d ' '
    fi
}
```

## Module

[`process`](../process.md)
