# `process::wait`

Wait for a process to finish

## Usage

```bash
process::wait pid [timeout_seconds]
```

## Source

```bash
process::wait() {
    local pid="$1" timeout="${2:-}"
    if [[ -z "$timeout" ]]; then
        wait "$pid" 2>/dev/null
        return $?
    fi

    local elapsed=0
    while process::is_running "$pid"; do
        sleep 1
        (( elapsed++ ))
        (( elapsed >= timeout )) && return 1
    done
    return 0
}
```

## Module

[`process`](../process.md)
