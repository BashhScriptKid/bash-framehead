# `process::timeout`

Run a command with a timeout, kill it if it exceeds

## Usage

```bash
process::timeout seconds command [args...]
```

## Source

```bash
process::timeout() {
    local timeout="$1"; shift
    if runtime::has_command timeout; then
        timeout "$timeout" "$@"
    else
        # Pure bash fallback
        "$@" &
        local pid=$!
        ( sleep "$timeout"; process::kill::graceful "$pid" ) &
        local watcher=$!
        wait "$pid" 2>/dev/null
        local ret=$?
        kill "$watcher" 2>/dev/null
        return $ret
    fi
}
```

## Module

[`process`](../process.md)
