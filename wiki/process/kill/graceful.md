# `process::kill::graceful`

Graceful kill — SIGTERM, wait, then SIGKILL if still running

## Usage

```bash
process::kill::graceful pid [timeout_seconds]
```

## Source

```bash
process::kill::graceful() {
    local pid="$1" timeout="${2:-5}"
    process::is_running "$pid" || return 0

    kill -TERM "$pid" 2>/dev/null

    local elapsed=0
    while (( elapsed < timeout )); do
        process::is_running "$pid" || return 0
        sleep 1
        (( elapsed++ ))
    done

    # Still running after timeout — force kill
    kill -KILL "$pid" 2>/dev/null
    sleep 1
    process::is_running "$pid" && return 1 || return 0
}
```

## Module

[`process`](../process.md)
