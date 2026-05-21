# `device::is_mounted`

**Signature:** `device::is_mounted(arg1)`

**Module:** [`device`](../device.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if a block device is mounted

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::is_mounted() {
    grep -q "^$1 " /proc/mounts 2>/dev/null \
        || grep -q " $1 " /proc/mounts 2>/dev/null
}
```

