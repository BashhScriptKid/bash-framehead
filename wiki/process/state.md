# `process::state`

Get process state (R=running, S=sleeping, Z=zombie, etc.)

## Usage

```bash
process::state pid
```

## Source

```bash
process::state() {
    local pid="$1"
    if [[ -f "/proc/$pid/status" ]]; then
        awk '/^State:/{print $2}' "/proc/$pid/status"
    else
        ps -o state= -p "$pid" 2>/dev/null
    fi
}
```

## Module

[`process`](../process.md)
