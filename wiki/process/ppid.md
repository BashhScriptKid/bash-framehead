# `process::ppid`

Get parent PID of a process

## Usage

```bash
process::ppid pid
```

## Source

```bash
process::ppid() {
    local pid="${1:-$$}"
    awk '{print $4}' "/proc/$pid/stat" 2>/dev/null || \
        ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' '
}
```

## Module

[`process`](../process.md)
