# `process::name`

Get process name from PID

## Usage

```bash
process::name pid
```

## Source

```bash
process::name() {
    local pid="${1:-$$}"
    if [[ -f "/proc/$pid/comm" ]]; then
        cat "/proc/$pid/comm"
    else
        ps -o comm= -p "$pid" 2>/dev/null
    fi
}
```

## Module

[`process`](../process.md)
