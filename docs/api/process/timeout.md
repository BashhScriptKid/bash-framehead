# `process::timeout`

**Signature:** `process::timeout(seconds, command, [args...])`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** exit code

## Description

Run a command with a timeout, kill it if it exceeds

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `seconds` | string | Yes | |
| `command` | command | Yes | |
| `args...` | string | No | |

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

