# `device::is_occupied`

**Signature:** `device::is_occupied()`

**Module:** [`device`](../device.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if device is occupied via /proc (no lsof needed)


## Source

```bash
device::is_occupied() {
    find /proc/[0-9]*/fd -lname "*${1#/dev/}" 2>/dev/null | head -1 | grep -q .
}
```

