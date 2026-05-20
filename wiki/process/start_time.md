# `process::start_time`

Get process start time (unix timestamp)

## Source

```bash
process::start_time() {
    local pid="$1"
    if runtime::has_command ps; then
        ps -o lstart= -p "$pid" 2>/dev/null
    fi
}
```

## Module

[`process`](../process.md)
