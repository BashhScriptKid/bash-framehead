# `device::is_occupied`

Check if device is occupied via /proc (no lsof needed)

## Source

```bash
device::is_occupied() {
    find /proc/[0-9]*/fd -lname "*${1#/dev/}" 2>/dev/null | head -1 | grep -q .
}
```

## Module

[`device`](../device.md)
