# `process::list`

List all running processes (PID and name)

## Source

```bash
process::list() {
    ps -eo pid,comm --no-headers 2>/dev/null || \
        ps -eo pid,comm 2>/dev/null | tail -n +2
}
```

## Module

[`process`](../process.md)
