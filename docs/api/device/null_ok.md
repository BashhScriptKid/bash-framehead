# `device::null_ok`

**Signature:** `device::null_ok()`

**Module:** [`device`](../device.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Check if /dev/null is functional (sanity check)


## Source

```bash
device::null_ok() {
    echo "" > /dev/null 2>&1
}
```

