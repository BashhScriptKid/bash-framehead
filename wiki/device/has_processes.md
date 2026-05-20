# `device::has_processes`

Check if device has open file handles via lsof

## Source

```bash
device::has_processes() {
    runtime::has_command lsof || return 1
    lsof -t "$1" >/dev/null 2>&1
}
```

## Module

[`device`](../device.md)
