# `process::cmdline`

Get command line of a process

## Usage

```bash
process::cmdline pid
```

## Source

```bash
process::cmdline() {
    local pid="${1:-$$}"
    if [[ -f "/proc/$pid/cmdline" ]]; then
        tr '\0' ' ' < "/proc/$pid/cmdline"
    else
        ps -o args= -p "$pid" 2>/dev/null
    fi
}
```

## Module

[`process`](../process.md)
